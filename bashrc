# Bash configuration
# shellcheck disable=1090

color_off="\001$(tput sgr0)\002"
color_red="\001$(tput setaf 1)\002"
color_green="\001$(tput setaf 2)\002"
color_yellow="\001$(tput setaf 3)\002"
color_blue="\001$(tput setaf 4)\002"

_git_prompt() {
	git_cmd=$(git status --porcelain --branch 2>/dev/null)
	[ "$git_cmd" ] || return 0

	local branch
	case "$git_cmd" in
		*No\ commits\ yet*) branch="no commits yet"                   ;;
		*no\ branch*)       branch=$(git describe --tags --always)    ;;
		*)                  branch=$(git rev-parse --abbrev-ref HEAD) ;;
	esac

	local output="${color_red}$branch${color_off}"
	case "$git_cmd" in *M\ \ *)  output="$output ${color_yellow}✗${color_off}" ;; esac
	case "$git_cmd" in *R\ \ *)  output="$output ${color_yellow}→${color_off}" ;; esac
	case "$git_cmd" in *\ M\ *)  output="$output ${color_green}✗${color_off}"  ;; esac
	case "$git_cmd" in *\?\?*)   output="$output ${color_blue}…${color_off}"   ;; esac
	case "$git_cmd" in *ahead*)  output="$output ${color_green}↑${color_off}"  ;; esac
	case "$git_cmd" in *behind*) output="$output ${color_green}↓${color_off}"  ;; esac

	echo -e " ${color_off}[$output]"
}

PS1="${color_blue}\w"
PS1+='$(_git_prompt)'
case "$USER" in
	(root) PS1+="${color_red} #"   ;;
	(*)    PS1+="${color_green} ❯" ;;
esac
PS1+="$color_off "

[ -f ~/.shell ] && . ~/.shell
[ -f ~/.bashrc_local ] && . ~/.bashrc_local

reload_bash() {
    . ~/.bashrc
}
