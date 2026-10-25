#!/usr/bin/env bash
# design-line usage: record what each subagent cost. Append-only _line/usage.tsv.
# Usage: usage.sh add <task> <lane> <role> <name> <model> <effort> <tokens> <tool_uses> <ms> <outcome> ["note"]
#   outcome: clean (first pass accepted) | returned (sent back once with findings) | escalated (re-dispatched on a larger model) | paused (stopped on a question for the designer) | failed
# The numbers come from the Agent tool's result: subagent_tokens, tool_uses, duration_ms. The session's own tokens are not visible to the model; /cost shows them.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(node $HERE/lib/config.mjs root)" || exit 1; F="$ROOT/_line/usage.tsv"
[ -f "$F" ] || printf 'time\ttask\tlane\trole\tname\tmodel\teffort\ttokens\ttool_uses\tms\toutcome\tnote\n' > "$F"
case "${1:-}" in
  add) [ $# -lt 11 ] && { echo 'usage.sh add <task> <lane> <role> <name> <model> <effort> <tokens> <tool_uses> <ms> <outcome> ["note"]'; exit 2; }
       printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(date '+%Y-%m-%d %H:%M')" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12:-}" >> "$F"; echo "usage: $2 $4/$5 $6/$7 ${8} tokens $11";;
  resume) # usage.sh resume <task> <lane> <role> <name> <model> <effort> <cumulative tokens> <cumulative tool_uses> <cumulative ms> <outcome> ["note"]
       # for an agent continued with SendMessage: the Agent tool reports cumulative numbers; this stores only the delta since the last rows for the same task+name.
       [ $# -lt 11 ] && { echo 'usage.sh resume <task> <lane> <role> <name> <model> <effort> <cum tokens> <cum tools> <cum ms> <outcome> ["note"]'; exit 2; }
       read -r PT PU PM <<<"$(awk -F'\t' -v t="$2" -v n="$5" '$2==t && $5==n {tk+=$8; tu+=$9; ms+=$10} END {print tk+0, tu+0, ms+0}' "$F")"
       DT=$(( $8 - PT )); DU=$(( $9 - PU )); DM=$(( ${10} - PM )); [ $DT -lt 0 ] && DT=$8; [ $DU -lt 0 ] && DU=$9; [ $DM -lt 0 ] && DM=${10}
       printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(date '+%Y-%m-%d %H:%M')" "$2" "$3" "$4" "$5" "$6" "$7" "$DT" "$DU" "$DM" "${11}" "${12:-resumed}" >> "$F"; echo "usage: $2 $4/$5 +$DT tokens (cumulative $8) ${11}";;
  *) echo 'usage: usage.sh add … | resume …'; exit 2;;
esac
