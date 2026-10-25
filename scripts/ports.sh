#!/usr/bin/env bash
# design-line ports: stop a server by port, never by process name. Usage: ports.sh kill <port> | list <lane>
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
export DESIGN_LINE_HOME="${DESIGN_LINE_HOME:-$(node "$HERE/lib/config.mjs" home 2>/dev/null)}"   # pin the profile for this run and its children, wherever cwd ends up
case "${1:-}" in
  kill) P="${2:?port}"; PIDS=$(lsof -ti tcp:$P -sTCP:LISTEN 2>/dev/null); [ -z "$PIDS" ] && { echo "port $P: nothing listening"; exit 0; }; echo "$PIDS" | xargs kill && echo "port $P: stopped $PIDS";;
  list) L="${2:?lane}"; for p in $(node $HERE/lib/config.mjs get "$L" ports | tr -d '[]"' | tr ',' ' '); do lsof -ti tcp:$p -sTCP:LISTEN >/dev/null 2>&1 && echo "$p listening" || echo "$p free"; done;;
  *) echo "usage: ports.sh kill <port> | list <lane>"; exit 2;;
esac
