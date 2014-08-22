#! /bin/bash

# set mapping to qwerty
setxkbmap us
# use right alt as compose key
setxkbmap -option compose:ralt

# Super fast typing
xset r rate 200 44

# export locales
export LC_ALL=en_US.UTF-8

# execute awesome
exec awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr
