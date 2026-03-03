# Minimal bash adapter — mirrors the zsh environment so that tools
# running under bash (e.g. Claude Code) have the same PATH and exports.

# Homebrew
if [ -x "/opt/homebrew/bin/brew" ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
	eval "$(/usr/local/bin/brew shellenv)"
fi

# PATH (matches .zshrc)
export PATH="$HOME/.npm-packages/bin:$HOME/.bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Deno (only if installed)
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# Shared exports
[ -r ~/.exports ] && . ~/.exports
[ -r ~/.extra ] && . ~/.extra
