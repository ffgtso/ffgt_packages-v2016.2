include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-banner
PKG_VERSION:=2
PKG_RELEASE:=$(GLUON_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/ffgt-banner
  SECTION:=ffgt
  CATEGORY:=Customization
  TITLE:=Banner file replacement
  DEPENDS:=+gluon-core +busybox
endef

define Package/ffgt-banner/description
	Freifunk KreisGT shell banner
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ffgt-banner/preinst
#!/bin/sh
cd "$${IPKG_INSTROOT}/etc/"
if [ -h "./banner" ] ; then
	/bin/rm "./banner"
elif [ -f "./banner" ] ; then
	/bin/mv "./banner" "./banner.openwrt"
fi
/bin/ln -s "./banner.openwrt" "./banner"
exit 0
endef

define Package/ffgt-banner/postinst
#!/bin/sh
cd "$${IPKG_INSTROOT}/etc/"
[ -h "./banner" ] && /bin/rm -f "./banner"
/bin/ln -s "./banner.ffgt" "./banner"
echo "" >> "./banner.ffgt"
#echo "OpenWRT-Basis: `grep ", r" ./banner.openwrt`"
#rm ./banner.openwrt
exit $$?
endef

define Package/ffgt-banner/prerm
#!/bin/sh
cd "$${IPKG_INSTROOT}/etc/"
if [ -h "./banner" ] ; then
	[[ "$$(readlink -n ./banner)" == "./banner.ffgt" ]] && \
	/bin/rm -f "./banner" && \
	[ -f "./banner.openwrt" ] && \
	/bin/ln -s "./banner.openwrt" "./banner"
fi
exit 0
endef

define Package/ffgt-banner/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ffgt-banner))
