#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch bars
polybar laptop &

SCREEN_COUNT=$(xrandr | grep -w connected -c)
if [ "$SCREEN_COUNT" -ge 2 ]; then
	polybar external_display &
fi

echo "Bars launched..."
