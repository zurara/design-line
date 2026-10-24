# design-line — context for agents

Read this before acting as any design-line role. It says where things are and in what order to read them. It contains no organization-specific facts; those live in the profile folder.

## The four layers

| Layer | What it holds | Where | Who changes it |
| --- | --- | --- | --- |
| Framework | roles, pipeline shape, templates, scripts, hooks | this plugin | the plugin's maintainers |
| Organization profile | repos, ports, tools, IDs, people, release process | `_line/org.md` | the designer, once; agents only when the designer says so |
| Designer profile | language, how to ask, approvals, screenshot scale, model and effort table | `_line/designer.md` | the designer |
| Lane configuration | one block per lane: sources, rules, gate, ship, archive | `_line/lanes.yaml` | the designer with `/design-line:init`; the coordinator only after the designer says so |

Domain rules (how the designer's work must look and behave) are files the lane points to under `rules:`. They belong to the organization, never to the plugin.

## Finding the profile folder

The profile folder is named `_line/`. Look for it in `$DESIGN_LINE_HOME`, else walk up from the working directory until a `_line/lanes.yaml` is found. `scripts/lib/config.mjs home` prints the path. If none exists, the only thing to do is run `/design-line:init`.

## Read order, every time a role starts

1. `_line/designer.md` — how to speak to this designer and what needs their yes.
2. `_line/org.md` — the world this work lives in.
3. `_line/lanes.yaml` — the lane you are on.
4. The lane's handoff note (`handoff:` in its block), then `_line/inbox.md` (items for this lane, and anything marked `blocks:` the task at hand). A `change:` line in the note's head means a resident session is expected to catch up; if you are that session, do it and delete the lines.
5. The lane's `rules:` files, whole, before the first edit (writers quote the last line of each in their report to prove they read it).
6. `_line/ledger.md`, the tail, to see what shipped recently.

Then verify against reality before trusting any of it: git state, open PRs, listening ports, the gate. Files describe the past; git describes now.

## The shape

Every lane has the same six stations. A task walks them in order, in one session.

```
read ──▶ brief ──▶ [designer approves] ──▶ write ──▶ check ──▶ ship ──▶ record
```

- **read**: readers run in parallel and return bounded tables, never whole files.
- **brief**: the coordinator writes one brief per task (`templates/brief.md`), with `status: draft`.
- **approve**: the designer answers the numbered decisions. Only then `status: approved`. "OK, go on" moves work forward; it is not a choice between options.
- **write**: one writer per worktree. Writers that touch the same files run one after another. A writer that meets a question the brief does not answer stops and hands it back; it never asks the designer.
- **check**: a checker runs the lane's gate and takes light and dark screenshots the moment a writer returns. It fixes nothing.
- **ship**: what `ship.mode` says: open a PR, merge, publish, or nothing. `ship.approval: designer` means the designer must say so in the current conversation; relayed consent from another session does not count.
- **record**: append one line to `_line/ledger.md`; update the handoff note at milestones; keep briefs with the task.

## The ledger

`_line/ledger.md` is append-only, one line per event, written by `scripts/ledger.sh`:

```
2026-01-31 14:05 | design-system | ITEM-123 | PR #42 opened: Button loading state | 3f2a1c9
```

Columns: time, lane, external item id or `-`, what happened, commit or link. Any lane appends; the ledger role reads it. No lane messages another lane about events; they both read the ledger.

## Sessions are per task, state is in files

There is no resident coordinator session. A session opens for one task, acts as that task's coordinator (brief, dispatch, check, ship, record), and ends. Everything the next session needs is in files: the lane's handoff note, `_line/inbox.md`, `_line/ledger.md`, and the task's brief. The fixed context is paid once per task, not once per message.

Whoever changes state updates the handoff note at the milestone. If the designer chooses to keep one long-running session for a lane (optional), other sessions that touch that lane add a line `change: {MM-DD HH:MM} · {who} · {what}` under "Last updated" so the resident session can catch up and delete it. Nobody writes dashboards; boards are rendered from the files (`scripts/render-board.mjs`), read-only.

## Batches: several tasks while the designer is away

`/design-line:run` is the one optional resident: a dispatcher that holds only the inbox and the ledger tail. It loads a batch while the designer is present (briefs written, every decision answered one at a time, ship consent recorded in each brief), runs each approved task as its own `line-coordinator` subagent (parallel across lanes and worktrees within `limits`, serial where writers share files), parks any question a task hits and moves on, and reports once when the designer returns, then resumes paused tasks with their answers. Walking away is possible exactly for tasks whose decisions were answered first.

## Seeing it from a phone

`lanes.yaml` may name a `board:` URL: a published copy of `templates/board.html` with the `db` capability. It shows one document, `board/state`: waiting for the designer, running, recently done, the inbox, each lane's open items. `scripts/board-snapshot.mjs` builds that document from the files; the dispatcher pushes it with the ArtifactData tool after each state change, and `/design-line:handoff` pushes it at close. Nothing reads from the board, so it can never drift from the files for long, and it costs one write per change. To talk to a running dispatcher from a phone, the designer uses Remote Control on that session.

## The inbox: things that come up mid-task

`_line/inbox.md` is one list every session reads at start and writes the moment something new is said. One line per item: `date | lane | what | blocks: <task id or -> | from`. Four cases, each with one fixed move:

1. **Blocks the current task**: it becomes a sub-brief of the current task in the same session. If it is large, write the handoff note first, do it, come back.
2. **Belongs to another lane**: write it to the inbox with that lane's id. The next session on that lane picks it up. No message to anyone.
3. **Small** (one color, one line of copy): do it now, one commit, one ledger line. It never enters the inbox.
4. **Should run now in parallel and does not block**: dispatch a writer to another worktree from this session, or the designer opens a second session. The designer keeps talking to this one.

When a task ends, the session reads the inbox and asks one question: which item next, or stop. The designer reorders by editing the file or saying so. The daily digest takes "still open" from the inbox.

## Questions to the designer

Only the coordinator of the lane that is blocked asks. One question at a time, options with the recommended one first, drawn or screenshotted before asking when the difference is visual. A role running as a subagent cannot ask: it numbers the decisions in its report; the parent session asks and sends the answer back to the same agent.

## Choosing models

Use the table in `_line/designer.md` (the template has a default). Reading, measuring, mechanical edits: a small model, medium effort. New components, flows, drawing in a design tool: a large model, high effort. Open design or architecture problems: the largest effort. A small model's result that is wrong or incomplete goes back to the same worker once; the second time, re-dispatch on a larger model.

## Never

- Push, open a PR, publish, or write to the organization's planning tool without the designer's yes when the lane says approval is the designer's.
- Force-push, push someone else's branch, or use a shared `git stash`.
- Kill processes by name pattern. Stop a server by its port only.
- Change versions or release metadata; releases belong to the developers unless `org.md` says otherwise.
- Leave servers, scratch installs or screenshots behind after a check.
