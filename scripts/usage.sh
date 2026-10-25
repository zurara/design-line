#!/usr/bin/env bash
# design-line usage: record what each subagent cost. Append-only _line/usage.tsv.
# Usage: usage.sh add <task> <lane> <role> <name> <model> <effort> <tokens> <tool_uses> <ms> <outcome> ["note"]
#   outcome: clean (first pass accepted) | returned (sent back once with findings) | escalated (re-dispatched on a larger model) | paused (stopped on a question for the designer) | failed
# The numbers come from the Agent tool's result: subagent_tokens, tool_uses, duration_ms. The session's own tokens are not visible to the model; /cost shows them.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(node $HERE/lib/config.mjs root)" || exit 1; F="$ROOT/_line/usage.tsv"
export DESIGN_LINE_HOME="${DESIGN_LINE_HOME:-$(node "$HERE/lib/config.mjs" home 2>/dev/null)}"   # pin the profile for this run and its children, wherever cwd ends up
[ -f "$F" ] || printf 'time\ttask\tlane\trole\tname\tmodel\teffort\ttokens\ttool_uses\tms\toutcome\tnote\n' > "$F"
case "${1:-}" in
  add) [ $# -lt 11 ] && { echo 'usage.sh add <task> <lane> <role> <name> <model> <effort> <tokens> <tool_uses> <ms> <outcome> ["note"]'; exit 2; }
       printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(date '+%Y-%m-%d %H:%M')" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12:-}" >> "$F"; echo "usage: $2 $4/$5 $6/$7 ${8} tokens $11";;
  resume) # usage.sh resume <task> <lane> <role> <name> <model> <effort> <cumulative tokens> <this-round tool_uses> <this-round ms> <outcome> ["note"]
       # for an agent continued with SendMessage. The Agent tool reports subagent_tokens as a CUMULATIVE total but tool_uses and
       # duration_ms per round (observed 2026-10-25), so only tokens are turned into a delta; tools and ms are stored as given.
       [ $# -lt 11 ] && { echo 'usage.sh resume <task> <lane> <role> <name> <model> <effort> <cum tokens> <round tools> <round ms> <outcome> ["note"]'; exit 2; }
       PT="$(awk -F'\t' -v t="$2" -v n="$5" '$2==t && $5==n {tk+=$8} END {print tk+0}' "$F")"
       DT=$(( $8 - PT )); [ $DT -lt 0 ] && { echo "usage: cumulative tokens ($8) below what is already recorded ($PT); recording as given"; DT=$8; }
       printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(date '+%Y-%m-%d %H:%M')" "$2" "$3" "$4" "$5" "$6" "$7" "$DT" "$9" "${10}" "${11}" "${12:-resumed}" >> "$F"; echo "usage: $2 $4/$5 +$DT tokens (cumulative $8), $9 tools, ${10} ms this round, ${11}";;
  *) echo 'usage: usage.sh add … | resume …'; exit 2;;
esac
