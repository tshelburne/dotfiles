#!/usr/bin/env bash

# Main setup script for new macOS machines
# Installs Homebrew packages, language packages, and sets up LaunchAgents

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "================================"
echo "macOS dotfiles setup"
echo "================================"
echo ""

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Ensure brew is installed
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make sure we're using the latest Homebrew
echo "Updating Homebrew..."
brew update

# Upgrade any already-installed formulae
echo "Upgrading existing packages..."
brew upgrade

echo ""
echo "================================"
echo "Installing Homebrew packages..."
echo "================================"
echo ""

# Run all brew installation scripts
for script in "$DOTFILES_DIR/setup/brew"/*.sh; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        "$script"
        echo ""
    fi
done

echo ""
echo "================================"
echo "Setting up LaunchAgents..."
echo "================================"
echo ""

# Run all LaunchAgent setup scripts
for script in "$DOTFILES_DIR/setup/launchagents"/*.sh; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        "$script"
        echo ""
    fi
done

# Remove outdated versions from the cellar
echo "Cleaning up Homebrew..."
brew cleanup

echo ""
echo "================================"
echo "Installing package manager packages..."
echo "================================"
echo ""

# Run package installations
chmod +x "$DOTFILES_DIR/setup/packages/install.sh"
"$DOTFILES_DIR/setup/packages/install.sh"

echo ""
echo "================================"
echo "Setup complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal"
echo "  2. ./bootstrap.sh"
echo ""
