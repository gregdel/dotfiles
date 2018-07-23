#!/bin/bash

VERSION="neomutt-20180716"
URL="https://github.com/neomutt/neomutt.git"
BUILD_DIR_ROOT="$HOME/dev/build"
BUILD_DIR="$BUILD_DIR_ROOT/neomutt"

[ ! -d "$BUILD_DIR_ROOT" ] && mkdir -p "$BUILD_DIR_ROOT"
[ ! -d "$BUILD_DIR" ] && git clone "$URL" "$BUILD_DIR"

cd "$BUILD_DIR" || exit 1
git pull origin master --tags
git checkout "$VERSION"

# Configure and make
./configure \
	--disable-doc \
	--tokyocabinet \
	--ssl
make
