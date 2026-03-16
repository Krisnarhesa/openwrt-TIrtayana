# SPDX-License-Identifier: MIT
#
# Copyright (C) 2024 Tirtayana
# Custom Argon Theme for Tirtayana OpenWrt
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Argon Tirtayana - Custom LuCI Theme
LUCI_DEPENDS:=+luci-base

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
	$(INSTALL_DIR) $(1)/www/luci-static/argon-tirtayana
	$(CP) ./htdocs/luci-static/argon-tirtayana/* $(1)/www/luci-static/argon-tirtayana/
	$(INSTALL_DIR) $(1)/usr/share/ucode/luci/template/themes/argon-tirtayana
	$(CP) ./ucode/template/themes/argon-tirtayana/* $(1)/usr/share/ucode/luci/template/themes/argon-tirtayana/ 2>/dev/null || true
endef

include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call BuildPackage,luci-theme-argon-tirtayana))
