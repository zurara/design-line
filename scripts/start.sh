#!/usr/bin/env bash
# design-line start: one screen of reality for a lane. Usage: start.sh <lane>
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/lib/config.mjs"
LANE="${1:-}"; [ -z "$LANE" ] && { echo "usage: start.sh <lane>"; $CFG lanes; exit 2; }
HOME_DIR="$($CFG home)" || exit 1
ROOT="$($CFG root)"
HANDOFF="$($CFG get "$LANE" handoff)"; REPO="$($CFG get "$LANE" repo)"; MAIN="$($CFG get "$LANE" main)"; PORTS="$($CFG get "$LANE" ports)"
echo "== design-line · lane $LANE · $(date '+%Y-%m-%d %H:%M')"
echo "== profile: $HOME_DIR"
if [ -f "$HANDOFF" ]; then
  echo "== handoff head ($HANDOFF)"; head -8 "$HANDOFF"
  if grep -q '^change:' "$HANDOFF"; then echo ">> change: lines present. Another agent worked here. Trust the file, catch up, then delete those lines."; fi
else echo "== handoff note missing: $HANDOFF (copy templates/handoff.md)"; fi
if [ -n "$REPO" ] && [ -d "$REPO/.git" ] || git -C "$REPO" rev-parse >/dev/null 2>&1; then
  echo "== git ($REPO)"; git -C "$REPO" fetch -q origin 2>/dev/null
  echo "   origin/${MAIN:-main}: $(git -C "$REPO" log -1 --format='%h %s' origin/${MAIN:-main} 2>/dev/null)"
  echo "   checkout: $(git -C "$REPO" status -sb 2>/dev/null | head -1)"
  echo "   worktrees:"; git -C "$REPO" worktree list 2>/dev/null | sed 's/^/     /'
  if command -v gh >/dev/null 2>&1; then echo "   open PRs:"; (cd "$REPO" && gh pr list --limit 10 --json number,title,headRefName,mergeable --jq '.[] | "     #\(.number) \(.headRefName) \(.mergeable) · \(.title)"' 2>/dev/null); fi
fi
if [ -n "$PORTS" ]; then echo "== ports"; for p in $(echo "$PORTS" | tr -d '[]",'); do lsof -ti tcp:$p -sTCP:LISTEN >/dev/null 2>&1 && echo "   $p listening" || echo "   $p free"; done; fi
INBOX="$ROOT/_line/inbox.md"; [ -f "$INBOX" ] && { echo "== inbox (this lane, then everything marked blocks:)"; grep -v "^#" "$INBOX" | grep -v "^Columns" | grep -v "^$" | grep -E -- " \| $LANE \| |blocks: [^-]" | sed "s/^/   /"; }
LEDGER="$ROOT/$($CFG top ledger)"; [ -f "$LEDGER" ] && { echo "== ledger tail"; grep -v '^#' "$LEDGER" | grep -v '^$' | tail -6 | sed 's/^/   /'; }
exit 0
