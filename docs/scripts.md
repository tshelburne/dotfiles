# Scripts & Utilities

Location: `scripts/`

## Files

### `.osx`
Configures macOS system preferences. Run once on a new Mac:
```zsh
./scripts/.osx
```

**Warning**: This script changes many system settings. Review it first!

Key changes:
- Finder preferences (show extensions, full POSIX path)
- Dock settings (auto-hide, fast animations)
- Keyboard & trackpad (fast repeat rate, tap-to-click)
- Safari & app settings
- Hot corners configuration

### `httpcompression`
Tests HTTP compression for URLs:
```zsh
./scripts/httpcompression https://example.com
```

Shows which content-encoding (gzip, deflate, sdch) the server uses.

### `marks/`
Directory bookmarking functions:
- `jump <mark>` - Jump to a bookmarked directory
- `mark <name>` - Bookmark current directory
- `unmark <name>` - Remove bookmark
- `marks` - List all bookmarks

These are loaded automatically by `.zshrc`.
