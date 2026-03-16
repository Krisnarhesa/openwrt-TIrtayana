# 🚀 Quick Start - Tema Tirtayana dengan Fitur Login Custom

Panduan cepat untuk menggunakan tema Tirtayana dengan halaman login informatif.

## 📦 Apa yang Baru?

### Halaman Login Custom dengan:
✅ **3 Versi Tirtayana** ditampilkan (Minimal, Standard, Edukasi)
✅ **Deteksi versi otomatis** dari release description
✅ **Warning password default** di halaman login
✅ **Modal reminder** setelah login untuk ganti password
✅ **Info sistem lengkap** (OpenWrt version, kernel, board)
✅ **Design responsif** untuk mobile dan desktop
✅ **Animasi modern** dan smooth transitions

---

## 🎯 Instalasi Super Cepat

```bash
# 1. Masuk ke direktori tema
cd openwrt/package/luci-theme-argon-tirtayana

# 2. Aktifkan tema (otomatis)
./enable-theme.sh

# 3. Kembali ke root openwrt
cd ../..

# 4. Build package
make package/luci-theme-argon-tirtayana/compile V=s

# 5. Install ke router
scp bin/packages/*/base/luci-theme-argon-tirtayana*.ipk root@192.168.1.1:/tmp/
ssh root@192.168.1.1 'opkg install /tmp/luci-theme-argon-tirtayana*.ipk'

# SELESAI! Tema otomatis aktif
```

---

## 🎨 Set Versi Tirtayana

### Pilihan 1: Via menuconfig (Recommended)

```bash
make menuconfig
# Navigasi ke:
# Global build settings
#   → Version configuration options
#     → Release description

# Isi salah satu:
# - "Tirtayana OpenWrt - Minimal Edition"
# - "Tirtayana OpenWrt - Standard Edition"  
# - "Tirtayana OpenWrt - Edukasi Edition"
```

### Pilihan 2: Via Command Line

**Untuk Minimal:**
```bash
mkdir -p files/etc
echo "DISTRIB_DESCRIPTION='Tirtayana OpenWrt - Minimal Edition'" >> files/etc/openwrt_release
```

**Untuk Standard:**
```bash
mkdir -p files/etc
echo "DISTRIB_DESCRIPTION='Tirtayana OpenWrt - Standard Edition'" >> files/etc/openwrt_release
```

**Untuk Edukasi:**
```bash
mkdir -p files/etc
echo "DISTRIB_DESCRIPTION='Tirtayana OpenWrt - Edukasi Edition'" >> files/etc/openwrt_release
```

---

## 📱 Preview Halaman Login

### Desktop View
```
┌─────────────────────────────────────────┐
│          🌊 [LOGO TIRTAYANA]            │
│         Tirtayana OpenWrt               │
│            Router-Anda                  │
│                                         │
│  ┌──────┐  ┌──────┐  ┌──────┐         │
│  │ 🔹   │  │ ⭐   │  │ 🎓   │         │
│  │Minimal  │Standard│Edukasi│         │
│  └──────┘  └──────┘  └──────┘         │
│                                         │
│    Current Version: [Standard]          │
│                                         │
│  👤 Username: [root________]            │
│  🔒 Password: [••••••••____]            │
│                                         │
│       [    Login  →    ]                │
│                                         │
│  📦 OpenWrt 23.05.2                     │
│  💾 Kernel 5.15.137                     │
│  🖥️  NanoPi R5S                         │
│                                         │
│  © 2024 Tirtayana                       │
└─────────────────────────────────────────┘
```

### Mobile View  
```
┌──────────────────┐
│   [LOGO]         │
│  Tirtayana       │
│   Router         │
│                  │
│ 🔹 Minimal       │
│ ⭐ Standard ✓   │
│ 🎓 Edukasi       │
│                  │
│ Version:         │
│ [Standard]       │
│                  │
│ 👤 Username      │
│ [___________]    │
│                  │
│ 🔒 Password      │
│ [___________]    │
│                  │
│ [ Login → ]      │
│                  │
│ 📦 OpenWrt       │
│ 💾 Kernel        │
│ 🖥️  Board        │
└──────────────────┘
```

---

## 🔒 Fitur Keamanan Password

### Warning di Halaman Login
Jika password masih default (kosong):
```
┌──────────────────────────────────────┐
│ ⚠️  Default Password Detected!       │
│                                      │
│ For security reasons, please set    │
│ a new password immediately.          │
└──────────────────────────────────────┘
```

