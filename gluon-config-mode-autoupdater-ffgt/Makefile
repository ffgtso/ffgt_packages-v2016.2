include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-autoupdater-ffgt
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-config-mode-autoupdater-ffgt
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Let the user know whether the autoupdater is enabled or not.
  DEPENDS:=gluon-config-mode-core-virtual +gluon-autoupdater
  PROVIDES:=gluon-config-mode-autoupdater
endef

define Package/gluon-config-mode-autoupdater-ffgt/description
	Luci based config mode
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-config-mode-autoupdater-ffgt,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-config-mode-autoupdater-ffgt/install
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(call GluonInstallI18N,gluon-config-mode-autoupdater-ffgt,$(1))
endef

$(eval $(call BuildPackage,gluon-config-mode-autoupdater-ffgt))
