#!/usr/bin/env node
// Renders a read-only HTML board from _line/: lanes, each handoff's open items, the inbox and the ledger tail. Nothing writes back.
import fs from 'node:fs'; import path from 'node:path'; import { load, expand } from './lib/config.mjs';
const cfg = load(); if (!cfg) { console.error('no _line/lanes.yaml found'); process.exit(1); }
const root = cfg._root, esc = s => String(s ?? '').replace(/[&<>]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]));
const read = p => { try { return fs.readFileSync(p, 'utf8'); } catch { return ''; } };
const rows = t => t.split('\n').filter(l => /^\d{4}-/.test(l));
const inbox = rows(read(path.join(root, '_line/inbox.md'))), ledger = rows(read(path.join(root, cfg.ledger || '_line/ledger.md'))).slice(-30).reverse();
const section = (md, title) => { const m = md.split(/^## /m).find(s => s.startsWith(title)); return m ? m.split('\n').slice(1).join('\n').trim() : ''; };
const lanes = (cfg.lanes || []).map(l => { const md = read(expand(l.handoff, root)); return { ...l, updated: (md.match(/Last updated:?\s*([^\n]+)/i) || [])[1] || '', open: section(md, '4.'), inbox: inbox.filter(r => r.split('|')[1]?.trim() === l.id) }; });
const html = `<!doctype html><meta charset="utf-8"><title>Line board</title><style>body{font:14px/1.5 system-ui;margin:24px;max-width:1100px;color:#1c2129}h1,h2{margin:.2em 0}.lanes{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:16px}.lane{border:1px solid #c7ccd5;border-radius:8px;padding:12px}.lane h2{font-size:18px}.k{font:12px ui-monospace,monospace;color:#5d6674}pre{white-space:pre-wrap;font:12.5px ui-monospace,monospace;background:#f3f4f7;padding:8px;border-radius:6px}table{border-collapse:collapse;width:100%;font-size:13px}td{padding:4px 8px;border-bottom:1px solid #e3e6eb;vertical-align:top}</style>
<h1>Line board</h1><p class="k">generated ${new Date().toISOString().slice(0, 16).replace('T', ' ')} from ${esc(root)}/_line · read-only</p>
<div class="lanes">${lanes.map(l => `<div class="lane"><h2>${esc(l.name)}</h2><div class="k">${esc(l.id)} · ships by ${esc(l.ship?.mode || '-')} (${esc(l.ship?.approval || '-')}) · updated ${esc(l.updated)}</div>
<h3>Open items</h3><pre>${esc(l.open || '(handoff note has no section 4)')}</pre><h3>Inbox</h3><pre>${esc(l.inbox.join('\n') || '(empty)')}</pre></div>`).join('')}</div>
<h2>Inbox, everything</h2><pre>${esc(inbox.join('\n') || '(empty)')}</pre>
<h2>Ledger, last ${ledger.length}</h2><table>${ledger.map(r => `<tr>${r.split('|').map(c => `<td>${esc(c.trim())}</td>`).join('')}</tr>`).join('')}</table>`;
const out = path.join(root, '_line', 'board.html'); fs.writeFileSync(out, html); console.log(out);
