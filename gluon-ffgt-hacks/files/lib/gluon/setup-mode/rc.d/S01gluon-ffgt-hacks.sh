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
