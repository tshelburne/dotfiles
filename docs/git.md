# Git Configuration

Location: `git/`

## Files

- `.gitconfig` - Git user settings, aliases, and preferences
- `.gitignore` - Global gitignore patterns
- `.githelpers` - Helper scripts for pretty git logs
- `.gitattributes` - Git attributes for line endings
- `.gitcompletion.zsh` - Zsh completion for git commands

## Key Aliases

Check `.gitconfig` for full list. Common ones:
- `git st` - status
- `git co` - checkout
- `git br` - branch
- `git d` - diff with diff-so-fancy

## Setup

The bootstrap script symlinks these files to your home directory as:
- `~/.gitconfig`
- `~/.gitignore`
- etc.

Update your name/email in `.gitconfig` or use `~/.extra`:
```zsh
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```
