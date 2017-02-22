#!/bin/bash

FONT_DIRECTORY=~/.local/share/fonts

FONT_VERSION="1.0.0"
FONTS_URL="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/$FONT_VERSION/patched-fonts"
FONTS="
    DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20for%20Powerline%20Nerd%20Font%20Complete%20Mono.ttf
    Inconsolata/complete/Inconsolata%20for%20Powerline%20Nerd%20Font%20Complete.otf
"

if [ -d $FONT_DIRECTORY ]; then
    echo "Nothing to do as $FONT_DIRECTORY folder already exists"
    exit 0
fi

mkdir -p $FONT_DIRECTORY
cd $FONT_DIRECTORY || exit 1

echo "Downloading fonts"
for font in $FONTS; do
    wget "$FONTS_URL/$font"
done

echo "Generating fontscale..."
mkfontscale

echo "Generating fontdir..."
mkfontdir

echo "Loading font folder to X..."
xset +fp $FONT_DIRECTORY
