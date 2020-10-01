
include $(TOPDIR)/rules.mk

PKG_NAME:=nightsky
PKG_VERSION:=0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/nightsky
  SECTION:=nightsky
  CATEGORY:=NightSky Project
  TITLE:=NightSky Project Base Package
  DEPENDS:= \
     +uhttpd \
     +luci-base \
     +luci-mod-rpc
endef

Build/Compile:=

define Package/nightsky/description
  Metapackage for NightSky Project System Settings.
endef

define Package/nightsky/install
	:
endef

$(eval $(call BuildPackage,nightsky))
