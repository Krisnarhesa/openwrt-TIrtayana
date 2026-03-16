# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 jerrykuku <jerrykuku@gmail.com>
# Packaged for TIrtayana OpenWrt build
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-theme-argon
PKG_VERSION:=2.3.1
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jerrykuku/luci-theme-argon.git
PKG_SOURCE_DATE:=2024-03-01
PKG_SOURCE_VERSION:=d9be7a2a2e2f04ea9e13c89cd77efb4fd7bfcce4
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=jerrykuku <jerrykuku@gmail.com>
PKG_LICENSE:=MIT

LUCI_TITLE:=Argon - Clean and Modern LuCI Theme
LUCI_DEPENDS:=+luci-base

define Package/luci-theme-argon/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	uci -q get luci.themes.Argon > /dev/null 2>&1 || {
		uci -q set luci.themes.Argon=/luci-static/argon
		uci commit luci
	}
	uci -q set luci.main.mediaurlbase=/luci-static/argon
	uci commit luci
}
exit 0
endef

define Package/luci-theme-argon/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	uci -q delete luci.themes.Argon
	uci -q set luci.main.mediaurlbase=/luci-static/bootstrap
	uci commit luci
}
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
$(eval $(call BuildPackage,luci-theme-argon))
