#!/bin/sh

DOCK_DEVICE=/sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0/device

if [ -f "$DOCK_DEVICE" ]; then
	xrandr \
		--output eDP1 --primary --mode 3200x1800 --pos 4032x0 --rotate normal --dpi 166 \
		--output DP1 --mode 1920x1080 --pos 0x0 --rotate normal --scale 2x2 --auto \
		--output DP2 --off \
		--output VIRTUAL1 --off

	i3-msg restart
	systemctl --user stop compton.service
	systemctl --user restart polybar-external.service
	systemctl --user restart polybar.service
	systemctl --user restart wallpaper.service
	notify-send -i display "Monitor" "External monitor connected"
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
	notify-send -i display "Monitor" "External monitor disconnected"
fi
