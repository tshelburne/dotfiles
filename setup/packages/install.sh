#!/usr/bin/env bash

# Install packages via Ruby gems, volta (Node.js), and uv (Python)
# Requires: Ruby, Node.js (via volta), uv to be installed first

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

    # CLI-based claude setup
    claude mcp add --scope user --transport stdio browser npx @agent-infra/mcp-server-browser@latest 

    echo "✓ npm packages installed via volta"
else
    echo "⚠ volta not found. Install Node.js first:"
    echo "  volta install node"
fi

# Install Python tools using uv
if command -v uv >/dev/null 2>&1; then
    echo "Installing Python tools with uv..."

    # Install global tools (equivalent to pipx/global pip installs)
    uv tool install claude-monitor

    # Additional tools you might want:
    # uv tool install virtualenv
    # uv tool install black
    # uv tool install ruff
    # uv tool install mypy

    echo "✓ Python tools installed via uv"
else
    echo "⚠ uv not found. Install uv first:"
    echo "  brew install uv"
fi

echo "✓ All package installations complete"
