#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

# Source environment variables if .env exists
if [ -f ".env" ]; then
    echo "Loading environment variables from .env..."
    set -a  # Export all variables
    source ".env"
    set +a  # Stop exporting
fi

git pull origin master;

function doIt() {
	DOTFILES_DIR="$PWD"

	echo "Creating symlinks for dotfiles..."

	# Shell configuration
	ln -sf "$DOTFILES_DIR/shell/.zshrc" ~/.zshrc
	ln -sf "$DOTFILES_DIR/shell/.zprofile" ~/.zprofile
	ln -sf "$DOTFILES_DIR/shell/.aliases" ~/.aliases
	ln -sf "$DOTFILES_DIR/shell/.functions" ~/.functions
	ln -sf "$DOTFILES_DIR/shell/.exports" ~/.exports
	ln -sf "$DOTFILES_DIR/shell/.extra" ~/.extra

	# Git configuration
	ln -sf "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig
	ln -sf "$DOTFILES_DIR/git/.gitignore" ~/.gitignore
	ln -sf "$DOTFILES_DIR/git/.githelpers" ~/.githelpers
	ln -sf "$DOTFILES_DIR/git/.gitattributes" ~/.gitattributes
	ln -sf "$DOTFILES_DIR/git/.gitcompletion.zsh" ~/.gitcompletion.zsh

	# Vim configuration
	ln -sf "$DOTFILES_DIR/config/vim/.vimrc" ~/.vimrc
	ln -sf "$DOTFILES_DIR/config/vim/.gvimrc" ~/.gvimrc
	ln -sf "$DOTFILES_DIR/config/vim/.vim" ~/.vim

	# Editor configuration
	ln -sf "$DOTFILES_DIR/config/editors/.editorconfig" ~/.editorconfig

	# Terminal configuration
	ln -sf "$DOTFILES_DIR/config/terminal/.inputrc" ~/.inputrc
	ln -sf "$DOTFILES_DIR/config/terminal/.screenrc" ~/.screenrc
	ln -sf "$DOTFILES_DIR/config/terminal/.hushlogin" ~/.hushlogin

	# Tool configuration
	ln -sf "$DOTFILES_DIR/config/tools/.curlrc" ~/.curlrc
	ln -sf "$DOTFILES_DIR/config/tools/.wgetrc" ~/.wgetrc
	ln -sf "$DOTFILES_DIR/config/tools/.hgignore" ~/.hgignore
	ln -sf "$DOTFILES_DIR/config/tools/.gdbinit" ~/.gdbinit

	# Claude configuration
	mkdir -p ~/.claude
	ln -sf "$DOTFILES_DIR/config/claude/CLAUDE.md" ~/.claude/CLAUDE.md
	ln -sf "$DOTFILES_DIR/config/claude/code-style.md" ~/.claude/code-style.md
	ln -sf "$DOTFILES_DIR/config/claude/settings.json" ~/.claude/settings.json

	# Claude commands directory
	mkdir -p ~/.claude/commands
	if [ -d "$DOTFILES_DIR/config/claude/commands" ]; then
		for cmd in "$DOTFILES_DIR/config/claude/commands"/*; do
			[ -f "$cmd" ] && ln -sf "$cmd" ~/.claude/commands/
		done
	fi

	# Directory marking functions
	mkdir -p ~/.marks
	ln -sf "$DOTFILES_DIR/scripts/marks/.functions" ~/.marks/.functions

	echo "Symlinks created successfully!"

	# Source zsh configuration
	if [ -n "$ZSH_VERSION" ]; then
		# Running in zsh
		source ~/.zprofile;
		source ~/.zshrc;
		echo "Zsh configuration loaded!"
	else
		# Running in another shell (likely zsh will be used for interactive sessions)
		echo ""
		echo "Note: This dotfiles setup is optimized for zsh."
		echo "After installation, make sure zsh is your default shell:"
		echo "  chsh -s \$(which zsh)"
	fi
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This will create symlinks for dotfiles in your home directory. Continue? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
