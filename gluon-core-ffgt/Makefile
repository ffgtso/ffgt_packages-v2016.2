include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-core-ffgt
PKG_VERSION:=3
PKG_RELEASE:=$(GLUON_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk


define Package/gluon-core-ffgt
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Base files of Gluon
  DEPENDS:=+gluon-site +libgluonutil +lua-platform-info +lua-hash +luci-base +luci-lib-jsonc +odhcp6c +firewall
  PROVIDES:=gluon-core
endef

define Package/gluon-core-ffgt/description
	Gluon community wifi mesh firmware framework: core (FFGT variant)
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-core-ffgt/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(SED) 's/__GLUON_OPENWRT_FEEDS__/{$(GLUON_OPENWRT_FEEDS:%="%",)}/' $(1)/lib/gluon/upgrade/500-opkg

	$(INSTALL_DIR) $(1)/lib/gluon
	echo "$(GLUON_VERSION)" > $(1)/lib/gluon/gluon-version
endef

define Package/gluon-core-ffgt/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-core-ffgt))
