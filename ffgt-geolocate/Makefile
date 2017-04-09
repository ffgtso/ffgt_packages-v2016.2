include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-geolocate
PKG_VERSION:=3
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/ffgt-geolocate
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-core
  TITLE:=Assist geolocating the node and survey the wifi spectrum
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,ffgt-geolocate,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/ffgt-geolocate/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(call GluonInstallI18N,ffgt-geolocate,$(1))
endef

$(eval $(call BuildPackage,ffgt-geolocate))
