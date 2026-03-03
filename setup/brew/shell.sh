#!/usr/bin/env bash

# Install shell and shell-related tools

echo "Installing shell tools..."

# Install zsh and completions (macOS includes zsh by default, but this gets the latest version)
brew install zsh
brew install zsh-completions

# Install useful CLI tools
brew install wget
brew install vim
brew install grep
brew install openssh
brew install screen

echo "✓ Shell tools installed"
