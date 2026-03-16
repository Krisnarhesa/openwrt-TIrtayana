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
# =============================================================

set -euo pipefail

# ── Warna terminal ──────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Konfigurasi default ─────────────────────────────────────
BOARD="s905x"                          # Chip B860H = Amlogic S905X
KERNEL_VERSION="6.1.y_6.6.y"          # Dua seri kernel sekaligus
OPENWRT_IP="192.168.1.1"              # IP default router
ROOTFS_SIZE="256/1024"                 # BOOTFS/ROOTFS dalam MB
BUILDER_NAME="TIrtayana"
OPHUB_REPO="https://github.com/ophub/amlogic-s9xxx-openwrt.git"
OPHUB_DIR="/tmp/ophub-packager"
ROOTFS_PATTERN="bin/targets/armsr/armv8/*rootfs.tar.gz"
OUTPUT_DIR="out/b860h"
KERNEL_REPO=""
PROFILE=""

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
    echo -e "  ${BOLD}OpenWrt Packaging Script untuk STB B860H (Amlogic S905X)${NC}"
    echo -e "  ${YELLOW}Powered by ophub/amlogic-s9xxx-openwrt${NC}"
    echo ""
}

# ── Parsing argumen ─────────────────────────────────────────
usage() {
    echo -e "Usage: ${BOLD}$0 [opsi]${NC}"
    echo ""
    echo "  -k  Versi kernel   (default: ${KERNEL_VERSION})"
    echo "      Contoh: -k 6.6.y  atau  -k 6.1.y_6.6.y"
    echo "  -i  IP Address     (default: ${OPENWRT_IP})"
    echo "  -s  Ukuran rootfs  (default: ${ROOTFS_SIZE} = BOOT/ROOT dalam MB)"
    echo "  -b  Board target   (default: ${BOARD})"
    echo "  -n  Nama builder   (default: ${BUILDER_NAME})"
    echo "  -o  Output dir     (default: ${OUTPUT_DIR})"
    echo "  -r  Custom Ophub   (default: ${OPHUB_REPO})"
    echo "  -R  Custom Kernel  (default: opsional)"
    echo "  -p  Profile build  (default: opsional)"
    echo "  -c  Kompilasi Ulang OpenWrt dari awal sebelum packaging"
    echo "  -h  Tampilkan bantuan ini"
    echo ""
    echo "Contoh:"
    echo "  sudo $0 -c -k 6.6.y"
    echo "  sudo $0 -k 6.1.y -i 10.0.0.1"
    exit 0
}

while getopts "k:i:s:b:n:o:r:R:p:h" opt; do
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

# ── Cek root ─────────────────────────────────────────────────
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Script ini harus dijalankan sebagai root.\n  Gunakan: sudo $0 $*"
    fi
}

# ── Compile Ulang (Opsional) ──────────────────────────────────
rebuild_openwrt() {
    if [ "${COMPILE_FIRST}" == "true" ]; then
        header "Membangun Ulang OpenWrt dari Awal"
        info "Menjalankan make clean && make -j\$(nproc)..."
        
        # Eksekusi kompilasi dengan memanggil Makefile OpenWrt di Current Dir
        make defconfig || true
        make -j$(nproc) || make -j1 V=s || error "Kompilasi OpenWrt Gagal!"
        
        success "Kompilasi OpenWrt Selesai!"
    fi
}

# ── Cek dependency ────────────────────────────────────────────
check_deps() {
    header "Memeriksa Dependencies"
    local deps=(git curl wget tar gzip)
    local missing=()

    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            success "$dep tersedia"
        else
            missing+=("$dep")
            warn "$dep tidak ditemukan"
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        info "Menginstall dependency yang kurang: ${missing[*]}"
        apt-get update -y -qq
        apt-get install -y -qq "${missing[@]}"
        success "Dependencies berhasil diinstall"
    fi
}

# ── Cari rootfs file ──────────────────────────────────────────
find_rootfs() {
    header "Mencari File rootfs.tar.gz"

    # Cari di direktori build output
    ROOTFS_FILE=$(ls ${ROOTFS_PATTERN} 2>/dev/null | tail -1)


    if [ -z "${ROOTFS_FILE}" ]; then
        echo ""
        warn "File rootfs tidak ditemukan di: ${ROOTFS_PATTERN}"
        echo ""
        echo -e "  ${YELLOW}Pastikan kamu sudah build OpenWrt terlebih dahulu:${NC}"
        echo -e "  ${BOLD}  make -j\$(nproc) || make -j1 V=s${NC}"
        echo ""
        echo -e "  ${YELLOW}File yang dibutuhkan:${NC}"
        echo -e "  ${BOLD}  bin/targets/armsr/armv8/*-rootfs.tar.gz${NC}"
        echo ""
        error "Build OpenWrt terlebih dahulu, lalu jalankan script ini kembali."
    fi

    success "Ditemukan: ${ROOTFS_FILE}"
    info "Ukuran: $(du -sh "${ROOTFS_FILE}" | cut -f1)"
}

# ── Clone atau update ophub ───────────────────────────────────
setup_ophub() {
    header "Menyiapkan ophub Packager"

    if [ -d "${OPHUB_DIR}" ]; then
        info "Direktori ophub sudah ada, melakukan update..."
        git -C "${OPHUB_DIR}" pull --ff-only origin main || {
            warn "Git pull gagal, menghapus dan clone ulang..."
            rm -rf "${OPHUB_DIR}"
        }
    fi

    if [ ! -d "${OPHUB_DIR}" ]; then
        info "Cloning ophub/amlogic-s9xxx-openwrt..."
        git clone --depth=1 "${OPHUB_REPO}" "${OPHUB_DIR}"
    fi

    success "ophub packager siap di: ${OPHUB_DIR}"
}

