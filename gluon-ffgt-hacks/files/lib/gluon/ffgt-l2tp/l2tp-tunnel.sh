#!/bin/sh

WANUP=0

ip link show dev br-wan | grep "state UP" >/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
 WANUP=1
else
 exit 0
fi

LIP="$(ip -o -4 addr show dev br-wan | awk '{printf("%s", substr($4, 1, index($4, "/")-1));}')"
PRIMARYMAC="$(cat /lib/gluon/core/sysconfig/primary_mac | sed -e s/://g)"
wget -q -O /tmp/l2tp.state "http://l2tp-gut.4830.org/l2tp.php?primarymac=$PRIMARYMAC"
grep ^OK /tmp/l2tp.state >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
 logger "L2TP setup failed."
 if [ -e /tmp/l2tp-${PRIMARYMAC}.down ]; then
  /bin/sh /tmp/l2tp-${PRIMARYMAC}.down
  /bin/rm /tmp/l2tp-${PRIMARYMAC}.*
 fi
 /etc/init.d/fastd restart
 exit 0
fi

SID="$(cut -d ' ' -f 2 </tmp/l2tp.state)"
PORT="$(cut -d ' ' -f 3 </tmp/l2tp.state)"
RIP="$(cut -d ' ' -f 4 </tmp/l2tp.state)"
LID="$(cut -d ' ' -f 5 </tmp/l2tp.state)"

cat <<eof >/tmp/l2tp-${PRIMARYMAC}.up
#!/bin/sh
ip l2tp add tunnel tunnel_id $SID peer_tunnel_id $SID encap udp udp_sport $PORT udp_dport $PORT local $LIP remote $RIP || true
ip l2tp add session name El2tp tunnel_id $SID session_id $SID peer_session_id $SID  || true
ip link set El2tp multicast on || true
ip link set El2tp mtu 1500 || true
ip link set El2tp up || true
batctl if add El2tp || true
eof
chmod +x /tmp/l2tp-${PRIMARYMAC}.up
cat <<eof >/tmp/l2tp-${PRIMARYMAC}.down
#!/bin/sh
batctl if del El2tp  || true
ip l2tp del session name El2tp tunnel_id $SID session_id $SID || true
ip l2tp del tunnel tunnel_id $SID peer_tunnel_id $SID || true
eof
chmod +x /tmp/l2tp-${PRIMARYMAC}.down

batctl if | grep El2tp >/dev/null 2>/dev/null
if [ $? -eq 1 ]; then
 /tmp/l2tp-${PRIMARYMAC}.up
 /etc/init.d/fastd stop
fi
