---
name: playbook
description: Explain or teach the design-line way of working, for the designer themself or for onboarding another designer: the one pipeline shape, the roles, the inbox, the few rules, where the files are, how a new person sets it up. Renders the read-only board of the current lanes, inbox and ledger (scripts/render-board.mjs) when asked to see the state. Trigger words: "explain the line", "how does this work", "teach <name>", "onboard", "show the board", "playbook".
---

# /design-line:playbook [board]

- `board`: `node ${CLAUDE_PLUGIN_ROOT}/scripts/render-board.mjs` writes `_line/board.html`, the kanban as one plain file; tell the designer the path (`open _line/board.html`). A phone-reachable copy is optional: publish `${CLAUDE_PLUGIN_ROOT}/templates/board.html` as an artifact with `capabilities: {db: {}, user: {}}`, `set` `board/state` once from `_line/board.json`, put its URL in `lanes.yaml` `board:` and set `budget.board: on`; then the skills also push it. The board is read-only; nothing in the line reads from it.
- Otherwise teach, in the designer's language, in this order and no more: (1) the shape, six stations, one session per task; (2) the four roles and what each may and may not do; (3) the inbox and its four cases; (4) the five rules: one question at a time, the designer's yes before push / PR / publish / planning-tool writes, one writer per worktree, stop servers by port, record in the ledger at every milestone; (5) the files: `_line/designer.md`, `org.md`, `lanes.yaml`, `inbox.md`, `ledger.md`, `rules/`, `lanes/<id>/briefs/`; (6) how a new designer starts: install the plugin, `/design-line:init`, `/design-line:line <lane>`.
- For onboarding another designer, produce a one-page document they can read without this conversation, from `${CLAUDE_PLUGIN_ROOT}/README.md`, with their own lane names substituted. Nothing from this organization's org.md goes into material for another organization.
