#!/usr/bin/env bash
# After a compaction or a resume: print the state file the PreCompact hook wrote, so the fresh context starts from facts, not from the summary alone.
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/../scripts/lib/config.mjs"
H="$($CFG home 2>/dev/null)"; [ -z "$H" ] && exit 0
if [ -f "$H/.compact-state.md" ]; then cat "$H/.compact-state.md"; else echo "design-line: context was compacted or resumed. Re-read CONTEXT.md, _line/designer.md and the lane's handoff note before continuing; the brief holds the task state."; fi
exit 0
