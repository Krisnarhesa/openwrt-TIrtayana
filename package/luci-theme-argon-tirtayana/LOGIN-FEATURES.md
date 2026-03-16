# Login Page Features - Tirtayana Theme

Dokumentasi lengkap tentang fitur-fitur halaman login custom untuk Tirtayana OpenWrt.

## 📋 Daftar Isi

1. [Overview](#overview)
2. [Fitur Utama](#fitur-utama)
3. [Version Information Display](#version-information-display)
4. [Default Password Warning System](#default-password-warning-system)
5. [Design & Responsiveness](#design--responsiveness)
6. [Implementasi Teknis](#implementasi-teknis)
7. [Kustomisasi](#kustomisasi)
8. [Screenshot & Preview](#screenshot--preview)

---

## Overview

Halaman login Tirtayana telah dirancang ulang dengan fitur-fitur modern yang tidak hanya estetis tetapi juga informatif dan meningkatkan keamanan. Halaman ini menampilkan:

- ✅ **Branding Tirtayana** dengan logo custom
- ✅ **Informasi 3 versi Tirtayana** (Minimal, Standard, Edukasi)
- ✅ **Deteksi password default** dengan warning system
- ✅ **Auto-reminder** untuk mengganti password
- ✅ **Responsive design** untuk mobile dan desktop
- ✅ **Informasi sistem** (OpenWrt version, kernel, board)

---

## Fitur Utama

### 1. **Visual Branding**
- Logo Tirtayana animasi (floating effect)
- Gradient background dengan animasi subtle
- Color scheme konsisten dengan tema OpenWrt 2020

### 2. **Version Information Cards**
Menampilkan 3 tipe instalasi Tirtayana:

| Versi | Icon | Deskripsi | Warna Badge |
|-------|------|-----------|-------------|
| **Minimal** | 🔹 | Essential features only | Light Blue |
| **Standard** | ⭐ | Recommended for most users | Gold |
| **Edukasi** | 🎓 | Educational tools included | Green |

**Card yang aktif** (versi yang sedang digunakan) akan:
- Highlighted dengan gradient background
- Scale lebih besar (105%)
- Shadow effect lebih prominent
- Icon berwarna penuh (tidak grayscale)

### 3. **Current Version Badge**
- Menampilkan versi yang sedang digunakan
- Badge dengan warna dinamis sesuai tipe:
  - Minimal: Blue gradient
  - Standard: Gold gradient
  - Edukasi: Green gradient

### 4. **Default Password Warning**
Jika router menggunakan password default (kosong):
- **Alert merah** muncul di halaman login
- Icon peringatan (⚠️)
- Pesan jelas tentang risiko keamanan
- Anjuran untuk segera mengganti password

### 5. **Login Form**
- Username field dengan icon 👤
- Password field dengan icon 🔒
- Auto-focus smart:
  - Fokus ke username jika kosong
  - Fokus ke password jika username sudah terisi
- Button "Login" dengan animasi hover
- Placeholder text yang jelas

### 6. **System Information**
Footer menampilkan informasi sistem:
- 📦 **OpenWrt Version**: Versi firmware yang digunakan
- 💾 **Kernel**: Versi kernel Linux
- 🖥️ **Board**: Tipe hardware/board yang digunakan

---

## Version Information Display

### Cara Kerja Deteksi Versi

Sistem mendeteksi versi Tirtayana dari `boardinfo.release.description`:

```javascript
if (match(desc, /minimal/i)) {
    versionType = "minimal";
} else if (match(desc, /edukasi/i)) {
    versionType = "edukasi";
} else if (match(desc, /standard/i)) {
    versionType = "standard";
}
```

### Konfigurasi Versi di Build

Untuk mengatur versi yang ditampilkan, edit file release description saat build:

```bash
# Contoh: Set versi Edukasi
echo "Tirtayana OpenWrt - Edukasi Edition" > files/etc/openwrt_release_description
```

Atau melalui menuconfig:
```
Global build settings → Version configuration options
  → Release description: "Tirtayana OpenWrt - Standard Edition"
```

### Visual Display

**Desktop View:**
```
┌─────────────┬─────────────┬─────────────┐
│     🔹      │     ⭐      │     🎓      │
│  Minimal    │  Standard   │  Edukasi    │
│ Essential   │ Recommended │ Educational │
│  features   │ for most    │   tools     │
└─────────────┴─────────────┴─────────────┘
```

**Mobile View (Stacked):**
```
┌──────────────────────────────────────┐
│ 🔹  Minimal                          │
│     Essential features only          │
├──────────────────────────────────────┤
│ ⭐  Standard  ← ACTIVE                │
│     Recommended for most users       │
├──────────────────────────────────────┤
│ 🎓  Edukasi                          │
│     Educational tools included       │
└──────────────────────────────────────┘
```

---

## Default Password Warning System

### Level 1: Login Page Warning

Jika password masih default (kosong), alert muncul di halaman login:

```
┌───────────────────────────────────────────┐
│ ⚠️  Default Password Detected!            │
│                                           │
│ For security reasons, please set a new   │
│ password immediately after login.        │
└───────────────────────────────────────────┘
```

**Karakteristik:**
- Background: Light red (#f8d7da)
- Border: Red (#cc1111)
- Icon: Warning emoji
- Pesan jelas dan langsung ke poin

### Level 2: Post-Login Modal Reminder

Setelah login berhasil dengan password default, muncul **modal dialog**:

```
╔═══════════════════════════════════════════╗
║ 🔐  Security Warning                  ✕  ║
╠═══════════════════════════════════════════╣
║                                           ║
║  ⚠️ Default Password Detected             ║
║                                           ║
║  Your router is using the default         ║
║  password!                                ║
║                                           ║
║  For security reasons, it is strongly     ║
║  recommended to set a new password        ║
║  immediately.                             ║
║                                           ║
║  Password Security Tips:                  ║
║  ✓ Use at least 12 characters            ║
║  ✓ Mix uppercase and lowercase letters   ║
║  ✓ Include numbers and symbols           ║
║  ✓ Avoid common words or phrases         ║
║  ✓ Don't reuse passwords                 ║
║                                           ║
║  [🔒 Change Password Now]                 ║
║  [  Remind Me Later   ]                   ║
╚═══════════════════════════════════════════╝
```

**Fitur Modal:**
- Overlay backdrop dengan blur effect
- Cannot be dismissed by clicking outside (must use buttons)
- Escape key untuk menutup
- Animasi smooth fade-in
- Auto-focus ke tombol "Change Password"

### Tombol Actions

**1. Change Password Now** (Primary Button)
- Warna: Red gradient
- Action: Redirect ke `/admin/system/admin`
- Auto-clear reminder flags
- Recommended action

**2. Remind Me Later** (Secondary Button)
- Warna: White dengan border
- Action: Tutup modal untuk sesi ini
- Modal akan muncul lagi di session berikme
- User tetap bisa menggunakan router

### Session Management

**Storage Keys:**
```javascript
sessionStorage.setItem('tirtayana_show_password_reminder', 'true');
sessionStorage.setItem('tirtayana_reminder_dismissed', 'true');
```

**Logic:**
- `tirtayana_show_password_reminder`: Set di login page jika password default
- `tirtayana_reminder_dismissed`: Set ketika user klik "Remind Later"
- Flags di-clear setiap new session (browser close/reopen)

---

## Design & Responsiveness

### Desktop (> 768px)

**Layout:**
- Container: 480px max-width
- Padding: 40px
- Logo: 100x100px
- Version cards: 3 columns grid
- Form fields: Full width dengan padding generous

**Animations:**
- Logo floating (3s infinite)
- Background gradient shift (15s infinite)
- Card hover lift effect
- Button hover scale & glow

### Tablet (768px - 480px)

**Adjustments:**
- Container: 420px max-width
- Padding: 30px
- Logo: 80x80px
- Version cards tetap 3 columns, gap lebih kecil
- Font sizes sedikit lebih kecil

### Mobile (< 480px)

**Major Changes:**
- **Version cards: 1 column** (stacked vertically)
- Card layout berubah ke **horizontal** (icon di kiri, text di kanan)
- Logo: 70x70px
- Padding: 20px
- Input font-size: 16px (prevent iOS zoom)
- Touch targets minimum 44px
- Full-width buttons

**Mobile-specific Features:**
```css
.version-card {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 15px;
  text-align: left;
}
```

### Accessibility

**Keyboard Navigation:**
- Tab order logis
- Focus indicators jelas
- Escape untuk close modal

**Screen Readers:**
- Aria labels pada buttons
- Alt text pada images
- Semantic HTML structure

**High Contrast Mode:**
- Border width increased
- Better color differentiation

**Reduced Motion:**
- Animations disabled
- Instant transitions

---

## Implementasi Teknis

### File Structure

```
ucode/template/themes/argon-tirtayana/
├── sysauth.ut           # Login page template
├── header.ut            # Includes password-reminder.js
└── footer.ut

htdocs/luci-static/argon-tirtayana/
├── login.css            # Login page styles
└── password-reminder.js # Modal & reminder logic
```

### Template (sysauth.ut)

**Key Components:**

1. **Version Detection:**
```javascript
let tirtayanaVersion = "Unknown";
let versionType = "standard";

if (boardinfo.release?.description) {
    const desc = boardinfo.release.description;
    if (match(desc, /minimal/i)) {
        tirtayanaVersion = "Minimal";
        versionType = "minimal";
    }
    // ... dst
}
```

2. **Password Check:**
```javascript
const hasDefaultPassword = (getuid() == 0 && getspnam('root')?.pwdp === '');
```

3. **Session Flag:**
```javascript
{% if (hasDefaultPassword): %}
window.addEventListener('load', function() {
    sessionStorage.setItem('tirtayana_show_password_reminder', 'true');
});
{% endif %}
```

### JavaScript (password-reminder.js)

**Main Functions:**

```javascript
PasswordReminder = {
    init()              // Initialize system
    shouldShowReminder() // Check if should show
    createModal()       // Create modal HTML
    showModal()         // Display modal
    hideModal()         // Hide modal
    navigateToPasswordChange() // Redirect to admin
    attachEventListeners() // Setup buttons
}
```

**Auto-initialization:**
```javascript
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        PasswordReminder.init();
    });
}
```

---

## Kustomisasi

### 1. Mengubah Teks Versi

Edit `sysauth.ut`:

```html
<div class="version-card">
    <div class="version-icon">🔹</div>
    <div class="version-name">Minimal</div>
    <div class="version-desc">Essential features only</div>
</div>
```

Ganti `version-name` dan `version-desc` sesuai kebutuhan.

### 2. Menambah Versi Keempat

**Langkah 1:** Edit CSS grid di `login.css`:
```css
.version-info-cards {
    grid-template-columns: repeat(4, 1fr); /* 3 → 4 */
}
```

**Langkah 2:** Tambah card di `sysauth.ut`:
```html
<div class="version-card {{ versionType == 'premium' ? 'active' : '' }}">
    <div class="version-icon">💎</div>
    <div class="version-name">Premium</div>
    <div class="version-desc">Advanced features</div>
</div>
```

**Langkah 3:** Update detection logic:
```javascript
} else if (match(desc, /premium/i)) {
    tirtayanaVersion = "Premium";
    versionType = "premium";
}
```

### 3. Mengubah Warna Badge

Edit `login.css`:

```css
.badge-value.minimal {
    background: linear-gradient(135deg, #your-color 0%, #your-color-dark 100%);
}
```

### 4. Menonaktifkan Password Reminder

Edit `header.ut`, hapus atau comment line:
```html
<!-- <script src="{{ media }}/password-reminder.js"></script> -->
```

### 5. Mengubah Password Change URL

Edit `password-reminder.js`:
```javascript
config: {
    passwordChangeUrl: '/your/custom/url'
}
```

---

## Screenshot & Preview

### Desktop View

```
┌─────────────────────────────────────────────────┐
│                                                 │
│                   [LOGO TIRTAYANA]              │
│                  Tirtayana OpenWrt              │
│                     Router Name                 │
│                                                 │
│  ┌────────┐  ┌────────┐  ┌────────┐            │
│  │   🔹   │  │   ⭐   │  │   🎓   │            │
│  │Minimal │  │Standard│  │Edukasi │            │
│  │Essential  │Recommend │Educational            │
│  └────────┘  └────────┘  └────────┘            │
│                                                 │
│        Current Version: [Standard]              │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 👤 Username                             │   │
│  │ [root_________________________]         │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🔒 Password                             │   │
│  │ [••••••••••••••____________]            │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│      [        Login →        ]                  │
│                                                 │
│  ─────────────────────────────────────────     │
│                                                 │
│  📦 OpenWrt: 23.05.2                            │
│  💾 Kernel: 5.15.137                            │
│  🖥️ Board: NanoPi R5S                           │
│                                                 │
│     © 2024 Tirtayana | Powered by OpenWrt      │
└─────────────────────────────────────────────────┘
```

### Mobile View

```
┌─────────────────────┐
│                     │
│   [LOGO]            │
│   Tirtayana         │
│   Router            │
│                     │
│ ┌─────────────────┐ │
│ │🔹  Minimal      │ │
│ │   Essential     │ │
│ └─────────────────┘ │
│ ┌─────────────────┐ │
│ │⭐  Standard    │ │
│ │   Recommended  │ │
│ └─────────────────┘ │
│ ┌─────────────────┐ │
│ │🎓  Edukasi     │ │
│ │   Educational  │ │
│ └─────────────────┘ │
│                     │
│ Version: Standard   │
│                     │
│ 👤 Username         │
│ [_______________]   │
│                     │
│ 🔒 Password         │
│ [_______________]   │
│                     │
│ [  Login →  ]       │
│                     │
│ ───────────────     │
│ 📦 OpenWrt 23.05    │
│ 💾 Kernel 5.15      │
│ 🖥️ NanoPi R5S       │
│                     │
│ © 2024 Tirtayana    │
└─────────────────────┘
```

---

## Browser Compatibility

| Browser | Version | Status |
|---------|---------|--------|
| Chrome  | 60+     | ✅ Full Support |
| Firefox | 60+     | ✅ Full Support |
| Safari  | 12+     | ✅ Full Support |
| Edge    | 79+     | ✅ Full Support |
| iOS Safari | 12+ | ✅ Full Support |
| Chrome Mobile | 60+ | ✅ Full Support |

---

## Security Considerations

### 1. **Password Detection**
- Menggunakan `getspnam()` untuk check password hash
- Hanya check user `root`
- Tidak expose password hash ke client

### 2. **Session Storage**
- Flags disimpan di `sessionStorage` (not `localStorage`)
- Auto-clear saat browser close
- Tidak ada sensitive data stored

### 3. **HTTPS Recommendation**
- Halaman login harus diakses via HTTPS
- Prevent man-in-the-middle attacks
- Enkripsi credentials saat transit

### 4. **Brute Force Protection**
- Kombinasikan dengan fail2ban
- Rate limiting di server side
- Consider CAPTCHA untuk multiple failures

---

## Testing Checklist

### Functionality
- [ ] Version detection bekerja (Minimal/Standard/Edukasi)
- [ ] Active version card ter-highlight
- [ ] Default password warning muncul
- [ ] Post-login modal muncul
- [ ] "Change Password Now" redirect ke admin page
- [ ] "Remind Me Later" menutup modal
- [ ] Modal bisa ditutup dengan Escape key
- [ ] Auto-focus bekerja (username → password)

### Visual
- [ ] Logo tampil dan animasi floating
- [ ] Background gradient animasi smooth
- [ ] Version cards hover effect
- [ ] Button hover animations
- [ ] Modal backdrop blur
- [ ] Icons tampil correctly (emoji support)

### Responsive
- [ ] Desktop (1920x1080) ✓
- [ ] Laptop (1366x768) ✓
- [ ] Tablet Portrait (768x1024) ✓
- [ ] Tablet Landscape (1024x768) ✓
- [ ] Mobile Portrait (375x667) ✓
- [ ] Mobile Landscape (667x375) ✓
- [ ] Small Mobile (360x640) ✓

### Accessibility
- [ ] Keyboard navigation
- [ ] Tab order logis
- [ ] Focus indicators visible
- [ ] Screen reader compatible
- [ ] High contrast mode
- [ ] Reduced motion respect

### Browsers
- [ ] Chrome/Chromium
- [ ] Firefox
- [ ] Safari
- [ ] Edge
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

---

## Troubleshooting

### Modal Tidak Muncul

**Penyebab:**
- JavaScript tidak ter-load
- Session storage tidak support
- Browser compatibility issue

**Solusi:**
```bash
# Check browser console untuk errors
# Pastikan password-reminder.js ter-load
ls -la /www/luci-static/argon-tirtayana/password-reminder.js

# Test di browser console:
sessionStorage.setItem('tirtayana_show_password_reminder', 'true');
```

### Version Tidak Terdeteksi

**Penyebab:**
- Release description tidak match pattern
- Boardinfo tidak tersedia

**Solusi:**
```bash
# Check release description
cat /etc/openwrt_release

# Pastikan ada keyword: minimal, standard, atau edukasi
# Edit jika perlu:
vi /etc/openwrt_release
# Tambahkan: DISTRIB_DESCRIPTION="Tirtayana OpenWrt - Standard Edition"
```

### Styling Broken di Mobile

**Penyebab:**
- CSS tidak ter-load
- Cache lama

**Solusi:**
```bash
# Clear browser cache
# Hard refresh: Ctrl+Shift+R

# Check CSS file
ls -la /www/luci-static/argon-tirtayana/login.css

# Check permissions
chmod 644 /www/luci-static/argon-tirtayana/*.css
```

---

## Changelog

### Version 1.0.0 (Initial Release)
- ✨ Custom login page dengan Tirtayana branding
- ✨ Version information display (3 tipe)
- ✨ Default password warning system
- ✨ Post-login modal reminder
- ✨ Fully responsive design
- ✨ Accessibility enhancements
- ✨ System information display
- ✨ Modern animations dan transitions

---

## Future Enhancements

### Planned Features
- [ ] Multi-language support (ID/EN toggle)
- [ ] Dark mode untuk login page
- [ ] QR code untuk mobile app login
- [ ] Two-factor authentication support
- [ ] Login attempt counter dengan lockout
- [ ] Custom background image upload
- [ ] Remember me checkbox
- [ ] Forgot password recovery
- [ ] User avatar/profile picture

### Community Requests
- Integrasi dengan LDAP/Active Directory
- Social login (Google, Facebook)
- Biometric authentication (fingerprint)
- Security audit log viewer
- Real-time connection status

---

## Credits & License

**Developed by:** Tirtayana Development Team
**License:** MIT
**Version:** 1.0.0
**Last Updated:** 2024

**Based on:**
- LuCI Bootstrap Theme
- OpenWrt 2020 Color Palette
- Modern UI/UX Best Practices

---

## Support & Contact

Untuk pertanyaan, bug reports, atau feature requests:
- **Email:** support@tirtayana.id (contoh)
- **Documentation:** README-ID.md
- **Installation Guide:** INSTALL.md

**Selamat menggunakan Tirtayana OpenWrt!** 🚀