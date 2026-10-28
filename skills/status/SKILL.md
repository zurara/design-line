---
name: status
description: Where am I. One screen across every lane for a designer who does not remember what is pending or how much has piled up: open items per lane, the inbox, the running batch, what shipped recently, the week's cost, then one question, which thing to start. Read-only. Use when the designer says "从哪开始", "我有什么事", "现在什么情况", "where was I", "what's pending", "status", or opens a session with no task in mind.
---

# /design-line:status

Read `${CLAUDE_PLUGIN_ROOT}/CONTEXT.md` once and `_line/designer.md` for the language. Then, without dispatching anyone:

1. `${CLAUDE_PLUGIN_ROOT}/scripts/start.sh` with no lane: it prints every lane's open briefs, the whole inbox, the batch table, the ledger tail and the week's usage.
2. For each lane, list the briefs whose status is not done (title and status only).
3. Show one screen, in this order, short:
   - **Waiting for you**: numbered decisions across lanes, each one line, with the id the brief gave it.
   - **Running or paused**: the batch table, if any.
   - **Shipped recently**: the ledger tail, one line each.
   - **Inbox**: grouped by lane, `#tags` kept, oldest first.
   - **Cost this week**: the first line of `node ${CLAUDE_PLUGIN_ROOT}/scripts/usage-report.mjs`.
4. If `scripts/inbox.sh old 30` lists lines older than 30 days, say how many and offer to archive them (`inbox.sh archive <n>`, into `_line/inbox-archive.md`) as part of the one question below.
5. Then one question, with a recommendation first: which item to start (the one that unblocks the most, or the oldest blocking one), or answer the waiting decisions first, or stop. When the designer picks a task, continue as `/design-line:line <lane> <task>`; when they pick decisions, ask them one at a time and write each into its brief.

Nothing is written during status except the answers the designer gives.
