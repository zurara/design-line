---
name: line
description: Start or continue work on one design-line lane as this session's task coordinator. Prints the lane's reality (handoff head, inbox, git, PRs, ports, ledger tail), names the task (given, or the next inbox item), then drives it through the shape: readers, brief, the designer's approval, writers, checkers, ship, record, and asks what is next. Use for any lane work: "work on <lane>", "continue <lane>", "next task on <lane>", "/line <lane> <task>".
---

# /design-line:line <lane> [task]

Read `${CLAUDE_PLUGIN_ROOT}/CONTEXT.md` once. Then act as the `line-coordinator` role for this one task, in this session (do not dispatch a coordinator subagent for it; dispatch readers, writers and checkers).

1. `node ${CLAUDE_PLUGIN_ROOT}/scripts/lib/config.mjs home`; if empty, stop and point to `/design-line:init`. Read `_line/designer.md`, `_line/org.md`, the lane block.
2. `${CLAUDE_PLUGIN_ROOT}/scripts/start.sh <lane>`. Read the handoff note whole and the lane's rules files' headings.
3. If no task was given: show the lane's inbox items and the handoff's queue, ask which one (recommended first), one question.
4. Create the brief at the place the lane's handoff note names for briefs (default `_line/lanes/<lane>/briefs/<task>.md`) from `templates/brief.md`, `status: draft`. Dispatch `line-reader` agents for the sources the task needs, in parallel, with a word limit. Fill the brief from their returns.
5. Ask the designer the brief's decisions one at a time, drawn or screenshotted first when visual. Write each answer into the brief. When all are answered, set `status: approved`.
6. Dispatch `line-writer` (one per worktree) with the brief path, worktree, rules files; when each returns, dispatch `line-checker` with the gate, pages and numbers. Send findings back to the same writer with SendMessage; re-check.
7. Ship as `ship.mode` and `ship.approval` say. Merge lanes: `${CLAUDE_PLUGIN_ROOT}/scripts/merge.sh <lane> <branch>`. PR lanes: wait for the designer's yes, then push and open the PR with the description the lane's rules require. Append to the ledger.
8. Anything the designer says mid-task that is not this task goes through the four inbox cases in CONTEXT.md, at once.
9. Report (designer.md shape). Update the handoff note. Mark the brief `status: done`. Stop servers by port, delete scratch. Read the inbox and ask: next item, or stop.
