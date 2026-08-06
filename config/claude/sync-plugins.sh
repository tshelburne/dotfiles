#!/usr/bin/env bash

# Install and update the Claude Code plugins declared in settings.json.
#
# `enabledPlugins` says which plugins should be on, but declaring one doesn't
# fetch it, and Claude Code pins each plugin at the commit it was fetched at.
# So a merge to the plugins repo reaches this machine only when something runs
# these commands. That something is this script.
#
# Idempotent. bootstrap.sh runs it, and it's symlinked to ~/.bin as
# `claude-plugins-sync` so pulling updates later is one word.

set -uo pipefail

# Reads ~/.claude/settings.json rather than the copy in this repo: it's the file
# Claude Code actually loads, it's a symlink to the repo copy anyway, and going
# through it keeps this script relocatable. bootstrap.sh creates that symlink
# before calling here.
SETTINGS="$HOME/.claude/settings.json"

if ! command -v claude >/dev/null 2>&1; then
    echo "⚠ claude not found, skipping plugins"
    exit 0
fi

if [ ! -f "$SETTINGS" ]; then
    echo "⚠ $SETTINGS not found — run bootstrap.sh first"
    exit 0
fi

# "marketplaces" emits `<name><tab><github repo>`, "plugins" emits
# `<plugin>@<marketplace>`.
read_settings() {
    python3 -c '
import json, sys

with open(sys.argv[1]) as handle:
    settings = json.load(handle)

if sys.argv[2] == "marketplaces":
    for name, entry in settings.get("extraKnownMarketplaces", {}).items():
        source = entry.get("source", {})
        if source.get("source") == "github" and source.get("repo"):
            print(name + "\t" + source["repo"])
else:
    for name, enabled in settings.get("enabledPlugins", {}).items():
        if enabled:
            print(name)
' "$SETTINGS" "$1"
}

failed=0

echo "Updating Claude Code marketplaces..."
while IFS=$'\t' read -r name repo; do
    [ -n "$name" ] || continue

    # `add` registers a marketplace this machine has never seen and no-ops
    # otherwise. `update` pulls the catalog, which is what makes a newly
    # published plugin visible at all.
    claude plugin marketplace add "$repo" >/dev/null 2>&1 || failed=1

    if claude plugin marketplace update "$name" >/dev/null 2>&1; then
        echo "  ✓ $name"
    else
        echo "  ✗ $name"
        failed=1
    fi
done < <(read_settings marketplaces)

echo "Installing and updating Claude Code plugins..."
while read -r plugin; do
    [ -n "$plugin" ] || continue

    # Neither command does the other's job: `install` fetches a plugin that has
    # never been installed but won't upgrade one that has, and `update` refuses
    # a plugin it has never installed. Running both converges from either state.
    claude plugin install "$plugin" >/dev/null 2>&1 || failed=1

    if claude plugin update "$plugin" >/dev/null 2>&1; then
        echo "  ✓ $plugin"
    else
        echo "  ✗ $plugin"
        failed=1
    fi
done < <(read_settings plugins)

if [ "$failed" -ne 0 ]; then
    echo "⚠ Some plugins failed to sync — offline, or the marketplace is unreachable"
    exit 1
fi

echo "✓ Plugins synced — restart Claude Code to load them"
