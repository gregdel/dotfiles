################
#   oh-my-zsh
################
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Dot when completion in progress
COMPLETION_WAITING_DOTS="true"

# oh-my-zsh plugins
plugins=(git brew vi-mode)

source $ZSH/oh-my-zsh.sh
################
# / oh-my-zsh
################

# Bind jk keys to escape insert mode
bindkey -M viins 'jk' vi-cmd-mode

# Import functions
if [ -f ~/.shell_functions ]; then
    source ~/.shell_functions
fi

# Import ps1 / rps1
if [ -f ~/.zshrc_ps1 ]; then
    source ~/.zshrc_ps1
fi

function reload_zsh {
    source ~/.zshrc
}

# fix backspace on Debian
bindkey "^?" backward-delete-char

# fix delete key on OSX
bindkey "\e[3~" delete-char