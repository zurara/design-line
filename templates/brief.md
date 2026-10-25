---
lane: <lane id>
task: <short task id>
status: draft        # draft → approved (all decisions answered) → done; paused = work stopped on a question the brief did not answer (Result may be filled)
written: <YYYY-MM-DD>
---

# Brief: <task name>

## 1. Goal

One sentence.

## 2. What changes

Files or parts. For each: where it lives, what it becomes. Name the worktree.

## 3. Done means

- The gate the lane defines passes (command and expected result).
- Light and dark screenshots of: …
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

## Result (filled in by the writer and checker; the coordinator keeps it as the record)

- Commits:
- Gate:
- Screenshots:
- Open:

## Cost and next time (from `scripts/usage-report.mjs <task>`)

Paste the report: per subagent its model, effort, tokens, outcome; then the "Next time" lines. One sentence of your own on what made it cheap or expensive (a clear rule, a missing default, a question the brief should have carried).
