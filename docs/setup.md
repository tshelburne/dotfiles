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
│   └── languages.sh   # Programming languages (uv, volta)
├── packages/       # Package manager dependencies
│   └── install.sh     # Installs gems, volta packages (pnpm, diff-so-fancy, claude-code), and uv tools (claude-monitor)
└── launchagents/   # macOS background services
    └── ollama.sh      # Ollama LaunchAgent setup
```

## Main Setup Script

The `setup.sh` script orchestrates all installations:

1. Installs/updates Homebrew
2. Runs all scripts in `setup/brew/`
3. Runs all scripts in `setup/launchagents/`
4. Runs `setup/packages/install.sh` to install gems, npm packages (via volta), and Python tools (via uv)

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

## Python Setup with uv

This setup uses **uv** to manage Python versions and packages. uv is a fast, Rust-based package manager that:
- Manages Python versions (like pyenv)
- Installs packages 10-100x faster than pip
- Provides unified tool for venvs, dependencies, and global tools
- Drop-in replacement for pip, virtualenv, and pipx

### Installation

After running `setup.sh`, uv will be installed and Python 3.12 will be automatically installed:

```zsh
# Verify installation
python --version
uv --version

# Install additional Python versions
uv python install 3.11
uv python list
```

### Using uv

```zsh
# Install global CLI tools (like pipx)
uv tool install claude-monitor
uv tool install black
uv tool install ruff

# Create and use virtual environments
cd my-project
uv venv
source .venv/bin/activate

# Install packages (faster than pip)
uv pip install requests flask

# List installed tools
uv tool list
```

### Per-Project Python Management

uv automatically manages virtual environments and dependencies via `pyproject.toml`:

```toml
[project]
name = "my-project"
requires-python = ">=3.12"
dependencies = [
    "requests>=2.31.0",
    "flask>=3.0.0",
]
```

Then use `uv pip install -e .` to install dependencies. uv handles the venv automatically!

## Package Installation

Package installations are defined inline in `setup/packages/install.sh` and are automatically run by `setup.sh`.

You can also run them manually:

```zsh
./setup/packages/install.sh
```

This installs:
- **Ruby gems**: bundler
- **npm packages via volta**: diff-so-fancy, pnpm, @anthropic-ai/claude-code
- **Python tools via uv**: claude-monitor

To add new packages, edit [setup/packages/install.sh](setup/packages/install.sh) and add them to the appropriate section.

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
