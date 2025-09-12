#!/bin/sh

_notify() {
	notify-send -i display "Monitor" "$1"
}

_get_outputs() {
	swaymsg -t get_outputs | jq -r '.[] | [.name, .make, .model] | join("|")'
}

_sum() {
	_get_outputs | sort | sha256sum
}

outputs=$(_get_outputs)
sum=$(_sum)

case "$sum" in
	d522b26e55aed4576adb9cc33887069397ab186de73e3d421aa7c6be34a93d4e*)
		_notify "Home setup detected"
		swaymsg output DP-1 pos 0 0 res 3840x2160 scale 2 enable
		swaymsg output eDP-1 disable
		exit 0
		;;

	83ded9eaa7db7c3a534ab0eb247524e3f560a4b34331b10d55bd7d39186e96d5*)
		_notify "Work setup detected (classic spot) old"
		swaymsg output DP-2 pos 0 0 res 1920x1080 enable
		swaymsg output DP-4 pos 1920 0 res 1920x1080 enable
		swaymsg output eDP-1 disable
		exit 0
		;;
	a70ee1b0e45a7252bc5b0150a0488c06bcb335b72fa194a882c79a11c1a45bc5*)
		_notify "Work setup detected (classic spot)"
		swaymsg output DP-3 pos 0 0 res 1920x1080 enable
		swaymsg output DP-6 pos 1920 0 res 1920x1080 enable
		swaymsg output eDP-1 disable
		exit 0
		;;
	aca658424413ac2a56ff1d1dfd9ee67e46b131668c78f05325511371070446d8*)
		_notify "Work setup detected (classic spot)"
		swaymsg output DP-2 pos 0 0 res 1920x1080 enable
		swaymsg output DP-3 pos 1920 0 res 1920x1080 enable
		swaymsg output eDP-1 disable
		exit 0
		;;
	xx*)
		_notify "Work setup detected (by the window)"
		swaymsg output DP-4 pos 0 0 res 1920x1080 enable
		swaymsg output DP-3 pos 1920 0 res 1920x1080 enable
		swaymsg output eDP-1 disable
		exit 0
		;;
esac

display_count="$(echo "$outputs" | wc -l)"
echo "displays: $display_count"
case $display_count in
	1)
		swaymsg output "eDP-1" "enable"
		_notify "External monitor disconnected"
		;;
	2)
		swaymsg output "eDP-1" "disable"
		_notify "External monitor connected"
		;;
	3)
		_notify "Need to handle this case: $sum"
		;;
	*)
		_notify "$display_count displays config not handled"
		;;
esac
