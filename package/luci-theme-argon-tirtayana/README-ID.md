# LuCI Theme Argon - Edisi Tirtayana

Tema LuCI kustom untuk OpenWrt dengan branding Tirtayana dan palet warna yang terinspirasi dari OpenWrt 2020.

## Fitur

- **Desain Modern Bergaya Argon**: Antarmuka yang bersih dan kontemporer dengan efek gradien
- **Branding Tirtayana**: Logo dan identitas brand kustom
- **Palet Warna OpenWrt 2020**: 
  - Warna Primer: `#0b0b0b` (Hitam Gelap)
  - Warna Sekunder: `#8a6800` (Coklat Keemasan)
  - Warna Aksen: `#cc8800` (Oranye)
  - Background: `#ffffff` (Putih)
  - Success: `#5cb85c` (Hijau)
  - Warning: `#cc8800` (Oranye)
  - Danger: `#cc1111` (Merah)
- **Desain Responsif**: Antarmuka yang ramah mobile
- **Animasi Halus**: Transisi modern dan efek hover
- **Scrollbar Kustom**: Scrollbar bertema yang sesuai dengan palet warna
- **Tipografi Profesional**: Font yang bersih dan mudah dibaca

## Instalasi

### Membangun dari Source

1. **Salin package ini ke buildroot OpenWrt Anda:**
   ```bash
   # Package sudah ada di: openwrt/package/luci-theme-argon-tirtayana/
   cd openwrt
   ```

2. **Aktifkan tema menggunakan script helper:**
   ```bash
   cd package/luci-theme-argon-tirtayana
   ./enable-theme.sh
   cd ../..
   ```

   Atau secara manual dengan menuconfig:
   ```bash
   make menuconfig
   # Navigasi ke: LuCI → Themes
   # Pilih: <*> luci-theme-argon-tirtayana
   ```

3. **Build package:**
   ```bash
   make package/luci-theme-argon-tirtayana/compile V=s
   ```

4. **Install di router Anda:**
   ```bash
   scp bin/packages/*/base/luci-theme-argon-tirtayana*.ipk root@192.168.1.1:/tmp/
   ssh root@192.168.1.1
   opkg install /tmp/luci-theme-argon-tirtayana*.ipk
   ```

### Instalasi Otomatis dalam Build Firmware

Jika Anda ingin tema ini sudah terinstall dalam firmware:

1. **Tambahkan ke .config:**
   ```bash
   echo "CONFIG_PACKAGE_luci-theme-argon-tirtayana=y" >> .config
   make defconfig
   ```

2. **Build firmware lengkap:**
   ```bash
   make -j$(nproc)
   ```

3. **Flash firmware ke router**

### Pasca-Instalasi

Tema akan otomatis diset sebagai default setelah instalasi. Untuk mengubah tema secara manual:

**Melalui Web Interface:**
1. Buka **System → System → Language and Style**
2. Di bagian **Design**, pilih **Argon Tirtayana**
3. Klik **Save & Apply**
4. Refresh halaman browser (Ctrl+F5)

**Melalui SSH:**
```bash
uci set luci.main.mediaurlbase=/luci-static/argon-tirtayana
uci commit luci
/etc/init.d/uhttpd restart
```

## Kustomisasi

### Mengganti Logo

1. **Siapkan logo Anda:**
   - Format: SVG (direkomendasikan) atau PNG
   - Ukuran: 200x200 pixel untuk logo utama, 64x64 untuk favicon
   - Nama file: `logo.svg`

2. **Ganti logo sebelum build:**
   ```bash
   cp /path/ke/logo-anda.svg \
      package/luci-theme-argon-tirtayana/htdocs/luci-static/argon-tirtayana/logo.svg
   ```

3. **Rebuild package:**
   ```bash
   make package/luci-theme-argon-tirtayana/compile V=s
   ```

### Mengubah Warna

Edit file CSS sebelum build:
```bash
nano package/luci-theme-argon-tirtayana/htdocs/luci-static/argon-tirtayana/cascade.css
```

Modifikasi bagian variabel `:root`:
```css
:root {
  --primary-color: #0b0b0b;        /* Warna header utama */
  --secondary-color: #8a6800;      /* Warna tombol dan link */
  --accent-color: #cc8800;         /* Warna aksen/highlight */
  --success-color: #5cb85c;        /* Warna pesan sukses */
  --warning-color: #cc8800;        /* Warna peringatan */
  --danger-color: #cc1111;         /* Warna error */
  /* ... sesuaikan sesuai kebutuhan */
}
```

