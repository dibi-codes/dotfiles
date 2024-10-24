#!/usr/bin/env bash

CURRENT_DIR=$(dirname "$(which $0 2>/dev/null || realpath $0)")

# Homebrew
echo "Installing brew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew analytics off

TAPS="${CURRENT_DIR}/taps.txt"

while read -r tap; do
  brew tap "$tap"
done <"$TAPS"

CASKS="${CURRENT_DIR}/casks.txt"

while read -r cask; do
  brew install --cask "$cask"
done <"$CASKS"

FORMULAE="${CURRENT_DIR}/formulae.txt"

while read -r formula; do
  brew install "$formula"
done <"$FORMULAE"

