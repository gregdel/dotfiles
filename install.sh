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

type make >/dev/null 2>/dev/null || _err "Please install make to install rcm"

type rcup >/dev/null 2>/dev/null || _install

rcup -f
