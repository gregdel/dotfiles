#!/bin/bash

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils
echo "Don’t forget to add $(brew --prefix coreutils)/libexec/gnubin to \$PATH."
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils
# Install Bash 4
brew install bash

# Install more recent versions of some OS X tools
brew install homebrew/dupes/grep
install vim --override-system-vi
install lynx
install node
install tree
install aria2

# Install everything else
brew install ack
brew install git


# Remove outdated versions from the cellar
brew cleanup
