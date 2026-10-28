---
name: park
description: Park something that came up so it is not lost and does not derail the current task. One line into _line/inbox.md with the lane, what it is, whether it blocks the current task, and who said it. Also lists or clears inbox items. Use whenever the designer says "also", "by the way", "later", "remind me", "add to the queue", or a writer hands back a question that belongs to another lane.
---

# /design-line:park [lane] <what> | list | done <n>

- `add`: decide the lane from what was said (ask only if two lanes fit equally). Decide `blocks:`: the current task's id if the task cannot finish without it, else `-`. Run `${CLAUDE_PLUGIN_ROOT}/scripts/inbox.sh add <lane> "<what, in the designer's words, under 140 characters>" [task id]`; details that do not fit go into a brief draft or the lane's notes, not the inbox line (every session reads the inbox at start). Confirm in one line and go back to the task.
- If it is case 3 of CONTEXT.md (small: one color, one line of copy, one flag), do not park it: do it now, one commit, `scripts/ledger.sh`, one line to the designer.
- `list`: `${CLAUDE_PLUGIN_ROOT}/scripts/inbox.sh list [lane]`, shown as the designer wrote it, with line numbers.
- `done <n>`: `${CLAUDE_PLUGIN_ROOT}/scripts/inbox.sh done <n>` when an item's task starts (its brief takes over). `archive <n>` when the designer drops it or it is superseded (kept in `_line/inbox-archive.md`); `old [days]` lists stale lines.
