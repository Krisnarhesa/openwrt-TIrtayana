# SPDX-License-Identifier: MIT
#
# Copyright (C) jerrykuku <jerrykuku@gmail.com>
# Packaged for TIrtayana OpenWrt Build
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-argon-config
PKG_VERSION:=1.0.9
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jerrykuku/luci-app-argon-config.git
PKG_SOURCE_DATE:=$(shell date +%Y-%m-%d)
PKG_SOURCE_VERSION:=main
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=jerrykuku <jerrykuku@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

LUCI_TITLE:=LuCI Argon Theme Config
LUCI_DEPENDS:=+luci-base +luci-theme-argon

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
$(eval $(call BuildPackage,luci-app-argon-config))
