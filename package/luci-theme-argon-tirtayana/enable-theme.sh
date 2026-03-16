#!/bin/bash
#
# Enable LuCI Theme Argon Tirtayana in OpenWrt Build
# Copyright (C) 2024 Tirtayana
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENWRT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "=========================================="
echo "  Tirtayana Theme Build Configuration"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "$OPENWRT_ROOT/feeds.conf.default" ]; then
    echo "ERROR: Cannot find OpenWrt root directory!"
    echo "Please run this script from: openwrt/package/luci-theme-argon-tirtayana/"
    exit 1
fi

cd "$OPENWRT_ROOT"

echo "Working directory: $OPENWRT_ROOT"
echo ""

# Backup existing config if it exists
if [ -f .config ]; then
    echo "Backing up existing .config to .config.backup.$(date +%Y%m%d_%H%M%S)"
    cp .config .config.backup.$(date +%Y%m%d_%H%M%S)
fi

# Add theme to config
echo "Adding luci-theme-argon-tirtayana to build configuration..."
echo ""

# Check if already in config
if grep -q "CONFIG_PACKAGE_luci-theme-argon-tirtayana" .config 2>/dev/null; then
    echo "Theme already in configuration. Updating..."
    sed -i '/CONFIG_PACKAGE_luci-theme-argon-tirtayana/d' .config
fi

# Add theme package
cat >> .config <<EOF
#
# Tirtayana Custom Theme
#
CONFIG_PACKAGE_luci-theme-argon-tirtayana=y
EOF

echo "✓ Theme added to configuration"
echo ""

# Run defconfig to validate and expand
echo "Running defconfig to validate configuration..."
make defconfig > /dev/null 2>&1

# Verify it was added
if grep -q "CONFIG_PACKAGE_luci-theme-argon-tirtayana=y" .config; then
    echo "✓ Configuration validated successfully!"
else
    echo "✗ Warning: Theme may not have been added properly"
    echo "  Please check .config manually"
fi

echo ""
echo "=========================================="
echo "  Configuration Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Build only the theme package:"
echo "   make package/luci-theme-argon-tirtayana/compile V=s"
echo ""
echo "2. Or build full firmware:"
echo "   make -j\$(nproc)"
echo ""
echo "3. Find the package in:"
echo "   bin/packages/*/base/luci-theme-argon-tirtayana_*.ipk"
echo ""
echo "4. Install on router:"
echo "   scp bin/packages/*/base/luci-theme-argon-tirtayana_*.ipk root@192.168.1.1:/tmp/"
echo "   ssh root@192.168.1.1 'opkg install /tmp/luci-theme-argon-tirtayana_*.ipk'"
echo ""
echo "=========================================="
