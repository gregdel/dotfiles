#!/bin/bash

# Find current script dir
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
BIN_DIR=$HOME/.local/bin

# Read input with default value
read -p "Install all files for '$USER' user ? (Y/n)" -n 1 choice
choice=${choice:-"y"};

# Yes or no ?
case ${choice} in
    y|Y)
        if [ ! -d $BIN_DIR ]; then
            mkdir -p $HOME/.local/bin
        fi

        # Config files
        FILES=(
            .bashrc
            .bashrc_ps1
            .gitconfig
            .inputrc
            .oh-my-zsh
            .screenrc
            .shell_functions
            .tmux.conf
            .vim
            .vimrc
            .zshrc
            .zshrc_ps1
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

        # Binary files
        FILES=(
            bin/z.sh
            bin/keychain
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
                SYMBOLIC_LINK="${HOME}/.local/${FILE}"
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
