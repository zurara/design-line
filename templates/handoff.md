# Handoff: <lane name> (<lane id>)

Last updated: <YYYY-MM-DD HH:MM>. Update at every milestone: brief approved, decision made, PR opened or merged, shipped, task done, queue reordered.
<!-- Agents working outside the coordinator add, right under the line above:  change: {MM-DD HH:MM} · {who} · {what changed, written where} -->

## How to resume in a terminal

```bash
cd <workspace> && claude
```

Say: "Read `_line/lanes/<lane id>/handoff.md` and continue as this lane's coordinator." Or dispatch the `line-coordinator` agent with the lane id. Read the Rules section before Open items.

## 1. What this lane does

One paragraph: scope, repos, what "shipped" means here, who else is involved.

## 2. Rules the designer set (all still valid)

Bullets, each with the date it was set. Organization-wide rules stay in designer.md and org.md; only lane-specific ones go here.

## 3. IDs and paths used often

| Thing | Value |
| --- | --- |

## 4. Open items (<date>)

### Waiting for the designer (ask one at a time, from 1)
1.

### Waiting for others
-

### In progress
-

### Queue
-

## 5. How to continue

1. Check the first 8 lines of this file for `change:` lines; trust them, catch up, delete them.
2. Verify against git, open PRs, listening ports, the ledger tail. Files describe the past.
3. Ask the designer the open questions one at a time; write each answer into the task's brief before acting.
4. When a branch comes back: check, ship as the lane says, append to the ledger, update this file.
5. Before stopping: stop servers you started (by port), delete scratch, write this file to the current state.
