# Integration Guide - Tirtayana Theme

Panduan lengkap untuk integrasi tema Tirtayana dengan berbagai build system dan CI/CD.

## 📋 Daftar Isi

1. [Integrasi dengan Ophub](#integrasi-dengan-ophub)
2. [Push ke GitHub Repository](#push-ke-github-repository)
3. [GitHub Actions CI/CD](#github-actions-cicd)
4. [Auto Build & Release](#auto-build--release)
5. [Integration dengan Build Systems Lain](#integration-dengan-build-systems-lain)

---

## 🔧 Integrasi dengan Ophub

### Ophub Build System Overview

Jika Anda menggunakan [ophub/amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt) atau fork-nya, berikut cara integrasinya:

### Metode 1: Include Package dalam Build Config

**File: `.github/workflows/build-openwrt.yml`**

Tambahkan di bagian `PACKAGE_LIST`:

```yaml
- name: Build OpenWrt
  env:
    PACKAGE_LIST: |
      luci
      luci-theme-argon-tirtayana
      # ... package lain
```

### Metode 2: Custom Files Integration

**Struktur Directory:**

```
your-repo/
├── .github/
│   └── workflows/
│       └── build-openwrt.yml
├── files/
│   └── etc/
│       └── openwrt_release     # Set version Tirtayana
├── package/
│   └── luci-theme-argon-tirtayana/   # <-- Copy package di sini
└── config/
    └── .config                  # Include tema
```

**Langkah-langkah:**

1. **Copy package ke repository Anda:**
```bash
# Di repository GitHub Anda
mkdir -p package
cp -r /path/to/openwrt/package/luci-theme-argon-tirtayana package/

# Commit
git add package/luci-theme-argon-tirtayana
git commit -m "Add Tirtayana custom theme"
git push
```

2. **Update .config file:**
```bash
# config/.config atau .config
echo "CONFIG_PACKAGE_luci-theme-argon-tirtayana=y" >> config/.config
```

3. **Set Tirtayana version:**
```bash
# files/etc/openwrt_release
mkdir -p files/etc
cat > files/etc/openwrt_release << 'EOF'
DISTRIB_ID='OpenWrt'
DISTRIB_RELEASE='23.05.2'
DISTRIB_REVISION='r23630-842932a63d'
DISTRIB_TARGET='armvirt/64'
DISTRIB_ARCH='aarch64_generic'
DISTRIB_DESCRIPTION='Tirtayana OpenWrt - Standard Edition'
DISTRIB_TAINTS='no-all override'
EOF
```

### Metode 3: Auto-Download dari GitHub

**File: `.github/workflows/build-openwrt.yml`**

Tambahkan step untuk download package:

```yaml
- name: Download Tirtayana Theme
  run: |
    cd openwrt/package
    git clone --depth 1 https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git
    
- name: Enable Tirtayana Theme
  run: |
    cd openwrt/package/luci-theme-argon-tirtayana
    chmod +x enable-theme.sh
    ./enable-theme.sh
```

### Metode 4: Git Submodule

```bash
# Di root repository Anda
git submodule add https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git package/luci-theme-argon-tirtayana
git submodule update --init --recursive

# Commit
git add .gitmodules package/luci-theme-argon-tirtayana
git commit -m "Add Tirtayana theme as submodule"
git push
```

**Keuntungan Submodule:**
- ✅ Auto-update dari repo utama
- ✅ Version control terpisah
- ✅ Easy maintenance

---

## 🚀 Push ke GitHub Repository

### Scenario 1: Repository Baru (Tema Standalone)

**Membuat repo khusus untuk tema:**

```bash
# 1. Buat repo baru di GitHub
# Nama: luci-theme-argon-tirtayana
# Description: Custom Argon Theme for Tirtayana OpenWrt

# 2. Di local machine
cd /path/to/openwrt/package/luci-theme-argon-tirtayana

# 3. Initialize git
git init
git add .
git commit -m "Initial commit: Tirtayana custom theme v1.0.0"

# 4. Add remote
git remote add origin https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git

# 5. Create main branch and push
git branch -M main
git push -u origin main

# 6. Create first release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

**Struktur Repository:**

```
luci-theme-argon-tirtayana/
├── .github/
│   └── workflows/
│       ├── build-ipk.yml        # Auto build IPK
│       └── release.yml          # Auto release
├── htdocs/
├── ucode/
├── Makefile
├── README.md
├── README-ID.md
├── INSTALL.md
├── LOGIN-FEATURES.md
├── INTEGRATION.md               # This file
├── LICENSE                      # MIT License
└── .gitignore
```

**File: `.gitignore`**

```gitignore
# Build artifacts
*.ipk
*.o
*.so

# Temp files
*~
*.swp
*.swo
.DS_Store

# IDE
.vscode/
.idea/

# Logs
*.log
```

**File: `LICENSE`**

```
MIT License

Copyright (c) 2024 Tirtayana Development Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### Scenario 2: Repository OpenWrt Build Existing

**Update existing OpenWrt build repo:**

```bash
# Di repository OpenWrt build Anda
cd /path/to/your-openwrt-build-repo

# 1. Copy tema
mkdir -p package
cp -r /path/to/openwrt/package/luci-theme-argon-tirtayana package/

# 2. Update .config
echo "CONFIG_PACKAGE_luci-theme-argon-tirtayana=y" >> .config

# 3. Commit
git add package/luci-theme-argon-tirtayana
git add .config
git commit -m "Add Tirtayana custom theme to build"
git push
```

---

## 🤖 GitHub Actions CI/CD

### Workflow 1: Build IPK Package

**File: `.github/workflows/build-ipk.yml`**

```yaml
name: Build Tirtayana Theme IPK

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'htdocs/**'
      - 'ucode/**'
      - 'Makefile'
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  OPENWRT_VERSION: '23.05.2'

jobs:
  build:
    runs-on: ubuntu-22.04
    
    steps:
    - name: Checkout theme repository
      uses: actions/checkout@v4
      with:
        path: theme
    
    - name: Prepare build environment
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential libncurses5-dev \
          gawk git libssl-dev gettext zlib1g-dev \
          file wget unzip python3
    
    - name: Clone OpenWrt
      run: |
        git clone --depth 1 --branch openwrt-${{ env.OPENWRT_VERSION }} \
          https://github.com/openwrt/openwrt.git
    
    - name: Update feeds
      run: |
        cd openwrt
        ./scripts/feeds update -a
        ./scripts/feeds install -a
    
    - name: Copy theme to OpenWrt
      run: |
        cp -r theme openwrt/package/luci-theme-argon-tirtayana
    
    - name: Configure build
      run: |
        cd openwrt
        cat > .config << EOF
        CONFIG_TARGET_armvirt=y
        CONFIG_TARGET_armvirt_64=y
        CONFIG_PACKAGE_luci=y
        CONFIG_PACKAGE_luci-theme-argon-tirtayana=y
        EOF
        make defconfig
    
    - name: Build theme package
      run: |
        cd openwrt
        make package/luci-theme-argon-tirtayana/compile V=s
    
    - name: Find IPK file
      id: find_ipk
      run: |
        cd openwrt
        IPK_FILE=$(find bin/packages -name "luci-theme-argon-tirtayana*.ipk" | head -1)
        echo "ipk_file=$IPK_FILE" >> $GITHUB_OUTPUT
        echo "ipk_name=$(basename $IPK_FILE)" >> $GITHUB_OUTPUT
    
    - name: Upload IPK artifact
      uses: actions/upload-artifact@v4
      with:
        name: luci-theme-argon-tirtayana-ipk
        path: openwrt/${{ steps.find_ipk.outputs.ipk_file }}
        retention-days: 30
    
    - name: Upload to release (on tag)
      if: startsWith(github.ref, 'refs/tags/')
      uses: softprops/action-gh-release@v1
      with:
        files: openwrt/${{ steps.find_ipk.outputs.ipk_file }}
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Workflow 2: Auto Release

**File: `.github/workflows/release.yml`**

```yaml
name: Create Release

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  create-release:
    runs-on: ubuntu-22.04
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Create Release Notes
      id: release_notes
      run: |
        cat > release-notes.md << 'EOF'
        ## Tirtayana Theme v${{ github.ref_name }}
        
        ### Features
        - Custom Argon-style LuCI theme
        - 3 Tirtayana versions display (Minimal, Standard, Edukasi)
        - Default password warning system
        - Responsive design for mobile & desktop
        - OpenWrt 2020 color palette
        
        ### Installation
        ```bash
        # Download IPK file
        wget https://github.com/${{ github.repository }}/releases/download/${{ github.ref_name }}/luci-theme-argon-tirtayana_*.ipk
        
        # Install on router
        opkg install luci-theme-argon-tirtayana_*.ipk
        
        # Theme will be activated automatically
        ```
        
        ### Documentation
        - [Installation Guide](https://github.com/${{ github.repository }}/blob/main/INSTALL.md)
        - [Login Features](https://github.com/${{ github.repository }}/blob/main/LOGIN-FEATURES.md)
        - [Quick Start (ID)](https://github.com/${{ github.repository }}/blob/main/QUICK-START-ID.md)
        
        ### Changelog
        See [CHANGELOG.md](https://github.com/${{ github.repository }}/blob/main/CHANGELOG.md)
        EOF
    
    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        body_path: release-notes.md
        draft: false
        prerelease: false
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Workflow 3: Code Quality Check

**File: `.github/workflows/quality.yml`**

```yaml
name: Code Quality

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  lint:
    runs-on: ubuntu-22.04
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Check JavaScript syntax
      run: |
        find htdocs -name "*.js" -exec node --check {} \;
    
    - name: Check CSS syntax
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - run: |
        npm install -g stylelint stylelint-config-standard
        find htdocs -name "*.css" -exec stylelint {} \; || true
    
    - name: Check file permissions
      run: |
        # CSS/JS should not be executable
        ! find htdocs -name "*.css" -executable
        ! find htdocs -name "*.js" -executable
        
        # Shell scripts should be executable
        find . -name "*.sh" ! -executable && exit 1 || true
    
    - name: Validate Makefile
      run: |
        make -f Makefile --dry-run || true
```

### Workflow 4: Full OpenWrt Build (Ophub Integration)

**File: `.github/workflows/build-openwrt-full.yml`**

```yaml
name: Build Tirtayana OpenWrt (Ophub)

on:
  workflow_dispatch:
    inputs:
      version_type:
        description: 'Tirtayana Version'
        required: true
        default: 'standard'
        type: choice
        options:
          - minimal
          - standard
          - edukasi

env:
  REPO_URL: https://github.com/openwrt/openwrt
  REPO_BRANCH: openwrt-23.05
  FEEDS_CONF: feeds.conf.default
  CONFIG_FILE: .config
  TZ: Asia/Jakarta

jobs:
  build:
    runs-on: ubuntu-22.04
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Initialization environment
      env:
        DEBIAN_FRONTEND: noninteractive
      run: |
        sudo rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc
        sudo -E apt-get -qq update
        sudo -E apt-get -qq install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc-s1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync
        sudo -E apt-get -qq autoremove --purge
        sudo -E apt-get -qq clean
    
    - name: Clone OpenWrt source
      run: |
        git clone --depth 1 $REPO_URL -b $REPO_BRANCH openwrt
    
    - name: Update feeds
      run: |
        cd openwrt
        ./scripts/feeds update -a
        ./scripts/feeds install -a
    
    - name: Copy Tirtayana theme
      run: |
        cp -r $GITHUB_WORKSPACE openwrt/package/luci-theme-argon-tirtayana
    
    - name: Set Tirtayana version
      run: |
        VERSION_TYPE="${{ github.event.inputs.version_type }}"
        VERSION_NAME=$(echo $VERSION_TYPE | sed 's/^./\u&/')
        
        mkdir -p openwrt/files/etc
        cat > openwrt/files/etc/openwrt_release << EOF
        DISTRIB_DESCRIPTION='Tirtayana OpenWrt - ${VERSION_NAME} Edition'
        EOF
    
    - name: Load custom configuration
      run: |
        cd openwrt
        cat > .config << EOF
        CONFIG_TARGET_armvirt=y
        CONFIG_TARGET_armvirt_64=y
        CONFIG_PACKAGE_luci=y
        CONFIG_PACKAGE_luci-ssl=y
        CONFIG_PACKAGE_luci-theme-argon-tirtayana=y
        EOF
        make defconfig
    
    - name: Download packages
      run: |
        cd openwrt
        make download -j8
        find dl -size -1024c -exec ls -l {} \;
        find dl -size -1024c -exec rm -f {} \;
    
    - name: Compile firmware
      run: |
        cd openwrt
        echo -e "$(nproc) thread compile"
        make -j$(nproc) || make -j1 || make -j1 V=s
    
    - name: Organize files
      run: |
        cd openwrt/bin/targets/*/*
        rm -rf packages
        echo "FIRMWARE=$PWD" >> $GITHUB_ENV
    
    - name: Upload firmware
      uses: actions/upload-artifact@v4
      with:
        name: tirtayana-openwrt-${{ github.event.inputs.version_type }}
        path: ${{ env.FIRMWARE }}
```

---

## 📦 Auto Build & Release

### Setup Auto-versioning

**File: `VERSION`**

```
1.0.0
```

**File: `CHANGELOG.md`**

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-03-15

### Added
- Initial release
- Custom Argon-style theme with Tirtayana branding
- 3 version display (Minimal, Standard, Edukasi)
- Auto-detection of active version
- Default password warning system
- Post-login password reminder modal
- Responsive design for mobile and desktop
- System information display
- Modern animations and transitions

### Documentation
- Complete installation guide (English & Indonesian)
- Login features documentation
- Integration guide for CI/CD
- Color palette visualization

## [Unreleased]

### Planned
- Multi-language support (toggle ID/EN)
- Dark mode for login page
- QR code authentication
- Two-factor authentication
- Custom background upload
```

### Auto-tag on Version Bump

**File: `.github/workflows/version-bump.yml`**

```yaml
name: Version Bump

on:
  workflow_dispatch:
    inputs:
      version_type:
        description: 'Version bump type'
        required: true
        type: choice
        options:
          - patch
          - minor
          - major

jobs:
  bump:
    runs-on: ubuntu-22.04
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Bump version
      id: bump
      run: |
        CURRENT=$(cat VERSION)
        IFS='.' read -ra VER <<< "$CURRENT"
        
        case "${{ github.event.inputs.version_type }}" in
          major)
            VER[0]=$((VER[0] + 1))
            VER[1]=0
            VER[2]=0
            ;;
          minor)
            VER[1]=$((VER[1] + 1))
            VER[2]=0
            ;;
          patch)
            VER[2]=$((VER[2] + 1))
            ;;
        esac
        
        NEW_VERSION="${VER[0]}.${VER[1]}.${VER[2]}"
        echo $NEW_VERSION > VERSION
        echo "version=$NEW_VERSION" >> $GITHUB_OUTPUT
    
    - name: Update Makefile version
      run: |
        sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=${{ steps.bump.outputs.version }}/" Makefile
    
    - name: Commit and tag
      run: |
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"
        git add VERSION Makefile
        git commit -m "Bump version to v${{ steps.bump.outputs.version }}"
        git tag -a "v${{ steps.bump.outputs.version }}" -m "Release v${{ steps.bump.outputs.version }}"
        git push origin main
        git push origin "v${{ steps.bump.outputs.version }}"
```

---

## 🔗 Integration dengan Build Systems Lain

### ImmortalWrt Build

```bash
# Clone ImmortalWrt
git clone https://github.com/immortalwrt/immortalwrt.git
cd immortalwrt

# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a

# Add Tirtayana theme
git clone https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git \
  package/luci-theme-argon-tirtayana

# Configure
make menuconfig
# LuCI → Themes → luci-theme-argon-tirtayana

# Build
make -j$(nproc)
```

### X-Wrt Build

Similar process dengan OpenWrt standar.

### Lean's LEDE

```bash
git clone https://github.com/coolsnowwolf/lede.git
cd lede

./scripts/feeds update -a
./scripts/feeds install -a

# Add theme
git clone https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git \
  package/lean/luci-theme-argon-tirtayana

make menuconfig
make -j$(nproc) V=s
```

---

## 📝 Best Practices

### 1. **Versioning Strategy**

- Use Semantic Versioning (SemVer): MAJOR.MINOR.PATCH
- Tag releases: `v1.0.0`, `v1.0.1`, etc.
- Maintain CHANGELOG.md

### 2. **Branch Strategy**

```
main        → Production-ready, stable releases
develop     → Development branch, latest features
feature/*   → New features
bugfix/*    → Bug fixes
hotfix/*    → Critical fixes for production
```

### 3. **Commit Message Convention**

```
feat: Add dark mode support
fix: Resolve modal z-index issue
docs: Update installation guide
style: Fix CSS formatting
refactor: Optimize JavaScript code
test: Add unit tests for password check
chore: Update dependencies
```

### 4. **Release Process**

```bash
# 1. Finish development
git checkout develop
git add .
git commit -m "feat: Complete feature X"

# 2. Create release branch
git checkout -b release/v1.1.0

# 3. Bump version
echo "1.1.0" > VERSION
git commit -am "chore: Bump version to 1.1.0"

# 4. Merge to main
git checkout main
git merge release/v1.1.0

# 5. Tag
git tag -a v1.1.0 -m "Release v1.1.0"

# 6. Push
git push origin main
git push origin v1.1.0

# 7. GitHub Actions auto-builds and releases
```

---

## 🎯 Quick Start Integration

### For Repository Owner

```bash
# 1. Create GitHub repository
# https://github.com/new
# Name: luci-theme-argon-tirtayana

# 2. Push code
cd /path/to/luci-theme-argon-tirtayana
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git
git branch -M main
git push -u origin main

# 3. Create workflows directory
mkdir -p .github/workflows
# Copy workflow files from above

# 4. Commit workflows
git add .github
git commit -m "ci: Add GitHub Actions workflows"
git push

# 5. Create first release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 6. GitHub Actions will automatically build IPK
```

### For Users (Integration)

**Method 1: Direct clone**
```bash
cd openwrt/package
git clone https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git
```

**Method 2: Submodule**
```bash
git submodule add https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git package/luci-theme-argon-tirtayana
```

**Method 3: Download release**
```bash
wget https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana/releases/download/v1.0.0/luci-theme-argon-tirtayana_1.0.0-1_all.ipk
opkg install luci-theme-argon-tirtayana_1.0.0-1_all.ipk
```

---

## 🆘 Troubleshooting

### Build Fails in CI

**Check:**
- OpenWrt version compatibility
- Dependencies installed
- Disk space available

**Fix:**
```yaml
- name: Free disk space
  run: |
    sudo rm -rf /usr/share/dotnet
    sudo rm -rf /opt/ghc
    sudo rm -rf /usr/local/share/boost
```

### IPK Not Found After Build

**Check:**
```bash
# In CI logs
find bin/packages -name "*.ipk" -ls
```

### Version Not Detected on Router

**Ensure release description is set:**
```bash
cat /etc/openwrt_release | grep DESCRIPTION
# Should contain: minimal, standard, or edukasi
```

---

## 📞 Support

- **Issues:** https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana/issues
- **Documentation:** See README.md, INSTALL.md, LOGIN-FEATURES.md
- **CI/CD Status:** https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana/actions

---

**Last Updated:** 2024-03-15  
**Version:** 1.0.0  
**Maintainer:** Tirtayana Development Team