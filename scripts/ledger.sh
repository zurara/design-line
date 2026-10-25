#!/usr/bin/env bash
# design-line ledger: append one event. Usage: ledger.sh <lane> <item id or -> <what happened> [commit or link]
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/lib/config.mjs"
export DESIGN_LINE_HOME="${DESIGN_LINE_HOME:-$(node "$HERE/lib/config.mjs" home 2>/dev/null)}"   # pin the profile for this run and its children, wherever cwd ends up
LANE="${1:?lane}"; ITEM="${2:--}"; WHAT="${3:?what happened}"; REF="${4:--}"
ROOT="$($CFG root)" || exit 1; LEDGER="$ROOT/$($CFG top ledger)"
[ -f "$LEDGER" ] || cp "$HERE/../templates/ledger.md" "$LEDGER"
LINE="$(date '+%Y-%m-%d %H:%M') | $LANE | $ITEM | $WHAT | $REF"
printf '%s\n' "$LINE" >> "$LEDGER"; echo "ledger: $LINE"
touch "$ROOT/_line/.dirty-$LANE"   # the Stop hook clears this once the handoff note is newer
