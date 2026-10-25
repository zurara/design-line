#!/usr/bin/env bash
# design-line merge: merge a gated branch into the lane's main in a throwaway worktree, re-run the gate, push, wait for deploy.
# Usage: merge.sh <lane> <branch> [--dry-run]
# DESIGN_LINE_TRAILER overrides lanes.yaml's trailer: the session sets it to its own model's line.
# ship.deploy_check may use {sha}: it is replaced by the pushed merge commit, so an earlier run is never read as this one.
#   Example: gh run list -L 1 --branch main --commit {sha}. It passes on "completed success", fails on "completed failure" / "completed cancelled", and waits otherwise.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/lib/config.mjs"
LANE="${1:?lane}"; BR="${2:?branch}"; DRY="${3:-}"
REPO="$($CFG get "$LANE" repo)"; MAIN="$($CFG get "$LANE" main)"; MAIN="${MAIN:-main}"
MODE="$($CFG get "$LANE" ship.mode)"; APPROVAL="$($CFG get "$LANE" ship.approval)"; DEPLOY="$($CFG get "$LANE" ship.deploy_check)"
SETUP="$($CFG get "$LANE" gate.setup)"; TRAILER="${DESIGN_LINE_TRAILER:-$($CFG top trailer)}"
[ "$MODE" = "merge" ] || { echo "merge: lane $LANE ships by '$MODE', not merge. Stop."; exit 2; }
[ "$APPROVAL" = "designer" ] && echo "merge: this lane needs the designer's yes in the current conversation. Continue only if you have it."
cd "$REPO" || exit 1
git fetch -q origin || exit 1
SHA=$(git rev-parse --verify "$BR" 2>/dev/null || git rev-parse --verify "origin/$BR" 2>/dev/null) || { echo "merge: branch $BR not found"; exit 1; }
git push -q origin "$BR" 2>/dev/null || true
WT="${TMPDIR:-/tmp}/design-line/merge-$LANE-$$"; mkdir -p "$(dirname "$WT")"
echo "1/6 worktree from origin/$MAIN at $WT"; git worktree add -q --detach "$WT" "origin/$MAIN" || exit 1
[ -d node_modules ] && [ ! -e "$WT/node_modules" ] && ln -s "$REPO/node_modules" "$WT/node_modules"
cleanup(){ cd "$REPO"; git worktree remove --force "$WT" >/dev/null 2>&1; }
cd "$WT"
MSG="Merge $BR into $MAIN (design-line, $(date +%Y-%m-%d))"; [ -n "$TRAILER" ] && MSG="$MSG

$TRAILER"
echo "2/6 git merge --no-ff $BR ($SHA)"; git merge --no-ff -m "$MSG" "$SHA" || { echo "merge: conflict. Resolve on the branch, not here."; cleanup; exit 1; }
[ -n "$SETUP" ] && [ ! -e node_modules ] && { echo "   setup: $SETUP"; bash -c "$SETUP" >/dev/null 2>&1 || { echo "merge: setup failed"; cleanup; exit 1; }; }
echo "3/6 gate"; "$HERE/gate.sh" "$LANE" "$WT" || { echo "merge: gate failed, nothing pushed."; cleanup; exit 1; }
echo "4/6 clean"; git status --porcelain | grep -v '^??' | awk '{print $2}' | xargs -r git checkout -- 2>/dev/null; git status --porcelain | grep '^??' && echo "   (untracked files above are left alone)"
if [ "$DRY" = "--dry-run" ]; then echo "dry run: would push $(git rev-parse --short HEAD) to $MAIN"; cleanup; exit 0; fi
echo "5/6 push"; git merge-base --is-ancestor "origin/$MAIN" HEAD || { echo "merge: origin/$MAIN moved. Re-run."; cleanup; exit 1; }
git push origin "HEAD:$MAIN" || { cleanup; exit 1; }
NEW=$(git rev-parse --short HEAD); FULL=$(git rev-parse HEAD); cleanup
cd "$REPO"; git fetch -q origin; [ "$(git rev-parse --abbrev-ref HEAD)" = "$MAIN" ] && git merge --ff-only -q "origin/$MAIN" 2>/dev/null || true
if [ -n "$DEPLOY" ]; then
  case "$DEPLOY" in *"{sha}"*) D="${DEPLOY//\{sha\}/$FULL}"; BYSHA=1;; *) D="$DEPLOY"; BYSHA=""; echo "   note: deploy_check has no {sha}; the result may belong to an earlier run";; esac
  echo "6/6 deploy: $D"; OK=""
  for i in $(seq 1 30); do OUT=$(bash -c "$D" 2>/dev/null)
    if [ -n "$BYSHA" ]; then
      echo "$OUT" | grep -Eq 'completed[[:space:]]+success' && { OK=1; echo "   $OUT"; break; }
      echo "$OUT" | grep -Eq 'completed[[:space:]]+(failure|cancelled|timed_out)' && { echo "   deploy failed: $OUT"; exit 1; }
    else
      echo "$OUT" | grep -qi 'success' && { OK=1; echo "   $OUT"; break; }
      echo "$OUT" | grep -qi 'fail' && { echo "   deploy failed: $OUT"; exit 1; }
    fi; sleep 20; done
  [ -z "$OK" ] && { echo "   deploy not finished after 10 min; check it before reporting"; }
else echo "6/6 no deploy check configured"; fi
echo "merged: $BR → $MAIN at $NEW"
"$HERE/ledger.sh" "$LANE" "-" "merged $BR into $MAIN" "$NEW" >/dev/null
