---
name: line
description: Start or continue work on one design-line lane as this session's task coordinator. Prints the lane's reality (handoff head, inbox, git, PRs, ports, ledger tail), names the task (given, or the next inbox item), then drives it through the shape: readers, brief, the designer's approval, writers, checkers, ship, record, and asks what is next. Use for any lane work: "work on <lane>", "continue <lane>", "next task on <lane>", "/line <lane> <task>".
---

# /design-line:line [lane] [task]

No lane given: run `/design-line:status` first and take the lane and task the designer picks there.

Read `${CLAUDE_PLUGIN_ROOT}/CONTEXT.md` once. Keep the task on the board the way `/design-line:run` does: `scripts/batch.sh set` for the task, `batch.sh worker` for each subagent you dispatch, `render-board.mjs` after each state change (plus the ArtifactData push only when `lanes.yaml` has a `board:` URL and `budget.board` is `on`). Then act as the `line-coordinator` role for this one task, in this session (do not dispatch a coordinator subagent for it; dispatch readers, writers and checkers).

1. `node ${CLAUDE_PLUGIN_ROOT}/scripts/lib/config.mjs home`; if empty, stop and point to `/design-line:init`. Read `_line/designer.md`, `_line/org.md`, the lane block.
2. `${CLAUDE_PLUGIN_ROOT}/scripts/start.sh <lane>`. Read the lane's rules files' headings and its `notes:` file if it has one.
3. If no task was given: show the lane's inbox items and its open briefs, ask which one (recommended first), one question.
4. Create the brief at `_line/lanes/<lane>/briefs/<task>.md` from `templates/brief.md`, `status: draft`. Read first, per `budget.readers`: `fold` (default) means you read the sources yourself, bounded, and answer the three questions (what it looks like now, work-item state, other branches on the folder); `lean` means one `line-reader` for all sources, 400 words; `on` means one per source in parallel. Fill the brief from what was read.
5. Ask the designer the brief's decisions one at a time, drawn or screenshotted first when visual. Write each answer into the brief. When all are answered, set `status: approved`.
6. Dispatch `line-writer` (one per worktree) with the brief path, worktree, rules files; when each returns, dispatch `line-checker` with the gate, the numbers to measure, and the short list of items the brief marks for the designer's eyes (often none); do not ask it to screenshot everything. Send findings back to the same writer with SendMessage; re-check. Every time a subagent returns, record its cost from the Agent tool's usage block: `${CLAUDE_PLUGIN_ROOT}/scripts/usage.sh add <task> <lane> <role> <agent name> <model> <effort> <tokens> <tool_uses> <ms> <outcome> "<note>"` (outcome clean / returned / escalated / paused; readers you dispatched in step 4 too).
7. Ship as `ship.mode` and `ship.approval` say. Merge lanes: `${CLAUDE_PLUGIN_ROOT}/scripts/merge.sh <lane> <branch>`. PR lanes: wait for the designer's yes, then push and open the PR with the description the lane's rules require. Append to the ledger.
8. Anything the designer says mid-task that is not this task goes through the four inbox cases in CONTEXT.md, at once.
9. `node ${CLAUDE_PLUGIN_ROOT}/scripts/usage-report.mjs <task>`: paste it into the brief's "Cost and next time" section with one sentence of your own on what made the task cheap or expensive. Report (designer.md shape) and end the report with the cost line and the "Next time" direction. Mark the brief `status: done` and remove its inbox line. Stop servers by port, delete scratch. Read the inbox and ask: next item, or stop.
