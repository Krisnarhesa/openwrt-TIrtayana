# SPDX-License-Identifier: MIT
#
# Copyright (C) 2024 Tirtayana
# Custom Argon Theme for Tirtayana OpenWrt
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Argon Tirtayana - Custom LuCI Theme
LUCI_DEPENDS:=+luci-base +luci-theme-argon +luci-app-argon-config

PKG_NAME:=luci-theme-argon-tirtayana
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Tirtayana
PKG_LICENSE:=MIT

define Package/luci-theme-argon-tirtayana/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	uci -q get luci.themes.ArgonTirtayana > /dev/null 2>&1 || {
		uci -q set luci.themes.ArgonTirtayana=/luci-static/argon-tirtayana
		uci commit luci
	}
	uci -q set luci.main.mediaurlbase=/luci-static/argon-tirtayana
	uci commit luci
}
exit 0
endef

define Package/luci-theme-argon-tirtayana/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	uci -q delete luci.themes.ArgonTirtayana
	uci -q set luci.main.mediaurlbase=/luci-static/bootstrap
	uci commit luci
}
exit 0
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-theme-argon-tirtayana/install
	# 1. Copy the full upstream argon theme as base
	$(INSTALL_DIR) $(1)/www/luci-static/argon-tirtayana
	$(CP) $(STAGING_DIR_ROOT)/usr/share/luci/www/luci-static/argon/* \
		$(1)/www/luci-static/argon-tirtayana/ 2>/dev/null || true
	# Fallback: copy from source package directory if staging isn't populated yet
	$(CP) $(BUILD_DIR)/luci-theme-argon*/htdocs/luci-static/argon/* \
		$(1)/www/luci-static/argon-tirtayana/ 2>/dev/null || true

	# 2. Overlay tirtayana-specific custom files on top
	$(CP) ./htdocs/luci-static/argon-tirtayana/* \
		$(1)/www/luci-static/argon-tirtayana/

	# 3. Install ucode view templates
	$(INSTALL_DIR) $(1)/usr/share/ucode/luci/template/themes/argon-tirtayana
	$(CP) ./ucode/template/themes/argon-tirtayana/* \
		$(1)/usr/share/ucode/luci/template/themes/argon-tirtayana/ 2>/dev/null || true
endef

include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call BuildPackage,luci-theme-argon-tirtayana))
