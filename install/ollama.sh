#!/usr/bin/env zsh
set -euo pipefail

# Install Ollama if not already installed
if ! command -v ollama >/dev/null 2>&1; then
  echo "Installing Ollama..."
  brew install ollama
fi

# Create LaunchAgent for current user
PLIST=~/Library/LaunchAgents/com.ollama.ollama.plist

mkdir -p ~/Library/LaunchAgents

cat > "$PLIST" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.ollama.ollama</string>
  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/bin/ollama</string>
    <string>serve</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
EOF

# Unload if already loaded (ignore errors), then load fresh
launchctl bootout gui/$(id -u) "$PLIST" 2>/dev/null || true
launchctl bootstrap gui/$(id -u) "$PLIST"
launchctl enable gui/$(id -u)/com.ollama.ollama
launchctl kickstart -k gui/$(id -u)/com.ollama.ollama

echo "✅ Ollama is set to auto-start and stay alive under your user account."
