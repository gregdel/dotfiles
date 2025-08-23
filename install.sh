#!/bin/sh
set -e

export RCRC="$HOME/.dotfiles/rcrc"
export PATH="$HOME/.local/bin:$PATH"

_install() {
	dotfiles=$(dirname "$0")
	dotfiles=$(readlink -f "$dotfiles")
	GPKG_PKG_DIR="$dotfiles/gpkg.d" ./local/bin/gpkg install rcm
}

_err() {
	echo "$@"
	exit 1
}

_check_cmd() {
	command -v "$1" >/dev/null 2>/dev/null
}

_check_cmd make || _err "Please install make to install rcm"
_check_cmd rcup || _install
rcup -fv
