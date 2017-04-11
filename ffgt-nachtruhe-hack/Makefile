include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-nachtruhe-hack
PKG_VERSION:=2
PKG_RELEASE:=$(GLUON_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/ffgt-nachtruhe-hack
  SECTION:=ffgt
  CATEGORY:=Customization
  TITLE:=Hack
  DEPENDS:=+gluon-luci-wifi-config-ffgt
endef

define Package/ffgt-nachtruhe-hack/description
	Hacking around Gluon ...
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ffgt-nachtruhe-hack/preinst
endef

define Package/ffgt-nachtruhe-hack/postinst
#!/bin/sh
cd "$${IPKG_INSTROOT}/lib/gluon/upgrade"
mv 321-gluon-client-bridge-wireless-ffgt 320-gluon-client-bridge-wireless
exit 0
endef

define Package/ffgt-nachtruhe-hack/install
endef

$(eval $(call BuildPackage,ffgt-nachtruhe-hack))
