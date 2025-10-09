# macOS dotfiles (zsh)

![Screenshot of my shell prompt](http://i.imgur.com/EkEtphC.png)

**Note:** This dotfiles setup is optimized for **zsh** (the default shell on macOS since Catalina). Legacy bash configuration files are available in the `legacy/` directory if needed.

## Installation

### Using Git and the bootstrap script

You can clone the repository wherever you want. (I like to keep it in `~/Projects/dotfiles`, with `~/dotfiles` as a symlink.) The bootstrapper script will pull in the latest version and copy the files to your home folder.

```zsh
git clone https://github.com/tshelburne/dotfiles.git && cd dotfiles && source bootstrap.sh
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
├── setup/          # Package lists and LaunchAgent setup scripts
├── legacy/         # Deprecated bash configs (for reference)
├── docs/           # Documentation for each directory
├── bootstrap.sh    # Installation script (creates symlinks)
└── brew.sh         # Homebrew package installer
```

**See [`docs/structure.md`](docs/structure.md) for detailed documentation.**

### Git-free install

To install these dotfiles without Git:

```bash
cd; curl -#L https://github.com/mathiasbynens/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,bootstrap.sh,LICENSE-MIT.txt}
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

### Install Homebrew formulae

When setting up a new Mac, you may want to install some common [Homebrew](http://brew.sh/) formulae (after installing Homebrew, of course):

```zsh
./brew.sh
```

## Feedback

Suggestions/improvements
[welcome](https://github.com/mathiasbynens/dotfiles/issues)!

## Author

| [![twitter/mathias](http://gravatar.com/avatar/24e08a9ea84deb17ae121074d0f17125?s=70)](http://twitter.com/mathias "Follow @mathias on Twitter") |
|---|
| [Mathias Bynens](https://mathiasbynens.be/) |

## Thanks to…

* @ptb and [his _OS X Lion Setup_ repository](https://github.com/ptb/Mac-OS-X-Lion-Setup)
* [Ben Alman](http://benalman.com/) and his [dotfiles repository](https://github.com/cowboy/dotfiles)
* [Chris Gerke](http://www.randomsquared.com/) and his [tutorial on creating an OS X SOE master image](http://chris-gerke.blogspot.com/2012/04/mac-osx-soe-master-image-day-7.html) + [_Insta_ repository](https://github.com/cgerke/Insta)
* [Cătălin Mariș](https://github.com/alrra) and his [dotfiles repository](https://github.com/alrra/dotfiles)
* [Gianni Chiappetta](http://gf3.ca/) for sharing his [amazing collection of dotfiles](https://github.com/gf3/dotfiles)
* [Jan Moesen](http://jan.moesen.nu/) and his [ancient `.bash_profile`](https://gist.github.com/1156154) + [shiny _tilde_ repository](https://github.com/janmoesen/tilde)
* [Lauri ‘Lri’ Ranta](http://lri.me/) for sharing [loads of hidden preferences](http://osxnotes.net/defaults.html)
* [Matijs Brinkhuis](http://hotfusion.nl/) and his [dotfiles repository](https://github.com/matijs/dotfiles)
* [Nicolas Gallagher](http://nicolasgallagher.com/) and his [dotfiles repository](https://github.com/necolas/dotfiles)
* [Sindre Sorhus](http://sindresorhus.com/)
* [Tom Ryder](http://blog.sanctum.geek.nz/) and his [dotfiles repository](https://github.com/tejr/dotfiles)
* [Kevin Suttle](http://kevinsuttle.com/) and his [dotfiles repository](https://github.com/kevinSuttle/dotfiles) and [OSXDefaults project](https://github.com/kevinSuttle/OSXDefaults), which aims to provide better documentation for [`~/.osx`](https://mths.be/osx)
* [Haralan Dobrev](http://hkdobrev.com/)
* anyone who [contributed a patch](https://github.com/mathiasbynens/dotfiles/contributors) or [made a helpful suggestion](https://github.com/mathiasbynens/dotfiles/issues)
