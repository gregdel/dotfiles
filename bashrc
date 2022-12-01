# Bash configuration
# shellcheck disable=1090

color_off="\001$(tput sgr0)\002"
color_red="\001$(tput bold)$(tput setaf 1)\002"
color_green="\001$(tput bold)$(tput setaf 2)\002"
color_yellow="\001$(tput bold)$(tput setaf 3)\002"
color_blue="\001$(tput bold)$(tput setaf 4)\002"
color_yo="\001$(tput bold)$(tput setaf 7)\002"

_git_prompt() {
	git_cmd=$(git status --porcelain --branch 2>/dev/null)
	[ "$git_cmd" ] || return 0

	local branch
	case "$git_cmd" in
		*No\ commits\ yet*) branch="no commits yet"                   ;;
		*no\ branch*)       branch=$(git describe --tags --always)    ;;
		*)                  branch=$(git rev-parse --abbrev-ref HEAD) ;;
	esac

	local output=" ${color_yo}$branch${color_off}"
	case "$git_cmd" in *M\ \ *)  output="$output ${color_yellow}✗${color_off}" ;; esac
	case "$git_cmd" in *R\ \ *)  output="$output ${color_yellow}→${color_off}" ;; esac
	case "$git_cmd" in *\ M\ *)  output="$output ${color_green}✗${color_off}"  ;; esac
	case "$git_cmd" in *\?\?*)   output="$output ${color_blue}…${color_off}"   ;; esac
	case "$git_cmd" in *ahead*)  output="$output ${color_green}↑${color_off}"  ;; esac
	case "$git_cmd" in *behind*) output="$output ${color_green}↓${color_off}"  ;; esac

	echo -e " - $output"
}

_ssh_agent() {
	ssh-add -L >/dev/null 2>/dev/null || return 0
	echo -e "${color_green}•${color_off} "
}

_ssh_connection() {
	[ -z "$SSH_CONNECTION" ] && return 0
	echo -e "${color_green}$USER@$HOSTNAME${color_off} "
}

PS1=
PS1+='$(_ssh_agent)'
PS1+='$(_ssh_connection)'
PS1+="${color_blue}\w${color_off}"
PS1+='$(_git_prompt)'
PS1+="${color_red} "
case "$USER" in
	(root) PS1+="#" ;;
	(*)    PS1+="❯" ;;
esac
PS1+="$color_off "

[ -f ~/.shell ] && . ~/.shell
[ -f ~/.bashrc_local ] && . ~/.bashrc_local

reload_bash() {
    . ~/.bashrc
}
