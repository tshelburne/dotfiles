# Simple Git completion for zsh
# This uses zsh's native git completion instead of bash completion

# Ensure compinit is loaded
autoload -Uz compinit
compinit

# Ensure git completion is available and loaded
if [[ -f /opt/homebrew/share/zsh/site-functions/_git ]]; then
    # Homebrew git completion is available
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
    autoload -Uz _git
    compdef _git git
elif command -v git >/dev/null 2>&1; then
    # Fallback: use zsh's built-in git completion
    autoload -Uz _git
    compdef _git git
fi

# Optional: Enable git flow completion if available
if [[ -f /opt/homebrew/share/zsh/site-functions/_git-flow ]]; then
    autoload -Uz _git-flow
    compdef _git-flow git-flow
fi