#!/bin/bash

FONT_DIRECTORY=~/.local/share/fonts

FONT_VERSION="0.9.0"
FONT_URL="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/${FONT_VERSION}/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20for%20Powerline%20Nerd%20Font%20Complete.ttf"

if [ -d $FONT_DIRECTORY ]; then
    echo "Nothing to do as $FONT_DIRECTORY folder already exists"
    exit 0
fi

mkdir -p $FONT_DIRECTORY
cd ${FONT_DIRECTORY}

echo "Downloading fonts"
wget ${FONT_URL}

echo "Generating fontscale..."
mkfontscale

echo "Generating fontdir..."
mkfontdir

echo "Loading font folder to X..."
xset +fp ${FONT_DIRECTORY}