### Modal Setelah Login
Otomatis muncul reminder dengan:
- ✅ Tips keamanan password
- ✅ Tombol "Change Password Now" (direct link)
- ✅ Tombol "Remind Me Later"
- ✅ Tidak mengganggu, bisa ditutup dengan Escape

---

## 🎨 Kustomisasi Cepat

### 1. Ganti Logo
```bash
cp logo-anda.svg \
   package/luci-theme-argon-tirtayana/htdocs/luci-static/argon-tirtayana/logo.svg
```

### 2. Ubah Warna
Edit file:
```
package/luci-theme-argon-tirtayana/htdocs/luci-static/argon-tirtayana/cascade.css
```

Cari bagian `:root` dan ubah:
```css
--primary-color: #0b0b0b;    /* Warna header */
--secondary-color: #8a6800;  /* Warna tombol */
--accent-color: #cc8800;     /* Warna highlight */
```

### 3. Ubah Teks Versi
Edit file:
```
package/luci-theme-argon-tirtayana/ucode/template/themes/argon-tirtayana/sysauth.ut
```

Cari bagian version cards dan edit sesuai kebutuhan.

---

## 📚 Dokumentasi Lengkap

| File | Deskripsi |
|------|-----------|
| `README-ID.md` | Overview lengkap (Bahasa Indonesia) |
| `INSTALL.md` | Panduan instalasi detail |
| `LOGIN-FEATURES.md` | Dokumentasi fitur login custom |
| `COLOR-PALETTE.html` | Visual preview warna (buka di browser) |
| `CHECKLIST.md` | Checklist build & testing |

---

## 🐛 Troubleshooting Cepat

### Modal Tidak Muncul
```bash
# Check JavaScript loaded
ls /www/luci-static/argon-tirtayana/password-reminder.js

# Test di browser console
sessionStorage.setItem('tirtayana_show_password_reminder', 'true');
```

### Versi Tidak Terdeteksi
```bash
# Check release description
cat /etc/openwrt_release | grep DESCRIPTION

# Harus ada kata: minimal, standard, atau edukasi
```

### CSS Tidak Load
```bash
# Check file ada
ls /www/luci-static/argon-tirtayana/login.css

# Fix permissions
chmod 644 /www/luci-static/argon-tirtayana/*.css

# Restart uhttpd
/etc/init.d/uhttpd restart

# Hard refresh browser: Ctrl+Shift+R
```

---

## ✅ Checklist Setelah Install

- [ ] Buka halaman login di browser
- [ ] Verifikasi 3 versi cards tampil
- [ ] Cek versi yang aktif ter-highlight
- [ ] Test di mobile (resize browser)
- [ ] Test login dengan password default → modal muncul
- [ ] Test tombol "Change Password Now"
- [ ] Verifikasi animasi smooth
- [ ] Check logo tampil correctly

---

## 🎯 Tips & Tricks

### Set Password Baru (Recommended)
```bash
# Via SSH
ssh root@192.168.1.1
passwd
# Masukkan password baru

# Atau via LuCI:
# System → Administration → Router Password
```

### Backup Config
```bash
# Backup tema custom
tar -czf tirtayana-theme-backup.tar.gz \
  package/luci-theme-argon-tirtayana/

# Backup .config
cp .config config.backup
```

### Multi-Version Build
```bash
# Build 3 versi sekaligus
for ver in minimal standard edukasi; do
  echo "DISTRIB_DESCRIPTION='Tirtayana OpenWrt - ${ver^} Edition'" \
    > files/etc/openwrt_release
  make -j$(nproc)
  mv bin/targets bin/targets-$ver
done
```

---

## 🚀 Next Steps

1. **Customize Logo**: Ganti dengan logo asli Tirtayana
2. **Set Version**: Pilih Minimal/Standard/Edukasi
3. **Test Mobile**: Coba di smartphone real
4. **Set Strong Password**: Ganti password default
5. **Deploy**: Flash ke router produksi

---

## 📞 Support

**Dokumentasi:**
- README-ID.md - Overview
- LOGIN-FEATURES.md - Fitur login detail
- INSTALL.md - Instalasi lengkap

**Contact:**
- Team: Tirtayana Development Team
- Version: 1.0.0
- License: MIT

---

**Selamat Menggunakan! 🎉**

Tema Tirtayana sudah siap dengan halaman login yang informatif dan aman!
