#!/usr/bin/env bash

# Install packages from package manager lists
# Requires: Ruby, Node.js (via volta), Python to be installed first

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

# Install npm global packages using volta
if [ -f "$SCRIPT_DIR/npm.txt" ]; then
    echo "Installing npm global packages with volta..."
    # Check if volta is available
    if command -v volta >/dev/null 2>&1; then
        # Use volta to install each package as a tool (better than npm install -g)
        while IFS= read -r package; do
            # Skip empty lines and comments
            [[ -z "$package" || "$package" =~ ^# ]] && continue
            echo "Installing $package..."
            volta install "$package"
        done < <(grep -v '^#' "$SCRIPT_DIR/npm.txt" | grep -v '^$')
        echo "✓ npm packages installed via volta"
    else
        echo "⚠ volta not found. Install Node.js first:"
        echo "  volta install node"
    fi
fi

# Install Python packages
if [ -f "$SCRIPT_DIR/pip.txt" ]; then
    echo "Installing Python packages..."
    pip install -r "$SCRIPT_DIR/pip.txt"
    echo "✓ Python packages installed"
fi

echo "✓ All package installations complete"
