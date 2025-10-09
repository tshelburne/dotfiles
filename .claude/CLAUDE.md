# Claude Context: macOS Dotfiles Repository

## Repository Purpose
This is a **zsh-only dotfiles repository** for setting up new macOS machines with personal configurations and development tools.

## Key Design Decisions

### 1. Symlink-Based Installation
- **`bootstrap.sh`** creates symlinks from repo → home directory
- Edit files in the repo, changes apply immediately to home directory
- No need to re-run bootstrap after editing configs
- Only run bootstrap once on new machines or when adding new files to symlink

### 2. Modular Setup Architecture
- **`setup.sh`** is the main orchestrator for installing everything
- Modular scripts in `setup/brew/` for Homebrew packages by category
- Auto-discovers all `.sh` files in subdirectories
- Easy to add new categories or skip existing ones

### 3. Two-Script Installation
```zsh
./setup.sh          # Installs packages, tools, LaunchAgents (run once or when adding packages)
source bootstrap.sh # Creates symlinks to dotfiles (run once)
```

## Directory Structure

```
dotfiles/
├── shell/          # Zsh configuration (.zshrc, .zprofile, .aliases, .functions, .exports)
├── git/            # Git configuration and helpers
├── config/         # Application configs organized by type
│   ├── vim/
│   ├── editors/
│   ├── terminal/
│   └── tools/
├── scripts/        # Utility scripts (.osx for macOS defaults, httpcompression, marks)
├── setup/          # Modular installation scripts
│   ├── brew/          # Homebrew installers by category
│   │   ├── coreutils.sh   # GNU core utilities
│   │   ├── shell.sh       # zsh and shell tools
│   │   ├── tools.sh       # Development tools
│   │   ├── security.sh    # CTF and security tools
│   │   └── languages.sh   # Programming languages (Python, nvm)
│   ├── packages/      # Package manager lists + installer
│   │   ├── install.sh  # Auto-installs all packages below
│   │   ├── gems.txt    # Ruby gems
│   │   ├── npm.txt     # npm global packages
│   │   └── pip.txt     # Python packages
│   └── launchagents/  # macOS background service setup
│       └── ollama.sh   # Example: Ollama LaunchAgent
├── legacy/         # Deprecated bash configs (for reference only)
├── docs/           # Documentation files
│   ├── shell.md
│   ├── git.md
│   ├── config.md
│   ├── scripts.md
│   ├── setup.md
│   └── structure.md
├── bootstrap.sh    # Creates symlinks to home directory
└── setup.sh        # Main setup orchestrator
```

## Shell Configuration

### .zshrc (shell/.zshrc)
- Loads nvm from Homebrew location (`/opt/homebrew/opt/nvm/nvm.sh`)
- Sources dotfiles: `.path`, `.exports`, `.aliases`, `.functions`, `.extra`
- Git completion for zsh (native, not bash-to-zsh bridge)
- Custom prompt with git status indicators
- History configuration (HISTSIZE=10000, SAVEHIST=10000)
- Case-insensitive completion
- `setopt nonomatch` - allows passing literals that don't match files

### .zprofile (shell/.zprofile)
- Minimal, sources from .zshrc for consistency

### Shell Dotfiles
- `.aliases` - Shell-agnostic command aliases
- `.functions` - Shell-agnostic functions
- `.exports` - Environment variables (shell history, editor, language settings)
- `.path` - Custom PATH additions (user can create `~/.path` for local overrides)
- `.extra` - Private settings (not committed, for git credentials, API keys, etc.)

## Node.js & Package Management

### nvm (Node Version Manager)
- Installed via **Homebrew** (not curl script)
- Location: `/opt/homebrew/opt/nvm/`
- After setup.sh, run: `nvm install --lts && nvm alias default lts/*`
- Per-project versions via `.nvmrc` files

