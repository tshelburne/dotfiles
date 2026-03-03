# Dotfiles

Zsh-only macOS dotfiles. See `docs/` for detailed documentation.

## Key Conventions

- **Two scripts**: `setup.sh` installs packages/tools, `bootstrap.sh` symlinks configs to `~`
- **Symlink-based**: edit files in the repo, not in `~` — changes apply immediately
- **Auto-discovery**: `setup.sh` finds and runs all `.sh` files in `setup/` subdirectories
- **Package managers**: use `volta install` for Node packages (not `npm install -g`), `uv tool install` for Python CLI tools (not pip)
- **Claude Code**: installed via `curl -fsSL https://claude.ai/install.sh | bash`, not via volta/npm
- **Main branch**: `main`
