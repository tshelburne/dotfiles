#!/usr/bin/env bash

# Install programming languages and version managers

echo "Installing programming languages..."

# Install Python
brew install python

# Install nvm (Node Version Manager)
# Note: nvm is installed via Homebrew for easier management
brew install nvm

# Create nvm directory if it doesn't exist
mkdir -p ~/.nvm

echo "✓ Programming languages installed"
echo ""
echo "Next steps for Node.js:"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. Install Node.js LTS: nvm install --lts"
echo "  3. Set as default: nvm alias default lts/*"
