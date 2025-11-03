# Repository Structure

## Overview

```
dotfiles/
├── shell/          # Shell configuration (zsh)
├── git/            # Git configuration
├── config/         # Application configs
│   ├── vim/
│   ├── editors/
│   ├── terminal/
│   └── tools/
├── scripts/        # Utility scripts
├── setup/          # Installation & setup
│   ├── brew/          # Homebrew installers by category
│   ├── packages/      # Package manager lists + installer
│   └── launchagents/  # Background service setup
├── legacy/         # Deprecated bash configs
├── docs/           # Documentation (you are here)
├── bootstrap.sh    # Symlinks dotfiles to home directory
├── setup.sh        # Main setup script (runs all installations)
└── README.md
```

## Key Concepts

### Symlinks
The `bootstrap.sh` script creates symlinks from this repo to your home directory. This means:
- Edit files in the repo, changes take effect immediately
- See git diffs when you modify configs
- No need to re-run bootstrap after changes

### Shell-First Organization
- `shell/` - Everything for your terminal experience
- `git/` - Version control configuration
- `config/` - App-specific settings grouped by category

### Setup Scripts
- `setup.sh` - Main orchestrator: runs all installation scripts
- `bootstrap.sh` - Creates all symlinks, sources zsh config
- `setup/brew/*.sh` - Modular Homebrew installers by category
- `setup/packages/install.sh` - Installs gems, npm packages (via volta), Python tools (via uv)
- `setup/launchagents/*.sh` - Sets up background services

## Adding New Files

### New shell config
Add to `shell/` and update `bootstrap.sh` to symlink it.

### New app config
Put in appropriate `config/` subdirectory, update `bootstrap.sh`.

### New utility script
Add to `scripts/` (make it executable with `chmod +x`).

### New package list
Add to `setup/packages/` with appropriate extension.

### New Homebrew package
Add to appropriate script in `setup/brew/` or create a new category script.

### New LaunchAgent
Create script in `setup/launchagents/`, it will be auto-discovered by `setup.sh`.

## Documentation
Each major directory has a doc file:
- `shell.md` - Shell configuration
- `git.md` - Git setup
- `config.md` - Application configs
- `scripts.md` - Utility scripts
- `setup.md` - Installation & packages
- `structure.md` - This file
