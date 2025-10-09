# Setup & Installation

Location: `setup/`

## Directory Structure

```
setup/
├── packages/       # Package manager dependencies
│   ├── gems.txt    # Ruby gems to install
│   ├── npm.txt     # npm global packages
│   └── pip.txt     # Python packages
└── launchagents/   # macOS background services
    └── ollama.sh   # Ollama LaunchAgent setup
```

## Package Lists

### gems.txt
Ruby gems to install globally:
```zsh
while read gem; do
  gem install $gem
done < setup/packages/gems.txt
```

### npm.txt
Global npm packages:
```zsh
while read pkg; do
  npm install -g $pkg
done < setup/packages/npm.txt
```

### pip.txt
Python packages for virtualenv:
```zsh
pip install -r setup/packages/pip.txt
```

## LaunchAgents

macOS LaunchAgents are background services that:
- Start automatically at login
- Keep running (restart if crashed)
- Run without a visible window

### ollama.sh
Sets up Ollama to run as a LaunchAgent:
```zsh
./setup/launchagents/ollama.sh
```

Creates `~/Library/LaunchAgents/com.ollama.ollama.plist` and loads it.

## Creating New LaunchAgents

1. Create a new script in `setup/launchagents/`
2. Use `ollama.sh` as a template
3. Key elements:
   - Install via Homebrew (if needed)
   - Create plist file in `~/Library/LaunchAgents/`
   - Use `launchctl bootstrap` to load
   - Set `RunAtLoad` and `KeepAlive` for auto-start
