#!/usr/bin/env bash
# Blocks the few commands the line never runs: force pushes, pattern kills, shared stash. Reads the tool call as JSON on stdin.
IN=$(cat); CMD=$(printf '%s' "$IN" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
[ -z "$CMD" ] && exit 0
deny(){ echo "design-line: blocked. $1" >&2; exit 2; }
echo "$CMD" | grep -Eq 'git +push[^|;&]*(--force|-f\b|--force-with-lease)' && deny "No force pushes on a design line. Merge forward instead."
echo "$CMD" | grep -Eq '\bpkill +-f|\bkillall\b' && deny "Stop servers by port only: scripts/ports.sh kill <port>."
echo "$CMD" | grep -Eq '\bgit +stash\b' && deny "No shared git stash. Commit on the branch or use a worktree."
exit 0
