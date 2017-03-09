#!/bin/bash

SCREEN_COUNT=$(xrandr | grep -w connected -c)
echo "Number of screens connected: ${SCREEN_COUNT}"

xrandr --output VIRTUAL1 --off
xrandr --output HDMI2 --off
xrandr --output HDMI1 --off
xrandr --output DP2 --off

if [ "$SCREEN_COUNT" -ge 2 ]; then
    xrandr --output eDP1 --primary --mode 3200x1800 --pos 4032x0
    xrandr --output DP1 --mode 1920x1080 --pos 0x0 --dpi 96 --scale 2.1x2.1
else
    xrandr --output DP1 --off
    xrandr --output eDP1 --primary --mode 3200x1800 --pos 0x0
fi

# shellcheck disable=1090
source "$HOME/.xinitrc"
