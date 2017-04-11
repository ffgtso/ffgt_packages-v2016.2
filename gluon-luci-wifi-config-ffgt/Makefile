include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-luci-wifi-config-ffgt
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-luci-wifi-config-ffgt
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-luci-admin +libiwinfo-lua
  TITLE:=UI for Wifi Settings
  PROVIDES:=gluon-luci-wifi-config
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-luci-wifi-config-ffgt,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-luci-wifi-config-ffgt/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-luci-wifi-config-ffgt,$(1))
endef

$(eval $(call BuildPackage,gluon-luci-wifi-config-ffgt))
