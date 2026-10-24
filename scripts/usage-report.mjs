#!/usr/bin/env node
// Per-task cost report and a direction for next time, from _line/usage.tsv. Usage: usage-report.mjs [task id] [--json]
// Heuristics, not verdicts: they read the outcome column (clean / returned / escalated / paused) against the model used.
import fs from 'node:fs'; import path from 'node:path'; import { load } from './lib/config.mjs';
const cfg = load(); if (!cfg) { console.error('no _line/lanes.yaml'); process.exit(1); }
const f = path.join(cfg._root, '_line/usage.tsv'); if (!fs.existsSync(f)) { console.log('no usage recorded yet'); process.exit(0); }
const [head, ...lines] = fs.readFileSync(f, 'utf8').trim().split('\n'); const cols = head.split('\t');
const rows = lines.filter(Boolean).map(l => Object.fromEntries(l.split('\t').map((v, i) => [cols[i], v]))).map(r => ({ ...r, tokens: +r.tokens || 0, tool_uses: +r.tool_uses || 0, ms: +r.ms || 0 }));
const [taskArg, flag] = process.argv.slice(2).filter(a => a !== '--json').concat(process.argv.includes('--json') ? ['--json'] : []);
const task = taskArg && taskArg !== '--json' ? taskArg : null;
const fmt = n => n >= 1000 ? (n / 1000).toFixed(1) + 'k' : String(n);
const big = m => /opus|fable|mythos/i.test(m), small = m => /sonnet|haiku/i.test(m);
function suggest(taskRows, history) {
  const out = [];
  for (const r of taskRows) {
    const hist = history.filter(h => h.lane === r.lane && h.role === r.role);
    const sameModel = hist.filter(h => h.model === r.model);
    const cleanRate = sameModel.length ? sameModel.filter(h => h.outcome === 'clean').length / sameModel.length : 0;
    if (big(r.model) && r.outcome === 'clean' && sameModel.length >= 3 && cleanRate >= 0.8 && !hist.some(h => small(h.model) && h.outcome === 'escalated'))
      out.push(`${r.role} on ${r.lane}: ${sameModel.length} runs on ${r.model}, ${Math.round(cleanRate * 100)}% clean. The rules seem clear enough: try a small model at medium effort on the next task of this kind, and watch the outcome column.`);
    if (small(r.model) && r.outcome === 'escalated') out.push(`${r.role} on ${r.lane}: a small model had to be re-dispatched. Keep the large model as this role's default here, or write down in the lane's rules what it missed so a small model can follow it next time.`);
    if (small(r.model) && r.outcome === 'returned') out.push(`${r.role} on ${r.lane}: a small model needed one return trip. Fine. If it happens twice in a row, raise the default.`);
    if (r.outcome === 'paused') out.push(`${r.role} on ${r.lane} stopped on a question the brief did not answer. Add that decision to the brief template's Decisions for this lane, or settle it as a rule in designer.md, so the next brief carries it.`);
    if (r.role === 'checker' && /FAIL/i.test(r.note || '')) out.push(`checker found failures the writer should have caught: ${r.note}. If the same check fails again, make it a line in the lane's rules file.`);
  }
  return [...new Set(out)];
}
const byTask = {}; for (const r of rows) (byTask[r.task] ||= []).push(r);
const tasks = task ? { [task]: byTask[task] || [] } : byTask;
if (process.argv.includes('--json')) { const o = {}; for (const [t, rs] of Object.entries(tasks)) o[t] = { tokens: rs.reduce((a, r) => a + r.tokens, 0), models: [...new Set(rs.map(r => r.model))], rows: rs.length, suggestions: suggest(rs, rows) }; console.log(JSON.stringify(o)); process.exit(0); }
for (const [t, rs] of Object.entries(tasks)) {
  if (!rs.length) { console.log(`## ${t}\nno usage rows`); continue; }
  const tot = rs.reduce((a, r) => a + r.tokens, 0), ms = rs.reduce((a, r) => a + r.ms, 0);
  console.log(`## ${t} · ${rs[0].lane} · ${fmt(tot)} subagent tokens · ${rs.length} dispatches · ${Math.round(ms / 60000)} min of agent time\n`);
  console.log('| role | agent | model / effort | tokens | tools | min | outcome | note |\n| --- | --- | --- | ---: | ---: | ---: | --- | --- |');
  for (const r of rs) console.log(`| ${r.role} | ${r.name} | ${r.model} / ${r.effort} | ${fmt(r.tokens)} | ${r.tool_uses} | ${(r.ms / 60000).toFixed(1)} | ${r.outcome} | ${r.note || ''} |`);
  const s = suggest(rs, rows); console.log(`\nNext time: ${s.length ? '\n- ' + s.join('\n- ') : 'nothing stands out; same models, same effort.'}\n`);
}
