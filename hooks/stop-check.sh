#!/usr/bin/env bash
# If a lane's ledger moved this session (ledger.sh leaves _line/.dirty-<lane>) and its handoff note is older than that, ask once to write the handoff.
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/../scripts/lib/config.mjs"
IN=$(cat); printf '%s' "$IN" | grep -q '"stop_hook_active": *true' && exit 0
H="$($CFG home 2>/dev/null)"; [ -z "$H" ] && exit 0
for f in "$H"/.dirty-*; do
  [ -e "$f" ] || continue; LANE="${f##*/.dirty-}"; HO="$($CFG get "$LANE" handoff 2>/dev/null)"
  if [ -f "$HO" ] && [ "$HO" -nt "$f" ]; then rm -f "$f"; continue; fi
  printf '{"decision":"block","reason":"design-line: lane %s shipped something this session but its handoff note (%s) was not updated. Run /design-line:handoff %s, then stop."}\n' "$LANE" "$HO" "$LANE"; rm -f "$f"; exit 0
done
exit 0
