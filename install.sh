#!/bin/sh
set -e

export RCRC="$HOME/.dotfiles/rcrc"
export PATH="$HOME/.local/bin:$PATH"

_install() {
	GPKG_PKG_DIR="$(pwd)/gpkg.d" ./local/bin/gpkg install rcm
}

type rcup >/dev/null 2>/dev/null || _install

rcup -f

[ "$SHELL" = "/bin/zsh" ] && reload_zsh
