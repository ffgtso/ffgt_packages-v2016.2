#!/bin/sh

cat /sys/class/net/$(lua -e 'print(require("gluon.sysconfig").wan_ifname)')/carrier >/tmp/link_on_wan.tmp && mv /tmp/link_on_wan.tmp /tmp/link_on_wan
