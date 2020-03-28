#!/bin/sh
set -e

_help() {
	echo "$0 [start|stop|status|toggle]"
	exit 1
}

_status() {
	if systemctl --user is-active syncthing >/dev/null; then
		echo ""
		return 0
	else
		echo ""
		return 1
	fi
}

_open() {
	o http://localhost:8384
}

_start() {
	systemctl --user start syncthing
}

_stop() {
	systemctl --user stop syncthing
}

_toggle() {
	if _status >/dev/null; then
		_stop
	else
		_start
	fi
}

case "$1" in
	status)  _status ;;
	start)   _start  ;;
	stop)    _stop   ;;
	toggle)  _toggle ;;
	open)    _open   ;;
	*)       _help   ;;
esac