# ── Siapkan direktori kerja ───────────────────────────────────
prepare_workspace() {
    header "Menyiapkan Workspace"

    # Buat folder openwrt-armsr yang dibutuhkan ophub
    local armsr_dir="${OPHUB_DIR}/openwrt-armsr"
    rm -rf "${armsr_dir}"
    mkdir -p "${armsr_dir}"

    # Salin rootfs ke sana
    info "Menyalin rootfs ke workspace ophub..."
    cp "${ROOTFS_FILE}" "${armsr_dir}/"
    success "rootfs disalin ke: ${armsr_dir}/"

    # Buat output dir lokal
    mkdir -p "${OUTPUT_DIR}"
}

# ── Jalankan proses packaging ─────────────────────────────────
run_packaging() {
    header "Packaging Firmware untuk B860H"

    echo ""
    echo -e "  ${BOLD}Konfigurasi packaging:${NC}"
    echo -e "  ├─ Board        : ${CYAN}${BOARD}${NC} (Amlogic S905X = B860H)"
    echo -e "  ├─ Kernel       : ${CYAN}${KERNEL_VERSION}${NC}"
    echo -e "  ├─ IP Default   : ${CYAN}${OPENWRT_IP}${NC}"
    echo -e "  ├─ Partisi      : ${CYAN}${ROOTFS_SIZE}${NC} MB (BOOT/ROOT)"
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

    if [ -n "${KERNEL_REPO}" ]; then
        export CUSTOM_KERNEL_REPO="${KERNEL_REPO}"
    fi

    # Jalankan script remake ophub
    sudo -E ./remake \
        -b "${BOARD}" \
        -k "${KERNEL_VERSION}" \
        -p "${OPENWRT_IP}" \
        -s "${ROOTFS_SIZE}" \
        -n "${final_builder}" \
        -a true

    cd - > /dev/null
    success "Packaging selesai!"
}

# ── Salin hasil ke output dir ─────────────────────────────────
collect_output() {
    header "Mengumpulkan Hasil Firmware"

    local ophub_out="${OPHUB_DIR}/openwrt/out"

    if [ ! -d "${ophub_out}" ] || [ -z "$(ls -A "${ophub_out}" 2>/dev/null)" ]; then
        error "Tidak ada output di: ${ophub_out}"
    fi

    cp -v "${ophub_out}"/*.img.gz "${OUTPUT_DIR}/" 2>/dev/null || true
    cp -v "${ophub_out}"/*.img    "${OUTPUT_DIR}/" 2>/dev/null || true

    echo ""
    success "Firmware tersedia di: ${OUTPUT_DIR}/"
    echo ""
    echo -e "  ${BOLD}File hasil:${NC}"
    ls -lh "${OUTPUT_DIR}/" | grep -v "^total" | while read -r line; do
        echo -e "  ${GREEN}✔${NC} $line"
    done
}

# ── Instruksi install ─────────────────────────────────────────
print_install_guide() {
    header "Cara Install ke STB B860H"

    echo -e "  ${BOLD}1. Flash ke USB/SD Card${NC}"
    echo -e "     Gunakan ${YELLOW}Rufus${NC} atau ${YELLOW}balenaEtcher${NC}:"
    echo -e "     File: ${CYAN}${OUTPUT_DIR}/*.img.gz${NC}"
    echo ""
    echo -e "  ${BOLD}2. Boot dari USB/SD${NC}"
    echo -e "     Colok ke STB B860H, nyalakan → boot otomatis"
    echo ""
    echo -e "  ${BOLD}3. Akses LuCI${NC}"
    echo -e "     Buka browser → ${CYAN}http://${OPENWRT_IP}${NC}"
    echo -e "     User: ${YELLOW}root${NC} | Pass: ${YELLOW}TIudayana${NC}"
    echo ""
    echo -e "  ${BOLD}4. Install ke eMMC (opsional)${NC}"
    echo -e "     System → ${YELLOW}Amlogic Service${NC} → ${YELLOW}Install OpenWrt${NC}"
    echo -e "     Pilih board: ${CYAN}B860H${NC} → klik Install"
    echo ""
    echo -e "  ${BOLD}5. Backup ROM Android (sebelum install ke eMMC)${NC}"
    echo -e "     Buka terminal: ${YELLOW}openwrt-ddbr${NC} → ketik ${YELLOW}b${NC} untuk backup"
    echo ""
    echo -e "  ${BOLD}Tema LuCI:${NC} ${CYAN}Argon (Modern Dark Theme)${NC}"
    echo -e "  Konfigurasi tema: System → ${YELLOW}Argon Config${NC}"
    echo ""
}

# ── Main ──────────────────────────────────────────────────────
main() {
    print_banner
    check_root "$@"
    check_deps
    rebuild_openwrt
    find_rootfs
    setup_ophub
    prepare_workspace
    run_packaging
    collect_output
    print_install_guide

    echo -e "${GREEN}${BOLD}✅  Semua selesai! Firmware B860H siap digunakan.${NC}"
    echo ""
}

main "$@"
