#!/bin/sh

display_count="$(swaymsg -t get_outputs | jq '. | length')"
if [ "$display_count" = "2" ]; then
	swaymsg output "eDP-1" "disable"
	wlr-randr --output DP-1 --preferred --on
	swaymsg output DP-1 scale 1
	# swaymsg output DP-1 scale 2
else
	swaymsg output "eDP-1" "enable"
fi
