#!/usr/bin/env bash
# design-line gate: run the lane's gate in a worktree, keep the full log, print totals. Usage: gate.sh <lane> [worktree] [extra args]
# If the lane sets gate.serve and gate.port, the server is started in the worktree first ({port} in serve and command is replaced),
# and stopped by its port afterwards. A busy port stops the gate: it is someone else's server.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/lib/config.mjs"
LANE="${1:?lane}"; WT="${2:-$($CFG get "$LANE" repo)}"; shift 2 2>/dev/null || shift $#
CMD="$($CFG get "$LANE" gate.command)"; PASS="$($CFG get "$LANE" gate.pass)"
SERVE="$($CFG get "$LANE" gate.serve)"; PORT="$($CFG get "$LANE" gate.port)"
[ -z "$CMD" ] && { echo "gate: lane $LANE defines no gate.command"; exit 2; }
LOGDIR="${TMPDIR:-/tmp}/design-line"; mkdir -p "$LOGDIR"; LOG="$LOGDIR/gate-$LANE-$(date +%Y%m%d-%H%M%S).log"
listening(){ lsof -ti "tcp:$1" -sTCP:LISTEN >/dev/null 2>&1; }
if [ -n "$SERVE" ]; then
  [ -z "$PORT" ] && { echo "gate: gate.serve needs gate.port"; exit 2; }
  listening "$PORT" && { echo "gate: port $PORT is already in use; free it by its port or wait"; exit 2; }
  ( cd "$WT" && nohup bash -c "${SERVE//\{port\}/$PORT}" >"$LOG.serve" 2>&1 & )
  for _ in $(seq 1 30); do listening "$PORT" && break; sleep 1; done
  listening "$PORT" || { echo "gate: server did not come up on $PORT (see $LOG.serve)"; exit 1; }
  trap 'lsof -ti "tcp:$PORT" -sTCP:LISTEN | xargs kill 2>/dev/null; rm -f "$LOG.serve"' EXIT
  echo "gate: serving $WT on $PORT"
fi
[ -n "$PORT" ] && CMD="${CMD//\{port\}/$PORT}"
echo "gate: $CMD $* (cwd $WT) → $LOG"
( cd "$WT" && bash -c "$CMD $*" ) >"$LOG" 2>&1; CODE=$?
echo "exit $CODE"; grep -Ei 'passed|failed|fail|error|[0-9]+/[0-9]+' "$LOG" | tail -12
if [ -n "$PASS" ]; then grep -q -- "$PASS" "$LOG" && echo "gate: PASS (found \"$PASS\")" || { echo "gate: FAIL (\"$PASS\" not in output)"; exit 1; }; fi
exit $CODE
