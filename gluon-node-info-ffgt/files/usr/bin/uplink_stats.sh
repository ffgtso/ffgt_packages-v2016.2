#!/bin/sh

/sbin/ip addr show dev br-wan 2>/dev/null |grep scope | egrep 'inet |inet6 [234]' | /usr/bin/sort | /usr/bin/uniq | awk 'BEGIN{ipfam="";} /inet/ {ipfam=sprintf("%s%s%s", $1, length(ipfam)>0?" ": "", length(ipfam)?ipfam:"");} END{gsub(" ", ", ", ipfam); print ipfam;}' >/tmp/wan_ipfamily.tmp && mv /tmp/wan_ipfamily.tmp /tmp/wan_ipfamily
