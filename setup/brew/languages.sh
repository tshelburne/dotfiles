#!/usr/bin/env bash

# Install programming languages and version managers

echo "Installing programming languages..."

# Install uv (Fast Python package and version manager)
brew install uv
uv python install 3.12

# Install volta (Fast Node.js version manager)
# Note: volta is installed via Homebrew for easier management
brew install volta
volta install node@latest

echo "✓ Programming languages installed"
echo ""
echo "Python 3.12 and Node.js (latest) have been installed"
echo ""
echo "Optional next steps:"
echo "  - Install other Python versions: uv python install 3.11"
echo "  - Install specific Node.js version: volta install node@20"
