#!/usr/bin/env bash
# PreToolUse gate: require the user's explicit approval before the
# kill-project-processes skill (or its script) can run. It kills dev
# servers/emulators across every worktree, so it should never fire autonomously.
#
# Emits an "ask" permission decision when the tool call targets it; stays silent
# (and exits 0) for every other Skill/Bash call so normal work is untouched.
input="$(cat)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // ""' 2>/dev/null)"

target=0
if [ "$tool" = "Skill" ]; then
  skill="$(printf '%s' "$input" | jq -r '.tool_input.skill // ""' 2>/dev/null)"
  [ "$skill" = "kill-project-processes" ] && target=1
elif [ "$tool" = "Bash" ]; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)"
  case "$cmd" in
    *kill-project-processes*) target=1 ;;
  esac
fi

if [ "$target" = "1" ]; then
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"The kill-project-processes skill kills dev servers/emulators across every worktree. Run it only when the user has explicitly asked for it this turn."}}'
fi

exit 0
