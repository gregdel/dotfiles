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

# Add perso bin path
if [ -d ~/.local/bin ]; then
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

# Import PS1
if [ -f ~/.bashrc_ps1 ]; then
    source ~/.bashrc_ps1
fi
