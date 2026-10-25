#!/usr/bin/env bash
# design-line inbox: park or list things that came up. Usage: inbox.sh add <lane> "<what>" [blocks-task-id] | list [lane] | done <line-number>
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/lib/config.mjs"
export DESIGN_LINE_HOME="${DESIGN_LINE_HOME:-$(node "$HERE/lib/config.mjs" home 2>/dev/null)}"   # pin the profile for this run and its children, wherever cwd ends up
ROOT="$($CFG root)" || exit 1; INBOX="$ROOT/_line/inbox.md"; . "$HERE/lib/lock.sh"
[ -z "${DL_LOCKED:-}" ] && case "${1:-}" in add|done) DL_LOCKED=1 with_lock inbox "$0" "$@"; exit $?;; esac
[ -f "$INBOX" ] || cp "$HERE/../templates/inbox.md" "$INBOX"
case "${1:-}" in
  add) LANE="${2:?lane}"; WHAT="${3:?what}"; BL="${4:--}"; FROM="${DESIGN_LINE_FROM:-designer}"
       LINE="$(date '+%Y-%m-%d') | $LANE | $WHAT | blocks: $BL | $FROM"; printf '%s\n' "$LINE" >> "$INBOX"; echo "inbox: $LINE";;
  list) L="${2:-}"; grep -E '^[0-9]{4}-' "$INBOX" | grep -n ${L:+-- " | $L | "} . | sed 's/^/   /';;
  done) N="${2:?line number from list}"; BODY=$(grep -E '^[0-9]{4}-' "$INBOX" | sed -n "${N}p"); [ -z "$BODY" ] && { echo "inbox: no line $N"; exit 1; }
        python3 - "$INBOX" "$BODY" <<'PY'
import sys; p,body=sys.argv[1],sys.argv[2]; L=open(p).read().split('\n'); i=L.index(body); del L[i]; open(p,'w').write('\n'.join(L)); print('inbox: removed:', body)
PY
        ;;
  *) echo 'usage: inbox.sh add <lane> "<what>" [blocks-task-id] | list [lane] | done <n>'; exit 2;;
esac
