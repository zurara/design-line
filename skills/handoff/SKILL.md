---
name: handoff
description: Close out a design-line session cleanly: every shipped thing has a ledger line, every brief this session touched has the right status (approved / paused / done) and its inbox line is kept or removed to match, servers this session started are stopped by port, scratch is deleted, the board is pushed. There is no status note to write; the files are the state. Use before stopping, before a long pause, or when the designer says "wrap up", "收工", "hand off".
---

# /design-line:handoff [lane]

1. Ledger: every PR opened or merged, publish, or merge this session did has a line (`scripts/ledger.sh`). Add what is missing.
2. Briefs this session touched: `status` is true (`approved` while writers run, `paused` when stopped on a question, `done` when shipped and recorded). A done task's inbox line is removed (`scripts/inbox.sh done <n>`); a paused task's question is in the inbox with its Q id.
3. Anything the designer said this session that is not done and not in the inbox: park it now.
4. The lane's `notes:` file, if the designer set a new rule for the lane this session: one dated line.
5. `${CLAUDE_PLUGIN_ROOT}/scripts/ports.sh list <lane>`; stop the ones this session started, by port. Never the designer's own server (org.md names its port). Delete scratch worktrees, screenshots and temporary installs you created.
6. `node ${CLAUDE_PLUGIN_ROOT}/scripts/render-board.mjs` so `_line/board.html` shows the closing state. If `lanes.yaml` has a `board:` URL and `budget.board` is `on`, also push `_line/board.json` with ArtifactData `update` (`board` / `state`, `if_version` as last read).
7. Report in three lines: what shipped, what waits for the designer, what is next in the inbox.
