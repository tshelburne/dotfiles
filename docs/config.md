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
└── tools/            # CLI tools
    ├── .curlrc
    ├── .wgetrc
    ├── .hgignore
    └── .gdbinit
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
