include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-setup-mode
PKG_VERSION:=2
PKG_RELEASE:=$(GLUON_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

define Package/ffgt-setup-mode
  SECTION:=ffgt
  CATEGORY:=Customization
  TITLE:=Notify setup server
  DEPENDS:=+gluon-core +busybox
endef

define Package/ffgt-setup-mode/description
	Notify central setup server about us
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ffgt-setup-mode/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ffgt-setup-mode))
