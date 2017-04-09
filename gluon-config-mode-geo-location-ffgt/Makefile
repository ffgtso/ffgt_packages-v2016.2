include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-geo-location-ffgt
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-config-mode-geo-location-ffgt
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Set geographic location of a node, FFGT version
  DEPENDS:=gluon-config-mode-core-virtual +gluon-node-info
  PROVIDES:=gluon-config-mode-geo-location
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-config-mode-geo-location-ffgt,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-config-mode-geo-location-ffgt/install
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-config-mode-geo-location-ffgt,$(1))
endef

define Package/gluon-config-mode-geo-location-ffgt/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-config-mode-geo-location-ffgt))
