#!/bin/sh

DOCK_DEVICE=/sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0/device

_notify() {
	notify-send -i display "Monitor" "$1"
}

display_count="$(swaymsg -t get_outputs | jq '. | length')"
if [ "$display_count" = "2" ]; then
	swaymsg output "eDP-1" "disable"
	_notify "External monitor connected"
else
	swaymsg output "eDP-1" "enable"
	_notify "External monitor disconnected"
fi

systemctl --user restart mako
