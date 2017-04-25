#!/bin/sh

cat /sys/class/net/$(lua -e 'print(require("gluon.sysconfig").wan_ifname)')/carrier >/tmp/link_on_wan