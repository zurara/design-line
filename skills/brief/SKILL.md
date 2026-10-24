---
name: brief
description: Write or update a design-line brief for one task in the fixed shape (goal, what changes, done means, numbered decisions with the recommended option first, not in this task) and move its status draft → approved → done. Use when a task needs a brief before writers start, when the designer answered a decision, or when a writer's result must be recorded. Trigger words: "write the brief", "brief this", "approve the brief", "record the result".
---

# /design-line:brief <lane> <task> [approve | result]

- New: copy `${CLAUDE_PLUGIN_ROOT}/templates/brief.md` to the lane's brief location, fill the five sections from what readers returned and what the designer asked for. Decisions are the only things the designer must answer; everything a reader or a rule already settles is written as fact, not asked. Each decision has a screenshot or link and the recommended option first. `status: draft`.
- Approve: only when every decision has the designer's answer in this conversation. Write each answer under its decision, then `status: approved`. "OK, go on" does not approve a decision that still has options.
- Result: fill the Result block from the writer's and checker's returns (commits, gate totals, screenshot paths, open points). `status: done` when shipped and recorded.
- The brief is the record the next session reads; write it so that someone who was not here understands it. No conversation history, only the final state and the dated decisions.
