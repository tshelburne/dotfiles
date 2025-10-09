# Shell Configuration

Location: `shell/`

## Files

- `.zshrc` - Main zsh configuration (interactive shells)
- `.zprofile` - zsh login shell configuration
- `.aliases` - Command aliases (works with any POSIX shell)
- `.functions` - Custom shell functions
- `.exports` - Environment variables
- `.extra` - Private/local settings (not in git)

## What Gets Loaded

When you open a terminal:
1. `.zprofile` (login shells only - sets up PATH, Homebrew)
2. `.zshrc` (always - loads aliases, functions, prompt)

## Customization

Create `~/.extra` for local settings you don't want to commit:
```zsh
# Git credentials
GIT_AUTHOR_NAME="Your Name"
git config --global user.name "$GIT_AUTHOR_NAME"
```

## Key Features

- Custom zsh prompt with git status indicators
- History configuration (10,000 entries, shared across sessions)
- Smart completion (case-insensitive, SSH hosts from ~/.ssh/config)
- Auto-cd (type directory name to navigate)
- Directory marking functions (from `scripts/marks/`)
