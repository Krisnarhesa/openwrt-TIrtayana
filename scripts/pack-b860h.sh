#!/bin/bash
# =============================================================
# TIrtayana OpenWrt - Local Packaging Script for B860H (S905X)
# Uses ophub/amlogic-s9xxx-openwrt to repack rootfs with
# a custom kernel for the STB B860H (Amlogic S905X)
# =============================================================
# Usage:
#   chmod +x scripts/pack-b860h.sh
#   sudo ./scripts/pack-b860h.sh
#   sudo ./scripts/pack-b860h.sh -k 6.6.y
#   sudo ./scripts/pack-b860h.sh -k 6.1.y -s 2048 -i 192.168.2.1
#   sudo ./scripts/pack-b860h.sh -R Krisnarhesa/kernel -k 6.6.y
# =============================================================

set -euo pipefail

# ── Terminal colors ──────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Default configuration ─────────────────────────────────────
BOARD="s905x-b860h"                    # ophub board ID for B860H (uses meson-gxl-s905x-b860h.dtb)
KERNEL_VERSION="6.1.y_6.6.y"          # Multiple kernel series
OPENWRT_IP="192.168.1.1"              # Default router IP
ROOTFS_SIZE="256/1024"                 # BOOTFS/ROOTFS in MB
BUILDER_NAME="TIrtayana"
OPHUB_REPO="https://github.com/ophub/amlogic-s9xxx-openwrt.git"
OPHUB_DIR="/tmp/ophub-packager"
ROOTFS_PATTERN="bin/targets/armsr/armv8/*rootfs.tar.gz"
OUTPUT_DIR="out/b860h"
KERNEL_REPO="Krisnarhesa/kernel"      # Default: TIrtayana custom kernel
PROFILE=""
COMPILE_FIRST="false"
DTB_FILE="meson-gxl-s905x-b860h.dtb"  # B860H device tree blob
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

# ── Helper functions ────────────────────────────────────────
info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERR]${NC}  $*"; exit 1; }
header()  { echo -e "\n${BOLD}${BLUE}════════════════════════════════════════${NC}"; \
            echo -e "${BOLD}${BLUE}  $*${NC}"; \
            echo -e "${BOLD}${BLUE}════════════════════════════════════════${NC}"; }

# ── Banner ──────────────────────────────────────────────────
print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
 ████████╗██╗██████╗ ████████╗ █████╗ ██╗   ██╗ █████╗ ███╗   ██╗ █████╗
 ╚══██╔══╝██║██╔══██╗╚══██╔══╝██╔══██╗╚██╗ ██╔╝██╔══██╗████╗  ██║██╔══██╗
    ██║   ██║██████╔╝   ██║   ███████║ ╚████╔╝ ███████║██╔██╗ ██║███████║
    ██║   ██║██╔══██╗   ██║   ██╔══██║  ╚██╔╝  ██╔══██║██║╚██╗██║██╔══██║
    ██║   ██║██║  ██║   ██║   ██║  ██║   ██║   ██║  ██║██║ ╚████║██║  ██║
    ╚═╝   ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
EOF
    echo -e "${NC}"
    echo -e "  ${BOLD}OpenWrt Packaging Script for STB B860H (Amlogic S905X)${NC}"
    echo -e "  ${YELLOW}Powered by ophub/amlogic-s9xxx-openwrt${NC}"
    echo ""
}

# ── Argument parsing ─────────────────────────────────────────
usage() {
    echo -e "Usage: ${BOLD}$0 [options]${NC}"
    echo ""
    echo "  -k  Kernel version   (default: ${KERNEL_VERSION})"
    echo "      Example: -k 6.6.y  or  -k 6.1.y_6.6.y"
    echo "  -i  IP Address       (default: ${OPENWRT_IP})"
    echo "  -s  Rootfs size      (default: ${ROOTFS_SIZE} = BOOT/ROOT in MB)"
    echo "  -b  Target board     (default: ${BOARD})"
    echo "  -n  Builder name     (default: ${BUILDER_NAME})"
    echo "  -o  Output dir       (default: ${OUTPUT_DIR})"
    echo "  -r  Custom Ophub     (default: ${OPHUB_REPO})"
    echo "  -R  Custom Kernel    (default: ${KERNEL_REPO})"
    echo "  -p  Build profile    (minimal/standard/education)"
    echo "  -c  Recompile OpenWrt from scratch before packaging"
    echo "  -h  Display this help message"
    echo ""
    echo "Examples:"
    echo "  sudo $0 -c -k 6.6.y -p standard"
    echo "  sudo $0 -k 6.1.y -i 10.0.0.1"
    echo "  sudo $0 -R Krisnarhesa/kernel -k 6.6.y"
    echo "  sudo $0 -R '' -k 6.1.y  # use default ophub kernel"
    exit 0
}

