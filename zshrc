autoload -U compinit colors vcs_info
colors
compinit

# Completion
# Complete aliases
setopt COMPLETE_ALIASES
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1

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
bindkey -M viins 'jk' vi-cmd-mode

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

# vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats "%s  %r/%S %b (%a) %m%u%c "
zstyle ':vcs_info:*' stagedstr '%F{yellow}*%f '
zstyle ':vcs_info:*' unstagedstr '%F{green}*%f '
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git*' formats "%F{blue}%b%f %u%c"

_setup_prompt() {
  vcs_info

  _vim_mode='\❯'
  [ "x$KEYMAP" = "xvicmd" ] && _vim_mode='\❮'

  _ssh_agent=
  ssh-add -L >/dev/null && _ssh_agent=❯

  PS1="%B%(!.%F{red}root.%F{green}%n)@%m%f %F{blue}%~%f %F{red}%${_vim_mode}${_ssh_agent} %f%b"

  # Git prompt
  RPROMPT="%B$vcs_info_msg_0_%b"
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
bindkey -v

# Import functions
[ -f ~/.shell ] && . ~/.shell
