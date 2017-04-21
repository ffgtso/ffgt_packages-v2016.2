#!/bin/sh
# Another big fat ugly hack ...

START=1

if [ -e /lib/gluon/setup-mode/rc.d/S20network ]; then
 /bin/echo -e "#!/bin/sh\nexit 0\n" >/lib/gluon/setup-mode/rc.d/S20network
fi

if [ -e /lib/gluon/setup-mode/rc.d/S60dnsmasq  ]; then
 /bin/echo -e "#!/bin/sh\nexit 0\n" >/lib/gluon/setup-mode/rc.d/S60dnsmasq
fi

if [ -e /lib/lua/gluon/util-ffgt.lua ]; then
  /bin/mv /lib/lua/gluon/util-ffgt.lua /lib/lua/gluon/util.lua
fi
