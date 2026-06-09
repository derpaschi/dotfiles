#!/bin/sh
#
# Homebrew
#
# Installs Homebrew if it's missing. The Brewfile then handles the actual
# packages, casks and Mac App Store apps (installed via `brew bundle` in
# script/install). The official installer works on both macOS and Linux.

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1
then
  echo "  Installing Homebrew for you."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

exit 0
