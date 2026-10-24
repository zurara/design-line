#!/usr/bin/env bash
# design-line gate: run the lane's gate in a worktree, keep the full log, print totals. Usage: gate.sh <lane> [worktree] [extra args]
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/lib/config.mjs"
LANE="${1:?lane}"; WT="${2:-$($CFG get "$LANE" repo)}"; shift 2 2>/dev/null || shift $#
CMD="$($CFG get "$LANE" gate.command)"; PASS="$($CFG get "$LANE" gate.pass)"
[ -z "$CMD" ] && { echo "gate: lane $LANE defines no gate.command"; exit 2; }
LOGDIR="${TMPDIR:-/tmp}/design-line"; mkdir -p "$LOGDIR"; LOG="$LOGDIR/gate-$LANE-$(date +%Y%m%d-%H%M%S).log"
echo "gate: $CMD $* (cwd $WT) → $LOG"
( cd "$WT" && bash -c "$CMD $*" ) >"$LOG" 2>&1; CODE=$?
echo "exit $CODE"; grep -Ei 'passed|failed|fail|error|[0-9]+/[0-9]+' "$LOG" | tail -12
if [ -n "$PASS" ]; then grep -q -- "$PASS" "$LOG" && echo "gate: PASS (found \"$PASS\")" || { echo "gate: FAIL (\"$PASS\" not in output)"; exit 1; }; fi
exit $CODE
