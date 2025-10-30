# Application Configuration

Location: `config/`

## Directory Structure

```
config/
├── vim/              # Vim editor
│   ├── .vimrc
│   ├── .gvimrc
│   └── .vim/
├── editors/          # Editor configs
│   ├── .editorconfig
│   └── sublime/      # Sublime Text settings
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
    ├── CLAUDE.md          # Main config (references code-style.md)
    ├── code-style.md      # Detailed code style preferences
    └── commands/          # Custom slash commands
        ├── review.md      # Code review command
        ├── test.md        # Test generation command
        ├── explain.md     # Code explanation command
        └── refactor.md    # Refactoring command
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

## EditorConfig

`.editorconfig` provides consistent coding styles across editors:
- 2-space indents for most files
- Trim trailing whitespace
- UTF-8 encoding

## Claude Code

- **settings.json** - Permissions (allowed, ask, deny)
- **CLAUDE.md** - Main config (references code-style.md)
- **code-style.md** - Code preferences and conventions
- **commands/** - Custom slash commands
