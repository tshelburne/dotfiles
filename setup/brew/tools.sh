#!/usr/bin/env bash

# Install general-purpose development tools

echo "Installing development tools..."

# Install other useful binaries
brew install ack
brew install tree

# Install GitHub CLI
brew install gh

# Install LastPass CLI. Holds the delivery credentials, read by name, so granting
# a repository one is a pipe into `gh secret set` with nothing pasted anywhere:
#   lpass show --password GH_PACKAGES_TOKEN | gh secret set GH_PACKAGES_TOKEN --repo <owner/name>
brew install lastpass-cli

# Install Google Cloud SDK
brew install --cask google-cloud-sdk

echo "✓ Development tools installed"
