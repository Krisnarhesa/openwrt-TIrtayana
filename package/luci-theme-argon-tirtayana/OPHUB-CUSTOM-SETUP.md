# 🚀 Custom Ophub + Kernel Custom + Tema Tirtayana Otomatis

Panduan lengkap untuk setup repository Ophub pribadi dengan:
- ✅ Custom kernel version (bebas pilih!)
- ✅ Tema Tirtayana auto-integrated
- ✅ Auto-remake setiap push
- ✅ Multi-version support (Minimal, Standard, Edukasi)

---

## 📋 Daftar Isi

1. [Fork & Setup Ophub Repository](#1-fork--setup-ophub-repository)
2. [Customize Kernel Versions](#2-customize-kernel-versions)
3. [Integrate Tema Tirtayana](#3-integrate-tema-tirtayana)
4. [Auto-Build Workflow](#4-auto-build-workflow)
5. [Multi-Version Build](#5-multi-version-build)
6. [Advanced Configuration](#6-advanced-configuration)

---

## 1️⃣ Fork & Setup Ophub Repository

### Step 1: Fork Ophub Repository

1. **Buka:** https://github.com/ophub/amlogic-s9xxx-openwrt
2. **Klik:** Fork (pojok kanan atas)
3. **Owner:** Pilih akun Anda
4. **Repository name:** `tirtayana-openwrt` (atau nama lain)
5. **Description:** `Custom OpenWrt for Tirtayana with custom kernel`
6. ✅ **Copy the main branch only**
7. **Create fork**

### Step 2: Clone ke Local

```bash
# Clone repository Anda
git clone https://github.com/YOUR_USERNAME/tirtayana-openwrt.git
cd tirtayana-openwrt

# Add upstream (untuk update nanti)
git remote add upstream https://github.com/ophub/amlogic-s9xxx-openwrt.git
```

### Step 3: Struktur Repository

```
tirtayana-openwrt/
├── .github/
│   └── workflows/
│       ├── build-openwrt.yml           # Main build workflow
│       └── remake-openwrt.yml          # Remake workflow (akan kita custom)
├── openwrt-files/
│   └── common-files/
│       └── etc/
│           └── openwrt_release         # Set Tirtayana version
├── router-config/
│   └── openwrt-21.02/
│       └── config/                     # Config files per device
├── make-openwrt/
│   └── openwrt-files/
│       └── custom/                     # Custom files
└── README.md
```

---

## 2️⃣ Customize Kernel Versions

### Method 1: Edit Workflow File (RECOMMENDED)

**File:** `.github/workflows/remake-openwrt.yml`

```yaml
name: Remake Tirtayana OpenWrt

on:
  repository_dispatch:
  workflow_dispatch:
    inputs:
      openwrt_board:
        description: 'Select Armvirt64 board'
        required: false
        default: 'all'
        type: choice
        options:
          - all
          - s905x3_s905d_s912
          - s905x2_s905x3_s905x
          - s905x3_s905x2_s905x
          - s905x3
          - s905x2
          - s905x
          - s905d
          - s905
          - s922x
          - s922x_s905x3
          - rk3588
          - rk3568
          - rk3328
      
      openwrt_kernel:
        description: 'Select kernel version (custom)'
        required: false
        default: '5.15.y_6.1.y'
        type: choice
        options:
          - 5.4.y
          - 5.10.y
          - 5.15.y
          - 6.1.y
          - 6.6.y
          - 5.15.y_6.1.y
          - 5.15.y_6.6.y
          - 6.1.y_6.6.y
          - custom
      
      custom_kernel:
        description: 'Custom kernel versions (comma separated, e.g., 5.15.150,6.1.80)'
        required: false
        default: ''
      
      tirtayana_version:
        description: 'Tirtayana Edition'
        required: true
        default: 'standard'
        type: choice
        options:
          - minimal
          - standard
          - edukasi
      
      auto_kernel:
        description: 'Auto use latest kernel'
        required: false
        default: 'true'
        type: choice
        options:
          - true
          - false

env:
  TZ: Asia/Jakarta
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

jobs:
  build:
    runs-on: ubuntu-22.04
    if: ${{ github.event.repository.owner.id }} == ${{ github.event.sender.id }}
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Initialization environment
        env:
          DEBIAN_FRONTEND: noninteractive
        run: |
          docker rmi $(docker images -q) 2>/dev/null || true
          sudo rm -rf /usr/share/dotnet /etc/apt/sources.list.d /usr/local/lib/android 2>/dev/null || true
          sudo -E apt-get -y update
          sudo -E apt-get -y install $(curl -fsSL https://is.gd/depend_ubuntu2204_openwrt)
          sudo -E apt-get -y autoremove --purge
          sudo -E apt-get clean
          sudo timedatectl set-timezone "$TZ"
      
      - name: Download OpenWrt firmware
        id: download
        run: |
          # Download latest release dari main repo
          LATEST_TAG=$(curl -s https://api.github.com/repos/${{ github.repository }}/releases/latest | jq -r '.tag_name')
          echo "latest_tag=${LATEST_TAG}" >> $GITHUB_OUTPUT
          
          # Atau build dari scratch jika perlu
          # Sesuaikan dengan kebutuhan
      
      - name: Clone Tirtayana Theme
        run: |
          # Clone tema Tirtayana
          git clone --depth 1 https://github.com/${{ github.repository_owner }}/luci-theme-argon-tirtayana.git \
            theme-tirtayana
      
      - name: Prepare custom files
        run: |
          # Set Tirtayana version
          VERSION_TYPE="${{ github.event.inputs.tirtayana_version }}"
          VERSION_NAME=$(echo $VERSION_TYPE | sed 's/^./\u&/')
          
          mkdir -p openwrt-files/common-files/etc
          cat > openwrt-files/common-files/etc/openwrt_release << EOF
          DISTRIB_ID='OpenWrt'
          DISTRIB_RELEASE='23.05-SNAPSHOT'
          DISTRIB_REVISION='Tirtayana'
          DISTRIB_DESCRIPTION='Tirtayana OpenWrt - ${VERSION_NAME} Edition'
          DISTRIB_TARGET='armvirt/64'
          DISTRIB_ARCH='aarch64_generic'
          EOF
          
          # Copy tema Tirtayana ke custom files
          mkdir -p openwrt-files/common-files/www/luci-static
          cp -r theme-tirtayana/htdocs/luci-static/argon-tirtayana \
            openwrt-files/common-files/www/luci-static/
          
          # Copy ucode templates
          mkdir -p openwrt-files/common-files/usr/share/ucode/luci/template/themes
          cp -r theme-tirtayana/ucode/template/themes/argon-tirtayana \
            openwrt-files/common-files/usr/share/ucode/luci/template/themes/
      
      - name: Determine kernel version
        id: kernel
        run: |
          if [ "${{ github.event.inputs.openwrt_kernel }}" == "custom" ] && [ -n "${{ github.event.inputs.custom_kernel }}" ]; then
            # Use custom kernel versions
            KERNEL_VERSION="${{ github.event.inputs.custom_kernel }}"
          else
            # Use preset kernel versions
            KERNEL_VERSION="${{ github.event.inputs.openwrt_kernel }}"
          fi
          
          echo "kernel_version=${KERNEL_VERSION}" >> $GITHUB_OUTPUT
          echo "🔧 Kernel version: ${KERNEL_VERSION}"
      
      - name: Remake OpenWrt firmware
        uses: ophub/amlogic-s9xxx-openwrt@main
        with:
          openwrt_path: openwrt/bin/targets/*/*/*rootfs.tar.gz
          openwrt_board: ${{ github.event.inputs.openwrt_board }}
          openwrt_kernel: ${{ steps.kernel.outputs.kernel_version }}
          auto_kernel: ${{ github.event.inputs.auto_kernel }}
          kernel_repo: ophub/kernel
          openwrt_size: 1024
          gh_token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Set LuCI theme to Tirtayana
        run: |
          # Extract firmware
          cd ${{ env.PACKAGED_OUTPUTPATH }}
          
          for file in *.img.gz; do
            if [ -f "$file" ]; then
              echo "Processing: $file"
              gunzip "$file"
              img_file="${file%.gz}"
              
              # Mount image
              sudo losetup -fP "${img_file}"
              LOOP_DEV=$(sudo losetup -j "${img_file}" | cut -d: -f1)
              sudo mkdir -p /mnt/openwrt
              sudo mount "${LOOP_DEV}p2" /mnt/openwrt
              
              # Set tema Tirtayana sebagai default
              if [ -f /mnt/openwrt/etc/config/luci ]; then
                sudo sed -i "s|option mediaurlbase.*|option mediaurlbase '/luci-static/argon-tirtayana'|g" \
                  /mnt/openwrt/etc/config/luci
              fi
              
              # Unmount
              sudo umount /mnt/openwrt
              sudo losetup -d "$LOOP_DEV"
              
              # Compress back
              gzip "${img_file}"
            fi
          done
      
      - name: Upload firmware to Release
        uses: ncipollo/release-action@main
        with:
          tag: Tirtayana_${{ github.event.inputs.tirtayana_version }}_kernel_${{ steps.kernel.outputs.kernel_version }}_${{ env.PACKAGED_OUTPUTDATE }}
          artifacts: ${{ env.PACKAGED_OUTPUTPATH }}/*
          allowUpdates: true
          token: ${{ secrets.GITHUB_TOKEN }}
          body: |
            ## Tirtayana OpenWrt Firmware
            
            **Version:** ${{ github.event.inputs.tirtayana_version }}
            **Kernel:** ${{ steps.kernel.outputs.kernel_version }}
            **Board:** ${{ github.event.inputs.openwrt_board }}
            **Build Date:** ${{ env.PACKAGED_OUTPUTDATE }}
            
            ### Features
            - 🎨 Custom Argon Theme (Tirtayana Edition)
            - 🔧 Kernel: ${{ steps.kernel.outputs.kernel_version }}
            - 📦 Version: ${{ github.event.inputs.tirtayana_version }}
            - 🌐 Auto-configured LuCI
            
            ### Installation
            1. Download firmware sesuai device Anda
            2. Flash ke SD card atau USB
            3. Boot dari media
            4. Akses LuCI: http://192.168.1.1
            5. Default login: root / password (set on first login)
            
            ### Theme Features
            - 3 Version display (Minimal/Standard/Edukasi)
            - Default password warning
            - Responsive design
            - Modern UI
      
      - name: Delete older releases
        uses: dev-drprasad/delete-older-releases@v0.3.2
        with:
          keep_latest: 10
          delete_tags: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Telegram notification
        if: env.TELEGRAM_BOT_TOKEN && always()
        run: |
          if [ "${{ steps.remake.outcome }}" == "success" ]; then
            MSG="✅ Tirtayana OpenWrt Build Success!
            
            Version: ${{ github.event.inputs.tirtayana_version }}
            Kernel: ${{ steps.kernel.outputs.kernel_version }}
            Board: ${{ github.event.inputs.openwrt_board }}
            
            Download: ${{ github.server_url }}/${{ github.repository }}/releases"
          else
            MSG="❌ Tirtayana OpenWrt Build Failed!
            
            Check: ${{ github.server_url }}/${{ github.repository }}/actions"
          fi
          
          curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d chat_id="${TELEGRAM_CHAT_ID}" \
            -d text="${MSG}"
        env:
          TELEGRAM_BOT_TOKEN: ${{ secrets.TELEGRAM_BOT_TOKEN }}
          TELEGRAM_CHAT_ID: ${{ secrets.TELEGRAM_CHAT_ID }}
```

### Method 2: Custom Kernel Build Script

**File:** `scripts/custom-kernel.sh`

```bash
#!/bin/bash
#
# Custom Kernel Selection for Tirtayana OpenWrt
#

set -e

# Kernel version options
KERNEL_5_4="5.4.270"
KERNEL_5_10="5.10.210"
KERNEL_5_15="5.15.150"
KERNEL_6_1="6.1.80"
KERNEL_6_6="6.6.20"

# Function to download specific kernel
download_kernel() {
    local version=$1
    local arch="aarch64"
    
    echo "📥 Downloading kernel ${version}..."
    
    # Download from ophub kernel repo
    wget -q "https://github.com/ophub/kernel/releases/download/kernel_stable/boot-${version}.tar.gz"
    wget -q "https://github.com/ophub/kernel/releases/download/kernel_stable/dtb-${arch}-${version}.tar.gz"
    wget -q "https://github.com/ophub/kernel/releases/download/kernel_stable/modules-${version}.tar.gz"
    
    echo "✅ Kernel ${version} downloaded"
}

# Function to list available kernels
list_kernels() {
    echo "Available kernel versions:"
    echo "1. 5.4.y  - LTS (Long Term Support)"
    echo "2. 5.10.y - LTS"
    echo "3. 5.15.y - LTS (Recommended)"
    echo "4. 6.1.y  - LTS"
    echo "5. 6.6.y  - Latest stable"
    echo "6. Custom version"
}

# Function to select kernel
select_kernel() {
    list_kernels
    read -p "Select kernel (1-6): " choice
    
    case $choice in
        1) echo "${KERNEL_5_4}" ;;
        2) echo "${KERNEL_5_10}" ;;
        3) echo "${KERNEL_5_15}" ;;
        4) echo "${KERNEL_6_1}" ;;
        5) echo "${KERNEL_6_6}" ;;
        6)
            read -p "Enter custom kernel version (e.g., 5.15.150): " custom
            echo "${custom}"
            ;;
        *) echo "${KERNEL_5_15}" ;;
    esac
}

# Main
main() {
    if [ -z "$1" ]; then
        SELECTED_KERNEL=$(select_kernel)
    else
        SELECTED_KERNEL="$1"
    fi
    
    echo "🔧 Selected kernel: ${SELECTED_KERNEL}"
    download_kernel "${SELECTED_KERNEL}"
}

main "$@"
```

### Method 3: Kernel Config File

**File:** `kernel-config.json`

```json
{
  "kernel_versions": {
    "stable": {
      "5.4": "5.4.270",
      "5.10": "5.10.210",
      "5.15": "5.15.150",
      "6.1": "6.1.80",
      "6.6": "6.6.20"
    },
    "latest": {
      "5.15": "auto",
      "6.1": "auto",
      "6.6": "auto"
    }
  },
  "recommended": {
    "s905x3": ["5.15", "6.1"],
    "s922x": ["5.15", "6.1"],
    "rk3588": ["6.1", "6.6"],
    "rk3568": ["5.15", "6.1"],
    "default": ["5.15", "6.1"]
  },
  "custom": {
    "enabled": true,
    "allow_testing": false
  }
}
```

---

## 3️⃣ Integrate Tema Tirtayana

### Method 1: Git Submodule (RECOMMENDED)

```bash
cd tirtayana-openwrt

# Add tema sebagai submodule
git submodule add https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git \
  theme/luci-theme-argon-tirtayana

# Initialize
git submodule update --init --recursive

# Commit
git add .gitmodules theme/
git commit -m "feat: Add Tirtayana theme as submodule"
git push
```

**Update submodule (saat tema update):**
```bash
git submodule update --remote
git commit -am "chore: Update Tirtayana theme"
git push
```

### Method 2: Auto-Download in Workflow

Sudah included di workflow di atas:
```yaml
- name: Clone Tirtayana Theme
  run: |
    git clone --depth 1 https://github.com/${{ github.repository_owner }}/luci-theme-argon-tirtayana.git \
      theme-tirtayana
```

### Method 3: Files Integration Script

**File:** `scripts/integrate-theme.sh`

```bash
#!/bin/bash
#
# Integrate Tirtayana Theme into Firmware
#

set -e

THEME_REPO="https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git"
THEME_DIR="theme-tirtayana"
OUTPUT_DIR="openwrt-files/common-files"

echo "🎨 Integrating Tirtayana Theme..."

# Clone theme if not exists
if [ ! -d "$THEME_DIR" ]; then
    git clone --depth 1 "$THEME_REPO" "$THEME_DIR"
else
    cd "$THEME_DIR"
    git pull
    cd ..
fi

# Create directories
mkdir -p "${OUTPUT_DIR}/www/luci-static"
mkdir -p "${OUTPUT_DIR}/usr/share/ucode/luci/template/themes"
mkdir -p "${OUTPUT_DIR}/etc/config"

# Copy theme assets
cp -r "${THEME_DIR}/htdocs/luci-static/argon-tirtayana" \
    "${OUTPUT_DIR}/www/luci-static/"

# Copy templates
cp -r "${THEME_DIR}/ucode/template/themes/argon-tirtayana" \
    "${OUTPUT_DIR}/usr/share/ucode/luci/template/themes/"

# Set as default theme
cat > "${OUTPUT_DIR}/etc/config/luci" << 'EOF'
config core 'main'
    option lang 'auto'
    option mediaurlbase '/luci-static/argon-tirtayana'
    option resourcebase '/luci-static/resources'

config internal 'themes'
    option ArgonTirtayana '/luci-static/argon-tirtayana'
EOF

echo "✅ Tirtayana theme integrated successfully!"
```

Make executable:
```bash
chmod +x scripts/integrate-theme.sh
```

---

## 4️⃣ Auto-Build Workflow

### Simplified Workflow for Quick Builds

**File:** `.github/workflows/quick-build.yml`

```yaml
name: Quick Build - Tirtayana OpenWrt

on:
  workflow_dispatch:
    inputs:
      kernel:
        description: 'Kernel Version'
        required: true
        default: '6.1.80'
      version:
        description: 'Tirtayana Version'
        required: true
        default: 'standard'
        type: choice
        options:
          - minimal
          - standard
          - edukasi
      board:
        description: 'Device Board'
        required: true
        default: 's905x3'

jobs:
  build:
    runs-on: ubuntu-22.04
    
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true
      
      - name: Setup environment
        run: |
          sudo apt-get update
          sudo apt-get install -y wget gzip
      
      - name: Integrate Tirtayana Theme
        run: |
          bash scripts/integrate-theme.sh
      
      - name: Set Tirtayana Version
        run: |
          VERSION=$(echo "${{ github.event.inputs.version }}" | sed 's/^./\u&/')
          echo "DISTRIB_DESCRIPTION='Tirtayana OpenWrt - ${VERSION} Edition'" \
            > openwrt-files/common-files/etc/openwrt_release
      
      - name: Remake with Ophub Action
        uses: ophub/amlogic-s9xxx-openwrt@main
        with:
          openwrt_path: firmware/*
          openwrt_board: ${{ github.event.inputs.board }}
          openwrt_kernel: ${{ github.event.inputs.kernel }}
          gh_token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Upload Release
        uses: ncipollo/release-action@main
        with:
          tag: tirtayana-${{ github.event.inputs.version }}-${{ github.event.inputs.kernel }}
          artifacts: ${{ env.PACKAGED_OUTPUTPATH }}/*
          token: ${{ secrets.GITHUB_TOKEN }}
```

---

## 5️⃣ Multi-Version Build

### Build All 3 Versions Simultaneously

**File:** `.github/workflows/build-all-versions.yml`

```yaml
name: Build All Tirtayana Versions

on:
  workflow_dispatch:
    inputs:
      kernel:
        description: 'Kernel Version'
        required: true
        default: '5.15.150,6.1.80'
      board:
        description: 'Board'
        required: true
        default: 's905x3'

jobs:
  build-matrix:
    runs-on: ubuntu-22.04
    strategy:
      matrix:
        version: [minimal, standard, edukasi]
    
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true
      
      - name: Build ${{ matrix.version }}
        run: |
          # Set version
          VERSION=$(echo "${{ matrix.version }}" | sed 's/^./\u&/')
          
          # Integrate theme
          bash scripts/integrate-theme.sh
          
          # Set release description
          echo "DISTRIB_DESCRIPTION='Tirtayana OpenWrt - ${VERSION} Edition'" \
            > openwrt-files/common-files/etc/openwrt_release
      
      - name: Remake Firmware
        uses: ophub/amlogic-s9xxx-openwrt@main
        with:
          openwrt_board: ${{ github.event.inputs.board }}
          openwrt_kernel: ${{ github.event.inputs.kernel }}
          gh_token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Upload ${{ matrix.version }}
        uses: actions/upload-artifact@v4
        with:
          name: tirtayana-${{ matrix.version }}-${{ github.event.inputs.board }}
          path: ${{ env.PACKAGED_OUTPUTPATH }}/*
  
  release:
    needs: build-matrix
    runs-on: ubuntu-22.04
    
    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@v4
      
      - name: Create Release
        uses: ncipollo/release-action@main
        with:
          tag: tirtayana-multi-${{ github.run_number }}
          artifacts: "**/*.img.gz"
          body: |
            ## Tirtayana OpenWrt - All Versions
            
            This release includes:
            - 📦 Minimal Edition
            - ⭐ Standard Edition
            - 🎓 Edukasi Edition
            
            Kernel: ${{ github.event.inputs.kernel }}
            Board: ${{ github.event.inputs.board }}
          token: ${{ secrets.GITHUB_TOKEN }}
```

---

## 6️⃣ Advanced Configuration

### Custom Packages Per Version

**File:** `configs/minimal-packages.txt`

```
# Minimal Version - Essential packages only
luci
luci-ssl
luci-theme-argon-tirtayana
kmod-usb2
kmod-usb3
kmod-usb-storage
kmod-fs-ext4
kmod-fs-vfat
```

**File:** `configs/standard-packages.txt`

```
# Standard Version - Recommended packages
luci
luci-ssl
luci-theme-argon-tirtayana
luci-app-opkg
luci-app-firewall
luci-app-ttyd
luci-app-diskman
kmod-usb2
kmod-usb3
kmod-usb-storage
kmod-fs-ext4
kmod-fs-vfat
kmod-fs-ntfs3
docker
dockerd
docker-compose
```

**File:** `configs/edukasi-packages.txt`

```
# Edukasi Version - Educational tools
luci
luci-ssl
luci-theme-argon-tirtayana
luci-app-opkg
luci-app-firewall
luci-app-ttyd
luci-app-diskman
luci-app-vlmcsd
luci-app-sqm
python3
python3-pip
git
vim
htop
iperf3
tcpdump
```

### Package Installation Script

**File:** `scripts/install-packages.sh`

```bash
#!/bin/bash
#
# Install packages based on Tirtayana version
#

VERSION=$1
PACKAGE_FILE="configs/${VERSION}-packages.txt"

if [ ! -f "$PACKAGE_FILE" ]; then
    echo "❌ Package file not found: $PACKAGE_FILE"
    exit 1
fi

echo "📦 Installing packages for ${VERSION} version..."

while read -r package; do
    # Skip comments and empty lines
    [[ "$package" =~ ^#.*$ ]] && continue
    [[ -z "$package" ]] && continue
    
    echo "Installing: $package"
    opkg install "$package" 2>/dev/null || echo "⚠️ Failed: $package"
done < "$PACKAGE_FILE"

echo "✅ Package installation complete!"
```

### Kernel Testing Workflow

**File:** `.github/workflows/test-kernel.yml`

```yaml
name: Test Kernel Versions

on:
  workflow_dispatch:
    inputs:
      kernels:
        description: 'Kernel versions to test (comma separated)'
        required: true
        default: '5.15.150,6.1.80,6.6.20'

jobs:
  test:
    runs-on: ubuntu-22.04
    strategy:
      matrix:
        kernel: ${{ fromJSON(format('["{0}"]', github.event.inputs.kernels)) }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Test kernel ${{ matrix.kernel }}
        run: |
          echo "🧪 Testing kernel ${{ matrix.kernel }}"
          
          # Download kernel
          bash scripts/custom-kernel.sh ${{ matrix.kernel }}
          
          # Basic validation
          if [ -f "boot-${{ matrix.kernel }}.tar.gz" ]; then
            echo "✅ Kernel ${{ matrix.kernel }} valid"
          else
            echo "❌ Kernel ${{ matrix.kernel }} failed"
            exit 1
          fi
      
      - name: Report
        run: |
          echo "### Test Result for ${{ matrix.kernel }}" >> $GITHUB_STEP_SUMMARY
          echo "Status: ✅ Passed" >> $GITHUB_STEP_SUMMARY
```

---

## 📊 Complete Integration Example

### Full Setup Commands

```bash
# 1. Clone your forked Ophub repo
git clone https://github.com/YOUR_USERNAME/tirtayana-openwrt.git
cd tirtayana-openwrt

# 2. Add tema Tirtayana sebagai submodule
git submodule add https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git \
  theme/luci-theme-argon-tirtayana

# 3. Create directories
mkdir -p scripts configs openwrt-files/common-files

# 4. Download scripts
wget https://raw.githubusercontent.com/YOUR_USERNAME/luci-theme-argon-tirtayana/main/scripts/integrate-theme.sh \
  -O scripts/integrate-theme.sh
chmod +x scripts/*.sh

# 5. Copy workflow files
# (Copy dari examples di atas)

# 6. Commit everything
git add .
git commit -m "feat: Setup Tirtayana OpenWrt with custom kernel support"
git push

# 7. Trigger build via GitHub Actions
# Go to: Actions → Remake Tirtayana OpenWrt → Run workflow
```

---

## 🎯 Usage Guide

### Build dengan Custom Kernel

1. **Buka GitHub repository Anda**
2. **Go to:** Actions → Remake Tirtayana OpenWrt
3. **Click:** Run workflow
4. **Pilih:**
   - Board: `s905x3` (atau device Anda)
   - Kernel: `custom`
   - Custom kernel: `5.15.150,6.1.80`
   - Tirtayana version: `standard`
5. **Run workflow**

### Build Multi-Version

1. **Go to:** Actions → Build All Tirtayana Versions
2. **Click:** Run workflow
3. **Set:** 
   - Kernel: `6.1.80`
   - Board: `s905x3`
4. **Run workflow**
5. **Result:** 3 firmware files (Minimal, Standard, Edukasi)

---

## 🔧 Troubleshooting

### Kernel Not Found