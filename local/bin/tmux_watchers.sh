#!/bin/sh

SESSION_NAME=$(tmux display-message -p '#S')
NB_WATCHERS=$(tmux list-clients -t "${SESSION_NAME}" | wc -l | sed -e 's/^[[:space:]]*//')
if [ "$NB_WATCHERS" -gt "1" ]; then
    echo " $NB_WATCHERS watchers "
fi