### npm Global Packages (setup/packages/npm.txt)
- `diff-so-fancy` - Git diff tool
- `pnpm` - Modern npm alternative
- Optional (commented): typescript, ts-node, eslint, prettier

## Homebrew Package Categories

### setup/brew/coreutils.sh
- GNU core utilities (coreutils, moreutils, findutils, gnu-sed)
- Replaces outdated macOS versions with modern GNU tools

### setup/brew/shell.sh
- Latest zsh and zsh-completions
- wget, vim, grep, openssh, screen

### setup/brew/tools.sh
- Development tools: ack, tree, gh (GitHub CLI)

### setup/brew/security.sh
- CTF and security tools (25+ packages)
- Examples: aircrack-ng, nmap, hydra, john, sqlmap

### setup/brew/languages.sh
- Python
- nvm (Node Version Manager)
- Creates `~/.nvm` directory

## Adding New Components

### New Homebrew Category
1. Create `setup/brew/mycategory.sh`
2. Add shebang: `#!/usr/bin/env bash`
3. Add echo statements for progress
4. Add brew install commands
5. Make executable: `chmod +x setup/brew/mycategory.sh`
6. Will be auto-discovered by `setup.sh`

### New LaunchAgent
1. Create script in `setup/launchagents/myservice.sh`
2. Use `ollama.sh` as template
3. Install via Homebrew if needed
4. Create plist in `~/Library/LaunchAgents/`
5. Use `launchctl bootstrap` to load
6. Set `RunAtLoad` and `KeepAlive` for auto-start
7. Will be auto-discovered by `setup.sh`

### New Shell Configuration
1. Add file to `shell/` directory
2. Update `bootstrap.sh` to create symlink
3. Update `shell/.zshrc` to source it (if needed)

### New Application Config
1. Add to appropriate `config/` subdirectory (vim/, editors/, terminal/, tools/)
2. Update `bootstrap.sh` to create symlink

## Important Notes

### Shell Profile Loading
- Shell profiles (`.zshrc`, `.zprofile`) handle all new shell sessions automatically
- No need to re-run bootstrap when editing these files (they're symlinked)

### Package Installation
- `setup/packages/install.sh` checks for availability (npm might not exist yet)
- Provides helpful error messages if dependencies missing
- Skips empty lines and comments in package lists

### Git Configuration
- Uses native zsh git completion (`.gitcompletion.zsh`)
- Custom git aliases in `.gitconfig`
- Git helpers in `git/.githelpers`

### macOS Defaults
- `scripts/.osx` contains macOS system preferences
- Run manually: `./scripts/.osx`
- References config paths for Sublime and terminal themes

## Common Workflows

### Initial Machine Setup
```zsh
git clone https://github.com/tshelburne/dotfiles.git
cd dotfiles
./setup.sh          # Installs everything
source bootstrap.sh # Symlinks dotfiles
```

### Adding a New Homebrew Package
1. Add to appropriate file in `setup/brew/` (or create new category)
2. Run `./setup.sh` to install
3. Commit the change

### Adding a New npm Package
1. Add to `setup/packages/npm.txt`
2. Run `./setup/packages/install.sh` or `npm install -g <package>`
3. Commit the change

### Updating Existing Configs
1. Edit files directly in repo
2. Changes apply immediately (symlinked)
3. Commit when satisfied

## Troubleshooting

### setup.sh fails on brew install
- Some packages may have changed names or been deprecated
- Check Homebrew documentation
- Update or remove from appropriate `setup/brew/*.sh` file

### npm packages fail to install
- Ensure Node.js installed: `nvm install --lts`
- Set default: `nvm alias default lts/*`
- Restart shell or: `source ~/.zshrc`

### Symlinks not working
- Re-run: `source bootstrap.sh`
- Check for conflicts in home directory
- Use `ls -la ~/ | grep "^l"` to see existing symlinks

## Git Repository Info
- Main branch: `master`
- GitHub: https://github.com/tshelburne/dotfiles
