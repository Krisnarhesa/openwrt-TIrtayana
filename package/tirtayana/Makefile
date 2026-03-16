# SPDX-License-Identifier: GPL-2.0-only
#
# TIrtayana Custom Firmware Package
# Teknologi Informasi - Universitas Udayana
# Provides: custom branding, system config, and first-boot setup
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tirtayana-custom-firmware
PKG_VERSION:=2.0
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/tirtayana-custom-firmware
  SECTION:=custom
  CATEGORY:=TIrtayana
  TITLE:=TIrtayana Custom Firmware Branding
  DEPENDS:=+luci-base +luci-theme-argon
  PKGARCH:=all
endef

define Package/tirtayana-custom-firmware/description
  Custom branding dan konfigurasi awal untuk TIrtayana Firmware:
  - Custom ASCII banner saat login SSH
  - Custom release info (/etc/openwrt_release)
  - Set Argon sebagai default LuCI theme
  - Konfigurasi hostname, timezone (WITA)
  - Optimasi sysctl untuk STB B860H (S905X)
  - Pesan selamat datang di LuCI
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/tirtayana-custom-firmware/install
	# ── /etc ────────────────────────────────────────────────
	$(INSTALL_DIR) $(1)/etc

	# Banner SSH login
	$(INSTALL_DATA) $(CURDIR)/files/banner       $(1)/etc/banner 2>/dev/null || true

	# Release & version info
	$(INSTALL_DATA) $(CURDIR)/files/openwrt_release   $(1)/etc/openwrt_release 2>/dev/null || true
	$(INSTALL_DATA) $(CURDIR)/files/openwrt_version   $(1)/etc/openwrt_version 2>/dev/null || true

	# ── /etc/config ─────────────────────────────────────────
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) $(CURDIR)/files/luci_config   $(1)/etc/config/luci   2>/dev/null || true
	$(INSTALL_DATA) $(CURDIR)/files/argon_config  $(1)/etc/config/argon  2>/dev/null || true
	$(INSTALL_DATA) $(CURDIR)/files/system_config $(1)/etc/config/system 2>/dev/null || true

	# ── /etc/uci-defaults ───────────────────────────────────
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(CURDIR)/files/uci-defaults/10-tirtayana-init \
	               $(1)/etc/uci-defaults/10-tirtayana-init 2>/dev/null || true
endef

$(eval $(call BuildPackage,tirtayana-custom-firmware))
