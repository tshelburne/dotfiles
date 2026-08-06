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
    "github-practices@tshelburne": true
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

### Updating plugins

`settings.json` names which plugins are on; it doesn't pin or track their
contents. Claude Code installs a plugin at whatever commit the marketplace was
at when it fetched, then holds that version until told otherwise — so merging
to `claude-plugins` changes nothing on this machine on its own. Pull the new
version explicitly:

```sh
claude plugin marketplace update tshelburne
claude plugin update project-architecture@tshelburne
claude plugin update github-practices@tshelburne
```

The first refreshes the catalog, which is what makes a *newly published* plugin
visible at all; the rest re-install one plugin each at the newer commit. All of
it takes effect on the next Claude Code restart. Adding a plugin that wasn't
previously enabled is the only case that also needs an edit here — a new key in
`enabledPlugins`.
