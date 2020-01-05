# Colors
autoload -U colors && colors

# Completion
autoload -U compinit
setopt COMPLETE_ALIASES
setopt NO_LIST_AMBIGUOUS
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zmodload zsh/complist

compinit

# Report command running time if it is more than 3 seconds
REPORTTIME=3
# Keep a lot of history
HISTFILE=~/.zhistory
HISTSIZE=5000
SAVEHIST=5000
# Do not keep duplicate commands in history
setopt HIST_IGNORE_ALL_DUPS
# Do not remember commands that start with a whitespace
setopt HIST_IGNORE_SPACE

# Bind jk keys to escape insert mode
bindkey -v
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M menuselect '^h' vi-backward-char

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Ctrl-R
bindkey '^R' history-incremental-search-backward

# Search through previous commands
bindkey "\e[A"  up-line-or-beginning-search
bindkey "\e[B"  down-line-or-beginning-search

autoload up-line-or-beginning-search
autoload down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Don't share history
setopt append_history no_inc_append_history no_share_history

# Ctrl-z to go back to vi after Ctrl-z
fancy-ctrl-z () {
	if [[ $#BUFFER -eq 0 ]]; then
		BUFFER="fg"
		zle accept-line
	else
		zle push-input
		zle clear-screen
	fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

function reload_zsh {
	. ~/.zshrc
	rehash
}

_git_prompt() {
	git_cmd=$(git status --porcelain --branch 2>/dev/null)
	[ "$git_cmd" ] || return 0

	local branch
	case "$git_cmd" in
		*no\ branch*)	branch=$(git describe --tags --always)		;;
		*)				branch=$(git rev-parse --abbrev-ref HEAD)	;;
	esac

	local output="%F{blue}$branch%f"
	case "$git_cmd" in *M\ \ *)  output="$output %F{yellow}✗%f"  ;; esac
	case "$git_cmd" in *R\ \ *)  output="$output %F{yellow}→%f"  ;; esac
	case "$git_cmd" in *\ M\ *)  output="$output %F{green}✗%f"   ;; esac
	case "$git_cmd" in *\?\?*)   output="$output %F{blue}…%f"    ;; esac
	case "$git_cmd" in *ahead*)  output="$output %F{green}↑%f"   ;; esac
	case "$git_cmd" in *behind*) output="$output %F{green}↓%f"   ;; esac

	echo "$output"
}

_setup_prompt() {
	local _vim_mode='%F{red}%(!.#.❯)%f'
	[ "x$KEYMAP" = "xvicmd" ] && _vim_mode='%(!.%F{green}#.%F{green}❮)%f'

	local _ssh_agent=
	ssh-add -L >/dev/null 2>/dev/null && _ssh_agent='%F{green}•%f '

	local _remote_connection=
	[ "$SSH_CONNECTION" ] && _remote_connection='%(!.%F{red}root.%F{green}%n)@%m%f '

	PS1="%B${_ssh_agent}${_remote_connection}%F{blue}%~%f %F{red}${_vim_mode} %f%b"

	# Git prompt
	RPROMPT="%B$(_git_prompt)%b"
}
_setup_prompt

# Vi mode
zle-keymap-select () {
	_setup_prompt
	zle reset-prompt
}

zle -N zle-keymap-select
zle-line-init () {
	zle -K viins
}
zle -N zle-line-init

# Import functions
[ -f ~/.shell ] && . ~/.shell
