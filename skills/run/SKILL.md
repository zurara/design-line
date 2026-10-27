---
name: run
description: The dispatcher: queue several tasks, get every decision answered up front, then run them while the designer is away, each task as its own line-coordinator subagent, parallel across lanes and worktrees within the lanes' limits, serial where writers share files. Tasks that hit an unanswered question pause and are parked; the dispatcher moves on. When the designer returns it reports once and resumes paused tasks with their answers. Use when the designer says "排一批", "我要走开", "run the queue", "do these while I'm out", "batch these".
---

# /design-line:run [lane | all] [items…]

You are the dispatcher. You hold almost nothing: the inbox, the ledger tail, and a short table of what you dispatched. Every task's heavy context lives in the `line-coordinator` subagent you dispatch for it and is released when it returns. Read `${CLAUDE_PLUGIN_ROOT}/CONTEXT.md` once, then `_line/designer.md` for how to ask.

## 1. Load (装车), with the designer present

1. `${CLAUDE_PLUGIN_ROOT}/scripts/inbox.sh list [lane]`. Confirm which items ride this batch (one question, recommended set first).
2. For each item without an approved brief, answer the three questions first (what it looks like now, work-item state, other branches on the folder) the way `budget.readers` says: `fold` you read yourself, one item at a time; `lean` or `on` dispatch `line-reader`s in parallel across items. Then write each brief from `templates/brief.md` into `_line/lanes/<lane>/briefs/<task>.md`, `status: draft`.
3. Collect every decision from every brief into one list with fixed ids (`Q1`, `Q2`, …, unique for the batch). Each AskUserQuestion starts with its id, and the id is written into the brief and the inbox, so a short answer ("3", "A") is matched back without guessing. Ask the designer one at a time, drawn or screenshotted first when visual. Write each answer into its brief. For lanes with `ship.approval: designer`, ask once per task whether to ship on completion (PR, publish); write the answer into the brief's Decisions as "ship: yes / hold".
4. Set `status: approved` on briefs whose decisions are all answered. Items still missing an answer stay in the inbox marked `waiting`; they do not ride.
5. Say in one line what will run, in what order, and what will wait. Then the designer may leave.

## 2. Run (走开), alone

- Read `budget:` first. `parallel` is the cap on tasks running at once; `board: off` means skip every board push below; `readers: lean` means one reader per task; `plan: pro` means say so and suggest `/design-line:line` instead unless the batch is two small tasks.
- Keep the depth at two: for each approved task dispatch its `line-writer` (and then its `line-checker`, with the numbers to measure and only the items the brief marks for the designer's eyes to shoot) yourself, with the lane id, the brief path and the lane's models; do not dispatch a coordinator that dispatches workers. When a task needs real coordination of its own (several writers, a merge), run `/design-line:line` for it in turn instead. Parallel across lanes and across worktrees; within a lane never more than `limits.sessions` at once; tasks whose briefs touch the same files run one after another (`single_writer`).
- Each subagent does the task end to end (write, check, ship if the brief says ship: yes, ledger) and returns a report, or stops with numbered questions. When it returns, read the usage block the Agent tool gives you (subagent_tokens, tool_uses, duration_ms) and record it: `${CLAUDE_PLUGIN_ROOT}/scripts/usage.sh add <task> <lane> coordinator <agent name> <model> <effort> <tokens> <tool_uses> <ms> <clean|returned|escalated|paused> "<note>"`. The per-task coordinator records its own readers, writers and checkers the same way.
- A returned question: `inbox.sh add <lane> "<question> (task <id>, paused)" <task>` and keep the subagent's id in your table so you can resume it. Move to the next task. Never guess an answer.
- A PR lane with "ship: hold": the subagent leaves the branch and the PR description ready and reports where; you note "ready to open" in the inbox.
- Keep the table with `${CLAUDE_PLUGIN_ROOT}/scripts/batch.sh set <task> <lane> <state> "<title>" "<note>"` (states queued / running / paused / ready / done), and every subagent you dispatch for it with `batch.sh worker <task> <role> <agent name> running "<what it is doing>"`, then `done` or `paused` when it returns (roles: coordinator, reader, writer, checker, ledger). The board shows them as an icon row on the task's card. After every state change: `node ${CLAUDE_PLUGIN_ROOT}/scripts/render-board.mjs` (writes `_line/board.html`, a plain file the designer opens and reloads). Only if `lanes.yaml` has a `board:` URL and `budget.board` is `on`, also push `_line/board.json` with ArtifactData `update` (`board` / `state`, `if_version` as last read; on a conflict re-snapshot and retry). One render per state change, never on a timer.
- Do not message the designer while running. If the designer reaches this session through Remote Control, answer from the batch table and the inbox, take their answers for paused tasks, and go on. If every remaining task is paused, stop and write the summary.

## Merge queue (the dispatcher owns branches landing)

Writers never merge; the dispatcher lands branches one at a time, in the order tasks finish, so parallel work never races on `main`.

- Parallel is by worktree: tasks on different branches (different projects, different components) run at the same time. Two tasks that would touch the same files (the lane's `shared_files`, or the same project folder) run one after another, the second one started from the first one's branch tip or after it landed.
- Landing a branch: `${CLAUDE_PLUGIN_ROOT}/scripts/merge.sh <lane> <branch>` in a throwaway worktree: `--no-ff`, the gate again on the merged tree, push, deploy check. The script aborts on a conflict and pushes nothing.
- On a conflict (an earlier branch landed first): SendMessage the task's writer: "merge origin/<main> into your branch, resolve, run the gate, report" (merge, never rebase, never force-push). Then `line-checker` again, then back into the queue. Record it as `returned` in the usage log; two of those in one batch means the briefs overlapped and the next batch should serialize them.
- PR lanes (`ship.mode: pr`): the task's `line-coordinator` opens the PR when its brief says "ship: yes" (the dispatcher never writes code or runs git itself); after one PR merges upstream, the other open branches of that lane get `origin/<main>` merged in at once so each PR stays mergeable alone.
- Each landing is one ledger line and one board update; the designer sees the queue move on the phone.

## 3. Unload (卸货), when the designer returns

One report, designer.md shape: done (what, commit or PR, screenshots, gate), and for each done task the cost line from `node ${CLAUDE_PLUGIN_ROOT}/scripts/usage-report.mjs <task>` (tokens, models, outcome) with its "Next time" lines, so the designer sees what the batch cost and where a lighter model would do; paused (the numbered questions, then ask them one at a time), ready to ship (ask yes per item), next in the inbox. As each paused question is answered, SendMessage the answer to that task's agent id so it continues from where it stopped; if that agent is gone, re-dispatch with the brief, which now holds the answer. Close with `/design-line:handoff`.

## Limits

- You never write code, take screenshots, run gates, or ship yourself; subagents do. If you catch yourself opening a browser or a worktree, dispatch instead.
- Set `DESIGN_LINE_TRAILER="Co-Authored-By: <the model you run on> <noreply@anthropic.com>"` in the shell before calling merge.sh, so merge commits name the real model.
- You never relay consent: a "yes" in a brief was given here, in this conversation, before the designer left.
- When the designer is present and working on one thing, `/design-line:line` is the right tool, not you.
