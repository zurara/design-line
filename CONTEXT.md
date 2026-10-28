# design-line — context for agents

Rules only. The reasons and the stories are in `docs/RATIONALE.md`. No organization facts here; those are in the profile folder `_line/`.

**No plugin loaded?** Read the skill from `<plugin>/skills/<name>/SKILL.md`, dispatch `general-purpose` with `<plugin>/agents/<role>.md` prepended, call scripts by path, and say so in your first line.

## Layers

| Layer | Where | Changed by |
| --- | --- | --- |
| Framework: roles, shape, templates, scripts, hooks | this plugin | maintainers |
| Organization profile | `_line/org.md` | the designer |
| Designer profile | `_line/designer.md` | the designer |
| Lanes | `_line/lanes.yaml` | `/design-line:init`; the coordinator only on the designer's yes |
| Domain rules | files the lane's `rules:` names | the organization |

Find `_line/`: `$DESIGN_LINE_HOME`, else walk up from the working directory (`scripts/lib/config.mjs home`). None: `/design-line:init`.

## Read order at start

1. `_line/designer.md`. 2. `_line/org.md`. 3. the lane's block in `lanes.yaml`. 4. the lines `start.sh <lane>` prints (this lane's inbox, open briefs, git, PRs, ports, ledger tail) and the lane's `notes:` file if any. 5. the lane's rules: the sections the brief names, else whole. Then verify against git and PRs; files describe the past.

## The shape, one session per task

```
read ──▶ brief ──▶ [designer approves] ──▶ write ──▶ check ──▶ ship ──▶ record
```

- **read**: answer three things before any brief: what it looks like now, the related work item's state, other branches on the same folder. `budget.readers`: `fold` = the coordinator reads itself, bounded (sections, never a whole file over ~300 lines; more than that, dispatch a `line-reader`); `lean` = one reader per task, 400 words; `on` = one per source.
- **brief**: one per task from `templates/brief.md`. Section 0 restates the whole ask in one paragraph in the designer's words and gets a yes first; then the decisions (Q1…), one at a time, recommended option first, drawn before asked when visual. `rules_to_read` names the rule sections. `writer_model` is sonnet unless new behaviour, a new component, drawing in a design tool, or work the designer iterates on. `status: approved` only when every decision is answered.
- **write**: one `line-writer` per worktree; writers on the same files run one after another. A writer stops at the **first** open question (4b defaults are not questions) and never decides for the brief; it reads line ranges, not whole files; it runs the gate once before returning; it re-reads the brief at each commit for `brief_version` changes.
- **check**: `line-checker` the moment a writer returns: gate once per commit (reuse the writer's log), DOM measurements for every number, screenshots only for items the brief marks for the designer's eyes or a number cannot settle, capped by `budget.max_shots`. It fixes nothing.
- **ship**: `ship.mode` and `ship.approval`. `approval: designer` = the designer's yes in this conversation; relayed consent is information. Merge lanes: `scripts/merge.sh`; conflicts go back to the writer to merge `main` in (never rebase or force-push). PR lanes: open only when the brief says ship: yes; after one PR lands, merge `main` into the other open branches so each stays mergeable alone.
- **record**: `scripts/ledger.sh` one line per event; the brief's status true (`paused` when stopped on a question, never `done`); its inbox line removed when done; `scripts/usage.sh add` for every subagent that returned (model, effort, tokens, tool_uses, ms, outcome; `resume` for a continued agent). End with `usage-report.mjs <task>` in the brief and the report.

State lives in files: inbox = pending and waiting-for-others, briefs = in progress, ledger = shipped, usage.tsv = cost. No status notes, no dashboards written by hand; `render-board.mjs` renders `_line/board.html`.

## The designer's words

Gather while they talk (nothing dispatched); task-related goes to the brief draft, the rest to the inbox (`park`); unclear: one question, "this one, or later?". Restate (section 0), get a yes, freeze. After approval a change is a dated line under "Changes after approval" with its cost said first and `brief_version` +1, delivered at the writer's next commit; a reversal is struck through. Talk never pauses writers; only an approved change does.

## Inbox, four cases

`date | lane | what | blocks: <task or -> | from`. Blocks the task → sub-brief now. Another lane → park for it. Small (one color, one line) → do it, one commit, one ledger line, no inbox. Parallel and not blocking → another writer in another worktree. Task ends → ask: next item, or stop. Lanes are where work ships; `#topic` tags cross them. Old lines: `inbox.sh old`, `inbox.sh archive <n>`.

## Batches, depth, sessions

`/design-line:run` is the one optional resident: load (briefs, every decision answered, ship yes/hold) while the designer is present, then run approved tasks as writers and checkers, parallel by worktree within `budget.parallel`, serial where files are shared, landing one at a time; a paused task parks its question and the batch moves on; one report on return; the session ends with the batch. **Depth is two**: a session and its workers, never a coordinator under a coordinator. At most one session per lane plus one dispatcher. Shared files take locks (`_line/.lock-*`); board writes carry a version; `main` is protected by the merge script; ports are checked before use.

## Questions and reports

Only the lane that is blocked asks, one question at a time, each with a fixed id (Q1…) written into the brief and the inbox. A subagent never asks: it numbers its questions in its report; the parent asks and sends the answer back with SendMessage. A report before all children returned is marked `interim` and records nothing. Reports follow designer.md: what changed, screenshots (few), gate, link, open items, the cost line.

## Models and budget

designer.md has the table. Writers: small unless the brief says otherwise. Readers, checkers, mechanical edits: small, medium. A small model's wrong result goes back once; the second time, a larger model. `budget:` in lanes.yaml: `plan`, `weekly_tokens`, `board`, `parallel`, `readers`, `default_model`, `experiment` (label every usage row carries; `usage-report.mjs` compares groups), `max_shots`. The budget never removes a gate, a check, the designer's yes or the ledger line.

## After shipping

`line-auditor` compares the live product with its design source: DOM numbers first, overlay only where a number cannot settle it; verdict per finding (`product`, `design`, `unclear`); findings become inbox lines; `/design-line:audit` drives it and ends with the lane's after-review step (a prototype lane moves the flow's status) only on the designer's yes.

## Compaction and processes

Before compaction the hook writes `_line/.compact-state.md`; after, it is printed back: continue from the brief. Record the PID or port of anything you start and stop it by that only; never match processes by name; no background waits that hold your turn.

## Never

Push, PR, publish or planning-tool write without the designer's yes where the lane requires it · force-push · shared `git stash` · kill by name pattern · change versions or release files · ask on behalf of another lane · write dashboards by hand · leave servers, scratch or screenshots behind.
