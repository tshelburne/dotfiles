#!/usr/bin/env bash

# Install packages from package manager lists
# Requires: Ruby, Node.js (via nvm), Python to be installed first

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Installing package manager packages..."

# Install Ruby gems
if [ -f "$SCRIPT_DIR/gems.txt" ]; then
    echo "Installing Ruby gems..."
    while read gem; do
        # Skip empty lines and comments
        [[ -z "$gem" || "$gem" =~ ^# ]] && continue
        gem install "$gem"
    done < "$SCRIPT_DIR/gems.txt"
    echo "✓ Ruby gems installed"
fi

# Install npm global packages
if [ -f "$SCRIPT_DIR/npm.txt" ]; then
    echo "Installing npm global packages..."
    # Check if npm is available
    if command -v npm >/dev/null 2>&1; then
        cat "$SCRIPT_DIR/npm.txt" | grep -v '^#' | grep -v '^$' | xargs npm install -g
        echo "✓ npm packages installed"
    else
        echo "⚠ npm not found. Install Node.js first:"
        echo "  nvm install --lts"
        echo "  nvm alias default lts/*"
    fi
fi

# Install Python packages
if [ -f "$SCRIPT_DIR/pip.txt" ]; then
    echo "Installing Python packages..."
    pip install -r "$SCRIPT_DIR/pip.txt"
    echo "✓ Python packages installed"
fi

echo "✓ All package installations complete"
