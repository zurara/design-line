---
lane: <lane id>
task: <short task id>
status: draft        # draft → approved (all decisions answered) → done; paused = work stopped on a question the brief did not answer (Result may be filled)
written: <YYYY-MM-DD>
writer_model: sonnet # sonnet unless this task is new behaviour, a new component, drawing in a design tool, or something the designer will iterate on: then opus
brief_version: 1     # +1 at every change after approval; writers re-read at each commit
rules_to_read: "<rules file>#<section>, …"   # the sections writers read; empty = whole files
---

# Brief: <task name>

## 0. In one paragraph

What the designer asked for, gathered from everything they said (the first sentence, the asides, the changes of mind), restated as one paragraph in their words. The designer approves this paragraph before the decisions are asked; it is the prompt the writers get.

## 1. Goal

One sentence.

## 2. What changes

Files or parts. For each: where it lives, what it becomes, and for a file over 800 lines the line ranges to touch (writers read ranges, not whole files). Name the worktree.

## 3. Done means

- The gate the lane defines passes (command and expected result).
- Numbers the checker measures (DOM, light and dark): …
- The designer wants to see (screenshots, few): … (leave empty when a passing gate and the numbers are enough)
- …

## 4. Decisions for the designer

Each with a fixed id (Q1, Q2, …), a screenshot or link, the recommended option first. Short answers are matched by id.

- **Q1 <question>**
  - A (recommended): …
  - B: …

## 4b. Defaults this lane applies without asking

Copied from the lane's `defaults:` file (lanes.yaml), the lines that apply here. A writer that meets a case not covered stops; the coordinator asks, and the answer becomes a new line in that file.

## 5. Not in this task

-

## Changes after approval

Dated, one line each, newest last, with what it costs (work undone, a re-check). Writers pick them up at their next commit. A change the designer reverses is struck through, not deleted.

- <date> v2: …

## Result (filled in by the writer and checker; the coordinator keeps it as the record)

- Commits:
- Gate:
- Screenshots:
- Open:

## Cost and next time (from `scripts/usage-report.mjs <task>`)

Paste the report: per subagent its model, effort, tokens, outcome; then the "Next time" lines. One sentence of your own on what made it cheap or expensive (a clear rule, a missing default, a question the brief should have carried).
