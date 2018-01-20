#!/bin/sh
# This script is supposed to be run every hour via micron.d.
#
# FIXME: do not uci commit all the time! That would kill the FLASH rather soonish :(
#
# Try to fetch config data from setup server (supposed to be used for fixups).

runnow=1
isconfigured="`/sbin/uci get gluon-setup-mode.@setup_mode[0].configured 2>/dev/null`"
if [ "$isconfigured" != "1" ]; then
 isconfigured=0
fi

if [ -e /tmp/run/gotcfg ]; then
 runnow=0
fi

if [ $# -eq 1 ]; then
  forcerun=1
  runnow=1
else
  forcerun=0
fi

GWL=$(batctl gwl | grep MBit | wc -l)

if [ $GWL -eq 0 ]; then
  runnow=0
fi

if [ ${runnow} -eq 0 ]; then
 exit 0
fi

# We're now supposed to run ...
mac=`/sbin/uci get network.bat0.macaddr`

/usr/bin/wget -q -O /tmp/getcfg.out "http://setup.ipv6.4830.org/getcfg.php?node=${mac}" # Only works in-mesh usually
if [ -e /tmp/getcfg.out ]; then
 # grep CFG:  /tmp/getcfg.out >/dev/null && touch /tmp/run/gotcfg
fi
