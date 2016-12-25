#!/bin/bash

VERSION="neomutt-20161126"
URL="https://github.com/neomutt/neomutt.git"
BUILD_DIR_ROOT=$HOME/dev/build
BUILD_DIR=$BUILD_DIR_ROOT/neomutt

if [ ! -d ${BUILD_DIR_ROOT} ]; then
    mkdir -p ${BUILD_DIR_ROOT}
fi

if [ ! -d ${BUILD_DIR} ]; then
    git clone ${URL} ${BUILD_DIR}
    cd neomutt
fi

cd ${BUILD_DIR}
git pull origin master --tags
git checkout ${VERSION}

# Install dependencies
sudo apt update
sudo apt install -y libssl-dev xsltproc libncursesw6-dev libtokyocabinet-dev

# Configure and make
autoreconf --install
./configure --enable-sidebar --enable-smtp --with-ssl --with-sasl --enable-hcache --with-tokyocabinet
make

# Make install
sudo make install