Kemudian rebuild dan install ulang.

### Kustomisasi Live (Advanced)

Untuk testing warna tanpa rebuild:

1. **SSH ke router:**
   ```bash
   ssh root@192.168.1.1
   ```

2. **Edit CSS langsung:**
   ```bash
   vi /www/luci-static/argon-tirtayana/cascade.css
   ```

3. **Clear cache browser** dan reload

**⚠️ Peringatan:** Perubahan akan hilang saat upgrade firmware!

## Struktur File

```
luci-theme-argon-tirtayana/
├── Makefile                          # OpenWrt package Makefile
├── README.md                         # Dokumentasi (English)
├── README-ID.md                      # Dokumentasi (Indonesia)
├── INSTALL.md                        # Panduan instalasi detail
├── enable-theme.sh                   # Script helper untuk aktivasi
├── htdocs/
│   └── luci-static/
│       └── argon-tirtayana/
│           ├── cascade.css           # Stylesheet utama
│           ├── mobile.css            # Style untuk mobile
│           ├── logo.svg              # Logo Tirtayana
│           └── favicon.ico.svg       # Favicon
└── ucode/
    └── template/
        └── themes/
            └── argon-tirtayana/
                ├── header.ut         # Template header
                └── footer.ut         # Template footer
```

## Referensi Palet Warna

| Nama Warna       | Kode Hex  | Penggunaan                     |
|------------------|-----------|--------------------------------|
| Primary Dark     | `#0b0b0b` | Header, navigasi utama         |
| Secondary Gold   | `#8a6800` | Tombol, aksen, link            |
| Accent Orange    | `#cc8800` | Warning, highlight             |
| Success Green    | `#5cb85c` | Pesan sukses, konfirmasi       |
| Danger Red       | `#cc1111` | Error, aksi hapus              |
| Text Dark        | `#5d5d5d` | Teks body                      |
| Background White | `#ffffff` | Background utama               |

## Kompatibilitas Browser

- Chrome/Chromium 60+
- Firefox 60+
- Safari 12+
- Edge 79+
- Browser mobile (iOS Safari, Chrome Mobile)

## Pengembangan

### Testing Perubahan

Setelah memodifikasi CSS atau template:

1. **Rebuild package:**
   ```bash
   make package/luci-theme-argon-tirtayana/clean
   make package/luci-theme-argon-tirtayana/compile V=s
   ```

2. **Update di router:**
   ```bash
   scp bin/packages/*/base/luci-theme-argon-tirtayana*.ipk root@router:/tmp/
   ssh root@router "opkg remove luci-theme-argon-tirtayana && \
                    opkg install /tmp/luci-theme-argon-tirtayana*.ipk"
   ```

3. **Clear cache browser** dan reload

### Referensi Class CSS

Class yang umum digunakan dalam tema:
- `.cbi-map` - Container konfigurasi utama
- `.cbi-section` - Section konfigurasi
- `.cbi-value` - Baris field form
- `.cbi-button` - Tombol aksi
- `.alert` - Box alert/notifikasi
- `.table` - Tabel data

## Troubleshooting

### Tema Tidak Muncul di Pilihan

**Solusi:**
```bash
# Verifikasi instalasi
opkg list-installed | grep argon-tirtayana

# Cek file tema ada
ls -la /www/luci-static/argon-tirtayana/

# Restart uhttpd
/etc/init.d/uhttpd restart

# Clear cache browser (Ctrl+Shift+Del)
```

### Logo Tidak Muncul

**Solusi:**
```bash
# Cek logo ada
ls -la /www/luci-static/argon-tirtayana/logo.svg

# Verifikasi CSS referensi ke file yang benar
grep "logo.svg" /www/luci-static/argon-tirtayana/cascade.css

# Test logo langsung di browser:
# http://192.168.1.1/luci-static/argon-tirtayana/logo.svg
```

### Build Error

**Solusi:**
```bash
# Clean dan rebuild
make package/luci-theme-argon-tirtayana/clean
make package/luci-theme-argon-tirtayana/compile V=s

# Cek dependencies
./scripts/feeds install luci-base

# Pastikan LuCI diaktifkan di menuconfig
make menuconfig  # LuCI → Collections → luci
```

### Kembali ke Tema Default

Jika ada masalah:

**Via Web:**
```
System → System → Language and Style → Design → Bootstrap
```

**Via SSH:**
```bash
uci set luci.main.mediaurlbase=/luci-static/bootstrap
uci commit luci
/etc/init.d/uhttpd restart
```

## Update Tema

### Update Package di Router

