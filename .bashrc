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

# PS1 colored for git
source ~/.git-prompt.sh
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\n\$ '

# Import PS1
if [ -f ~/.bashrc_ps1 ]; then
    source ~/.bashrc_ps1
fi

# System alias
alias ls='ls -G'

# Set appropriate ls alias
case $(uname -s) in
    Darwin|FreeBSD)
        alias ls="ls -FG"
        ;;
    Linux)
        alias ls="ls --color=always -F"
        ;;
esac
alias l='ls'
alias ll='ls -lh'
alias la='ls -lah'
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias git-pull-sub='git submodule foreach git pull origin master'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias c='clear'

# System functions
extract () {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)   tar xjf $1     ;;
			*.tar.gz)    tar xzf $1     ;;
			*.bz2)       bunzip2 $1     ;;
			*.rar)       unrar e $1     ;;
			*.gz)        gunzip $1      ;;
			*.tar)       tar xf $1      ;;
			*.tbz2)      tar xjf $1     ;;
			*.tgz)       tar xzf $1     ;;
			*.zip)       unzip $1       ;;
			*.Z)         uncompress $1  ;;
			*.7z)        7z x $1        ;;
		  	*) echo "'$1' cannot be extracted via extract()" ;;
	  	esac
  	else
	 	echo "'$1' is not a valid file"
  	fi
}

# Create dir and jump into it
function mcd() {
  mkdir -p "$1" && cd "$1";
}

function reload_bash
{
    source ~/.bashrc
}
