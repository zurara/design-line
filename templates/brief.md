---
lane: <lane id>
task: <short task id>
status: draft        # draft → approved (only after the designer answered the decisions) → done
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

Numbered. Each with a screenshot or link. The recommended option first.

1. **<question>**
   - A (recommended): …
   - B: …

## 5. Not in this task

-

## Result (filled in by the writer and checker; the coordinator keeps it as the record)

- Commits:
- Gate:
- Screenshots:
- Open:

## Cost and next time (from `scripts/usage-report.mjs <task>`)

Paste the report: per subagent its model, effort, tokens, outcome; then the "Next time" lines. One sentence of your own on what made it cheap or expensive (a clear rule, a missing default, a question the brief should have carried).
