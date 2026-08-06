# Application Configuration

Location: `config/`

## Directory Structure

```
config/
├── vim/              # Vim editor
│   ├── .vimrc
│   ├── .gvimrc
│   └── .vim/
├── terminal/         # Terminal apps
│   ├── .inputrc      # Readline config
│   ├── .screenrc     # GNU Screen
│   ├── .hushlogin    # Suppress login message
│   └── themes/       # Color schemes for iTerm/Terminal
├── tools/            # CLI tools
│   ├── .curlrc
│   ├── .wgetrc
│   ├── .hgignore
│   └── .gdbinit
└── claude/           # Claude Code configuration
    ├── settings.json       # Permissions, settings, and plugin subscriptions
    ├── sync-plugins.sh     # Installs/updates the plugins settings.json declares
    ├── hooks/             # Scripts settings.json wires to tool events
    │   └── gate-kill-project-processes.sh
    └── skills/            # Personal Claude Code skills
        └── kill-project-processes/
            └── SKILL.md
```

## Vim

The `.vim/` directory contains:
- `backups/` - Backup files location
- `colors/` - Color schemes
- `swaps/` - Swap files location
- `syntax/` - Custom syntax files
- `undo/` - Persistent undo history

## Terminal Themes

Color schemes for:
- iTerm 2 (`.itermcolors`)
- Terminal.app (`.terminal`)

Based on Solarized Dark theme.

## Claude Code

- **settings.json** - Permissions (allow, ask, deny), notification settings, and
  the plugin marketplaces this machine subscribes to
- **sync-plugins.sh** - Installs and updates every plugin `settings.json`
  declares. Run by `bootstrap.sh` and available as `claude-plugins-sync`
- **skills/** - Personal skills, symlinked to `~/.claude/skills/`
  - **kill-project-processes/** - Kill dev servers across a project's worktrees
- **hooks/** - Scripts `settings.json` wires to tool events, symlinked to
  `~/.claude/hooks/`. They must live here rather than only in the home
  directory: `settings.json` references them by path, so an unversioned script
  means a broken hook on a fresh machine.
  - **gate-kill-project-processes.sh** - A `PreToolUse` gate that forces an
    explicit approval prompt before the kill-project-processes skill (or its
    script) runs, since it kills dev servers across every worktree and should
    never fire autonomously. Silent for every other call.

### Plugins

Skills meant to be shared — with other people or other projects — don't live
here. They're published from [`tshelburne/claude-plugins`](https://github.com/tshelburne/claude-plugins)
and consumed the same way anyone else would consume them, via `settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "tshelburne": {
      "source": { "source": "github", "repo": "tshelburne/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "project-architecture@tshelburne": true,
    "github-practices@tshelburne": true,
    "dev-environment@tshelburne": true
  }
}
```

Because that's declarative, there's nothing for `bootstrap.sh` to symlink —
Claude Code fetches and caches the plugin itself. Dropping the same two keys
into a *project's* `.claude/settings.json` gives every contributor on that repo
the same skills automatically.

Currently subscribed:

- **project-architecture** - The layered architecture standard: a pure domain at
  the center, operations as use cases, thin surfaces at the edges, and the
  ratchets that keep it true in CI.
- **github-practices** - How to create and run a GitHub repository to a
  standard: the questions to settle up front, then branch protection, CI
  gating, and the checks that verify it.
- **dev-environment** - Running a project locally: wiring dev servers into the
  preview pane through `.claude/launch.json`, and working in git worktrees
  without the failures they cause.

### Updating plugins

`settings.json` names which plugins are on; it doesn't pin or track their
contents. Claude Code installs a plugin at whatever commit the marketplace was
at when it fetched, then holds it there — so merging to `claude-plugins`
changes nothing on this machine on its own. Something has to go and pull it.
That something is `config/claude/sync-plugins.sh`:

```sh
claude-plugins-sync
```

`bootstrap.sh` runs it and symlinks it into `~/.bin` under that name, so a new
machine gets every subscribed plugin as part of setup, and pulling later
updates is one word. It reads the plugin list out of `settings.json`, so
subscribing to a new plugin stays a one-line edit — there's no second list to
keep in step.

It's doing something slightly awkward that's worth knowing if you ever run the
underlying commands by hand: it calls both `install` and `update` on every
plugin, because neither does the other's job. `install` fetches a plugin this
machine has never seen but won't upgrade one it already has; `update` refuses a
plugin that was never installed. Running both converges from either state.
There's also no update-all, hence the loop.

Changes take effect on the next Claude Code restart, not immediately.

### settings.json is not only hand-written

`claude plugin install` **writes to `settings.json`** — it adds the key to
`enabledPlugins` itself, and rewrites the file in its own key order. Since this
file is symlinked to `~/.claude/settings.json`, that lands as an uncommitted
change in this repo.

So the file has two authors, and installing a plugin on one machine leaves a
diff to commit rather than a change to make. The committed key order is the
one the CLI produces, which keeps its writes from showing up as churn.
