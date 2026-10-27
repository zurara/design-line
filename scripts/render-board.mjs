#!/usr/bin/env node
// Renders the kanban board as one plain HTML file, _line/board.html, with the data embedded: no artifact, no database, nothing to push.
// Run it after each state change (the skills do); open the file in a browser and reload. board-snapshot.mjs builds the data.
import fs from 'node:fs'; import path from 'node:path'; import { execFileSync } from 'node:child_process'; import { fileURLToPath } from 'node:url';
import { load } from './lib/config.mjs';
const cfg = load(); if (!cfg) { console.error('no _line/lanes.yaml found'); process.exit(1); }
const here = path.dirname(fileURLToPath(import.meta.url)); const root = cfg._root;
execFileSync('node', [path.join(here, 'board-snapshot.mjs')], { stdio: 'ignore' });
const data = fs.readFileSync(path.join(root, '_line/board.json'), 'utf8');
let page = fs.readFileSync(path.join(here, '..', 'templates', 'board.html'), 'utf8');
const title = (cfg.board_title || 'Line board');
page = page.replace('<title>Line board</title>', `<title>${title}</title>`);
const embed = `<script>window.__BOARD__=${data.replace(/<\/script/gi, '<\\/script')};</script>\n`;
page = page.replace('<script>\n(async function(){', embed + '<script>\n(async function(){');
const html = `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"></head><body>\n${page}\n</body></html>`;
const out = path.join(root, '_line', 'board.html'); fs.writeFileSync(out, html); console.log(out);
