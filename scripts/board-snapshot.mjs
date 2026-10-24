#!/usr/bin/env node
// Writes _line/board.json: one JSON document the live board shows. The dispatcher (or /design-line:handoff) then pushes it to the board
// artifact with the ArtifactData tool: update board/state from file_path _line/board.json (set, the first time). One write per state change.
import fs from 'node:fs'; import path from 'node:path'; import { load, expand } from './lib/config.mjs';
const cfg = load(); if (!cfg) { console.error('no _line/lanes.yaml'); process.exit(1); }
const root = cfg._root, read = p => { try { return fs.readFileSync(p, 'utf8'); } catch { return ''; } };
const rows = t => t.split('\n').filter(l => /^\d{4}-/.test(l));
const section = (md, n) => { const m = md.split(/^## /m).find(s => s.startsWith(n)); return m ? m.split('\n').slice(1).join('\n').trim().slice(0, 4000) : ''; };
const inbox = rows(read(path.join(root, '_line/inbox.md'))).map(l => { const [date, lane, what, blocks, from] = l.split('|').map(s => s.trim()); return { date, lane, what, blocks: (blocks || '').replace(/^blocks:\s*/, ''), from }; });
const ledger = rows(read(path.join(root, cfg.ledger || '_line/ledger.md'))).slice(-40).reverse().map(l => { const [time, lane, item, what, ref] = l.split('|').map(s => s.trim()); return { time, lane, item, what, ref }; });
const batch = (() => { try { return JSON.parse(read(path.join(root, '_line/batch.json'))).tasks || []; } catch { return []; } })();
const lanes = (cfg.lanes || []).map(l => { const md = read(expand(l.handoff, root)); return { id: l.id, name: l.name, ship: l.ship?.mode || '-', approval: l.ship?.approval || '-', updated: (md.match(/(?:Last updated|最后更新)[:：]?\s*([^\n。]+)/) || [])[1] || '', open: section(md, '4') }; });
const doc = { updated: new Date().toISOString(), lanes, inbox, ledger, tasks: batch };
const out = path.join(root, '_line', 'board.json'); fs.writeFileSync(out, JSON.stringify(doc)); console.log(out, JSON.stringify(doc).length, 'bytes');
