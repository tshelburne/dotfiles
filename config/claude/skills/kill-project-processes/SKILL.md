---
name: kill-project-processes
description: Kill dev/server processes started within the current project — its main git checkout and every worktree (plus their Claude scratchpads in /tmp). Use when ports are stuck or collide across worktrees, dev servers are orphaned, or before switching branches. Trigger phrases include "kill all project processes", "kill the worktree processes", "free the stuck ports", "stop all dev servers for this project".
---

# Kill project processes

Terminates processes whose working directory is inside the current project: the
main checkout, every linked git worktree, and each worktree's Claude scratchpad
under `/tmp`. This is the tool for clearing stuck ports and orphaned dev servers
(Vite, Metro, Firebase emulators, API servers, idle placeholders) that pile up
across worktrees.

The script lives next to this file: `kill-project-processes.sh`.

## How to run

1. **Dry-run first** — it lists every target (PID, listening ports, command) and
   kills nothing:

   ```
   ~/.claude/skills/kill-project-processes/kill-project-processes.sh
   ```

2. Show the user that list, then terminate:

   ```
   ~/.claude/skills/kill-project-processes/kill-project-processes.sh --kill
   ```

   It sends `SIGTERM`, waits ~3s, then `SIGKILL`s any survivor.

If the user has already clearly asked to kill everything, going straight to
`--kill` is fine — but report what was killed.

## Safety

- The current session is never killed: the script protects itself and its entire
  parent chain (shell, agent, terminal).
- Interactive shells, editors (zsh/bash/fish/tmux, VS Code, Cursor, JetBrains),
  and MCP servers are skipped by default. MCP servers matter because a sibling
  worktree may host another live Claude session — killing its browser MCP server
  would break that session, which a dev-server sweep should never do. Add `--all`
  to include shells, editors, and MCP servers too.
- It only targets *this* project. Worktree paths come from `git worktree list`,
  so it never touches a different repo's processes — even when several projects'
  dev servers are running at once.

## Notes

- Run it from anywhere inside the project (main checkout or any worktree).
- It matches by working directory, so it catches processes regardless of which
  port they hold — including a stuck emulator that never finished binding.
- Cross-project port clashes (e.g. two different projects both wanting `:8080`)
  are *not* something this resolves — it only kills the current project's own
  processes. Freeing the other project's port means running this there too.
