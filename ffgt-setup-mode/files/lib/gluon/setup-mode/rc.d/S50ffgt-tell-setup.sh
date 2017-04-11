#!/bin/sh
#/etc/rc.common

START=14

# Run multiple time, in case the User forgot to re-plug blue=>yellow ...
((sleep 240 ; /lib/gluon/config-mode/notify-setup.sh)&)
((sleep 120 ; /lib/gluon/config-mode/notify-setup.sh)&)
((sleep 90 ; /lib/gluon/config-mode/notify-setup.sh)&)
((sleep 60 ; /lib/gluon/config-mode/notify-setup.sh)&)
((sleep 30 ; /lib/gluon/config-mode/notify-setup.sh)&)
((sleep 15 ; /lib/gluon/config-mode/notify-setup.sh)&)
/lib/gluon/config-mode/notify-setup.sh
