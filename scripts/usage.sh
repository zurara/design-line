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
  *) echo 'usage: usage.sh add …'; exit 2;;
esac
