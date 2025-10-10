#!/usr/bin/env zsh
set -euo pipefail

# Install Caddy if not already installed
if ! command -v caddy >/dev/null 2>&1; then
  echo "Installing Caddy..."
  brew install caddy
fi

# Create Caddyfile for Ollama CORS proxy
CADDYFILE=~/.config/caddy/Caddyfile.ollama

mkdir -p ~/.config/caddy

cat > "$CADDYFILE" <<'EOF'
# Caddy proxy for Ollama with CORS headers
# Proxies requests from :8787 to Ollama at :11434
# Enables Chrome extensions to communicate with Ollama

:8787 {
	# Enable CORS for all origins
	@options {
		method OPTIONS
	}

	# Handle preflight requests
	handle @options {
		header {
			Access-Control-Allow-Origin "*"
			Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
			Access-Control-Allow-Headers "*"
			Access-Control-Max-Age "3600"
		}
		respond 204
	}

	# Proxy all requests to Ollama
	reverse_proxy localhost:11434 {
		# Add CORS headers to all responses
		header_up Host {upstream_hostport}
		header_down Access-Control-Allow-Origin "*"
		header_down Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
		header_down Access-Control-Allow-Headers "*"
	}
}
EOF

echo "✅ Created Caddyfile at $CADDYFILE"

# Create LaunchAgent for current user
PLIST=~/Library/LaunchAgents/com.ollama.proxy.plist

mkdir -p ~/Library/LaunchAgents

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.ollama.proxy</string>
  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/bin/caddy</string>
    <string>run</string>
    <string>--config</string>
    <string>$CADDYFILE</string>
    <string>--adapter</string>
    <string>caddyfile</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$HOME</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/ollama-proxy.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/ollama-proxy.error.log</string>
</dict>
</plist>
EOF

echo "✅ Created LaunchAgent plist"

# Unload if already loaded (ignore errors), then load fresh
launchctl bootout gui/$(id -u) "$PLIST" 2>/dev/null || true
launchctl bootstrap gui/$(id -u) "$PLIST"
launchctl enable gui/$(id -u)/com.ollama.proxy
launchctl kickstart -k gui/$(id -u)/com.ollama.proxy

echo "✅ Ollama proxy is set to auto-start and stay alive under your user account."
echo "📍 Proxying localhost:8787 → localhost:11434 (Ollama)"
echo "🌐 Chrome extensions can now use http://localhost:8787 with CORS enabled"
echo "📝 Logs available at:"
echo "   ~/Library/Logs/ollama-proxy.log"
echo "   ~/Library/Logs/ollama-proxy.error.log"
