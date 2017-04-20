include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ffgt-hacks
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-ffgt-hacks
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-setup-mode
  TITLE:=Ugly hacks to change Gluon main components outside of the Gluon source.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-ffgt-hacks/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	/bin/rm $(1)/lib/gluon/setup-mode/rc.d/S20network
	/bin/rm $(1)/lib/gluon/setup-mode/rc.d/S60dnsmasq
endef

$(eval $(call BuildPackage,gluon-ffgt-hacks))
