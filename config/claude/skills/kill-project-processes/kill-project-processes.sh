#!/usr/bin/env bash
#
# kill-project-processes.sh — terminate processes whose working directory lives
# inside the current project: its main git checkout, every linked worktree, and
# each worktree's Claude scratchpad under /tmp.
#
# Safe by default: with no flags it only PRINTS what it would kill. Pass --kill
# to actually terminate (SIGTERM, then SIGKILL any survivor).
#
# The current session is never touched: the script and its whole ancestor chain
# (shell, agent, terminal) are protected, and interactive shells / editors are
# skipped unless --all is given.
#
# Usage:
#   kill-project-processes.sh            # dry run — list targets, kill nothing
#   kill-project-processes.sh --kill     # terminate the targets
#   kill-project-processes.sh --kill --all   # also include shells/editors
#
# Written for macOS's default bash 3.2 — no arrays/mapfile, no bashisms beyond
# what 3.2 supports.
set -u

MODE_KILL=0
INCLUDE_ALL=0
for arg in "$@"; do
    case "$arg" in
        --kill | -k | --force | --yes) MODE_KILL=1 ;;
        --all) INCLUDE_ALL=1 ;;
        --dry-run) MODE_KILL=0 ;;
        -h | --help)
            sed -n '3,20p' "$0"
            exit 0
            ;;
        *)
            echo "Unknown arg: $arg (try --help)" >&2
            exit 2
            ;;
    esac
done

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Not inside a git repository — run this from within the project." >&2
    exit 1
fi

# --- This project's worktree paths (main first, then linked) ---
WORKTREES="$(git worktree list --porcelain | awk '/^worktree /{print substr($0, 10)}')"

# Mangled scratchpad tokens: each worktree path with '/' and '.' turned into '-'.
# Claude stores a session scratchpad under /private/tmp/claude-*/<token>/<uuid>/.
TOKENS=""
while IFS= read -r w; do
    [ -n "$w" ] || continue
    TOKENS="$TOKENS
$(printf '%s' "$w" | tr '/.' '--')"
done <<EOF
$WORKTREES
EOF

# --- Protected pids: this script plus its entire ancestor chain ---
PROTECTED=" "
p=$$
while [ "${p:-0}" -gt 1 ]; do
    PROTECTED="$PROTECTED$p "
    p="$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')"
    [ -n "$p" ] || break
done
is_protected() { case "$PROTECTED" in *" $1 "*) return 0 ;; esac; return 1; }

# Commands skipped unless --all: interactive shells, editors, the agent itself,
# and MCP servers. The last matters because sibling worktrees may host OTHER
# live Claude sessions — killing their MCP servers (e.g. the browser server)
# would break those sessions, which is never the point of a dev-server sweep.
SKIP_RE='(^|/)(-?zsh|-?bash|-?fish|tmux|sshd?|login|claude|Code Helper|Electron|Cursor|IntelliJ|JetBrains|goland|pycharm|webstorm)( |$)'
skip_cmd() {
    printf '%s' "$1" | grep -Eq "$SKIP_RE" && return 0
    case "$1" in *mcp-server*) return 0 ;; esac
    return 1
}

belongs_to_project() {
    cwd="$1"
    [ -n "$cwd" ] || return 1
    while IFS= read -r w; do
        [ -n "$w" ] || continue
        case "$cwd" in "$w" | "$w"/*) return 0 ;; esac
    done <<EOF
$WORKTREES
EOF
    while IFS= read -r t; do
        [ -n "$t" ] || continue
        case "$cwd" in *"/$t/"*) return 0 ;; esac
    done <<EOF
$TOKENS
EOF
    return 1
}

# --- One lsof pass: match every process whose cwd is in the project ---
MATCHED=""
curpid=""
while IFS= read -r line; do
    case "$line" in
        p*) curpid="${line#p}" ;;
        n*)
            if [ -n "$curpid" ] && belongs_to_project "${line#n}"; then
                MATCHED="$MATCHED $curpid"
            fi
            ;;
    esac
# -S 2 caps how long lsof blocks on a single kernel stat, so one stuck
# process (e.g. a hung emulator whose cwd can't be read) can't wedge the
# whole scan for minutes; -w silences the resulting warnings.
done <<EOF
$(lsof -S 2 -w -d cwd -Fpn 2>/dev/null)
EOF

# --- Expand to descendants (a stuck dev stack keeps children in other cwds) ---
PSMAP="$(ps -axo pid=,ppid= 2>/dev/null)"
ALL="$MATCHED"
QUEUE="$MATCHED"
while [ -n "$(echo "$QUEUE" | tr -d ' ')" ]; do
    NEXT=""
    for pid in $QUEUE; do
        for c in $(echo "$PSMAP" | awk -v pp="$pid" '$2==pp{print $1}'); do
            case " $ALL " in
                *" $c "*) : ;;
                *)
                    ALL="$ALL $c"
                    NEXT="$NEXT $c"
                    ;;
            esac
        done
    done
    QUEUE="$NEXT"
done

# --- pid -> listening ports, for the report ---
PORTMAP="$(lsof -S 2 -w -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1{n=$9; sub(/.*:/,"",n); print $2, n}')"
ports_of() { echo "$PORTMAP" | awk -v pp="$1" '$1==pp{printf "%s ", $2}'; }

# --- Final target set: dedupe, drop protected, drop shells/editors ---
FINAL=""
for pid in $ALL; do
    [ -n "$pid" ] || continue
    case " $FINAL " in *" $pid "*) continue ;; esac
    is_protected "$pid" && continue
    cmd="$(ps -o command= -p "$pid" 2>/dev/null)"
    [ -n "$cmd" ] || continue
    if [ "$INCLUDE_ALL" -eq 0 ] && skip_cmd "$cmd"; then
        continue
    fi
    FINAL="$FINAL $pid"
done

if [ -z "$(echo "$FINAL" | tr -d ' ')" ]; then
    echo "No project processes found running."
    exit 0
fi

echo "Project: $(echo "$WORKTREES" | head -1)"
echo "Worktrees scanned:"
echo "$WORKTREES" | sed 's/^/  /'
echo
printf '%-8s %-12s %s\n' PID PORTS COMMAND
for pid in $FINAL; do
    printf '%-8s %-12s %s\n' \
        "$pid" \
        "$(ports_of "$pid" | sed 's/ *$//')" \
        "$(ps -o command= -p "$pid" 2>/dev/null | cut -c1-96)"
done
echo

if [ "$MODE_KILL" -eq 0 ]; then
    echo "Dry run — nothing killed. Re-run with --kill to terminate."
    exit 0
fi

echo "Sending SIGTERM…"
for pid in $FINAL; do kill -TERM "$pid" 2>/dev/null; done

n=0
while [ "$n" -lt 6 ]; do
    alive=0
    for pid in $FINAL; do kill -0 "$pid" 2>/dev/null && alive=1; done
    [ "$alive" -eq 0 ] && break
    sleep 0.5
    n=$((n + 1))
done

for pid in $FINAL; do
    if kill -0 "$pid" 2>/dev/null; then
        echo "SIGKILL $pid"
        kill -KILL "$pid" 2>/dev/null
    fi
done

echo "Done."
