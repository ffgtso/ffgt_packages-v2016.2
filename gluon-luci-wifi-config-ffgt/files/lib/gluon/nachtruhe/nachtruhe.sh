#! /bin/sh

CHANGES=0
DISABLETARGET=0
HOUR="`/bin/date +%H`"
if [ $HOUR -ge 22 -o $HOUR -lt 6 ]; then
  DISABLETARGET=1
fi

# Just delay execution a bit to prevent race conditions.
sleep 20

# Check all configured radios. If they are on a nighttime peace ("nachtruhe") setting,
# check their current state and set them to DISABLEDSTATE, unless their cfgdisabled
# value is 1, i. e. they are disabled anyway.

radios="`uci show wireless | grep client_ | grep wifi-iface | sed -e 's/wireless.//g' -e 's/=wifi-iface//g'`"
for radio in ${radios}
do
  nachtruhe=$(uci get wireless.${radio}.nachtruhe 2>/dev/null)
  if [ "X${nachtruhe}" = "X" ]; then
    logger -s -t "nachtruhe.sh" -p 5 "Oops, wireless.${radio}.nachtruhe is undefined, defaulting to disabled (0)."
    uci set wireless.${radio}.nachtruhe=0
    nachtruhe=0
  fi

  if [ "${nachtruhe}" -eq 1 ]; then
    radiostate=$(uci get wireless.${radio}.disabled)
    configstate=$(uci get wireless.${radio}.cfgdisabled 2>/dev/null)
    if [ "X${configstate}" = "X" ]; then
      logger -s -t "nachtruhe.sh" -p 5 "Something is fishy, wireless.${radio}.cfgdisabled is undefined, skipping."
    else
      if [ "${configstate}" -eq 1 ]; then # radio should be disabled
        if [ "${radiostate}" -eq 1 ]; then
          logger -s -t "nachtruhe.sh" -p 5 "${radio} already disabled as per config (${radiostate}, ${configstate}). Nothing to do."
        else
          logger -s -t "nachtruhe.sh" -p 5 "${radio} is enabled, but should not be (${radiostate}, ${configstate}), oops? Disabling."
          uci set wireless.${radio}.disabled=${configstate}
          CHANGES=1
        fi
      else # radio should be enabled; disable for nighttime peace or enable during the day accordingly.
         if [ "${radiostate}" -ne ${DISABLETARGET} ]; then
           logger -s -t "nachtruhe.sh" -p 5 "${radio} state mismatch ('disabled' is ${radiostate}, should be ${DISABLETARGET}), adjusting."
           uci set wireless.${radio}.disabled=${DISABLETARGET}
           CHANGES=1
         else
           logger -s -t "nachtruhe.sh" -p 5 "${radio} state as desired ('disabled' is ${radiostate}, should be ${DISABLETARGET}), nothing to do."
         fi
      fi
    fi
  fi
done

if [ ${CHANGES} -eq 1 ]; then
  wifi reload
  logger -s -t "nachtruhe.sh" -p 5 "Some setting was changed, restarted wifi."
fi
