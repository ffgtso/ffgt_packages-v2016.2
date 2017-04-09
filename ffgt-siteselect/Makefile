include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-siteselect
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ffgt-siteselect
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Package for (automatic) selection of a site.conf file
  DEPENDS:=+ffgt-geolocate
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ffgt-siteselect/install
	mkdir -p $(1)/etc/config/
	mkdir -p $(1)/lib/gluon/site-select/
	$(CP) ./files/* $(1)/

	lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/site.json
    GLUON_SITE_CONFIG=./luasrc/sitefiles/zzz.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/zzz.json
    GLUON_SITE_CONFIG=./luasrc/sitefiles/wrz.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/wrz.json
    GLUON_SITE_CONFIG=./luasrc/sitefiles/rhw.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/rhw.json
    GLUON_SITE_CONFIG=./luasrc/sitefiles/gto.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/gto.json
    GLUON_SITE_CONFIG=./luasrc/sitefiles/gt8.conf lua -e 'print(require("cjson").encode(assert(dofile("$(GLUONDIR)/scripts/site_config.lua"))))' > $(1)/lib/gluon/sitefiles/gt8.json
endef

$(eval $(call BuildPackage,ffgt-siteselect))
