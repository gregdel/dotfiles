#!/bin/bash

export DISPLAY=:0
SCREEN_COUNT=$(xrandr | grep -w connected -c)
echo "Number of screens connected: ${SCREEN_COUNT}"

if [ "$SCREEN_COUNT" -ge 2 ]; then
    xrandr \
        --output eDP-1 --primary --mode 3200x1800 --pos 4032x0 --rotate normal --dpi 166 \
        --output DP-1 --mode 1920x1080 --pos 0x0 --rotate normal --scale 2x2 --auto \
        --output VIRTUAL-1 --off \
        --output HDMI-2 --off \
        --output HDMI-1 --off \
        --output DP-2 --off
else
    xrandr \
        --output eDP-1 --primary --mode 3200x1800 --pos 0x0 --rotate normal --dpi 166 \
        --output DP-1 --off \
        --output VIRTUAL-1 --off \
        --output HDMI-2 --off \
        --output HDMI-1 --off \
        --output DP-2 --off
fi

# shellcheck disable=1091
source /home/greg/.xinitrc
