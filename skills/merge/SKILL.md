---
name: merge
description: Ship a gated branch on a design-line lane whose ship.mode is merge: throwaway worktree from main, --no-ff merge with the configured trailer, the lane's gate re-run there, push, wait for the deploy check, append to the ledger, fast-forward the main checkout. Refuses when the lane ships by PR or publish, or when the designer's yes is required and not given. Trigger words: "merge <branch>", "ship this branch", "land it".
---

# /design-line:merge <lane> <branch>

1. Check the lane: `ship.mode` must be `merge`. If `ship.approval` is `designer`, the designer must have said so in this conversation about this branch; a "hold" from them stops everything.
2. The branch must have come back from a checker with the gate passing. If not, run `line-checker` first.
3. `${CLAUDE_PLUGIN_ROOT}/scripts/merge.sh <lane> <branch>`; add `--dry-run` first when the lane is new. Read its six numbered lines. A gate failure means nothing was pushed: send the FAIL lines to the writer.
4. On success the script appended to the ledger. Report: what landed, the merge commit, the deploy result, light and dark screenshots from the checker, what is still open. Update the handoff note.
