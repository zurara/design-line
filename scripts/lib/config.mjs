#!/usr/bin/env node
// design-line config helper: finds the _line profile folder and reads lanes.yaml (a small YAML subset:
// block maps, block lists of scalars or maps, inline [a, b] lists, quoted or bare scalars, # comments).
// Usage: config.mjs home | lanes | get <lane> <dotted.key or .> | json
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';

export function home(start = process.cwd()) {
  if (process.env.DESIGN_LINE_HOME && fs.existsSync(path.join(process.env.DESIGN_LINE_HOME, 'lanes.yaml'))) return process.env.DESIGN_LINE_HOME;
  let d = path.resolve(start);
  for (;;) {
    const c = path.join(d, '_line', 'lanes.yaml');
    if (fs.existsSync(c)) return path.join(d, '_line');
    const up = path.dirname(d);
    if (up === d) return null;
    d = up;
  }
}
export function expand(p, root) {
  if (p == null) return p;
  if (typeof p !== 'string') return p;
  if (p.startsWith('~')) return path.join(os.homedir(), p.slice(1));
  if (path.isAbsolute(p)) return p;
  return root ? path.resolve(root, p) : p;
}
function scalar(s) {
  s = s.trim();
  if (s === '' ) return '';
  if (s.startsWith('"') && s.endsWith('"')) return s.slice(1, -1).replace(/\\(["\\])/g, '$1');
  if (s.startsWith("'") && s.endsWith("'")) return s.slice(1, -1);
  if (s.startsWith('[') && s.endsWith(']')) return s.slice(1, -1).split(',').map(x => scalar(x)).filter(x => x !== '');
  if (s === 'true') return true; if (s === 'false') return false; if (s === 'null' || s === '~') return null;
  if (/^-?\d+(\.\d+)?$/.test(s)) return Number(s);
  return s;
}
function stripComment(line) {
  let q = null, out = '';
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (q) { out += ch; if (ch === q) q = null; continue; }
    if (ch === '"' || ch === "'") { q = ch; out += ch; continue; }
    if (ch === '#') break;
    out += ch;
  }
  return out.replace(/\s+$/, '');
}
export function parseYaml(text) {
  const lines = text.split('\n').map(stripComment).map((l, i) => ({ i, raw: l, indent: l.match(/^ */)[0].length, body: l.trim() })).filter(l => l.body !== '');
  let pos = 0;
  function block(indent) {
    if (pos >= lines.length) return null;
    const first = lines[pos];
    if (first.body.startsWith('- ')) return list(first.indent);
    return map(indent);
  }
  function map(indent) {
    const obj = {};
    while (pos < lines.length) {
      const l = lines[pos];
      if (l.indent < indent) break;
      if (l.indent > indent) throw new Error(`lanes.yaml line ${l.i + 1}: unexpected indent`);
      if (l.body.startsWith('- ')) break;
      const m = l.body.match(/^([^:]+):\s*(.*)$/);
      if (!m) throw new Error(`lanes.yaml line ${l.i + 1}: expected key: value`);
      const key = m[1].trim(), rest = m[2];
      pos++;
      if (rest === '') {
        const next = lines[pos];
        if (next && next.indent > indent) obj[key] = block(next.indent);
        else if (next && next.indent === indent && next.body.startsWith('- ')) obj[key] = list(indent);
        else obj[key] = null;
      } else obj[key] = scalar(rest);
    }
    return obj;
  }
  function list(indent) {
    const arr = [];
    while (pos < lines.length) {
      const l = lines[pos];
      if (l.indent !== indent || !l.body.startsWith('- ')) break;
      const rest = l.body.slice(2);
      const m = rest.match(/^([^:\[\]"']+):\s*(.*)$/);
      if (m) {
        // list item that is a map: rewrite the first line as a map entry at indent+2
        lines[pos] = { ...l, indent: indent + 2, body: rest };
        arr.push(map(indent + 2));
      } else { arr.push(scalar(rest)); pos++; }
    }
    return arr;
  }
  return block(lines.length ? lines[0].indent : 0) ?? {};
}
export function load(start) {
  const h = home(start);
  if (!h) return null;
  const cfg = parseYaml(fs.readFileSync(path.join(h, 'lanes.yaml'), 'utf8'));
  cfg._home = h; cfg._root = path.dirname(h);
  return cfg;
}
export function lane(cfg, id) {
  return (cfg.lanes || []).find(l => l.id === id) || null;
}
function dig(o, key) {
  if (key === '.' || key === '') return o;
  return key.split('.').reduce((a, k) => (a == null ? undefined : a[k]), o);
}
if (import.meta.url === `file://${process.argv[1]}`) {
  const [cmd, a, b] = process.argv.slice(2);
  const cfg = load();
  if (cmd === 'home') { console.log(cfg ? cfg._home : ''); process.exit(cfg ? 0 : 1); }
  if (!cfg) { console.error('design-line: no _line/lanes.yaml found above the working directory (or set DESIGN_LINE_HOME). Run /design-line:init.'); process.exit(1); }
  if (cmd === 'json') console.log(JSON.stringify(cfg, null, 2));
  else if (cmd === 'lanes') console.log((cfg.lanes || []).map(l => l.id).join('\n'));
  else if (cmd === 'root') console.log(cfg._root);
  else if (cmd === 'top') { const v = dig(cfg, a); console.log(typeof v === 'object' ? JSON.stringify(v) : (v ?? '')); }
  else if (cmd === 'get') {
    const L = lane(cfg, a); if (!L) { console.error(`design-line: no lane "${a}"`); process.exit(1); }
    const v = dig(L, b || '.');
    if (v == null) console.log('');
    else if (typeof v === 'object') console.log(JSON.stringify(v));
    else console.log(['repo', 'handoff', 'notes', 'defaults'].includes(b) || (b || '').endsWith('.path') ? expand(v, cfg._root) : v);
  } else { console.error('usage: config.mjs home | root | lanes | json | top <key> | get <lane> <key>'); process.exit(2); }
}
