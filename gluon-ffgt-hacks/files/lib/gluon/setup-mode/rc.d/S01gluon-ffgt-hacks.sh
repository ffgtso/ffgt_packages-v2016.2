#!/bin/sh
# Another big fat ugly hack ...

START=1

if [ -e /lib/gluon/setup-mode/rc.d/S20network ]; then
 /bin/echo -e "#!/bin/sh\nexit 0\n" >/lib/gluon/setup-mode/rc.d/S20network
fi

if [ -e /lib/gluon/setup-mode/rc.d/S60dnsmasq  ]; then
 /bin/echo -e "#!/bin/sh\nexit 0\n" >/lib/gluon/setup-mode/rc.d/S60dnsmasq
fi

if [ -e /usr/lib/lua/gluon/util-ffgt.lua ]; then
  /bin/mv /usr/lib/lua/gluon/util-ffgt.lua /usr/lib/lua/gluon/util.lua
fi

if [ -e /etc/config/siteselect.upgrade ]; then
  mv /etc/config/siteselect.upgrade /etc/config/siteselect
fi

if [ -e /lib/gluon/upgrade/320-setup-ifname-ffgt ]; then
  mv /lib/gluon/upgrade/320-setup-ifname-ffgt /lib/gluon/upgrade/320-setup-ifname
fi

# FIXME! -wusel, 2018-01-24
# Ugly hack against
# ...
# Package iptables (1.4.21-1) installed in root is up to date.
# Installing iwinfo (2015-06-01-ade8b1b299cbd5748db1acf80dd3e9f567938371) to root...
# Downloading file:../openwrt/bin/ar71xx/packages/iwinfo_2015-06-01-ade8b1b299cbd5748db1acf80dd3e9f567938371_ar71xx.ipk.
# /home/ffgt/jenkins_data/build/gluon-ffgt-v2016.2/build/ar71xx-generic/profiles/TLMR3220/root/etc/init.d/siteselect: line 26: /usr/bin/lua: No such file or directory
# /home/ffgt/jenkins_data/build/gluon-ffgt-v2016.2/build/ar71xx-generic/profiles/TLMR3220/root/etc/init.d/siteselect: line 38: /lib/gluon/ffgt-geolocate/rgeo.sh: No such file or directory
# Configuring gluon-site.
# ...
if [ -e /lib/gluon/setup-mode/siteselect ]; then
  mv /lib/gluon/setup-mode/siteselect /etc/init.d/siteselect
fi