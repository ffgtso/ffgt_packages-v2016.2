#!/bin/sh

/sbin/ip addr show dev br-wan 2>/dev/null | grep scope | grep -v fe80: | egrep 'inet |inet6 ' | /usr/bin/sort | /usr/bin/uniq | /usr/bin/awk -f /usr/bin/uplink_stats.awk >/tmp/wan_ipfamily.tmp && mv /tmp/wan_ipfamily.tmp /tmp/wan_ipfamily
