#!/bin/sh

set -e

# shellcheck source=/dev/null
. "$HOME/.dotfiles/builds/lib"

_usage() {
	basename="$(basename "$0")"
	printf "USAGE:\n"
	printf "\t%s { install | uninstall } project_name\n" "$basename"
	printf "\t%s list\n" "$basename"
	printf "\t%s help\n" "$basename"
	exit 1
}

_list_projects() {
	printf "PROJECTS:\n"
	for p in "$PROJECTS_DIR"/*; do
		[ -d "$p" ] || continue
		printf "\t%s\n" "$(basename "$p")"
	done
}

cmd=$1
[ "$cmd" ] || _usage

PROJECT_NAME=$2
case "$cmd" in
	install|uninstall)
		[ "$PROJECT_NAME" ] || _usage
		export BUILD_PROJECT_PATH="$PROJECTS_DIR/$PROJECT_NAME"
		export BUILD_DIR_PATH="$CUSTOM_BUILD_DIR/$PROJECT_NAME"
		# shellcheck source=/dev/null
		. "$BUILD_PROJECT_PATH/build"
		_log "${cmd}ing $PROJECT_NAME"
		[ "$cmd" = "install" ] && _install
		[ "$cmd" = "uninstall" ] && _uninstall
		;;
	list)
		_list_projects
		;;
	*)
		_usage
		;;
esac
