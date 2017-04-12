#!/bin/sh
# This script is supposed to be run (once) from lua
IW="/usr/sbin/iw"
if [ ! -e $IW ]; then
 echo >/tmp/fake_iw -e "#!/bin/sh\ncat /dev/null"
 chmod +x /tmp/fake_iw
 IW="/tmp/fake_iw"
fi
export IW

runnow=0
isconfigured="`/sbin/uci get gluon-setup-mode.@setup_mode[0].configured 2>/dev/null`"
if [ "$isconfigured" != "1" ]; then
 isconfigured=0
fi

if [ ! -e /tmp/run/geolocate-data-sent ]; then
 runnow=1
fi

if [ ${runnow} -eq 1 ]; then
 IPVXPREFIX="`/lib/gluon/ffgt-geolocate/ipv5.sh`"
 if [ "Y$IPVXPREFIX" == "Y" -o "$IPVXPREFIX" == "ipv5." ]; then
  logger "$0: IPv5 not implemented."
  exit 1
 fi

 mac=`/sbin/uci get network.bat0.macaddr`
 # FIXME. On multiband devices, check wlan1 as well!
 ${IW} dev wlan0 scan >/dev/null 2>&1
 if [ $? -ne 0 ]; then
  /sbin/ifconfig wlan0 up
  sleep 2
 fi
 /usr/bin/wget -q -O /dev/null "`${IW} wlan0 scan | /usr/bin/awk -v mac=$mac -v ipv4prefix=$IPVXPREFIX -f /lib/gluon/ffgt-geolocate/preparse.awk`" && /bin/touch /tmp/run/geolocate-data-sent
 # On success only ...
 if [ -e /tmp/run/geolocate-data-sent ]; then
  curlat="`/sbin/uci get gluon-node-info.@location[0].longitude 2>/dev/null`"
  if [ "X${curlat}" = "X" ]; then
   sleep 5
   /usr/bin/wget -q -O /tmp/geoloc.out "http://setup.${IPVXPREFIX}4830.org/geoloc.php?list=me&node=$mac"
   if [ -e /tmp/geoloc.out ]; then
    # Actually, we might want to sanity check the reply, as it could be empty or worse ... (FIXME) 
    /bin/cat /dev/null >/tmp/geoloc.sh
    haslocation="`/sbin/uci get gluon-node-info.@location[0] 2>/dev/null]`"
    if [ "${haslocation}" != "location" ]; then
     echo "/sbin/uci add gluon-node-info location" >>/tmp/geoloc.sh
    fi
    # Honour existing share_location setting; if missing, create & set to '1'
    hasshare="`/sbin/uci get gluon-node-info.@location[0].share_location 1>/dev/null 2>&1; echo $?`"
    if [ "${hasshare}" != "0" ]; then
     echo "/sbin/uci set gluon-node-info.@location[0].share_location=1" >>/tmp/geoloc.sh
    fi
    /usr/bin/awk </tmp/geoloc.out '/^LAT:/ {printf("/sbin/uci set gluon-node-info.@location[0].latitude=%s\n", $2);} /^LON:/ {printf("/sbin/uci set gluon-node-info.@location[0].longitude=%s\n", $2);} /^ADR:/ {printf("/sbin/uci set gluon-node-info.@location[0].addr=%c%s%c\n", 39, $2, 39);} /^CTY:/ {printf("/sbin/uci set gluon-node-info.@location[0].city=%s\n", $2);} /^ZIP:/ {printf("/sbin/uci set gluon-node-info.@location[0].zip=%s\n", $2);} /^LOC:/ {printf("/sbin/uci set gluon-node-info.@location[0].locode=%s\n", $2);} END{printf("/sbin/uci commit gluon-node-info\n");}' >>/tmp/geoloc.sh
    /bin/sh /tmp/geoloc.sh
    if [ $isconfigured -ne 1 ]; then
     loc="`/sbin/uci get gluon-node-info.@location[0].locode 2>/dev/null`"
     adr="`/sbin/uci get gluon-node-info.@location[0].addr 2>/dev/null`"
     if [ "x${loc}" != "x" -a "x${adr}" != "x" ]; then
      hostname="${loc}-${adr}"
      /sbin/uci set system.@system[0].hostname="${hostname}"
      /sbin/uci commit system
     fi
    fi
   fi
  fi
 fi
fi
