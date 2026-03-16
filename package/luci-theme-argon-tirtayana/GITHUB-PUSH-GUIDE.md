# 🚀 Quick Guide: Push ke GitHub

## 1️⃣ Buat Repo di GitHub
1. Login → https://github.com/new
2. Nama: `luci-theme-argon-tirtayana`
3. Public/Private: Pilih
4. ❌ JANGAN centang "Add README" (sudah ada)
5. License: MIT
6. Create!

## 2️⃣ Push dari Local

```bash
cd /path/to/openwrt/package/luci-theme-argon-tirtayana

# Init git
git init
git add .
git commit -m "feat: Initial commit - Tirtayana theme v1.0.0"

# Connect ke GitHub (GANTI YOUR_USERNAME!)
git remote add origin https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git

# Push
git branch -M main
git push -u origin main

# Create release tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## 3️⃣ User Lain Bisa Clone

```bash
cd openwrt/package
git clone https://github.com/YOUR_USERNAME/luci-theme-argon-tirtayana.git
```

Done! ✅
