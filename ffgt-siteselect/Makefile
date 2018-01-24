include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-siteselect
PKG_VERSION:=0.5
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/ffgt-siteselect
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Package for (automatic) selection of a site.conf file
  DEPENDS:=+ffgt-geolocate +lua
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/ffgt-siteselect/install
	$(INSTALL_DIR) $(1)/lib/gluon
	mkdir -p $(1)/etc/config/
	mkdir -p $(1)/lib/gluon/sitefiles/
	mkdir -p $(1)/lib/gluon/siteselect/
	GLUON_SITE_CONFIG=./files/lib/gluon/siteselect/zzz.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/zzz.json
	GLUON_SITE_CONFIG=./files/lib/gluon/siteselect/wrz.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/wrz.json
	GLUON_SITE_CONFIG=./files/lib/gluon/siteselect/rhw.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/rhw.json
	GLUON_SITE_CONFIG=./files/lib/gluon/siteselect/gto.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/gto.json
	GLUON_SITE_CONFIG=./files/lib/gluon/siteselect/gt8.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/gt8.json
	GLUON_SITE_CONFIG=./files/lib/gluon/siteselect/gut.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/gut.json
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	# Remove the just now copied source .conf files. FIXME or normal cleanup?
	rm -rf $(1)/lib/gluon/siteselect
endef

$(eval $(call BuildPackage,ffgt-siteselect))
