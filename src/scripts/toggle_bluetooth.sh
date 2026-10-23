#! /bin/bash
#
# script that toggles bluetooth on/off, invoking rfkill to avoid 
# undersirable behaviour encountered on system startup/suspension.

# get bluetooth status
bluetooth_status=$(bluetoothctl show | grep Powered | awk '{print $2}')


# do the thing
if [ $bluetooth_status = "no" ]; then
	rfkill unblock bluetooth
	bluetoothctl power on
else
	if [ $bluetooth_status = "yes" ]; then
		bluetoothctl power off
		rfkill block bluetooth
	fi
fi
