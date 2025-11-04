# macOS dotfiles (zsh)

![Screenshot of my shell prompt](http://i.imgur.com/EkEtphC.png)

**Note:** This dotfiles setup is optimized for **zsh** (the default shell on macOS since Catalina). Legacy bash configuration files are available in the `legacy/` directory if needed.

## Installation

### Using Git and the bootstrap script

You can clone the repository wherever you want. (I like to keep it in `~/Projects/dotfiles`, with `~/dotfiles` as a symlink.) The bootstrapper script will pull in the latest version and copy the files to your home folder.

```zsh
git clone https://github.com/tshelburne/dotfiles.git
cd dotfiles
cp .env.example .env # and then update the file
./setup.sh
source bootstrap.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```zsh
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```zsh
set -- -f; source bootstrap.sh
```

### Repository Structure

This repository is organized into focused directories:

```
dotfiles/
├── shell/          # Zsh configuration (.zshrc, .aliases, .functions, etc.)
├── git/            # Git configuration and helpers
├── config/         # Application configs (vim, editors, terminal, tools)
├── scripts/        # Utility scripts (.osx, httpcompression, marks)
├── setup/          # Modular installation scripts
│   ├── brew/          # Homebrew package installers by category
│   ├── packages/      # Package manager lists (gems, npm via volta, uv tools)
│   └── launchagents/  # macOS background service setup
├── legacy/         # Deprecated bash configs (for reference)
├── docs/           # Documentation for each directory
├── bootstrap.sh    # Symlinks dotfiles to home directory
└── setup.sh        # Main setup script (runs all installations)
```

**See [`docs/structure.md`](docs/structure.md) for detailed documentation.**

### Git-free install

To install these dotfiles without Git:

```bash
cd; curl -#L https://github.com/tshelburne/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,bootstrap.sh,LICENSE-MIT.txt}
```

To update later on, just run that command again.

### Customization

#### Private Settings (`~/.extra`)

Create `shell/.extra` for local settings you don't want to commit:

```zsh
# Git credentials
GIT_AUTHOR_NAME="Your Name"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="you@example.com"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

#### Custom PATH (`~/.path`)

If `~/.path` exists, it will be sourced to extend `$PATH`:

```zsh
export PATH="/usr/local/bin:$PATH"
```

#### Documentation

See the `docs/` directory for detailed information:
- [`shell.md`](docs/shell.md) - Shell configuration
- [`git.md`](docs/git.md) - Git setup
- [`config.md`](docs/config.md) - Application configs
- [`scripts.md`](docs/scripts.md) - Utility scripts
- [`setup.md`](docs/setup.md) - Installation & packages
- [`structure.md`](docs/structure.md) - Repository organization

### Sensible OS X defaults

When setting up a new Mac, you may want to set some sensible OS X defaults:

```zsh
./scripts/.osx
```

### Install Homebrew formulae and packages

When setting up a new Mac, run the main setup script to install all Homebrew packages, LaunchAgents, and package manager tools:

```zsh
./setup.sh
```

This will automatically install everything from:
- `setup/brew/*.sh` - Homebrew packages (coreutils, shell tools, dev tools, security tools, languages)
- `setup/launchagents/*.sh` - Background services
- `setup/packages/install.sh` - Ruby gems, npm packages (via volta), Python tools (via uv)

## Feedback

Suggestions/improvements
[welcome](https://github.com/tshelburne/dotfiles/issues)!