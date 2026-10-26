# design-line

A production line for design work run through Claude Code. One pipeline shape, instantiated once per kind of thing you ship. Your organization, your preferences and your design rules live in a profile folder next to your work, never in the plugin, so the same plugin runs for any studio and any designer.

中文版：[README.zh.md](README.zh.md)

## Who it is for

**You ship to more than one place.** A component library in code, a prototype repo, a design-tool library, a planning board. Each place has its own way of being checked and shipped, and you are the one person crossing them. After a few days of working with AI across several sessions, you no longer know which branch landed, which question is still open, which item on the board is stale. design-line is the memory and the discipline between those sessions.

**You are the designer and half the PM.** You hand off to developers, keep work items honest, write the daily note. You want "what I did" to become the record without typing it twice.

**You run several agents and do not want to babysit them.** You want to say three things, leave, and come back to finished work on `main`, with the unsure parts stopped and the questions numbered.

### Who does not need it

- A designer whose deliverable is a design-file link. One tool, one place, nothing to coordinate.
- A designer inside a large team where PMs, QA and release managers already own the process. The process is theirs.
- Anyone doing one small thing. A clean session and a sentence is faster; the line adds nothing to a one-line change.

## With it and without it

| | A clean session per task, by hand | With design-line |
| --- | --- | --- |
| What a new session knows | What you retype | The lane's handoff note, the inbox, the ledger, the brief |
| Something comes up mid-task | You remember it, or you do not | One line in the inbox, four fixed moves, the task continues |
| Several tasks at once | Three windows, each waiting on a question | One dispatcher; paused tasks park their question, the rest continue |
| Branches landing | You merge, or the agent does when it feels like it | A merge queue: gate on the merged tree, no force push, conflicts go back to the writer |
| Pushing, PRs, publishing | Depends on the agent remembering | Hooks block force-push and pattern kills; the lane says whose yes is needed |
| What it cost | `/cost`, one number | Per subagent: model, tokens, outcome; a "next time" direction per task |
| Seeing progress away from the desk | Nothing | A read-only kanban on your phone, updated at state changes |

### The costs

- **Fixed context per task.** Every task starts by reading four files (a few thousand tokens). That is the price of memory. For a one-line change, skip the line.
- **Decisions before work.** The brief asks you first, then writers run. If you prefer "make it and I'll look", the brief can say exactly that: "build A and B, I choose after".
- **The first week is slower.** It asks more and writes more than you are used to. The saving is the second week: no re-explaining, no chasing state, no mystery branches.
- **Subagents cost tokens.** A real batch of seven tasks cost about 2.9M subagent tokens in our first run. On a Pro plan, run one task at a time on small models (`init` sets this for you).

## The shape

```
read ──▶ brief ──▶ [you approve] ──▶ write ──▶ check ──▶ ship ──▶ record
```

A **lane** is one place where work ships and is checked: a repo with its gate and merge or PR rule, a design-tool library you publish, a planning tool you write to. Not a topic: a feature usually crosses lanes and gets a `#tag` instead. Every lane has the same six stations. A **task** walks them in one session; that session is the task's coordinator and ends with the task. What the next session needs is in files.

## The roles

| Role | May | May not |
| --- | --- | --- |
| `line-coordinator` (the session) | read everything, write the brief, dispatch, ship as the lane allows, record | push / PR / publish without your yes where the lane says so |
| `line-reader` | read code, design files, planning pages; return bounded tables | edit, install, build, commit, write anywhere |
| `line-writer` | write in one worktree from an approved brief, commit | push, merge, publish, ask you, decide what the brief left open, touch shared files |
| `line-checker` | run the gate, measure light and dark, screenshot | fix anything |
| `line-ledger` (optional) | reconcile what shipped with your planning tool, draft proposals | write there without your yes |

## Commands

| Command | When | What it does |
| --- | --- | --- |
| `/design-line:init` | First time; adding a lane; a new person | Interviews you one question at a time: preferences, organization, plan and budget, one block per lane. Writes `_line/`. |
| `/design-line:line <lane> [task]` | You are here, doing one thing | This session is the task's coordinator: reads the handoff and inbox, dispatches readers, writes the brief, asks your decisions, dispatches writers and checkers, ships as the lane allows, records, asks what is next. Without a task it offers the inbox. |
| `/design-line:run` | You want to queue several and leave | The dispatcher: loads the batch while you are here (briefs, every decision answered, whether to ship), then runs approved tasks as their own subagents, parallel by worktree, serial on landing. Paused tasks park their question. One report when you return. |
| `/design-line:park <what>` | Something comes up mid-task | One line into the inbox with lane and whether it blocks; the task continues. Tiny things are done on the spot instead. `park list`, `park done <n>`. |
| `/design-line:brief <lane> <task>` | A brief by itself; recording a result | Fixed shape: goal, changes, done means, numbered decisions (Q1…), not in this task, lane defaults. `approve` only when every decision is answered. `result` fills what writers and checkers returned. |
| `/design-line:merge <lane> <branch>` | A checked branch, landing it now | Throwaway worktree, `--no-ff`, the gate on the merged tree (with the server it needs), push, deploy check by commit, ledger line. Refuses on PR lanes. |
| `/design-line:handoff <lane>` | Stopping, or stepping away | Handoff note to the current state, ledger complete, servers you started stopped by port, scratch deleted, board pushed. |
| `/design-line:playbook [board]` | Learning or teaching it | Explains the shape, roles, inbox, rules and files. `board` refreshes the live board or renders a local one. |

