#!/usr/bin/env bash
# design-line start: one screen of reality for a lane. Usage: start.sh <lane>
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/lib/config.mjs"
export DESIGN_LINE_HOME="${DESIGN_LINE_HOME:-$(node "$HERE/lib/config.mjs" home 2>/dev/null)}"   # pin the profile for this run and its children, wherever cwd ends up
LANE="${1:-}"
if [ -z "$LANE" ]; then   # no lane: everything, one screen
  ROOT="$($CFG root)" || exit 1; echo "== design-line · all lanes · $(date '+%Y-%m-%d %H:%M')"
  for l in $($CFG lanes); do echo; echo "## $l"; for b in "$ROOT"/_line/lanes/$l/briefs/*.md; do [ -f "$b" ] || continue; st=$(grep -m1 '^status:' "$b" | awk '{print $2}'); [ "$st" = "done" ] && continue; echo "   $st  $(basename "$b" .md)  $(grep -m1 '^# ' "$b" | cut -c3-90)"; done; done
  echo; echo "## inbox"; [ -f "$ROOT/_line/inbox.md" ] && grep -E '^[0-9]{4}-' "$ROOT/_line/inbox.md" | sed 's/^/   /'
  echo; echo "## batch"; [ -f "$ROOT/_line/batch.json" ] && bash "$HERE/batch.sh" list | sed 's/^/   /'
  echo; echo "## ledger tail"; L="$ROOT/$($CFG top ledger)"; [ -f "$L" ] && grep -E '^[0-9]{4}-' "$L" | tail -8 | sed 's/^/   /'
  echo; node "$HERE/usage-report.mjs" 2>/dev/null | sed -n '1,2p'
  exit 0
fi
HOME_DIR="$($CFG home)" || exit 1
ROOT="$($CFG root)"
NOTES="$($CFG get "$LANE" notes)"; REPO="$($CFG get "$LANE" repo)"; MAIN="$($CFG get "$LANE" main)"; PORTS="$($CFG get "$LANE" ports)"
echo "== design-line · lane $LANE · $(date '+%Y-%m-%d %H:%M')"
echo "== profile: $HOME_DIR"
echo "== open briefs"; for b in "$ROOT"/_line/lanes/$LANE/briefs/*.md; do [ -f "$b" ] || continue; st=$(grep -m1 '^status:' "$b" | awk '{print $2}'); [ "$st" = "done" ] && continue; echo "   $st  $(basename "$b" .md)  $(grep -m1 '^# ' "$b" | cut -c3-90)"; done
[ -n "$NOTES" ] && [ -f "$NOTES" ] && { echo "== notes ($NOTES)"; sed -n '1,12p' "$NOTES"; }
if [ -n "$REPO" ] && [ -d "$REPO/.git" ] || git -C "$REPO" rev-parse >/dev/null 2>&1; then
  echo "== git ($REPO)"; git -C "$REPO" fetch -q origin 2>/dev/null
  echo "   origin/${MAIN:-main}: $(git -C "$REPO" log -1 --format='%h %s' origin/${MAIN:-main} 2>/dev/null)"
  echo "   checkout: $(git -C "$REPO" status -sb 2>/dev/null | head -1)"
  echo "   worktrees:"; git -C "$REPO" worktree list 2>/dev/null | sed 's/^/     /'
  if command -v gh >/dev/null 2>&1; then echo "   open PRs:"; (cd "$REPO" && gh pr list --limit 10 --json number,title,headRefName,mergeable --jq '.[] | "     #\(.number) \(.headRefName) \(.mergeable) · \(.title)"' 2>/dev/null); fi
fi
if [ -n "$PORTS" ]; then echo "== ports"; for p in $(echo "$PORTS" | tr -d '[]"' | tr ',' ' '); do lsof -ti tcp:$p -sTCP:LISTEN >/dev/null 2>&1 && echo "   $p listening" || echo "   $p free"; done; fi
INBOX="$ROOT/_line/inbox.md"; [ -f "$INBOX" ] && { echo "== inbox (this lane, then everything marked blocks:)"; grep -E "^[0-9]{4}-" "$INBOX" | grep -E -- " \| $LANE \| |blocks: [^-]" | sed "s/^/   /"; }
LEDGER="$ROOT/$($CFG top ledger)"; [ -f "$LEDGER" ] && { echo "== ledger tail"; grep -E '^[0-9]{4}-' "$LEDGER" | tail -6 | sed 's/^/   /'; }
exit 0
