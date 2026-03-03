# Application Configuration

Location: `config/`

## Directory Structure

```
config/
├── vim/              # Vim editor
│   ├── .vimrc
│   ├── .gvimrc
│   └── .vim/
├── terminal/         # Terminal apps
│   ├── .inputrc      # Readline config
│   ├── .screenrc     # GNU Screen
│   ├── .hushlogin    # Suppress login message
│   └── themes/       # Color schemes for iTerm/Terminal
├── tools/            # CLI tools
│   ├── .curlrc
│   ├── .wgetrc
│   ├── .hgignore
│   └── .gdbinit
└── claude/           # Claude Code configuration
    ├── settings.json       # Permissions and settings
    └── skills/            # Claude Code skills
        └── code-style/    # Code style guidelines
            └── SKILL.md
```

## Vim

The `.vim/` directory contains:
- `backups/` - Backup files location
- `colors/` - Color schemes
- `swaps/` - Swap files location
- `syntax/` - Custom syntax files
- `undo/` - Persistent undo history

## Terminal Themes

Color schemes for:
- iTerm 2 (`.itermcolors`)
- Terminal.app (`.terminal`)

Based on Solarized Dark theme.

## Claude Code

- **settings.json** - Permissions (allowed, ask, deny)
- **skills/** - Claude Code skills (symlinked to `~/.claude/skills/`)
  - **code-style/** - Code style guidelines for writing, reviewing, and fixing code
