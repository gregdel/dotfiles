########################################
#
#        SHARED CONFIG FILE
#
########################################

# Set colors to match iTerm2 Terminal Colors
export TERM=xterm-256color

# vim as editor
export EDITOR=vim

# allow utf8
stty cs8 -istrip -parenb
bind 'set convert-meta off'
bind 'set meta-flag on'
bind 'set output-meta on'

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

# Import virtualenwrapper
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    source /usr/local/bin/virtualenvwrapper.sh
fi

# Homebrew
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
