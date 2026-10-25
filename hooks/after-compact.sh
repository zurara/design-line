#!/usr/bin/env bash
# After a compaction or a resume: print the state file the PreCompact hook wrote, so the fresh context starts from facts, not from the summary alone.
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="node $HERE/../scripts/lib/config.mjs"
export DESIGN_LINE_HOME="${DESIGN_LINE_HOME:-$(node "$HERE/../scripts/lib/config.mjs" home 2>/dev/null)}"
H="$($CFG home 2>/dev/null)"; [ -z "$H" ] && exit 0
if [ -f "$H/.compact-state.md" ]; then echo "design-line: the context was compacted or resumed. The summary above may have dropped detail; this is the state from the files at that moment:"; cat "$H/.compact-state.md"; else echo "design-line: context was compacted or resumed. Re-read CONTEXT.md, _line/designer.md and the lane's handoff note before continuing; the brief holds the task state."; fi
exit 0