```bash
# Upload package baru
scp new-package.ipk root@192.168.1.1:/tmp/

# SSH ke router
ssh root@192.168.1.1

# Hapus yang lama, install yang baru
opkg remove luci-theme-argon-tirtayana
opkg install /tmp/luci-theme-argon-tirtayana_*.ipk

# Clear cache dan restart
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

## Uninstall

```bash
# Hapus package
opkg remove luci-theme-argon-tirtayana

# Kembali ke tema default
uci set luci.main.mediaurlbase=/luci-static/bootstrap
uci delete luci.themes.ArgonTirtayana
uci commit luci
/etc/init.d/uhttpd restart
```

## Referensi Command Cepat

```bash
# Build tema
make package/luci-theme-argon-tirtayana/compile V=s

# Cari package hasil build
find bin/packages -name "*argon-tirtayana*"

# Install di router
opkg install /tmp/luci-theme-argon-tirtayana_*.ipk

# Aktifkan tema
uci set luci.main.mediaurlbase=/luci-static/argon-tirtayana
uci commit luci

# Restart web server
/etc/init.d/uhttpd restart

# Cek tema aktif
uci get luci.main.mediaurlbase
```

## Integrasi dengan Build System Tirtayana

Untuk memasukkan tema ini dalam build otomatis Tirtayana:

1. **Edit script build Anda:**
   ```bash
   #!/bin/bash
   cd openwrt
   
   # Update feeds
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   
   # Tambahkan tema ke config
   cat >> .config <<EOF
   CONFIG_PACKAGE_luci=y
   CONFIG_PACKAGE_luci-theme-argon-tirtayana=y
   EOF
   
   make defconfig
   make -j$(nproc) V=s
   ```

2. **Atau gunakan script helper:**
   ```bash
   cd package/luci-theme-argon-tirtayana
   ./enable-theme.sh
   cd ../..
   make -j$(nproc)
   ```

## Best Practices

1. **Selalu backup** konfigurasi sebelum perubahan besar
2. **Test tema** di perangkat development sebelum produksi
3. **Clear cache browser** setelah setiap update tema
4. **Simpan file source** untuk rebuild dengan kustomisasi
5. **Dokumentasikan kustomisasi** untuk referensi masa depan
6. **Gunakan version control** untuk modifikasi tema

## Kredit

- Berdasarkan [LuCI Argon Theme](https://github.com/jerrykuku/luci-theme-argon) oleh jerrykuku
- Palet warna terinspirasi dari tema OpenWrt 2020
- Dikustomisasi untuk Tirtayana oleh Tim Pengembangan Tirtayana

## Lisensi

MIT License

Copyright (c) 2024 Tirtayana

Izin dengan ini diberikan, secara gratis, kepada siapa pun yang mendapatkan salinan
dari perangkat lunak ini dan file dokumentasi terkait ("Perangkat Lunak"), untuk 
berurusan dengan Perangkat Lunak tanpa batasan, termasuk tanpa batasan hak untuk 
menggunakan, menyalin, memodifikasi, menggabungkan, menerbitkan, mendistribusikan, 
mensublisensikan, dan/atau menjual salinan Perangkat Lunak, dan untuk mengizinkan 
orang-orang kepada siapa Perangkat Lunak dilengkapi untuk melakukannya, dengan 
ketentuan sebagai berikut:

Pemberitahuan hak cipta di atas dan pemberitahuan izin ini harus disertakan dalam 
semua salinan atau bagian substansial dari Perangkat Lunak.

PERANGKAT LUNAK INI DISEDIAKAN "SEBAGAIMANA ADANYA", TANPA JAMINAN APA PUN, BAIK 
TERSURAT MAUPUN TERSIRAT, TERMASUK NAMUN TIDAK TERBATAS PADA JAMINAN DAPAT 
DIPERDAGANGKAN, KESESUAIAN UNTUK TUJUAN TERTENTU DAN TIDAK ADA PELANGGARAN.

## Dukungan

Untuk masalah, pertanyaan, atau kontribusi, silakan hubungi tim pengembangan Tirtayana.

## Changelog

### Versi 1.0.0 (Rilis Awal)
- Tema kustom bergaya Argon untuk Tirtayana
- Integrasi palet warna OpenWrt 2020
- Logo dan branding Tirtayana
- Desain responsif untuk perangkat mobile
- UI modern dengan animasi halus
- Kompatibilitas penuh dengan LuCI

---

**Terakhir Diperbarui:** 2024
**Versi:** 1.0.0
**Maintainer:** Tim Pengembangan Tirtayana