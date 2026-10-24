#!/usr/bin/env bash
# design-line ports: stop a server by port, never by process name. Usage: ports.sh kill <port> | list <lane>
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
case "${1:-}" in
  kill) P="${2:?port}"; PIDS=$(lsof -ti tcp:$P -sTCP:LISTEN 2>/dev/null); [ -z "$PIDS" ] && { echo "port $P: nothing listening"; exit 0; }; echo "$PIDS" | xargs kill && echo "port $P: stopped $PIDS";;
  list) L="${2:?lane}"; for p in $(node $HERE/lib/config.mjs get "$L" ports | tr -d '[]"' | tr ',' ' '); do lsof -ti tcp:$p -sTCP:LISTEN >/dev/null 2>&1 && echo "$p listening" || echo "$p free"; done;;
  *) echo "usage: ports.sh kill <port> | list <lane>"; exit 2;;
esac
