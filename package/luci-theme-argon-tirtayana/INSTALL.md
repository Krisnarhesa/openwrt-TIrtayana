# Installation Guide - LuCI Theme Argon Tirtayana

Complete installation and configuration guide for the Tirtayana custom LuCI theme.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Installation](#quick-installation)
3. [Detailed Build Instructions](#detailed-build-instructions)
4. [Activation](#activation)
5. [Customization](#customization)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- OpenWrt buildroot properly configured
- LuCI packages feed installed
- Basic understanding of OpenWrt build system

### Verify Prerequisites

```bash
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
```

---

## Quick Installation

### Option 1: Include in Full Build

1. **Add theme to build configuration:**
   ```bash
   cd openwrt
   make menuconfig
   ```

2. **Navigate to theme selection:**
   ```
   LuCI → Themes → <*> luci-theme-argon-tirtayana
   ```

3. **Save and exit** (press ESC twice, then Y to save)

4. **Build everything:**
   ```bash
   make -j$(nproc)
   ```

### Option 2: Build Theme Package Only

```bash
cd openwrt
make package/luci-theme-argon-tirtayana/compile V=s
```

The compiled package will be in:
```
bin/packages/<architecture>/base/luci-theme-argon-tirtayana_*.ipk
```

---

## Detailed Build Instructions

### Step 1: Add to Build Configuration

Open menuconfig:
```bash
cd openwrt
make menuconfig
```

Select the theme:
```
LuCI --->
    Themes --->
        <*> luci-theme-argon-tirtayana ................................. Custom Argon Theme for Tirtayana
```

**Note:** Use spacebar to toggle selection:
- `< >` = Not selected
- `<M>` = Build as module (separate package)
- `<*>` = Include in firmware

We recommend `<*>` to include it directly in the firmware.

### Step 2: Build the Package

#### Build Only the Theme Package
```bash
make package/luci-theme-argon-tirtayana/compile V=s
```

#### Build with Full Firmware
```bash
make -j$(nproc) V=s
```

### Step 3: Locate Built Package

Find the package:
```bash
find bin/packages -name "luci-theme-argon-tirtayana*.ipk"
```

Example output:
```
bin/packages/aarch64_cortex-a53/base/luci-theme-argon-tirtayana_1.0.0-1_all.ipk
```

---

## Installation on Router

### Method 1: Pre-installed in Firmware

If you selected `<*>` in menuconfig and built full firmware, the theme is already included. Skip to [Activation](#activation).

### Method 2: Manual Package Installation

#### Upload to Router
```bash
scp bin/packages/*/base/luci-theme-argon-tirtayana_*.ipk root@192.168.1.1:/tmp/
```

#### Install via SSH
```bash
ssh root@192.168.1.1
cd /tmp
opkg update
opkg install luci-theme-argon-tirtayana_*.ipk
```

#### Install via LuCI Web Interface
1. Go to **System → Software**
2. Click **Upload Package...**
3. Select the `.ipk` file
4. Click **Install**

---

## Activation

The theme is automatically activated upon installation. To manually verify or change:

### Via Web Interface

1. **Login to LuCI** (http://192.168.1.1)
2. Navigate to **System → System**
3. Click on **Language and Style** tab
4. Under **Design**, select **Argon Tirtayana**
5. Click **Save & Apply**
6. **Refresh the page** (Ctrl+F5 to clear cache)

### Via SSH/CLI

```bash
uci set luci.main.mediaurlbase=/luci-static/argon-tirtayana
uci commit luci
/etc/init.d/uhttpd restart
```

Verify the setting:
```bash
uci get luci.main.mediaurlbase
```

Expected output:
```
/luci-static/argon-tirtayana
```

---

## Customization

### Custom Logo

1. **Prepare your logo:**
   - Format: SVG (recommended) or PNG
   - Size: 200x200 pixels
   - Name it `logo.svg` or `logo.png`

2. **Replace logo in package before building:**
   ```bash
   cp /path/to/your/logo.svg \
      openwrt/package/luci-theme-argon-tirtayana/htdocs/luci-static/argon-tirtayana/
   ```

3. **Rebuild the package:**
   ```bash
   make package/luci-theme-argon-tirtayana/compile V=s
   ```

### Custom Colors

Edit the CSS file before building:
```bash
nano openwrt/package/luci-theme-argon-tirtayana/htdocs/luci-static/argon-tirtayana/cascade.css
```

Modify the `:root` variables section:
```css
:root {
  --primary-color: #YOUR_COLOR;
  --secondary-color: #YOUR_COLOR;
  --accent-color: #YOUR_COLOR;
  /* ... etc */
}
```

Then rebuild and reinstall.

### Live Customization (Advanced)

For testing colors without rebuilding:

1. **SSH into router:**
   ```bash
   ssh root@192.168.1.1
   ```

2. **Edit CSS directly:**
   ```bash
   vi /www/luci-static/argon-tirtayana/cascade.css
   ```

3. **Clear browser cache** and reload

**Warning:** Changes will be lost on firmware upgrade!

---

## Integration with Tirtayana Build System

### Add to Default Package Selection

Edit your `.config` or `diffconfig`:
```bash
cd openwrt
echo "CONFIG_PACKAGE_luci-theme-argon-tirtayana=y" >> .config
make defconfig
```

### Include in Image Builder

For custom firmware builds:
```bash
make image PROFILE=your_profile \
  PACKAGES="luci luci-theme-argon-tirtayana ..."
```

### Automated Build Script

Add to your build script:
```bash
#!/bin/bash
cd openwrt

# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a

# Configure
cat >> .config <<EOF
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-theme-argon-tirtayana=y
EOF

make defconfig

# Build
make -j$(nproc) V=s
```

---

## Troubleshooting

### Theme Not Showing in Selection

**Problem:** Theme doesn't appear in Design dropdown

**Solutions:**
1. Verify installation:
   ```bash
   opkg list-installed | grep argon-tirtayana
   ```

2. Check theme files exist:
   ```bash
   ls -la /www/luci-static/argon-tirtayana/
   ```

3. Restart uhttpd:
   ```bash
   /etc/init.d/uhttpd restart
   ```

4. Clear browser cache (Ctrl+Shift+Del)

### Theme Files Not Found (404 Error)

**Problem:** CSS/logo returns 404

**Solution:**
```bash
# Check file permissions
chmod -R 755 /www/luci-static/argon-tirtayana/

# Verify files are present
ls -la /www/luci-static/argon-tirtayana/
```

### Logo Not Displaying

**Problem:** Logo doesn't show in header

**Solutions:**
1. Check logo exists:
   ```bash
   ls -la /www/luci-static/argon-tirtayana/logo.svg
   ```

2. Verify CSS references correct file:
   ```bash
   grep "logo.svg" /www/luci-static/argon-tirtayana/cascade.css
   ```

3. Test logo directly in browser:
   ```
   http://192.168.1.1/luci-static/argon-tirtayana/logo.svg
   ```

### Build Errors

**Problem:** Compilation fails

**Solution 1 - Clean and rebuild:**
```bash
make package/luci-theme-argon-tirtayana/clean
make package/luci-theme-argon-tirtayana/compile V=s
```

**Solution 2 - Check dependencies:**
```bash
./scripts/feeds install luci-base
make menuconfig  # Ensure LuCI → Collections → luci is selected
```

**Solution 3 - Verify package structure:**
```bash
cd package/luci-theme-argon-tirtayana
ls -la
# Should contain: Makefile, htdocs/, ucode/, README.md
```

### Theme Partially Applied

**Problem:** Some elements use old theme

**Solutions:**
1. Hard refresh browser: **Ctrl + Shift + R** (or Cmd + Shift + R on Mac)

2. Clear browser data:
   - Chrome: Settings → Privacy → Clear browsing data
   - Firefox: Settings → Privacy → Clear Data
   - Select "Cached images and files"

3. Force CSS reload:
   ```bash
   # Add version parameter to CSS in header.ut
   # This forces browser to reload
   ```

### Reverting to Default Theme

If something goes wrong:

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

---

## Updating the Theme

### Update Package on Router

```bash
# Upload new package
scp new-package.ipk root@192.168.1.1:/tmp/

# SSH to router
ssh root@192.168.1.1

# Remove old, install new
opkg remove luci-theme-argon-tirtayana
opkg install /tmp/luci-theme-argon-tirtayana_*.ipk

# Clear cache and restart
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

### Rebuild from Source

```bash
cd openwrt
make package/luci-theme-argon-tirtayana/clean
make package/luci-theme-argon-tirtayana/compile V=s
```

---

## Uninstallation

### Remove Package

```bash
opkg remove luci-theme-argon-tirtayana
```

### Revert to Default Theme

```bash
uci set luci.main.mediaurlbase=/luci-static/bootstrap
uci delete luci.themes.ArgonTirtayana
uci commit luci
/etc/init.d/uhttpd restart
```

---

## Advanced Configuration

### Set as Default for New Installations

In package's Makefile, the `postinst` script automatically sets the theme as default. If you want to change this behavior, edit:

```makefile
define Package/luci-theme-argon-tirtayana/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
    # Remove these lines to NOT auto-activate:
    # uci -q set luci.main.mediaurlbase=/luci-static/argon-tirtayana
    # uci commit luci
}
exit 0
endef
```

### Multi-Theme Support

Keep multiple themes installed:
```bash
opkg install luci-theme-bootstrap
opkg install luci-theme-material
opkg install luci-theme-argon-tirtayana
```

Switch between them in System → System → Language and Style.

---

## Best Practices

1. **Always backup** your configuration before major theme changes
2. **Test theme** on development device before production
3. **Clear browser cache** after every theme update
4. **Keep source files** for rebuilding with customizations
5. **Document customizations** for future reference
6. **Version control** your theme modifications

---

## Support & Resources

- **Package Location:** `openwrt/package/luci-theme-argon-tirtayana/`
- **Documentation:** See `README.md` in package directory
- **Build Logs:** Check `openwrt/logs/` for compilation errors
- **LuCI Documentation:** https://openwrt.org/docs/guide-developer/luci

---

## Quick Reference Commands

```bash
# Build theme
make package/luci-theme-argon-tirtayana/compile V=s

# Find package
find bin/packages -name "*argon-tirtayana*"

# Install on router
opkg install /tmp/luci-theme-argon-tirtayana_*.ipk

# Activate theme
uci set luci.main.mediaurlbase=/luci-static/argon-tirtayana
uci commit luci

# Restart web server
/etc/init.d/uhttpd restart

# Check active theme
uci get luci.main.mediaurlbase
```

---

**Last Updated:** 2024
**Version:** 1.0.0
**Maintainer:** Tirtayana Development Team