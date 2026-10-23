#! /bin/bash
# script for a (sway)bar that displays what media is currently playing
# note: all icons require a nerd font


# check if anything is playing
player_status="$(playerctl status 2> /dev/null)"

if [ -n "$player_status" ]; then

	# get title, artist and album
	media_title="$(playerctl metadata title)"
	media_artist="$(playerctl metadata artist)"
	media_album="$(playerctl metadata album)"

	# determine icon to display - spotify and youtube/freetube custom icons, generic icon if anything else, pause icon if paused and mute icon if muted

	# for future: should probably use a case statement

	if [ "$player_status" = "Paused" ]; then
		icon="󰏤"
	else
		muted="$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')"
		if [ "$muted" = "yes" ]; then
			icon="󰓄"
		else
			playing_spotify="$(playerctl metadata | grep spotify | head -n 1)"
			
			# the logic here uses negatives (-z instead of -n)

			if [ -z "$playing_spotify" ]; then
			playing_youtube="$(playerctl metadata | grep youtube | head -n 1)"
			playing_freetube="$(playerctl metadata | grep chromium | head -n 1)"
			playing_youtube_like="$playing_youtube$playing_freetube"
				if [ -z "$playing_youtube_like" ]; then
					icon="󰎇"
				else
					icon="󰗃"
				fi
			else
				icon="󰓇"
			fi
		fi
	fi

	# display bar - selective echoes for if there is an artist, an album, both, and/or lack thereof for formatting purposes 

	if [ -n "$media_artist" ]; then
		if [ -n "$media_album" ]; then
			echo "$icon $media_title - $media_artist > $media_album |"
		else
			echo "$icon $media_title - $media_artist |"
		fi
	else
		echo "$icon $media_title |"
	fi
else
	# display bar - include mute icon if muted

	muted="$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')"
	if [ "$muted" = "yes" ]; then
		icon="󰓄"
	fi

	echo "$icon No media playing |"
fi
