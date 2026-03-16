# TIrtayana OpenWrt — Panduan Lengkap Build untuk STB B860H

> **Teknologi Informasi — Universitas Udayana**
> Firmware OpenWrt kustom berbasis [ophub/amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt)
> Target Hardware: **STB B860H (Amlogic S905X)**

---

## 📋 Daftar Isi

- [Gambaran Umum](#gambaran-umum)
- [Struktur Direktori](#struktur-direktori)
- [Alur Build Lengkap](#alur-build-lengkap)
- [Persiapan Lingkungan Build](#persiapan-lingkungan-build)
- [Langkah 1 — Build OpenWrt Generic ARM64](#langkah-1--build-openwrt-generic-arm64)
- [Langkah 2 — Repack dengan ophub untuk B860H](#langkah-2--repack-dengan-ophub-untuk-b860h)
- [Langkah 3 — Install ke STB B860H](#langkah-3--install-ke-stb-b860h)
- [Tema LuCI Argon](#tema-luci-argon)
- [Custom Kernel](#custom-kernel)
- [GitHub Actions (CI/CD)](#github-actions-cicd)
- [Kustomisasi Lanjutan](#kustomisasi-lanjutan)
- [Troubleshooting](#troubleshooting)
- [Informasi Hardware B860H](#informasi-hardware-b860h)

---

## Gambaran Umum

Build ini menggunakan **dua tahap**:

```
[Tahap 1]  OpenWrt source (armsr/armv8)
           make menuconfig → make → rootfs.tar.gz
                    ↓
[Tahap 2]  ophub remake script
           rootfs.tar.gz + Custom Kernel (S905X)
                    ↓
           openwrt_s905x_*.img.gz  ← siap flash ke B860H
```

| Item | Detail |
|------|--------|
| **OpenWrt Base** | OpenWrt main (openwrt-24.10) |
| **Target Build** | `armsr/armv8` — Generic EFI ARM64 |
| **Packaging** | `ophub/amlogic-s9xxx-openwrt` → board `s905x` |
| **Kernel** | ophub kernel repo (6.1.y / 6.6.y) |
| **Tema LuCI** | `luci-theme-argon` (Modern Dark) |
| **IP Default** | `192.168.1.1` |
| **User / Pass** | `root` / `TIudayana` |
| **Timezone** | `Asia/Makassar` (WITA) |

---

## Struktur Direktori

```
openwrt-build/openwrt/
│
├── .config                         ← Konfigurasi build fallback
├── .config.minimal                 ← Konfigurasi versi minimal
├── .config.standard                ← Konfigurasi versi standard
├── .config.education               ← Konfigurasi versi education
├── feeds.conf.default              ← Daftar feed sumber paket
│
├── files/                          ← File kustom yang dioverlay ke rootfs
│   └── etc/
│       ├── banner                  ← ASCII banner saat login SSH
│       ├── openwrt_release         ← Informasi rilis firmware
│       ├── openwrt_version         ← Versi firmware
│       ├── config/
│       │   ├── luci                ← Konfigurasi LuCI (tema, sesi, dll)
│       │   ├── argon               ← Konfigurasi default tema Argon
│       │   └── system              ← Hostname, timezone, dll
│       ├── sysctl.d/               ← Optimasi kernel parameter
│       └── uci-defaults/
│           ├── 99-argon-theme      ← Set Argon sebagai tema default
│           └── 99-root-password    ← Set password root awal
│
├── package/
│   ├── luci-theme-argon/
│   │   └── Makefile                ← Package tema Argon (dari jerrykuku)
│   ├── luci-app-argon-config/
│   │   └── Makefile                ← Package konfigurasi tema Argon
│   └── tirtayana/
│       └── Makefile                ← Branding & konfigurasi TIrtayana
│
├── scripts/
│   └── pack-b860h.sh               ← Script packaging lokal via ophub
│
└── .github/
    └── workflows/
        └── build-b860h.yml         ← GitHub Actions untuk build + package otomatis
```

---

## Alur Build Lengkap

```
┌─────────────────────────────────────────────────────────────┐
│                    ALUR BUILD TIRTAYANA                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Persiapan                                               │
│     └─ Install dependencies                                 │
│     └─ Update feeds                                         │
│                                                             │
│  2. Konfigurasi                                             │
│     └─ make menuconfig  (atau gunakan .config yang ada)     │
│     └─ Target: armsr → armv8 → Generic EFI Boot            │
│     └─ Theme: luci-theme-argon                              │
│                                                             │
│  3. Kompilasi OpenWrt                                       │
│     └─ make -j$(nproc)                                      │
│     └─ Output: bin/targets/armsr/armv8/*rootfs.tar.gz       │
│                                                             │
│  4. Repack via ophub                                        │
│     └─ sudo ./scripts/pack-b860h.sh                         │
│     └─ Board: s905x | Kernel: 6.1.y / 6.6.y                │
│     └─ Output: out/b860h/openwrt_s905x_*.img.gz             │
│                                                             │
│  5. Flash & Install                                         │
│     └─ Rufus / balenaEtcher → USB/SD                        │
│     └─ Boot B860H dari USB/SD                               │
│     └─ (Opsional) Install ke eMMC via Amlogic Service       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Persiapan Lingkungan Build

### Sistem Operasi yang Didukung
- Ubuntu 22.04 LTS / 24.04 LTS ✅
- Debian 11 / 12 ✅
- WSL2 (Ubuntu) ✅
- macOS (dengan tools GNU) ⚠️

### Install Dependencies (Ubuntu/Debian)

```bash
sudo apt-get update -y
sudo apt-get full-upgrade -y
sudo apt-get install -y \
    ack antlr3 asciidoc autoconf automake autopoint binutils bison \
    build-essential bzip2 ccache clang cmake cpio curl \
    device-tree-compiler flex gawk gcc-multilib g++-multilib \
    gettext git genisoimage gperf haveged help2man intltool \
    lib32gcc-s1 libc6-dev-i386 libelf-dev libfuse-dev \
    libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev \
    libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev \
    libssl-dev libtool lrzsz mkisofs msmtp ninja-build p7zip \
    p7zip-full patch pkgconf python3 python3-pyelftools \
    python3-setuptools qemu-utils rsync scons squashfs-tools \
    subversion swig texinfo uglifyjs upx-ucl unzip wget \
    xmlto xxd zlib1g-dev
```

### Ruang Disk yang Dibutuhkan
| Tahap | Kebutuhan |
|-------|-----------|
| Source code + feeds | ~5 GB |
| Download cache (`dl/`) | ~3 GB |
| Build output (`build_dir/`) | ~20 GB |
| **Total (aman)** | **≥ 40 GB** |

---

## Langkah 1 — Build OpenWrt Generic ARM64

### 1.1 Update Feeds

```bash
cd openwrt/

# Update semua feed (packages, luci, routing, telephony)
./scripts/feeds update -a

# Install semua paket dari feed ke source tree
./scripts/feeds install -a
```

### 1.2 Konfigurasi Build

File `.config` sudah dikonfigurasi untuk B860H. Untuk melihat atau mengubah:

```bash
# Gunakan .config yang sudah ada
make defconfig

# Atau buka menuconfig untuk kustomisasi manual
make menuconfig
```

**Konfigurasi penting yang sudah di-set:**

| Opsi | Nilai |
|------|-------|
| Target System | `Arm SystemReady (EFI) compliant` |
| Subtarget | `64-bit (armv8) machines` |
| Target Profile | `Generic EFI Boot` |
| Target Images | `tar.gz` ✅ (wajib untuk ophub) |
| Kernel | `6.6.x` |
| LuCI Theme | `luci-theme-argon` |

> ⚠️ **Penting:** Pastikan `Target Images → tar.gz` DICENTANG.
> File `*rootfs.tar.gz` inilah yang dibutuhkan ophub untuk packaging.

### 1.3 Download Paket

```bash
make download -j8 V=s

# Hapus file yang tidak lengkap diunduh
find dl -size -1024c -exec rm -f {} \;
```

### 1.4 Kompilasi

```bash
# Kompilasi paralel (disarankan)
make -j$(nproc)

# Jika gagal, coba single thread untuk melihat error
make -j1 V=s
```

### 1.5 Cek Output

```bash
ls -lh bin/targets/armsr/armv8/

# File penting:
# TIrtayana-openwrt-armsr-armv8-generic-rootfs.tar.gz  ← INPUT untuk ophub
# TIrtayana-openwrt-armsr-armv8-generic-ext4-combined-efi.img.gz
# TIrtayana-openwrt-armsr-armv8-generic-squashfs-combined-efi.img.gz
```

---

## Langkah 2 — Repack dengan ophub untuk B860H

### Metode A: Script Lokal (Disarankan)

Script `scripts/pack-b860h.sh` akan otomatis:
1. Clone ophub packager
2. Menyalin rootfs ke workspace ophub
3. Menjalankan `./remake` dengan parameter B860H
4. Menyimpan hasil di `out/b860h/`

```bash
# Jalankan dengan konfigurasi default
sudo ./scripts/pack-b860h.sh

# Dengan kernel spesifik
sudo ./scripts/pack-b860h.sh -k 6.6.y

# Dengan dua seri kernel sekaligus
sudo ./scripts/pack-b860h.sh -k 6.1.y_6.6.y

# Dengan custom ophub repo, custom kernel repo, dan profile khusus
sudo ./scripts/pack-b860h.sh -r https://github.com/ophub/amlogic-s9xxx-openwrt.git -R URL/repo/kustom -p minimal

# Dengan IP kustom dan rootfs lebih besar
sudo ./scripts/pack-b860h.sh -k 6.6.y -i 10.0.0.1 -s 256/2048

# Lihat semua opsi
./scripts/pack-b860h.sh -h
```

**Parameter script:**
| Flag | Default | Keterangan |
|------|---------|------------|
| `-k` | `6.1.y_6.6.y` | Versi kernel ophub |
| `-i` | `192.168.1.1` | IP default OpenWrt |
| `-s` | `256/1024` | Ukuran BOOT/ROOT (MB) |
| `-b` | `s905x` | Board (jangan diubah untuk B860H) |
| `-n` | `TIrtayana` | Nama builder |
| `-o` | `out/b860h` | Direktori output |
| `-r` | URL Repo | Custom Ophub Repo URL |
| `-R` | `(kosong)` | Custom Kernel Repo (opsional) |
| `-p` | `(kosong)` | Profile/Versi output (e.g., minimal) |

### Metode B: Manual (ophub CLI)

```bash
# Clone ophub
git clone --depth=1 https://github.com/ophub/amlogic-s9xxx-openwrt.git /tmp/ophub

# Siapkan rootfs
mkdir -p /tmp/ophub/openwrt-armsr
cp bin/targets/armsr/armv8/*rootfs.tar.gz /tmp/ophub/openwrt-armsr/

# Packaging untuk B860H
cd /tmp/ophub
sudo ./remake -b s905x -k 6.1.y_6.6.y -p 192.168.1.1 -s 256/1024 -n TIrtayana

# Lihat hasil
ls -lh openwrt/out/
```

### Metode C: GitHub Actions (Otomatis / 3 Versi)

Sistem ini mendukung pembuatan 3 versi firmware secara bersamaan (Matrix Build): **minimal**, **standard**, dan **education**.
Konfigurasi tiap versi bersumber dari file `.config.minimal`, `.config.standard`, dan `.config.education`. GitHub Actions menggunakan packager dari `ophub/amlogic-s9xxx-openwrt`.

Push ke branch `main` atau trigger manual via:
**Actions → Build TIrtayana OpenWrt for B860H → Run workflow**

Parameter yang bisa dikustomisasi saat trigger manual:
- **Profile Build**: Pilih `all` (untuk build ketiganya sekaligus), `minimal`, `standard`, atau `education`.
- **Versi Kernel** & **Custom Kernel Repo** (opsional)
- **IP Address Default** & **Ukuran Rootfs**
- **Upload ke Releases**

---

## Langkah 3 — Install ke STB B860H

### 3.1 Cek File Output

```
out/b860h/
└── openwrt_s905x_k6.1.y_TIrtayana_YYYYMMDD-HHMM.img.gz
```

### 3.2 Flash ke USB/SD Card

**Menggunakan Rufus (Windows):**
1. Buka Rufus → pilih USB/SD card
2. Boot selection: pilih file `.img.gz`
3. Klik **START** → tunggu selesai

**Menggunakan balenaEtcher (Linux/Mac/Windows):**
1. Flash from file → pilih file `.img.gz`
2. Select target → pilih USB/SD card
3. Klik **Flash!**

**Menggunakan `dd` (Linux):**
```bash
# Decompress dan flash sekaligus
zcat openwrt_s905x_*.img.gz | sudo dd of=/dev/sdX bs=4M status=progress
sudo sync
```
> ⚠️ Ganti `/dev/sdX` dengan device USB/SD card yang benar.

### 3.3 Boot dari USB/SD

1. Masukkan USB/SD ke port STB B860H
2. Nyalakan STB → akan boot otomatis ke OpenWrt
3. Tunggu sekitar 30-60 detik (boot pertama lebih lama)

### 3.4 Akses LuCI

```
URL      : http://192.168.1.1
Username : root
Password : TIudayana
```

Tampilan akan menggunakan **tema Argon (dark mode)** secara default.

### 3.5 Install ke eMMC (Opsional — Permanen)

> ⚠️ **Backup ROM Android original sebelum melakukan ini!**

**Backup Android ROM dulu:**
```bash
# Di terminal LuCI (System → TTYD Terminal)
openwrt-ddbr
# Ketik 'b' untuk backup ke USB/SD
```

**Install ke eMMC:**
1. Login LuCI → **System → Amlogic Service**
2. Klik **Install OpenWrt**
3. Pilih board: **B860H**
4. Klik **Install** → tunggu proses selesai
5. STB akan reboot dari eMMC

---

## Tema LuCI Argon

Tema [luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon) memberikan tampilan modern dengan fitur:

| Fitur | Keterangan |
|-------|------------|
| **Dark Mode** | Aktif secara default |
| **Background Kustom** | Upload gambar/video sebagai latar login |
| **Tampilan Jam** | Jam digital di halaman login |
| **Warna Aksen** | Bisa dikustomisasi |
| **Transparansi** | Efek blur pada background |
| **Responsif** | Mendukung tampilan mobile |

### Konfigurasi Tema

**Via LuCI:**
`System → Argon Config`

**Via file konfigurasi** (`files/etc/config/argon`):
```
config argon
    option mode          'dark'        # dark / light / auto
    option transparency  '0.5'         # 0.0 - 1.0
    option blur          '10'          # px blur background
    option primary_color '#1a73e8'     # warna aksen utama
    option clock_enable  '1'           # tampilkan jam (1/0)
    option clock_24h     '1'           # format 24 jam (1/0)
    option show_sysstat  '1'           # tampilkan info sistem
    option animation     '1'           # aktifkan animasi
```

### Package yang Ditambahkan

```
package/luci-theme-argon/       ← Tema utama
package/luci-app-argon-config/  ← Panel konfigurasi tema di LuCI
```

### Memperbarui Versi Argon

Edit `package/luci-theme-argon/Makefile` dan perbarui:
```makefile
PKG_VERSION:=x.x.x
PKG_SOURCE_DATE:=YYYY-MM-DD
PKG_SOURCE_VERSION:=<commit-hash-terbaru>
```

Dapatkan commit hash terbaru:
```bash
git ls-remote https://github.com/jerrykuku/luci-theme-argon.git HEAD
```

---

## Custom Kernel

Firmware B860H menggunakan kernel yang dikompilasi dan dipelihara oleh ophub,
diambil dari repository [ophub/kernel](https://github.com/ophub/kernel).

### Seri Kernel yang Didukung untuk S905X

| Kernel | Status | Rekomendasi |
|--------|--------|-------------|
| `5.15.y` | Stable | Kompatibilitas maksimal |
| `6.1.y` | Stable | **Disarankan** ✅ |
| `6.6.y` | Stable | **Disarankan** ✅ |
| `6.12.y` | Latest | Fitur terbaru |

> Gunakan `_` untuk memilih lebih dari satu seri sekaligus:
> `-k 6.1.y_6.6.y` → akan menghasilkan dua file firmware berbeda

### Update Kernel Tanpa Rebuild

Setelah OpenWrt terinstall, update kernel bisa dilakukan via LuCI:
**System → Amlogic Service → Update Kernel**

Atau via terminal:
```bash
# Di terminal B860H yang sudah berjalan OpenWrt
openwrt-kernel -u
```

### Kompilasi Kernel Kustom (Advanced)

Jika ingin kernel dengan patch khusus, gunakan:
```yaml
# Di GitHub Actions
- name: Compile custom kernel
  uses: ophub/amlogic-s9xxx-armbian@main
  with:
    build_target: kernel
    kernel_version: 6.6.y
    kernel_auto: true
    kernel_sign: -TIrtayana
    kernel_config: kernel-config/s905x.config  # konfigurasi kustom
```

---

## GitHub Actions (CI/CD)

File: `.github/workflows/build-b860h.yml`

### Trigger Otomatis

Build otomatis berjalan saat ada push ke `main` yang mengubah:
- `.config`
- `feeds.conf.default`
- `package/**`
- `files/**`

### Trigger Manual

1. Buka tab **Actions** di GitHub
2. Pilih **Build TIrtayana OpenWrt for B860H**
3. Klik **Run workflow**
4. Isi parameter (opsional):

| Parameter | Default | Keterangan |
|-----------|---------|------------|
| `kernel_version` | `6.1.y_6.6.y` | Seri kernel |
| `openwrt_ip` | `192.168.1.1` | IP default |
| `rootfs_size` | `1024` | Ukuran rootfs (MB) |
| `upload_release` | `true` | Buat GitHub Release |

### Output Artifacts

| Artifact | Keterangan |
|----------|------------|
| `openwrt-armsr-rootfs` | File rootfs.tar.gz (input ophub) |
| `TIrtayana-OpenWrt-B860H-*` | Firmware siap flash untuk B860H |
| `build-info` | Manifest, config, feeds info |

### Syarat GitHub Actions

Pastikan repository memiliki:
- ✅ **Write permission** untuk Actions: `Settings → Actions → General → Workflow permissions → Read and write`
- ✅ **Secret `GITHUB_TOKEN`** sudah tersedia otomatis

---

## Kustomisasi Lanjutan

### Menambah Paket ke Firmware

Edit `.config` menggunakan `make menuconfig`:
```bash
make menuconfig
# atau langsung edit .config:
echo "CONFIG_PACKAGE_nama-paket=y" >> .config
```

Contoh paket populer:
```bash
# Adblock
CONFIG_PACKAGE_luci-app-adblock=y

# OpenVPN
CONFIG_PACKAGE_openvpn-openssl=y
CONFIG_PACKAGE_luci-app-openvpn=y

# SQM / QoS
CONFIG_PACKAGE_luci-app-sqm=y

# File Manager
CONFIG_PACKAGE_luci-app-filemanager=y

# DDNS
CONFIG_PACKAGE_luci-app-ddns=y
```

### Mengubah IP Default

**Via menuconfig:**
```
Global build settings → Target Images → Image Options
→ LAN IP address of the firmware
```

**Via files/etc/config/network** (buat file baru):
```
config interface 'loopback'
    option ifname 'lo'
    option proto 'static'
    option ipaddr '127.0.0.1'
    option netmask '255.0.0.0'

config interface 'lan'
    option type 'bridge'
    option ifname 'eth0'
    option proto 'static'
    option ipaddr '192.168.1.1'
    option netmask '255.255.255.0'
```

### Mengubah Hostname dan Timezone

Edit `files/etc/config/system`:
```
config system
    option hostname  'TIrtayana'
    option timezone  'Asia/Makassar'    # WIB: Asia/Jakarta | WITA: Asia/Makassar | WIT: Asia/Jayapura
    option ttylogin  '0'
    option log_size  '64'
```

### Menambah Feed Kustom

Edit `feeds.conf.default`:
```
# Feed official
src-git packages https://git.openwrt.org/feed/packages.git;openwrt-24.10
src-git luci     https://git.openwrt.org/project/luci.git;openwrt-24.10

# Feed komunitas (opsional, banyak plugin populer)
# src-git kenzok8  https://github.com/kenzok8/small-package

# Feed routing & telephony
src-git routing   https://git.openwrt.org/feed/routing.git;openwrt-24.10
src-git telephony https://git.openwrt.org/feed/telephony.git;openwrt-24.10
```

### Custom UCI-Defaults (Konfigurasi First-Boot)

Tambahkan script di `files/etc/uci-defaults/`:
```bash
# files/etc/uci-defaults/10-custom-setup
#!/bin/sh

# Contoh: set DNS ke Cloudflare
uci set network.wan.dns='1.1.1.1 1.0.0.1'
uci commit network

# Aktifkan SSH dari WAN (hati-hati!)
# uci set dropbear.@dropbear[0].Interface=''
# uci commit dropbear

exit 0
```

---

## Troubleshooting

### Build Gagal saat Compile

```bash
# Coba dengan single thread dan verbose untuk lihat error detail
make -j1 V=s 2>&1 | tee build.log | tail -50

# Bersihkan build dan coba lagi
make clean
make -j$(nproc)
```

### Error: `feeds/luci/luci.mk not found`

Pastikan feeds sudah diupdate dan luci feed tersedia:
```bash
./scripts/feeds update luci
./scripts/feeds install -a
ls feeds/luci/luci.mk   # harus ada
```

### Tema Argon Tidak Muncul di LuCI

1. Pastikan package terinstall:
   ```bash
   opkg list-installed | grep argon
   ```
2. Set manual via SSH:
   ```bash
   uci set luci.main.mediaurlbase=/luci-static/argon
   uci commit luci
   /etc/init.d/uhttpd restart
   ```

### B860H Tidak Mau Boot dari USB

1. Pastikan USB diformat dengan benar (gunakan Rufus/Etcher, bukan manual)
2. Coba port USB yang berbeda (biasanya USB 2.0 lebih reliable untuk boot)
3. Beberapa unit B860H perlu langkah khusus:
   - Tekan tombol reset saat power masuk (untuk masuk recovery)
   - Gunakan toothpick method: tekan tombol AV kecil di samping port AV

### Update Kernel Gagal

```bash
# Cek status kernel saat ini
uname -r

# Recovery kernel via USB
openwrt-kernel -s   # restore kernel sebelumnya
```

### Lupa Password

Boot dari USB OpenWrt baru, mount eMMC partition, dan reset:
```bash
mount /dev/mmcblk2p2 /mnt
chroot /mnt passwd root
```

---

## Informasi Hardware B860H

### Spesifikasi STB B860H (Amlogic S905X)

| Komponen | Spesifikasi |
|----------|-------------|
| **SoC** | Amlogic S905X (Quad-core ARM Cortex-A53, 1.5 GHz) |
| **GPU** | ARM Mali-450 |
| **RAM** | 2 GB DDR3 |
| **Storage** | 8 GB eMMC |
| **Ethernet** | 10/100 Mbps |
| **USB** | 2× USB 2.0 |
| **Output** | HDMI 2.0, AV |
| **Wifi** | Tidak ada (versi standar) |
| **Bluetooth** | Tidak ada (versi standar) |
| **Boot** | Android TV (bisa diganti OpenWrt) |

> ⚠️ **Catatan Versi:** STB B860H memiliki beberapa varian hardware.
> Build ini khusus untuk varian **Amlogic S905X**.
> Varian lain (HiSilicon Hi3798MV200) **tidak kompatibel**.

### Cara Identifikasi Versi B860H

Lihat label di bagian bawah STB atau masuk ke menu Android:
- Jika ada **S905X** → ✅ Kompatibel dengan build ini
- Jika ada **Hi3798MV200** → ❌ Butuh build berbeda

---

## Lisensi dan Kredit

| Komponen | Lisensi | Pembuat |
|----------|---------|---------|
| OpenWrt | GPL-2.0 | [OpenWrt Project](https://openwrt.org) |
| ophub amlogic-s9xxx-openwrt | GPL-2.0 | [ophub](https://github.com/ophub) |
| luci-theme-argon | MIT | [jerrykuku](https://github.com/jerrykuku) |
| TIrtayana customization | GPL-2.0 | Teknologi Informasi Universitas Udayana |

---

<div align="center">

**TIrtayana OpenWrt** — Teknologi Informasi Universitas Udayana

Dibuat dengan ❤️ untuk riset dan edukasi jaringan komputer

</div>