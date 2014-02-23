#!/bin/bash

RM_COLORS='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'

# Find current script dir
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Read input with default value
read -p "Install all files for '$USER' user ? (Y/n)" -n 1 choice
choice=${choice:-"y"};

# Yes or no ?
case ${choice} in
    y|Y)
        # Config files
        FILES=(
            .bashrc
            .bashrc_ps1
            .zshrc
            .oh-my-zsh
            .shell_functions
            .gitconfig
            .inputrc
            .screenrc
            .vim
            .vimrc
        )

        for FILE in  ${FILES[@]}
        do
            if [ -f ~/${FILE} ]
            then
                echo "File exists : ${FILE} not linked"
            elif [ -d ~/${FILE} ]
            then
                echo "Folder exists: ${FILE} not linked"
            else
                ORIGINAL_FILE="${DIR}/${FILE}"
                SYMBOLIC_LINK="${HOME}/${FILE}"
                `ln -s "${ORIGINAL_FILE}" "${SYMBOLIC_LINK}"`
                echo "${FILE} linked"
            fi
        done
        ;;
    n|N)
        echo "Too bad.."
        exit
        ;;
esac