while getopts "k:i:s:b:n:o:r:R:p:hc" opt; do
    case "$opt" in
        k) KERNEL_VERSION="$OPTARG" ;;
        i) OPENWRT_IP="$OPTARG" ;;
        s) ROOTFS_SIZE="$OPTARG" ;;
        b) BOARD="$OPTARG" ;;
        n) BUILDER_NAME="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        r) OPHUB_REPO="$OPTARG" ;;
        R) KERNEL_REPO="$OPTARG" ;;
        p) PROFILE="$OPTARG" ;;
        h) usage ;;
        c) COMPILE_FIRST="true" ;;
        *) usage ;;
    esac
done

# ── Root check ────────────────────────────────────────────────
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "This script must be run as root.\n  Use: sudo $0 $*"
    fi
}

# ── Optional Recompile ────────────────────────────────────────
rebuild_openwrt() {
    if [ "${COMPILE_FIRST}" == "true" ]; then
        header "Rebuilding OpenWrt from Scratch"
        
        # OpenWrt forbids compiling as root. Since this script is run via sudo,
        # we must drop privileges back to the original user for the compilation step.
        local orig_user="${SUDO_USER:-}"
        
        if [ -z "${orig_user}" ] || [ "${orig_user}" == "root" ]; then
            warn "Running directly as root or SUDO_USER not detected."
            warn "OpenWrt compilation might fail if you are actually root."
            orig_user="${USER}"
        fi
        
        # Repair ownership: files generated by previous root processes must be owned by the user
        info "Repairing file ownerships before compiling..."
        chown -R "${orig_user}:${orig_user}" .
        
        # Cleanup broken build folders (common cause of patch failures)
        if [ -d "build_dir" ]; then
            info "Cleaning up potentially broken build directories..."
            rm -rf build_dir/toolchain-*/*/gcc-* 2>/dev/null || true
        fi
        
        info "Preparing configuration for profile: ${PROFILE:-standard}..."
        
        # Load profile-specific config if it exists
        if [ -n "${PROFILE}" ] && [ -f ".config.${PROFILE}" ]; then
            cp ".config.${PROFILE}" .config
            info "Loaded .config.${PROFILE}"
        elif [ ! -f ".config" ]; then
            warn "No .config found, using default standard config"
            [ -f ".config.standard" ] && cp ".config.standard" .config
        fi

        # Enforce architecture targets (same as GitHub Actions)
        # We use a temp file to avoid issues with sed/redirection during privilege drop
        cat > .config.extra <<EOF
CONFIG_TARGET_armsr=y
CONFIG_TARGET_armsr_armv8=y
CONFIG_TARGET_armsr_armv8_DEVICE_generic=y
CONFIG_TARGET_ROOTFS_TARGZ=y
EOF
        cat .config.extra >> .config
        rm .config.extra
        
        # Sync with GitHub Actions: Fix Kernel Config Conflicts
        info "Resolving potential kernel config conflicts..."
        local conflict_opts=("CONFIG_ARM64_VA_BITS_48" "CONFIG_IOMMU_DEFAULT_PASSTHROUGH" "CONFIG_NO_HZ_IDLE")
        for opt in "${conflict_opts[@]}"; do
            sed -i "/^${opt}=/d" .config 2>/dev/null || true
            sed -i "/^# ${opt} /d" .config 2>/dev/null || true
        done
        
        chown "${orig_user}:${orig_user}" .config

        # ── Ensure feeds are updated so packages stay in .config ──────
        info "Updating feeds to ensure plugins (like luci-app-amlogic) are found..."
        sudo -u "${orig_user}" ./scripts/feeds update ophub >/dev/null 2>&1 || true
        sudo -u "${orig_user}" ./scripts/feeds install luci-app-amlogic >/dev/null 2>&1 || true

        # ── Clean stale package install artifacts ────────────────────────
        # When recompiling after a previous build used a different kernel version,
        # the old kmod package stamps cause "kernel hash mismatch" errors.
        # Root cause: bin/targets/.../packages/ contains old kmod-*.ipk files
        # baked against the old kernel hash. The package index then lists these
        # stale packages and make package/install picks them instead of the new ones.
        info "Cleaning stale package install stamps + kmod artifacts (kernel hash reset)..."

        # 1. Remove staging rootfs and package install stamp
        rm -f  staging_dir/target-*/stamp/.package_install 2>/dev/null || true
        rm -rf staging_dir/target-*/root-* 2>/dev/null || true
        rm -f  staging_dir/target-*/pkginfo/*.control 2>/dev/null || true
        rm -f  staging_dir/target-*/stamp/.target_compile 2>/dev/null || true

        # 2. THE ACTUAL FIX: delete stale kmod .ipk files from bin/ output dir
        #    These get built against old kernel hash and persist between runs.
        find bin/ -name "kmod-*.ipk" -delete 2>/dev/null || true
        # Also delete the package Packages index so it gets regenerated cleanly
        find bin/ -name "Packages" -delete 2>/dev/null || true
        find bin/ -name "Packages.gz" -delete 2>/dev/null || true
        find bin/ -name "Packages.manifest" -delete 2>/dev/null || true
        
        # 3. Force root filesystem tarball to be recreated with fresh packages
        rm -f bin/targets/*/*/*rootfs.tar.gz 2>/dev/null || true

        success "Stale kmod packages and index cleaned — kernel will be rebuilt cleanly"
        # ────────────────────────────────────────────────────────────────

        info "Running make defconfig && make -j$(nproc)..."
        
        # Execute compilation in the current directory as the normal user
        # We use 'sudo -u' instead of 'su' for better compatibility with sudo environments
        # make olddefconfig ensures no interactive prompts for new symbols
        yes "" | sudo -u "${orig_user}" make defconfig || true
        yes "" | sudo -u "${orig_user}" make olddefconfig || true
        sudo -u "${orig_user}" make -j$(nproc) || sudo -u "${orig_user}" make -j1 V=s || error "OpenWrt compilation failed!"

        success "OpenWrt compilation finished!"
    fi
}

