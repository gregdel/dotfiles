########################################
#
#        SHARED CONFIG FILE
#
########################################

# Fix locals issue
export LC_ALL=C

# Set colors to match iTerm2 Terminal Colors
export TERM=xterm-256color

# vim as editor
export EDITOR=vim

# Node path
export NODE_PATH='/usr/local/lib/node_modules'

# Add perso bin path
if [ -d ~/.local/bin ]; then
    #On l'ajoute à la variable PATH
    export PATH=$PATH:~/.local/bin
fi

# Import personnal conf
if [ -f ~/.bashrc_local ]; then
    source ~/.bashrc_local
fi

# Import functions
if [ -f ~/.bashrc_functions ]; then
    source ~/.bashrc_functions
fi

# PS1 colored for git
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[31m\] $(parse_git_branch)\[\033[00m\]\$ '

# Import PS1
if [ -f ~/.bashrc_ps1 ]; then
    source ~/.bashrc_ps1
fi
