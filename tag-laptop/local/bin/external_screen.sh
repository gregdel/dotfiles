#!/bin/bash

export DISPLAY=:0
SCREEN_COUNT=$(xrandr | grep -w connected -c)
echo "Number of screens connected: ${SCREEN_COUNT}"

if [ "$SCREEN_COUNT" -ge 2 ]; then
    xrandr \
        --output eDP1 --primary --mode 3200x1800 --pos 4032x0 --rotate normal --dpi 166 \
        --output DP1 --mode 1920x1080 --pos 0x0 --rotate normal --scale 2x2 --auto \
        --output VIRTUAL1 --off \
        --output HDMI2 --off \
        --output HDMI1 --off \
        --output DP2 --off
else
    xrandr \
        --output eDP1 --primary --mode 3200x1800 --pos 0x0 --rotate normal --dpi 166 \
        --output DP1 --off \
        --output VIRTUAL1 --off \
        --output HDMI2 --off \
        --output HDMI1 --off \
        --output DP2 --off
fi

# shellcheck disable=1091
source /home/greg/.xinitrc
