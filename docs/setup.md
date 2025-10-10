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
│   └── languages.sh   # Programming languages (Python, volta)
├── packages/       # Package manager dependencies
│   ├── install.sh     # Installs all packages below
│   ├── gems.txt       # Ruby gems to install
│   ├── npm.txt        # npm global packages (via volta)
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

## Node.js Setup with volta

This setup uses **volta** to manage Node.js versions. Volta is a fast, Rust-based version manager that:
- Automatically switches versions per project (reads from `package.json`)
- Installs multiple versions side-by-side
- Provides instant version switching (no shell sourcing)
- Avoids permission issues with global packages

### Installation

After running `setup.sh`, volta will be installed. To set up Node.js:

```zsh
# Install the latest Node.js (LTS by default)
volta install node

# Install a specific version
volta install node@20

# Verify installation
node --version
npm --version
```

### Using volta

```zsh
# Install global packages as volta-managed tools
volta install pnpm
volta install typescript

# Check which version is active
volta list

# Pin a version to a project (adds to package.json)
cd my-project
volta pin node@20
```

### Per-Project Node Versions

Volta automatically switches Node versions based on `package.json`. Add this to your project:

```json
{
  "volta": {
    "node": "20.10.0",
    "npm": "10.2.3"
  }
}
```

When you `cd` into the directory, volta automatically uses those versions. No manual switching needed!

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
Global npm packages (install after setting up Node.js with volta):
```zsh
# Via volta (recommended - installs as managed tools)
./setup/packages/install.sh

# Or manually install each package
volta install diff-so-fancy
volta install pnpm
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
