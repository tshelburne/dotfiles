#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {
	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
		--exclude "README.md" --exclude "LICENSE-MIT.txt" --exclude "init/" \
		--exclude "brew.sh" --exclude "legacy/" --exclude "install/" \
		-avh --no-perms . ~;

	# Source zsh configuration
	if [ -n "$ZSH_VERSION" ]; then
		# Running in zsh
		source ~/.zprofile;
		source ~/.zshrc;
	else
		# Running in another shell (likely zsh will be used for interactive sessions)
		echo "Note: This dotfiles setup is optimized for zsh."
		echo "After installation, make sure zsh is your default shell:"
		echo "  chsh -s \$(which zsh)"
	fi
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
