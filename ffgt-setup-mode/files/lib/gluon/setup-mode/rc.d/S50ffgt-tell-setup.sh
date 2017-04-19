#!/bin/sh
#/etc/rc.common

START=50

# Run every 15 seconds ...
/lib/gluon/config-mode/notify-setup.sh force
((sleep 15 ; /lib/gluon/setup-mode/rc.d/S50ffgt-tell-setup.sh force)&)
