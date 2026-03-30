# SPDX-License-Identifier: MIT
#
# Copyright (C) 2024 Tirtayana
# LuCI App: TIrtayana Service (Install OpenWrt, Update Kernel, Backup ROM)
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-tirtayana-installer
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Tirtayana
PKG_LICENSE:=MIT

LUCI_TITLE:=LuCI TIrtayana Service - Install/Update/Backup for Amlogic STB
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+luci-base +luci-compat

define Package/luci-app-tirtayana-installer/conffiles
/etc/config/tirtayana
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
$(eval $(call BuildPackage,luci-app-tirtayana-installer))
