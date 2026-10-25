#!/usr/bin/env bash
# Before the context is compacted: write the line's state to a file so nothing is lost in the summary, and refresh the board snapshot.
# The SessionStart(compact) hook prints this file back into the fresh context.
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/../scripts/lib/config.mjs"
H="$($CFG home 2>/dev/null)"; [ -z "$H" ] && exit 0
ROOT="$(dirname "$H")"; OUT="$H/.compact-state.md"
{
  echo "# design-line state at compaction $(date '+%Y-%m-%d %H:%M')"
  echo; echo "## batch (what this session dispatched)"; [ -f "$H/batch.json" ] && bash "$HERE/../scripts/batch.sh" list 2>/dev/null | sed 's/^/    /'
  echo; echo "## inbox"; [ -f "$H/inbox.md" ] && grep -E '^[0-9]{4}-' "$H/inbox.md" | sed 's/^/    /'
  echo; echo "## ledger tail"; grep -E '^[0-9]{4}-' "$ROOT/$($CFG top ledger 2>/dev/null)" 2>/dev/null | tail -8 | sed 's/^/    /'
  echo; echo "## briefs not done"; grep -l -E '^status: (draft|approved|paused)' "$H"/lanes/*/briefs/*.md 2>/dev/null | sed 's/^/    /'
  echo; echo "## read again after compaction: CONTEXT.md, _line/designer.md, the lane's handoff note. Continue the task you were on; the brief has its state."
} > "$OUT"
node "$HERE/../scripts/board-snapshot.mjs" >/dev/null 2>&1 || true
# Tell the summarizer what to keep (ignored by runtimes that do not read hook JSON for this event).
printf '{"hookSpecificOutput":{"hookEventName":"PreCompact","additionalContext":"design-line: keep in the summary the current lane, task id, brief path, which subagents are still out with their agent ids, and the last question asked to the designer. Everything else is in _line/.compact-state.md."}}\n'
exit 0
