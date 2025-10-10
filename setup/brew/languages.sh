#!/usr/bin/env bash

# Install programming languages and version managers

echo "Installing programming languages..."

# Install Python
brew install python

# Install volta (Fast Node.js version manager)
# Note: volta is installed via Homebrew for easier management
brew install volta

echo "✓ Programming languages installed"
echo ""
echo "Next steps for Node.js:"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. Install Node.js: volta install node"
echo "  3. (Optional) Install specific version: volta install node@20"