# ── System check & dependency verification (mirrors CI workflow) ──
check_system() {
    header "System Check & Build Requirements"

    echo -e "  ${BOLD}OS Information:${NC}"
    if command -v lsb_release &>/dev/null; then
        echo -e "  ├─ Distro  : ${CYAN}$(lsb_release -ds 2>/dev/null)${NC}"
    else
        echo -e "  ├─ Distro  : ${CYAN}$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)${NC}"
    fi
    echo -e "  ├─ CPU     : ${CYAN}$(nproc) cores${NC}"
    echo -e "  ├─ RAM     : ${CYAN}$(free -h | awk '/Mem:/{print $2}') total / $(free -h | awk '/Mem:/{print $7}') available${NC}"
    echo -e "  └─ Disk    : ${CYAN}$(df -h . | awk 'NR==2{print $4}') free${NC}"
    echo ""

    # ── Check required tools ──
    local TOOLS=(git make gcc g++ flex bison gawk wget unzip python3 rsync ccache curl tar gzip losetup pigz)
    local MISSING=()

    echo -e "  ${BOLD}Checking required tools:${NC}"
    for t in "${TOOLS[@]}"; do
        if command -v "$t" &>/dev/null; then
            echo -e "  ${GREEN}[OK]${NC}      $t  →  $(command -v $t)"
        else
            echo -e "  ${RED}[MISSING]${NC} $t"
            MISSING+=("$t")
        fi
    done

    # ── Check pahole / dwarves ──
    echo ""
    echo -e "  ${BOLD}Checking pahole (dwarves):${NC}"
    if command -v pahole &>/dev/null; then
        local PAHOLE_VER
        PAHOLE_VER=$(pahole --version 2>&1 | grep -oP '\d+\.\d+' | head -1)
        local MAJOR MINOR
        MAJOR=$(echo "$PAHOLE_VER" | cut -d. -f1)
        MINOR=$(echo "$PAHOLE_VER" | cut -d. -f2)
        if [ "${MAJOR:-0}" -lt 1 ] || { [ "${MAJOR:-0}" -eq 1 ] && [ "${MINOR:-0}" -lt 16 ]; }; then
            warn "pahole $PAHOLE_VER is older than 1.16 — may cause build errors with kernel 6.6"
        else
            echo -e "  ${GREEN}[OK]${NC}      pahole $PAHOLE_VER"
        fi
    else
        echo -e "  ${RED}[MISSING]${NC} pahole (dwarves)"
        MISSING+=("dwarves")
    fi

    # ── Check Python3 modules ──
    echo ""
    echo -e "  ${BOLD}Checking Python3 modules:${NC}"
    for mod in distutils setuptools; do
        if python3 -c "import $mod" 2>/dev/null; then
            echo -e "  ${GREEN}[OK]${NC}      python3-$mod"
        else
            echo -e "  ${YELLOW}[WARN]${NC}    python3-$mod not found (non-fatal on Ubuntu 24.04+)"
        fi
    done

    # ── Disk space warning ──
    local FREE_GB
    FREE_GB=$(df -BG . | awk 'NR==2{print $4}' | tr -d 'G')
    if [ "${FREE_GB:-0}" -lt 10 ]; then
        warn "Less than 10GB free disk space — build may fail!"
    fi

    # ── Auto-install missing ──
    echo ""
    if [ ${#MISSING[@]} -gt 0 ]; then
        info "Installing missing dependencies: ${MISSING[*]}"
        apt-get update -y -qq
        apt-get install -y -qq "${MISSING[@]}" || true
        success "Installation attempt finished"
    else
        success "All required dependencies are present"
    fi

    # ── Build environment summary ──
    echo ""
    echo -e "  ${BOLD}Build Environment Summary:${NC}"
    echo -e "  ├─ gcc    : ${CYAN}$(gcc --version 2>/dev/null | head -1 || echo 'N/A')${NC}"
    echo -e "  ├─ make   : ${CYAN}$(make --version 2>/dev/null | head -1 || echo 'N/A')${NC}"
    echo -e "  ├─ python : ${CYAN}$(python3 --version 2>/dev/null || echo 'N/A')${NC}"
    echo -e "  ├─ git    : ${CYAN}$(git --version 2>/dev/null || echo 'N/A')${NC}"
    echo -e "  └─ pahole : ${CYAN}$(pahole --version 2>&1 | head -1 || echo 'N/A')${NC}"
}

# ── Find rootfs file ──────────────────────────────────────────
find_rootfs() {
    header "Searching for rootfs.tar.gz file"

    # Search in build output directory
    ROOTFS_FILE=$(ls ${ROOTFS_PATTERN} 2>/dev/null | tail -1)


    if [ -z "${ROOTFS_FILE}" ]; then
        echo ""
        warn "Rootfs file not found at: ${ROOTFS_PATTERN}"
        echo ""
        echo -e "  ${YELLOW}Make sure to build OpenWrt first:${NC}"
        echo -e "  ${BOLD}  make -j\$(nproc) || make -j1 V=s${NC}"
        echo ""
        echo -e "  ${YELLOW}Required file:${NC}"
        echo -e "  ${BOLD}  bin/targets/armsr/armv8/*-rootfs.tar.gz${NC}"
        echo ""
        error "Build OpenWrt first, then run this script again."
    fi

    success "Found: ${ROOTFS_FILE}"
    info "Size: $(du -sh "${ROOTFS_FILE}" | cut -f1)"
}

# ── Clone or update ophub ─────────────────────────────────────
setup_ophub() {
    header "Preparing Ophub Packager"

    if [ -d "${OPHUB_DIR}" ]; then
        info "Ophub directory exists, updating..."
        git -C "${OPHUB_DIR}" pull --ff-only origin main || {
            warn "Git pull failed, removing and cloning again..."
            rm -rf "${OPHUB_DIR}"
        }
    fi

    if [ ! -d "${OPHUB_DIR}" ]; then
        info "Cloning ophub/amlogic-s9xxx-openwrt..."
        git clone --depth=1 "${OPHUB_REPO}" "${OPHUB_DIR}"
    fi

    success "Ophub packager is ready at: ${OPHUB_DIR}"
}

# ── Prepare workspace ─────────────────────────────────────────
prepare_workspace() {
    header "Preparing Workspace"

    # Create openwrt-armsr folder required by ophub
    local armsr_dir="${OPHUB_DIR}/openwrt-armsr"
    rm -rf "${armsr_dir}"
    mkdir -p "${armsr_dir}"

    # Clean stale output from previous builds
    # This prevents old kernel images (e.g. 6.6 from education) from
    # contaminating a new build (e.g. 6.1 standard) and overwriting output
    local ophub_out="${OPHUB_DIR}/openwrt/out"
    if [ -d "${ophub_out}" ]; then
        info "Cleaning previous build output..."
        rm -f "${ophub_out}"/*.img "${ophub_out}"/*.img.gz 2>/dev/null || true
        success "Previous output cleaned"
    fi

    # Copy rootfs there
    info "Copying rootfs to ophub workspace..."
    cp "${ROOTFS_FILE}" "${armsr_dir}/"
    success "Rootfs copied to: ${armsr_dir}/"

    # Create local output dir
    mkdir -p "${OUTPUT_DIR}"
}

# ── Execute packaging ─────────────────────────────────────────
run_packaging() {
    header "Packaging Firmware for B860H"

    echo ""
    echo -e "  ${BOLD}Packaging configuration:${NC}"
    echo -e "  ├─ Board        : ${CYAN}${BOARD}${NC} (Amlogic S905X = B860H)"
    echo -e "  ├─ Kernel       : ${CYAN}${KERNEL_VERSION}${NC}"
    echo -e "  ├─ Default IP   : ${CYAN}${OPENWRT_IP}${NC}"
    echo -e "  ├─ Partitions   : ${CYAN}${ROOTFS_SIZE}${NC} MB (BOOT/ROOT)"
    echo -e "  ├─ Builder      : ${CYAN}${BUILDER_NAME}${NC}"
    if [ -n "${PROFILE}" ]; then
        echo -e "  ├─ Profile      : ${CYAN}${PROFILE}${NC}"
    fi
    if [ -n "${KERNEL_REPO}" ]; then
        echo -e "  ├─ Kernel Repo  : ${CYAN}${KERNEL_REPO}${NC}"
    fi
    echo -e "  └─ rootfs       : ${CYAN}${ROOTFS_FILE}${NC}"
    echo ""

    cd "${OPHUB_DIR}"

    local final_builder="${BUILDER_NAME}"
    if [ -n "${PROFILE}" ]; then
        final_builder="${BUILDER_NAME}_${PROFILE}"
    fi

    # Build remake command with optional kernel repo
    local remake_cmd=(
        sudo -E ./remake
        -b "${BOARD}"
        -k "${KERNEL_VERSION}"
        -p "${OPENWRT_IP}"
        -s "${ROOTFS_SIZE}"
        -n "${final_builder}"
        -a true
    )

    # Pass custom kernel repo via -r flag (not env variable)
    if [ -n "${KERNEL_REPO}" ]; then
        remake_cmd+=(-r "${KERNEL_REPO}")
        info "Using custom kernel from: ${KERNEL_REPO}"
    fi

    # Run ophub remake script
    "${remake_cmd[@]}"

    cd - > /dev/null
    success "Packaging process completed!"

    # ── Post-packaging: Re-inject custom files that ophub overwrites ──
    header "Re-injecting TIrtayana Custom Files"
    local ophub_out="${OPHUB_DIR}/openwrt/out"

    # CRITICAL: Ophub compresses .img → .img.gz at the end of remake.
    # We must decompress first, patch, then recompress.
    local found_images=0
    for imgz in "${ophub_out}/"*.img.gz; do
        [ -f "$imgz" ] || continue
        info "Decompressing: $(basename $imgz)"
        gunzip -f "$imgz" || { warn "Failed to decompress $imgz"; continue; }
        found_images=$((found_images + 1))
    done

    if [ ${found_images} -eq 0 ]; then
        # Check if there are uncompressed .img files already
        for img in "${ophub_out}/"*.img; do
            [ -f "$img" ] && found_images=$((found_images + 1))
        done
    fi

    if [ ${found_images} -eq 0 ]; then
        warn "No .img or .img.gz files found in ${ophub_out}"
    fi

    for img in "${ophub_out}/"*.img; do
        [ -f "$img" ] || continue
        info "Patching image: $(basename $img)"

        # Mount both partitions
        local loop_dev boot_mnt root_mnt
        loop_dev=$(losetup --show -fP "$img") || { warn "Failed to setup loop for $img"; continue; }
        boot_mnt="/tmp/b860h-boot-$$"
        root_mnt="/tmp/b860h-root-$$"
        mkdir -p "${boot_mnt}" "${root_mnt}"

        mount "${loop_dev}p1" "${boot_mnt}" 2>/dev/null || { losetup -d "${loop_dev}"; warn "Failed to mount boot partition"; continue; }
        mount -t btrfs -o compress=zstd:6 "${loop_dev}p2" "${root_mnt}" 2>/dev/null || mount "${loop_dev}p2" "${root_mnt}" 2>/dev/null || {
            umount "${boot_mnt}" 2>/dev/null
            losetup -d "${loop_dev}"
            warn "Failed to mount root partition"
            continue
        }

        # 1. Re-inject custom banner (ophub overwrites this with its own)
        if [ -f "${PROJECT_DIR}/files/etc/banner" ]; then
            cp -f "${PROJECT_DIR}/files/etc/banner" "${root_mnt}/etc/banner"
            # Append ophub-style info lines after our custom banner
            echo " Install OpenWrt: System → Amlogic Service → Install OpenWrt" >> "${root_mnt}/etc/banner"
            echo " Update  OpenWrt: System → Amlogic Service → Online  Update" >> "${root_mnt}/etc/banner"
            echo " Board: s905x-b860h | DTB: ${DTB_FILE}" >> "${root_mnt}/etc/banner"
            echo " Builder: ${BUILDER_NAME} | Date: $(date +%Y-%m-%d)" >> "${root_mnt}/etc/banner"
            echo "───────────────────────────────────────────────────────────────────────" >> "${root_mnt}/etc/banner"
            success "Custom banner re-injected"
        fi

        # 2. Re-inject custom shadow (root password)
        if [ -f "${PROJECT_DIR}/files/etc/shadow" ]; then
            cp -f "${PROJECT_DIR}/files/etc/shadow" "${root_mnt}/etc/shadow"
            chmod 600 "${root_mnt}/etc/shadow"
            success "Custom root password re-injected"
        fi

        # 3. Re-inject system config (hostname)
        if [ -f "${PROJECT_DIR}/files/etc/config/system" ]; then
            cp -f "${PROJECT_DIR}/files/etc/config/system" "${root_mnt}/etc/config/system"
            success "Custom system config re-injected"
        fi

        # 3b. Brand firmware version as TIrtayana
        if [ -f "${root_mnt}/etc/openwrt_release" ]; then
            # Extract real version info from ophub-generated file
            local orig_ver orig_rev orig_target orig_arch
            orig_ver=$(grep "DISTRIB_RELEASE=" "${root_mnt}/etc/openwrt_release" | cut -d"'" -f2)
            orig_rev=$(grep "DISTRIB_REVISION=" "${root_mnt}/etc/openwrt_release" | cut -d"'" -f2)
            orig_target=$(grep "DISTRIB_TARGET=" "${root_mnt}/etc/openwrt_release" | cut -d"'" -f2)
            orig_arch=$(grep "DISTRIB_ARCH=" "${root_mnt}/etc/openwrt_release" | cut -d"'" -f2)
            # Build profile tag for version string (e.g. "Standard", "Education")
            local profile_tag=""
            if [ -n "${PROFILE}" ]; then
                profile_tag=" $(echo "${PROFILE}" | sed 's/.*/\u&/')"
            fi
            # Overwrite entire file with TIrtayana branding
            cat > "${root_mnt}/etc/openwrt_release" <<EOF
DISTRIB_ID='TIrtayana'
DISTRIB_RELEASE='${orig_ver:-24.10}${profile_tag}'
DISTRIB_REVISION='${orig_rev:-custom}'
DISTRIB_TARGET='${orig_target:-armsr/armv8}'
DISTRIB_ARCH='${orig_arch:-aarch64_generic}'
DISTRIB_DESCRIPTION='TIrtayana ${orig_ver:-24.10}${profile_tag} (${orig_rev:-custom})'
DISTRIB_TAINTS=''
EOF
            success "Firmware branded as TIrtayana${profile_tag} (openwrt_release overwritten)"
        fi

        # 3b2. Brand /usr/lib/os-release (procd reads THIS for ubus call system board → LuCI Firmware Version)
        if [ -f "${root_mnt}/usr/lib/os-release" ]; then
            local orig_build_id orig_build_date
            orig_build_id=$(grep "^BUILD_ID=" "${root_mnt}/usr/lib/os-release" | cut -d'"' -f2)
            orig_build_date=$(grep "^OPENWRT_BUILD_DATE=" "${root_mnt}/usr/lib/os-release" | cut -d'"' -f2)
            cat > "${root_mnt}/usr/lib/os-release" <<EOF
NAME="TIrtayana"
VERSION="${orig_ver:-24.10}${profile_tag}"
ID="tirtayana"
ID_LIKE="lede openwrt"
PRETTY_NAME="TIrtayana ${orig_ver:-24.10}${profile_tag}"
VERSION_ID="${orig_ver:-24.10}"
HOME_URL="https://github.com/Krisnarhesa/openwrt-TIrtayana"
BUG_URL="https://github.com/Krisnarhesa/openwrt-TIrtayana/issues"
SUPPORT_URL="https://github.com/Krisnarhesa/openwrt-TIrtayana"
BUILD_ID="${orig_build_id:-custom}"
OPENWRT_BOARD="${orig_target:-armsr/armv8}"
OPENWRT_ARCH="${orig_arch:-aarch64_generic}"
OPENWRT_TAINTS=""
OPENWRT_DEVICE_MANUFACTURER="Universitas Udayana"
OPENWRT_DEVICE_MANUFACTURER_URL="https://github.com/Krisnarhesa"
OPENWRT_DEVICE_PRODUCT="STB B860H"
OPENWRT_DEVICE_REVISION="S905X"
OPENWRT_RELEASE="TIrtayana ${orig_ver:-24.10}${profile_tag} (${orig_rev:-custom})"
OPENWRT_BUILD_DATE="${orig_build_date:-$(date +%s)}"
EOF
            success "Firmware branded as TIrtayana${profile_tag} (os-release overwritten → LuCI will show TIrtayana)"
        fi

        # 3c. Re-inject argon theme config
        if [ -f "${PROJECT_DIR}/files/etc/config/argon" ]; then
            cp -f "${PROJECT_DIR}/files/etc/config/argon" "${root_mnt}/etc/config/argon"
            success "Argon theme config re-injected"
        fi

        # 3d. Copy custom argon background
        if [ -d "${PROJECT_DIR}/files/www/luci-static/argon/background" ]; then
            mkdir -p "${root_mnt}/www/luci-static/argon/background/"
            cp -f "${PROJECT_DIR}/files/www/luci-static/argon/background/"* \
                  "${root_mnt}/www/luci-static/argon/background/" 2>/dev/null
            success "Custom login background re-injected"
        fi

        # 3e. Append custom gold CSS to argon's cascade.css
        if [ -f "${PROJECT_DIR}/files/www/luci-static/argon/css/custom.css" ] && \
           [ -f "${root_mnt}/www/luci-static/argon/css/cascade.css" ]; then
            cat "${PROJECT_DIR}/files/www/luci-static/argon/css/custom.css" >> \
                "${root_mnt}/www/luci-static/argon/css/cascade.css"
            success "Custom gold CSS appended to cascade.css"
        fi

        # 3f. Replace argon favicons with TIrtayana logo
        if [ -d "${PROJECT_DIR}/files/www/luci-static/argon/icon" ]; then
            cp -f "${PROJECT_DIR}/files/www/luci-static/argon/icon/"*.png \
                  "${root_mnt}/www/luci-static/argon/icon/" 2>/dev/null
            success "Favicons replaced with TIrtayana branding"
        fi

        # 3g. Copy TIrtayana sidebar logo
        if [ -f "${PROJECT_DIR}/files/www/luci-static/argon/img/logo-tirtayana.png" ]; then
            mkdir -p "${root_mnt}/www/luci-static/argon/img/"
            cp -f "${PROJECT_DIR}/files/www/luci-static/argon/img/logo-tirtayana.png" \
                  "${root_mnt}/www/luci-static/argon/img/logo-tirtayana.png"
            success "TIrtayana sidebar logo injected"
        fi

        # 3h. Patch argon-config.lua for save and upload functionality
        local argon_cbi="${root_mnt}/usr/lib/lua/luci/model/cbi/argon-config.lua"
        if [ -f "$argon_cbi" ]; then
            # Add missing nixio require for file upload
            if ! grep -q "^local nixio = require 'nixio'" "$argon_cbi"; then
                sed -i '1i\local nixio = require '\''nixio'\''' "$argon_cbi"
            fi
            # Fix form submit to enable Save Changes
            sed -i "s/^br.submit = false/br.submit = translate('Save Changes')/" "$argon_cbi"
            # Remove redundant Button option
            sed -i '/^o = s:option(Button.*save.*Save Changes/d' "$argon_cbi"
            sed -i '/^o.inputstyle.*reload/d' "$argon_cbi"
            # Fix save handler state check
            sed -i 's/state == FORM_VALID and data.blur ~= nil/state == FORM_VALID/' "$argon_cbi"
            sed -i 's/data ~= nil and data.blur ~= nil.*data.mode ~= nil/state == FORM_VALID/' "$argon_cbi"
            # Remove debug writefile
            sed -i "/writefile.*tmp.*aaa/d" "$argon_cbi"
            # Remove incorrect datatype for hex color fields
            sed -i '/^o.datatype = ufloat$/d' "$argon_cbi"
            success "argon-config.lua patched (save + upload fixes)"
        fi

        # 3i. Fix Force Light mode in header.htm
        # Bug: argon treats 'light' and 'normal' the same (mode ~= 'dark')
        # Both inject dark.css via @media, so Force Light has no effect on dark-OS users
        # Fix: change to 'mode == normal' so only 'normal' uses @media query
        local header_htm="${root_mnt}/usr/lib/lua/luci/view/themes/argon/header.htm"
        if [ -f "$header_htm" ]; then
            sed -i "s/if mode ~= 'dark'/if mode == 'normal'/" "$header_htm"
            success "header.htm patched (Force Light mode fix)"
        fi

        # 3j. Copy custom footer templates with embedded GitHub link
        local argon_views="${root_mnt}/usr/lib/lua/luci/view/themes/argon"
        local src_views="${PROJECT_DIR}/files/usr/lib/lua/luci/view/themes/argon"
        for tmpl in footer.htm footer_login.htm; do
            if [ -f "${src_views}/${tmpl}" ]; then
                cp -f "${src_views}/${tmpl}" "${argon_views}/${tmpl}"
                success "${tmpl} replaced (GitHub link embedded)"
            fi
        done

        # 4. Force LuCI to use base argon theme
        cat > "${root_mnt}/etc/config/luci" <<'LUCI_EOF'
config core 'main'
	option lang 'auto'
	option mediaurlbase '/luci-static/argon'
	option resourcebase '/luci-static/resources'
	option ubuspath '/ubus/'

config extern 'flash_keep'
	option uci '/etc/config/'
	option dropbear '/etc/dropbear/'

config internal 'sauth'
	option sessionpath '/tmp/luci-sessions'
	option sessiontime '3600'

config internal 'ccache'
	option enable '1'

config internal 'apply'
	option rollback '90'
	option holdoff '4'
	option timeout '5'
	option display '1.5'

config internal 'themes'
	option Argon '/luci-static/argon'
	option OpenWrt2020 '/luci-static/openwrt2020'
LUCI_EOF
        success "LuCI forced to base argon theme"

        # 5. Re-inject amlogic_model.conf
        if [ -f "${PROJECT_DIR}/files/etc/amlogic_model.conf" ]; then
            cp -f "${PROJECT_DIR}/files/etc/amlogic_model.conf" "${root_mnt}/etc/amlogic_model.conf"
            success "amlogic_model.conf re-injected"
        fi

        # 6. Fix extlinux.conf.bak → extlinux.conf
        if [ -f "${boot_mnt}/extlinux/extlinux.conf.bak" ] && [ ! -f "${boot_mnt}/extlinux/extlinux.conf" ]; then
            mv "${boot_mnt}/extlinux/extlinux.conf.bak" "${boot_mnt}/extlinux/extlinux.conf"
            success "Renamed extlinux.conf.bak → extlinux.conf"
        elif [ -f "${boot_mnt}/extlinux/extlinux.conf.bak" ]; then
            cp -f "${boot_mnt}/extlinux/extlinux.conf.bak" "${boot_mnt}/extlinux/extlinux.conf"
            success "Copied extlinux.conf.bak → extlinux.conf (kept backup)"
        fi

        # 7. Create u-boot.ext from u-boot-s905x-s912.bin
        if [ -f "${boot_mnt}/u-boot-s905x-s912.bin" ]; then
            cp -f "${boot_mnt}/u-boot-s905x-s912.bin" "${boot_mnt}/u-boot.ext"
            chmod +x "${boot_mnt}/u-boot.ext"
            success "Created u-boot.ext from u-boot-s905x-s912.bin"
        elif [ ! -f "${boot_mnt}/u-boot.ext" ]; then
            warn "u-boot-s905x-s912.bin NOT found, u-boot.ext not created"
        else
            success "u-boot.ext already present"
        fi

        # 8. Verify boot config has correct DTB
        if [ -f "${boot_mnt}/uEnv.txt" ]; then
            info "uEnv.txt FDT: $(grep 'FDT\|dtb' "${boot_mnt}/uEnv.txt" 2>/dev/null)"
        fi
        if [ -f "${boot_mnt}/extlinux/extlinux.conf" ]; then
            info "extlinux FDT: $(grep 'FDT\|dtb\|fdt' "${boot_mnt}/extlinux/extlinux.conf" 2>/dev/null)"
        fi

        sync
        umount "${root_mnt}" 2>/dev/null
        umount "${boot_mnt}" 2>/dev/null
        losetup -d "${loop_dev}" 2>/dev/null
        rm -rf "${boot_mnt}" "${root_mnt}"
        success "Image patched successfully: $(basename $img)"
    done

    # Re-compress patched images back to .img.gz
    header "Re-compressing Patched Images"
    for img in "${ophub_out}/"*.img; do
        [ -f "$img" ] || continue
        info "Compressing: $(basename $img)"
        pigz -f "$img" 2>/dev/null || gzip -f "$img"
        success "Compressed: $(basename $img).gz"
    done
}

# ── Copy results to output dir ────────────────────────────────
collect_output() {
    header "Collecting Firmware Results"

    local ophub_out="${OPHUB_DIR}/openwrt/out"

    if [ ! -d "${ophub_out}" ] || [ -z "$(ls -A "${ophub_out}" 2>/dev/null)" ]; then
        error "No output found in: ${ophub_out}"
    fi

    local DATE_TAG
    DATE_TAG=$(date +%Y.%m.%d)

    local PROFILE_TAG="${PROFILE:-standard}"
    # Sanitize kernel version for filename: 6.1.y → 6.1, 6.1.167 → 6.1.167
    local KERNEL_TAG
    KERNEL_TAG=$(echo "${KERNEL_VERSION}" | sed 's/\.y//' | cut -d_ -f1)

    # Copy and rename: openwrt_amlogic_* → TIrtayana-B860H-{profile}-k{kernel}-{date}.img.gz
    for f in "${ophub_out}/"*.img.gz "${ophub_out}/"*.img; do
        [ -f "$f" ] || continue
        local EXT="${f##*.}"
        # Preserve the inner extension (.img.gz vs .img)
        if [[ "$f" == *.img.gz ]]; then
            local TARGET="${OUTPUT_DIR}/TIrtayana-B860H-${PROFILE_TAG}-k${KERNEL_TAG}-${DATE_TAG}.img.gz"
        else
            local TARGET="${OUTPUT_DIR}/TIrtayana-B860H-${PROFILE_TAG}-k${KERNEL_TAG}-${DATE_TAG}.img"
        fi
        cp -v "$f" "$TARGET"
    done

    echo ""
    success "Firmware is available in: ${OUTPUT_DIR}/"
    echo ""
    echo -e "  ${BOLD}Generated files:${NC}"
    ls -lh "${OUTPUT_DIR}/" | grep -v "^total" | while read -r line; do
        echo -e "  ${GREEN}OK${NC} $line"
    done
}

# ── Installation instructions ─────────────────────────────────
print_install_guide() {
    header "Installation Guide for STB B860H"

    echo -e "  ${BOLD}1. Flash to USB/SD Card${NC}"
    echo -e "     Use ${YELLOW}Rufus${NC} or ${YELLOW}balenaEtcher${NC}:"
    echo -e "     File: ${CYAN}${OUTPUT_DIR}/*.img.gz${NC}"
    echo ""
    echo -e "  ${BOLD}2. Boot from USB/SD${NC}"
    echo -e "     Plug into STB B860H, turn on → automatic boot"
    echo ""
    echo -e "  ${BOLD}3. Access LuCI${NC}"
    echo -e "     Open browser → ${CYAN}http://${OPENWRT_IP}${NC}"
    echo -e "     User: ${YELLOW}root${NC} | Pass: ${YELLOW}TIudayana${NC}"
    echo ""
    echo -e "  ${BOLD}4. Install to eMMC (Optional)${NC}"
    echo -e "     System → ${YELLOW}TIrtayana Service${NC} → ${YELLOW}Install OpenWrt${NC}"
    echo -e "     Select board: ${CYAN}B860H${NC} → click Install"
    echo ""
    echo -e "  ${BOLD}5. Backup Android ROM (Before installing to eMMC)${NC}"
    echo -e "     System → ${YELLOW}TIrtayana Service${NC} → ${YELLOW}Backup / Restore ROM${NC}"
    echo ""
    echo -e "  ${BOLD}LuCI Theme:${NC} ${CYAN}Argon Tirtayana (Custom Gold Theme)${NC}"
    echo -e "  Theme config: System → ${YELLOW}Argon Config${NC}"
    echo ""
}

# ── Main ──────────────────────────────────────────────────────
main() {
    print_banner
    check_root "$@"
    check_system
    rebuild_openwrt
    find_rootfs
    setup_ophub
    prepare_workspace
    run_packaging
    collect_output
    print_install_guide

    echo -e "${GREEN}${BOLD}All done! The B860H Firmware is ready to use.${NC}"
    echo ""
}

main "$@"
