#!/usr/bin/env bash

# Install shell and shell-related tools

echo "Installing shell tools..."

# Install zsh and completions (macOS includes zsh by default, but this gets the latest version)
brew install zsh
brew install zsh-completions

# Install `wget` with IRI support.
brew install wget --with-iri

# Install more recent versions of some OS X tools.
brew install vim --override-system-vi
brew install homebrew/dupes/grep
brew install homebrew/dupes/openssh
brew install homebrew/dupes/screen

echo "✓ Shell tools installed"
