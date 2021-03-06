#!/bin/sh

DOCK_DEVICE=/sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0/device

_notify() {
	notify-send -i display "Monitor" "$1"
}

_handle_wayland() {
	display_count="$(swaymsg -t get_outputs | jq '. | length')"
	if [ "$display_count" = "2" ]; then
		swaymsg output "eDP-1" "disable"
		_notify "External monitor connected"
	else
		swaymsg output "eDP-1" "enable"
		_notify "External monitor disconnected"
	fi
}

_handle_x() {
	if [ -f "$DOCK_DEVICE" ]; then
		xrandr \
			--output eDP1 --primary --mode 3200x1800 --pos 4032x0 --rotate normal --dpi 166 \
			--output DP1 --mode 1920x1080 --pos 0x0 --rotate normal --scale 2x2 --auto \
			--output DP2 --off \
			--output VIRTUAL1 --off

		i3-msg restart
		sleep 5

		systemctl --user stop compton.service
		systemctl --user restart polybar-external.service
		systemctl --user restart polybar.service
		systemctl --user restart wallpaper.service

		~/.xinitrc

		_notify "External monitor connected"
	else
		xrandr \
			--output eDP1 --primary --mode 3200x1800 --pos 0x0 --rotate normal --dpi 166 \
			--output DP1 --off \
			--output DP2 --off \
			--output VIRTUAL1 --off

		i3-msg restart
		systemctl --user stop polybar-external.service
		systemctl --user restart polybar.service
		systemctl --user restart wallpaper.service
		systemctl --user start compton.service
		_notify "External monitor disconnected"
	fi
}


if [ "$WAYLAND_DISPLAY" ]; then
	_handle_wayland
else
	_handle_x
fi