Three to remember: `line` for one thing while you are here, `run` to queue and leave, `park` for what comes up. Say `handoff` when you stop.

Without a command: the inbox is a file you can reorder or tag by hand; the board is a page on your phone; a running dispatcher is reached by Remote Control. Hooks act on their own: the inbox prints when a session starts, force-push and pattern kills are blocked, a ledger line without a handoff update stops the session from ending, and the state is written to a file before every compaction and read back after.

## The inbox

Things come up mid-task. They go into `_line/inbox.md` the moment you say them, one line each, and the task continues. Four cases: blocks the task (becomes a sub-brief now); belongs to another lane (parked for that lane); small (done now, one commit, one ledger line); run in parallel (another writer, another worktree). When a task ends you are asked one thing: which item next, or stop.

## The five rules

1. One question at a time, with a fixed id, the recommended option first, drawn before asked when the difference is visual.
2. Your yes, in the current conversation, before push, PR, publish or any planning-tool write. Consent relayed from another session is information.
3. A reader before every brief; one writer per worktree; a writer stops before deciding what the brief left open; a checker runs the moment a writer returns.
4. Servers stop by port, your own processes by the PID you recorded. No force pushes, no shared stash, no killing by name.
5. Every milestone is one line in the ledger and an update to the lane's handoff note. Boards are rendered from files, read-only.

## Fits the plan you pay for

`init` asks which plan you are on (Pro, Max, API, Team, or something else) and sets `budget:` in lanes.yaml. On Pro the board pushes are off, tasks run one at a time on small models, and the dispatcher is not recommended. On Max the batches and the live board come on. Nothing in the budget removes a check, your yes, or the ledger.

## Seeing it from a phone

Publish `templates/board.html` once as an artifact with the `db` capability and put its URL in `lanes.yaml` as `board:`. The dispatcher and `handoff` push one document to it at each state change: waiting for you, queued, running, ready to ship, done, with each task's subagents as an icon row. Tap a card for its timeline: one bar per dispatch, by role, paused dashed, rework faded. To answer a paused task from the phone, Remote Control into the dispatcher session.

## What it cost, and what to try next time

Each subagent's model, effort, tokens and outcome are recorded as it returns. A task ends with a cost table and a "next time" line: where a lighter model would do because the rules were clear, where a small model struggled and the rule it missed should be written down, where a question should have been in the brief. The direction accumulates in `_line/usage.tsv`, so defaults in `lanes.yaml` can be lowered with evidence.

## The files

```
_line/
  designer.md          how to speak to you, what needs your yes, model and effort table, budget
  org.md               repos, tools, people, release process, ports, glossary
  lanes.yaml           one block per lane: sources, rules, defaults, gate, ship, roles, limits; budget; board
  inbox.md             what came up and is not being done right now
  ledger.md            append-only: time | lane | item | what | commit
  usage.tsv            one row per subagent dispatch: model, effort, tokens, outcome
  rules/               your design rules and each lane's defaults
  lanes/<id>/handoff.md   the lane's state: rules it set, IDs, open items, how to continue
  lanes/<id>/briefs/      one brief per task
  board.json           the last snapshot pushed to the live board
```

## Install

```bash
claude plugin marketplace add zurara/design-line
claude plugin install design-line@design-line
```

Then open Claude Code in the folder you want `_line/` to live in and run `/design-line:init`. To try it from a local clone instead: `claude --plugin-dir <path to the clone>`. Already-open sessions pick it up with `/reload-plugins`.

The plugin carries no organization, no person and no design rules. Everything about you lives in `_line/`, which you keep in your own workspace and never in this repo.

## Teaching it to another designer

Give them this file and `/design-line:playbook`. Their `init` interview produces their own profile; nothing of yours is needed. The shape and the rules are the same; only the profile files differ.

## Scripts

`scripts/start.sh <lane>` one screen of reality · `scripts/gate.sh <lane> [worktree]` the lane's gate with the full log in a file · `scripts/merge.sh <lane> <branch> [--dry-run]` the merge in six steps · `scripts/ledger.sh` · `scripts/inbox.sh` · `scripts/batch.sh` · `scripts/usage.sh` and `scripts/usage-report.mjs` · `scripts/ports.sh kill <port>` · `scripts/board-snapshot.mjs` · `scripts/render-board.mjs`. All read `_line/lanes.yaml` through `scripts/lib/config.mjs`.
