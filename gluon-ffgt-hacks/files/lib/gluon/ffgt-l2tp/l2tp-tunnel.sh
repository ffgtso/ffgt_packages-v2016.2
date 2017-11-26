#!/bin/sh

WANUP=0
L2TPGW=l2tp-gut.4830.org

ip link show dev br-wan | grep "state UP" >/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
 WANUP=1
else
 exit 0
fi

if [ ! -e /tmp/l2tp-${PRIMARYMAC}.l2tpgwip4 ]; then
 L2TPGWIP4=$(nslookup ${L2TPGW} | awk '/^Name:/ {doparse=1; next;} /^Address/ {if(doparse!=1) next; if(index($3, ":")) next; ip=$3;} END{printf("%s\n", ip);}')
 if [ ! -z ${L2TPGWIP4} ]; then
  echo "${L2TPGWIP4}" >/tmp/l2tp-${PRIMARYMAC}.l2tpgwip4
 else
  exit 0
 fi
else
 L2TPGWIP4=$(cat /tmp/l2tp-${PRIMARYMAC}.l2tpgwip4)
fi

LIP="$(ip -o -4 addr show dev br-wan | awk '{printf("%s", substr($4, 1, index($4, "/")-1));}')"
PRIMARYMAC="$(cat /lib/gluon/core/sysconfig/primary_mac | sed -e s/://g)"
X=$(cat /lib/gluon/core/sysconfig/primary_mac | cut -d ":" -f 6 )
LOCALPORT=$(printf %d 0x$X)
LOCALPORT=$(expr 10000 + $LOCALPORT)
RIP=${L2TPGWIP4}
SID="$(echo $PRIMARYMAC | awk '{printf("%d", "0x" substr($1, 9,4));}')"

# Due to CGN/ATFR (DS-Lite), we can't predict our exit port; therefore we
# need to get the target IP upfront, setup a tunnel as we intend to do and
# the remote end will sniff our actual port number. We add the dummy tunnel
# to batman to ensure some actual traffic hits the target ...
if [ ! -e /sys/class/net/El2tp/carrier ]; then
 cat <<eof >/tmp/l2tp-${PRIMARYMAC}.tmpup
#!/bin/sh
ip l2tp add tunnel tunnel_id $SID peer_tunnel_id $SID encap udp udp_sport $LOCALPORT udp_dport $PORT local $LIP remote $RIP || true
ip l2tp add session name El2tp tunnel_id $SID session_id $SID peer_session_id $SID || true
ip link set El2tp multicast on || true
ip link set El2tp mtu 1392 || true
ip link set El2tp up || true
batctl if add El2tp || true
eof
 chmod +x /tmp/l2tp-${PRIMARYMAC}.tmpup
 cat <<eof >/tmp/l2tp-${PRIMARYMAC}.down
#!/bin/sh
batctl if del El2tp  || true
ip l2tp del session name El2tp tunnel_id $SID session_id $SID || true
ip l2tp del tunnel tunnel_id $SID peer_tunnel_id $SID || true
eof
 chmod +x /tmp/l2tp-${PRIMARYMAC}.down
 /bin/sh /tmp/l2tp-${PRIMARYMAC}.tmpup
fi

wget -q -O /tmp/l2tp.state "http://${L2TPGWIP4}/l2tp.php?primarymac=$PRIMARYMAC&port=$LOCALPORT)"
grep ^OK /tmp/l2tp.state >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
 logger "L2TP setup failed."
 if [ -e /tmp/l2tp-${PRIMARYMAC}.down ]; then
  /bin/sh /tmp/l2tp-${PRIMARYMAC}.down
  /bin/rm /tmp/l2tp-${PRIMARYMAC}.*
 fi
 /etc/init.d/fastd restart
 echo "fastd" >/tmp/tunnelprotocol
 exit 0
fi

SID="$(cut -d ' ' -f 2 </tmp/l2tp.state)"
PORT="$(cut -d ' ' -f 3 </tmp/l2tp.state)"
RIP="$(cut -d ' ' -f 4 </tmp/l2tp.state)"
LID="$(cut -d ' ' -f 5 </tmp/l2tp.state)"
PEERV6="$(cut -d ' ' -f 6 </tmp/l2tp.state)"

# Delete temporary tunnel, remote end should have received our "ping"
if [ -e /tmp/l2tp-${PRIMARYMAC}.tmpup -a -e /sys/class/net/El2tp/carrier ]; then
 /bin/sh /tmp/l2tp-${PRIMARYMAC}.down
 /bin/rm /tmp/l2tp-${PRIMARYMAC}.tmpup /tmp/l2tp-${PRIMARYMAC}.down
fi

if [ ! -e /tmp/l2tp-${PRIMARYMAC}.up ]; then
 cat <<eof >/tmp/l2tp-${PRIMARYMAC}.up
#!/bin/sh
ip l2tp add tunnel tunnel_id $SID peer_tunnel_id $SID encap udp udp_sport $LOCALPORT udp_dport $PORT local $LIP remote $RIP || true
ip l2tp add session name El2tp tunnel_id $SID session_id $SID peer_session_id $SID || true
ip link set El2tp multicast on || true
ip link set El2tp mtu 1392 || true
ip link set El2tp up || true
batctl if add El2tp || true
eof
 chmod +x /tmp/l2tp-${PRIMARYMAC}.up
fi
if [ ! -e  /tmp/l2tp-${PRIMARYMAC}.down ]; then
 cat <<eof >/tmp/l2tp-${PRIMARYMAC}.down
#!/bin/sh
batctl if del El2tp  || true
ip l2tp del session name El2tp tunnel_id $SID session_id $SID || true
ip l2tp del tunnel tunnel_id $SID peer_tunnel_id $SID || true
eof
 chmod +x /tmp/l2tp-${PRIMARYMAC}.down
fi

# Already live? If not, make it so!
batctl if | grep El2tp >/dev/null 2>/dev/null
if [ $? -eq 1 ]; then
 /bin/sh /tmp/l2tp-${PRIMARYMAC}.up
fi

ip -6 addr show dev El2tp >/dev/null 2>&1
if [ $? -eq 0 ]; then
 ping6 -q -c 5 ${PEERV6}%El2tp
 if [ $? -eq 0]; then
  /etc/init.d/fastd stop
  echo "l2tp" >/tmp/tunnelprotocol
  if [ -e /var/run/restart_fastd ]; then
   /bin/rm /var/run/restart_fastd
  fi
 else
  if [ ! -e /var/run/restart_fastd ]; then
    touch /var/run/restart_fastd
  else
    /etc/init.d/fastd start
    /bin/rm /var/run/restart_fastd
    echo "fastd" >/tmp/tunnelprotocol
  fi
 fi
fi
