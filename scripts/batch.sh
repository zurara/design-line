#!/usr/bin/env bash
# design-line batch table: what the dispatcher has running. Usage: batch.sh set <task> <lane> <state> "<title>" ["<note>"] | clear <task> | list
# states: queued | running | paused | ready | done
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(node $HERE/lib/config.mjs root)" || exit 1; F="$ROOT/_line/batch.json"
[ -f "$F" ] || echo '{"tasks":[]}' > "$F"
case "${1:-}" in
  set) python3 - "$F" "$2" "$3" "$4" "$5" "${6:-}" <<'PY'
import json,sys,datetime; f,tid,lane,state,title,note=sys.argv[1:7]; d=json.load(open(f)); now=datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
t=next((x for x in d['tasks'] if x['id']==tid),None)
if not t: t={'id':tid,'lane':lane,'title':title,'since':now}; d['tasks'].append(t)
t.update({'lane':lane,'state':state,'title':title or t.get('title',''),'note':note,'updated':now}); json.dump(d,open(f,'w'),ensure_ascii=False,indent=1); print('batch:',tid,state,note)
PY
  ;;
  clear) python3 - "$F" "$2" <<'PY'
import json,sys; f,tid=sys.argv[1:3]; d=json.load(open(f)); d['tasks']=[x for x in d['tasks'] if x['id']!=tid]; json.dump(d,open(f,'w'),ensure_ascii=False,indent=1); print('batch: cleared',tid)
PY
  ;;
  list) python3 -c "import json,sys; [print(f\"{t['state']:8} {t['lane']:18} {t['id']:14} {t['title']}  {t.get('note','')}\") for t in json.load(open(sys.argv[1]))['tasks']]" "$F";;
  *) echo 'usage: batch.sh set <task> <lane> <state> "<title>" ["<note>"] | clear <task> | list'; exit 2;;
esac
