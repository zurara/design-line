---
name: handoff
description: Close out a design-line session cleanly: write the lane's handoff note to the current state (open items, waiting-for, queue), make sure the ledger has the events, stop the servers this session started by port, delete scratch files, and if a resident session exists for the lane add a change: line. Use before stopping, before a long pause, or when the designer says "wrap up", "收工", "hand off", "write the handoff".
---

# /design-line:handoff <lane>

1. Compare the handoff note with reality: `git log origin/<main>` since the note's date, open PRs, the ledger tail, inbox items for this lane. Rewrite sections 4 and 5 of the note to the current state: what waits for the designer (numbered, one line each), for others, in progress, queue. Facts, no conversation history; mark what is unverified.
2. Set "Last updated" to now. If the lane has a resident session that is not this one (org.md says so), add `change: {MM-DD HH:MM} · {this session} · {what changed, written where}` under it.
3. Ledger: every PR opened or merged, publish, or merge this session did has a line. Add what is missing with `scripts/ledger.sh`.
4. Briefs this session touched: `status` is right (approved / done).
5. `${CLAUDE_PLUGIN_ROOT}/scripts/ports.sh list <lane>`; stop the ones this session started, by port. Never the designer's own server (org.md names its port). Delete scratch worktrees, screenshots and temporary installs you created.
6. Report in three lines: what shipped, what waits for the designer, what is next in the inbox.
