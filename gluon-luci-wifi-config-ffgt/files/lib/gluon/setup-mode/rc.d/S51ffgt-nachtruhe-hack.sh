#!/bin/sh
# My big fat ugly hack ...

START=51

if [ -e /lib/gluon/upgrade/321-gluon-client-bridge-wireless-ffgt ]; then
 /bin/mv /lib/gluon/upgrade/321-gluon-client-bridge-wireless-ffgt /lib/gluon/upgrade/320-gluon-client-bridge-wireless
fi
