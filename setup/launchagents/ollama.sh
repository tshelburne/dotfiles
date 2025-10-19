#!/usr/bin/env zsh
set -euo pipefail

# Install Ollama if not already installed
if ! command -v ollama >/dev/null 2>&1; then
  echo "Installing Ollama..."
  brew install ollama
fi

brew services start ollama

echo "✅ Ollama is set to auto-start and stay alive under your user account."
echo "📍 Ollama is listening on localhost:11434"
echo "🌐 CORS enabled for all origins (Chrome extensions can access directly)"
