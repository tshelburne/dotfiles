# Setup & Installation

Location: `setup/` and root `setup.sh`

## Quick Start

For a new macOS machine:

```zsh
# 1. Install all Homebrew packages, LaunchAgents, and package manager tools
./setup.sh

# 2. Symlink dotfiles to home directory
source bootstrap.sh
```

## Directory Structure

```
setup/
├── brew/           # Homebrew package installation scripts
│   ├── coreutils.sh   # GNU core utilities
│   ├── shell.sh       # zsh and shell tools
│   ├── tools.sh       # Development tools
│   ├── security.sh    # CTF and security tools
│   └── languages.sh   # Programming languages (Python, nvm)
├── packages/       # Package manager dependencies
│   ├── install.sh     # Installs all packages below
│   ├── gems.txt       # Ruby gems to install
│   ├── npm.txt        # npm global packages
│   └── pip.txt        # Python packages
└── launchagents/   # macOS background services
    └── ollama.sh      # Ollama LaunchAgent setup
```

## Main Setup Script

The `setup.sh` script orchestrates all installations:

1. Installs/updates Homebrew
2. Runs all scripts in `setup/brew/`
3. Runs all scripts in `setup/launchagents/`
4. Runs `setup/packages/install.sh` to install gems, npm packages, and pip packages

This modular approach makes it easy to:
- Add new Homebrew packages by creating a new script in `setup/brew/`
- Add new LaunchAgents by creating a new script in `setup/launchagents/`
- Skip specific categories if needed

## Node.js Setup with nvm

This setup uses **nvm (Node Version Manager)** to manage Node.js versions. This allows you to:
- Switch between different Node.js versions per project
- Install multiple versions side-by-side
- Avoid permission issues with global packages

### Installation

After running `brew.sh`, nvm will be installed. To set up Node.js:

```zsh
# Install the latest LTS version
nvm install --lts

# Set it as the default
nvm alias default lts/*

# Verify installation
node --version
npm --version
```

### Using nvm

```zsh
# List available versions
nvm ls-remote

# Install a specific version
nvm install 20.10.0

# Switch to a version
nvm use 20

# Check current version
nvm current
```

### Per-Project Node Versions

Create a `.nvmrc` file in your project:
```
20.10.0
```

Then run `nvm use` in that directory to automatically switch versions.

## Package Lists

Package lists are located in `setup/packages/` and are automatically installed by `setup.sh`.

You can also install them manually:

### gems.txt
Ruby gems to install globally:
```zsh
while read gem; do
  [[ -z "$gem" || "$gem" =~ ^# ]] && continue
  gem install "$gem"
done < setup/packages/gems.txt
```

### npm.txt
Global npm packages (install after setting up Node.js with nvm):
```zsh
cat setup/packages/npm.txt | grep -v '^#' | grep -v '^$' | xargs npm install -g
```

### pip.txt
Python packages for virtualenv:
```zsh
pip install -r setup/packages/pip.txt
```

Or run them all at once:
```zsh
./setup/packages/install.sh
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
