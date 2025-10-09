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
│   ├── packages/
│   └── launchagents/
├── legacy/         # Deprecated bash configs
├── docs/           # Documentation (you are here)
├── bootstrap.sh    # Main installation script
├── brew.sh         # Homebrew package installer
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
- `bootstrap.sh` - Creates all symlinks, sources zsh config
- `brew.sh` - Installs Homebrew packages and tools
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

### New LaunchAgent
Create script in `setup/launchagents/`, call from `brew.sh` if needed.

## Documentation
Each major directory has a doc file:
- `shell.md` - Shell configuration
- `git.md` - Git setup
- `config.md` - Application configs
- `scripts.md` - Utility scripts
- `setup.md` - Installation & packages
- `structure.md` - This file
