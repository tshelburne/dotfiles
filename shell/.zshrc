# Add `~/.bin` to the `$PATH`
export PATH="$HOME/.npm-packages/bin:$HOME/.bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH"

# PostgreSQL path (from bashrc)
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# volta setup (Fast Node.js version manager)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don't want to commit.
for file in ~/.{path,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Git completion for zsh
autoload -Uz compinit && compinit
# Enable bash-style completion (for compatibility)
autoload -Uz bashcompinit && bashcompinit
# If you have git completion, enable it
[ -f ~/.gitcompletion.zsh ] && source ~/.gitcompletion.zsh

# Add directory marking (if it exists) - must be after compinit
[ -f ~/.marks/.functions ] && source ~/.marks/.functions

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Enable auto-cd (just type directory name to cd into it)
setopt AUTO_CD

# Enable extended globbing
setopt EXTENDED_GLOB

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && _ssh_hosts=($(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n'))

# ZSH PROMPT SETUP (replicating bash_prompt)
# Enable prompt substitution
setopt PROMPT_SUBST

# Terminal setup
if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
	export TERM='gnome-256color';
elif infocmp xterm-256color >/dev/null 2>&1; then
	export TERM='xterm-256color';
fi;

# Git prompt function for zsh
prompt_git() {
	local s='';
	local branchName='';

	# Check if the current directory is in a Git repository.
	if git rev-parse --is-inside-work-tree &>/dev/null; then

		# check if the current directory is in .git before running git checks
		if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" = 'false' ]; then

			# Ensure the index is up to date.
			git update-index --really-refresh -q &>/dev/null;

			# Check for uncommitted changes in the index.
			if ! git diff --quiet --ignore-submodules --cached 2>/dev/null; then
				s+='+';
			fi;

			# Check for unstaged changes.
			if ! git diff-files --quiet --ignore-submodules -- 2>/dev/null; then
				s+='!';
			fi;

			# Check for untracked files.
			if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
				s+='?';
			fi;

			# Check for stashed files.
			if git rev-parse --verify refs/stash &>/dev/null; then
				s+='$';
			fi;

		fi;

		# Get the short symbolic ref.
		branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
			git rev-parse --short HEAD 2> /dev/null || \
			echo '(unknown)')";

		[ -n "${s}" ] && s=" [${s}]";

		echo "${1}(${branchName})%F{33}${s}";
	else
		return;
	fi;
}

# Colors using zsh color codes
if [[ $terminfo[colors] -ge 8 ]]; then
	# Solarized colors
	black='%F{0}'
	blue='%F{33}'
	cyan='%F{37}'
	green='%F{64}'
	orange='%F{166}'
	purple='%F{125}'
	red='%F{124}'
	violet='%F{61}'
	white='%F{15}'
	gray='%F{246}'
	yellow='%F{136}'
	bold='%B'
	reset='%f%b'
else
	black='%F{black}'
	blue='%F{blue}'
	cyan='%F{cyan}'
	green='%F{green}'
	orange='%F{yellow}'
	purple='%F{magenta}'
	red='%F{red}'
	violet='%F{magenta}'
	white='%F{white}'
	gray='%F{white}'
	yellow='%F{yellow}'
	bold='%B'
	reset='%f%b'
fi

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
	userStyle="${red}";
else
	userStyle="${orange}";
fi;

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
	hostStyle="${bold}${red}";
else
	hostStyle="${yellow}";
fi;

# Set the terminal title and prompt
# Note: In zsh, we use %~ for the working directory and %n for username, %m for hostname
PROMPT="${bold}
${userStyle}%n${gray}@${hostStyle}%m${gray}: ${green}%~ \$(prompt_git \"${violet}\")
${white}\$ ${reset}"

# Secondary prompt
PROMPT2="${yellow}→ ${reset}"

# Deno setup
. "/Users/timshelburne/.deno/env"

# enable passing literals that don't match any files as-is (instead of throwing an error)
setopt nonomatch