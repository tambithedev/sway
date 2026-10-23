#! /bin/bash
# my main (sway)bar

# get time and date
current_time=$(date "+%H:%M")
current_date=$(date "+%d.%m.%Y")

# get battery information: percentage and state (charging or discharging)
battery_charge=$(upower --show-info $(upower --enumerate | grep 'BAT') | grep -E percentage | awk '{print $2}')
battery_status=$(upower --show-info $(upower --enumerate | grep 'BAT') | grep -E state | awk '{print $2}')

# get volume information: percentage and mute state
audio_volume="$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n 1)"
audio_is_muted="Muted: $(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')"

# get mic information: percentage and mute state
mic_volume="$(pactl get-source-volume @DEFAULT_SOURCE@ | awk '{print $5}' | head -n 1)"
mic_is_muted="Muted: $(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')"

# check if network connection available
network=$(ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | cut -f1 -d ' ')

# get bluetooth status
bluetooth_on=$(bluetoothctl show | grep Powered | awk '{print $2}')

# get raw battery number, check if charging or discharing, change display icon accordingly + display no battery charge number in the bar if fully charged and charging
battery_number=$(echo $battery_charge | cut -f1 -d '%')
if [ $battery_status = "discharging" ]; then
	if
		(($battery_number<=15))
	then
		battery_plugged_in="󱃍"
	elif (($battery_number<40))
	then
		battery_plugged_in="󰁻"
	elif (($battery_number<60))
	then
		battery_plugged_in="󰁽"
	elif (($battery_number<80))
	then
		battery_plugged_in="󰁿"
	elif (($battery_number<=100))
	then
		battery_plugged_in="󰂂"
	fi
else
	if [[ $battery_number = 100 ]]; then
		battery_charge=""
		battery_plugged_in="󱐋 "
	else
		battery_plugged_in="󱐋"
	fi
fi

# check if mic is muted and set display icon accordingly + display no volume number if muted
check_string=$(echo $mic_is_muted | cut -f2 -d ' ')
if [ $check_string = "no" ]; then
	mic_is_muted=""
else
	mic_is_muted="󰍭 "
	mic_volume=""
fi

# check if audio is muted and set display icon accordingly + display no volume number if muted
check_string=$(echo $audio_is_muted | cut -f2 -d ' ')
if [ $check_string = "no" ]; then
	audio_is_muted="󰓃"
else
	audio_is_muted="󰓄 "
	audio_volume=""
fi

# check if network connection is active and set display icon accordingly
if ! [ $network ]; then
	network_active="󰜺"
else
	network_active="󰖩"
fi

# check if bluetooth connection is active and set display icon accordingly
if [ $bluetooth_on = "yes" ]; then
	bluetooth_on="󰂯 "
else
	bluetooth_on=""
fi

# display if usb storage device(s) mounted
if  mountpoint -q /media/tambi/*
then
	device_connected="󰕓 "
else
	device_connected=""
fi

# display bar
echo "$network_active $bluetooth_on$device_connected| $audio_volume $audio_is_muted | $mic_volume $mic_is_muted | $battery_charge $battery_plugged_in | $current_time | $current_date |"
