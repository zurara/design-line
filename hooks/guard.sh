#!/usr/bin/env bash
# Blocks the few commands the line never runs: force pushes, killing processes by name match, shared stash.
# Reads the tool call as JSON on stdin. Heredoc bodies and quoted file contents are not commands, so they are stripped before matching:
# writing a rules file that mentions these commands must not trip the guard.
IN=$(cat); CMD=$(printf '%s' "$IN" | python3 -c '
import sys, json, re
c = json.load(sys.stdin).get("tool_input", {}).get("command", "")
# drop heredoc bodies: from a line containing <<MARK (optionally quoted) to the line that is exactly MARK
out = []; lines = c.split("\n"); i = 0
while i < len(lines):
    m = re.search(r"<<-?\s*[\x27\"]?([A-Za-z_][A-Za-z0-9_]*)[\x27\"]?", lines[i])
    out.append(lines[i]); i += 1
    if m:
        mark = m.group(1)
        while i < len(lines) and lines[i].strip() != mark: i += 1
        i += 1
print("\n".join(out))
' 2>/dev/null)
[ -z "$CMD" ] && exit 0
deny(){ echo "design-line: blocked. $1" >&2; exit 2; }
echo "$CMD" | grep -Eq 'git +push[^|;&]*(--force|-f\b|--force-with-lease)' && deny "No force pushes on a design line. Merge forward instead."
echo "$CMD" | grep -Eq '\bpkill +-f|\bkillall\b|\bpgrep +-f[^|]*\|[^|]*\bkill\b|kill +\$\(pgrep' && deny "Stop your own processes by recorded PID or by port (scripts/ports.sh kill <port>), never by name match: other agents run the same scripts."
echo "$CMD" | grep -Eq '\bgit +stash\b' && deny "No shared git stash. Commit on the branch or use a worktree."
exit 0
