# Designer profile

Who the agents work for and how to behave with them. Every role reads this first. Change it whenever a preference changes; agents never edit it on their own.

## Who

- Name:
- Role: designer (decides how things look and behave; releases, versions and engineering process belong to the developers unless org.md says otherwise)
- Writes in: <language>. Agents reply in the same language, plainly, every sentence with a subject.

## How to ask

- One question at a time. Number the options, put the recommended one first.
- When options differ in pixels or in where a click lands, draw them first, then ask. Screenshots at 2× scale.
- "OK, go on" moves the work forward. It is not a choice between options.
- The same question is asked once, by the lane coordinator that is blocked by it. Other lanes never repeat it.
- When the designer says they are away or busy, every question from every session goes through the coordinator and is asked one by one when they return.
- A reply button offers an action, never states a fact. If what the agent found contradicts the button's premise, the agent says so before writing anywhere.

## How the designer gives input

- <one of: in one clear brief | in fragments, with asides and changes of mind | mostly by pointing at screenshots>. The line gathers, restates in one paragraph (brief section 0), gets a yes, then works; changes after that go through the brief at checkpoints, with their cost said first.
- When it is unclear whether an aside belongs to the current task: ask "this one, or later?" once.

## What needs the designer's yes, said in the current conversation

- Push, open a PR, publish a library, merge where the lane says `approval: designer`.
- Any write to the planning tool, any comment made in the designer's name (show the draft first).
- Archiving a session, deleting a branch, changing shared rules or settings.
- Relayed consent from another session is information, not a yes.

## Reports

- What changed, light and dark screenshots, gate or test result, link or PR, what is still open.
- No progress messages while a task runs. Interrupt only for a new decision.
- Last line: the lane's status link, if the lane has one.
- No dashes used as punctuation in shipped copy; no ID chains in prose; PR numbers as links.

## Model and effort

| Work | Model | Effort |
| --- | --- | --- |
| Reading, listing, checking whether something is used (read-only) | small (sonnet) | medium |
| Checking against a list: measuring, screenshots, gate and tests | small | medium |
| Mechanical edits: syncing icons, a one-line doc change, assembling a small feature from existing parts | small | medium |
| New components, behavior changes, flows, drawing in the design tool, work iterated with the designer | large (opus) | high |
| Design or architecture problems with no ready answer | large | xhigh |
| The coordinator itself (judgment, briefs, questions) | large | high |

A small model's result that is wrong or incomplete goes back to the same worker once; the second time, re-dispatch on a large model.

## Budget

- Plan: <pro | max5 | max20 | api | team>. Rough weekly budget for subagent tokens: <number or "not tracked">.
- What is switched off to fit it (mirrors `budget:` in lanes.yaml): board pushes, parallel batches, one reader per source, large default model. Switch things back on when the plan changes.
- A task that would clearly blow the week's budget is parked in the inbox with a note, not started.

## Clean-up

- Delete screenshots, scratch installs and servers once results are written; say so in the report.
- Stop servers by port only. The designer's own server (list its port in org.md) stays up.
