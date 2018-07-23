#!/bin/bash

VERSION="v0.3.0"
URL="https://github.com/neovim/neovim.git"
BUILD_DIR_ROOT=$HOME/dev/build
BUILD_DIR=$BUILD_DIR_ROOT/neovim

if [ ! -d "$BUILD_DIR_ROOT" ]; then
    mkdir -p "$BUILD_DIR_ROOT"
fi

if [ ! -d "$BUILD_DIR" ]; then
    git clone "$URL" "$BUILD_DIR"
    cd neovim || exit 1
fi

cd "$BUILD_DIR" || exit 1
git pull origin master --tags
git checkout "$VERSION"

# Install dependencies
sudo apt update
sudo apt install -y libtool libtool-bin autoconf automake cmake g++ pkg-config unzip

# Make
rm -rf "$BUILD_DIR/build"
make clean
make CMAKE_BUILD_TYPE=Release

# Make install
sudo make install
