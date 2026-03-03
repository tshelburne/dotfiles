#!/usr/bin/env bash

# Install general-purpose development tools

echo "Installing development tools..."

# Install other useful binaries
brew install ack
brew install tree

# Install GitHub CLI
brew install gh

# Install Google Cloud SDK
brew install --cask google-cloud-sdk

echo "✓ Development tools installed"
