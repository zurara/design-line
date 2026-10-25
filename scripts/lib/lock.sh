# design-line file lock: serialize read-modify-write of _line/*.json and inbox.md across sessions. Source it, then: with_lock <name> <command…>
with_lock(){ local name="$1"; shift; local ROOT; ROOT="$(node "$(dirname "${BASH_SOURCE[0]}")/config.mjs" root)" || return 1
  local d="$ROOT/_line/.lock-$name"; local i=0
  until mkdir "$d" 2>/dev/null; do i=$((i+1)); [ $i -gt 100 ] && { echo "lock $name held too long ($d); remove it if no session is running" >&2; return 1; }; sleep 0.1; done
  "$@"; local rc=$?; rmdir "$d" 2>/dev/null; return $rc; }
