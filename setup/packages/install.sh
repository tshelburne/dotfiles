#!/usr/bin/env bash

# Install packages via Ruby gems, volta (Node.js), and pip (Python)
# Requires: Ruby, Node.js (via volta), Python to be installed first

echo "Installing package manager packages..."

# Install Ruby gems
if command -v gem >/dev/null 2>&1; then
    echo "Installing Ruby gems..."
    gem install bundler
    echo "✓ Ruby gems installed"
else
    echo "⚠ gem not found, skipping Ruby gems"
fi

# Install npm global packages using volta
if command -v volta >/dev/null 2>&1; then
    echo "Installing npm global packages with volta..."

    # List of packages to install
    volta install diff-so-fancy
    volta install pnpm
    volta install @anthropic-ai/claude-code

    echo "✓ npm packages installed via volta"
else
    echo "⚠ volta not found. Install Node.js first:"
    echo "  volta install node"
fi

# Install Python packages
if command -v pip >/dev/null 2>&1; then
    echo "Installing Python packages..."
    pip install --upgrade pip setuptools
    pip install virtualenv
    echo "✓ Python packages installed"
else
    echo "⚠ pip not found, skipping Python packages"
fi

echo "✓ All package installations complete"
