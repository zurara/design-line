#!/usr/bin/env bash
# design-line inbox: park or list things that came up. Usage: inbox.sh add <lane> "<what>" [blocks-task-id] | list [lane] | done <line-number>
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/lib/config.mjs"
ROOT="$($CFG root)" || exit 1; INBOX="$ROOT/_line/inbox.md"
[ -f "$INBOX" ] || cp "$HERE/../templates/inbox.md" "$INBOX"
case "${1:-}" in
  add) LANE="${2:?lane}"; WHAT="${3:?what}"; BL="${4:--}"; FROM="${DESIGN_LINE_FROM:-designer}"
       LINE="$(date '+%Y-%m-%d') | $LANE | $WHAT | blocks: $BL | $FROM"; printf '%s\n' "$LINE" >> "$INBOX"; echo "inbox: $LINE";;
  list) L="${2:-}"; grep -v '^#' "$INBOX" | grep -v '^Columns' | grep -v '^$' | grep -n ${L:+-- " | $L | "} . | sed 's/^/   /';;
  done) N="${2:?line number from list}"; BODY=$(grep -v '^#' "$INBOX" | grep -v '^Columns' | grep -v '^$' | sed -n "${N}p"); [ -z "$BODY" ] && { echo "inbox: no line $N"; exit 1; }
        python3 - "$INBOX" "$BODY" <<'PY'
import sys; p,body=sys.argv[1],sys.argv[2]; L=open(p).read().split('\n'); i=L.index(body); del L[i]; open(p,'w').write('\n'.join(L)); print('inbox: removed:', body)
PY
        ;;
  *) echo 'usage: inbox.sh add <lane> "<what>" [blocks-task-id] | list [lane] | done <n>'; exit 2;;
esac
