#!/usr/bin/env bash
# If a lane's ledger moved this session (ledger.sh leaves _line/.dirty-<lane>) and no close-out followed (board.json older than the marker),
# ask once to run /design-line:handoff: briefs' status, inbox lines, ports, scratch, board.
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/../scripts/lib/config.mjs"
export DESIGN_LINE_HOME="${DESIGN_LINE_HOME:-$(node "$HERE/../scripts/lib/config.mjs" home 2>/dev/null)}"
IN=$(cat); printf '%s' "$IN" | grep -q '"stop_hook_active": *true' && exit 0
H="$($CFG home 2>/dev/null)"; [ -z "$H" ] && exit 0
for f in "$H"/.dirty-*; do
  [ -e "$f" ] || continue; LANE="${f##*/.dirty-}"; B="$H/board.json"
  if [ -f "$B" ] && ! [ "$f" -nt "$B" ]; then rm -f "$f"; continue; fi
  printf '{"decision":"block","reason":"design-line: lane %s shipped something this session and no close-out followed. Run /design-line:handoff %s (briefs status, inbox, ports, scratch, board), then stop."}\n' "$LANE" "$LANE"; rm -f "$f"; exit 0
done
exit 0
