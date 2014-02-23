################
#   oh-my-zsh
################
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="gallois"

# Dot when completion in progress
COMPLETION_WAITING_DOTS="true"

# oh-my-zsh plugins
plugins=(git brew vi-mode)

source $ZSH/oh-my-zsh.sh
################
# / oh-my-zsh
################

alias zshconfig="vim ~/.zshrc"

# Import functions
if [ -f ~/.shell_functions ]; then
    source ~/.shell_functions
fi


# User configuration

# export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/Users/gregoiredelattre/.local/bin"
# export MANPATH="/usr/local/man:$MANPATH"


function reload_zsh {
    source ~/.zshrc
}
