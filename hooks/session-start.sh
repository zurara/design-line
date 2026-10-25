#!/usr/bin/env bash
# Prints where the profile folder is and the inbox, so every session starts knowing what is parked. Silent when no _line/ exists.
HERE="$(cd "$(dirname "$0")" && pwd)"
export DESIGN_LINE_HOME="${DESIGN_LINE_HOME:-$(node "$HERE/../scripts/lib/config.mjs" home 2>/dev/null)}"
H="$(node "$HERE/../scripts/lib/config.mjs" home 2>/dev/null)" || exit 0
[ -z "$H" ] && exit 0
echo "design-line: profile at $H. Lanes: $(node "$HERE/../scripts/lib/config.mjs" lanes | tr '\n' ' ')"
if [ -f "$H/inbox.md" ]; then N=$(grep -Ec '^[0-9]{4}-' "$H/inbox.md"); echo "design-line: $N inbox item(s). Read $H/inbox.md before taking a task; park new things with /design-line:park."; fi
echo "design-line: read \${CLAUDE_PLUGIN_ROOT}/CONTEXT.md, then _line/designer.md and _line/org.md, before acting on a lane."
exit 0
