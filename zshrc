################
#   oh-my-zsh
################
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Disable auto updates
DISABLE_AUTO_UPDATE="true"

# Dot when completion in progress
COMPLETION_WAITING_DOTS="true"

# oh-my-zsh plugins
plugins=( docker docker-compose git-prompt pass vi-mode )

source $ZSH/oh-my-zsh.sh
################
# / oh-my-zsh
################

# Bind jk keys to escape insert mode
bindkey -M viins 'jk' vi-cmd-mode

# Fix backspace on Debian
bindkey "^?" backward-delete-char

# Fix delete key on OSX
bindkey "\e[3~" delete-char

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

# Import ps1 / rps1
if [ -f ~/.zshrc_ps1 ]; then
    source ~/.zshrc_ps1
fi

# Import functions
if [ -f ~/.shell_functions ]; then
    source ~/.shell_functions
fi

function reload_zsh {
    source ~/.zshrc
    rehash
}
