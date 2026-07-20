# Goals

- Track one or more forked git repositories and their relationship to upstream.
- Maintain a set of custom patches per fork.
- Sync a fork with upstream (fetch new upstream commits, tags, or releases).
- Rebase/replay the maintained patch set onto the new upstream state after a sync.
- Surface merge/rebase conflicts when a patch no longer applies cleanly, for manual resolution.
- Operate across multiple forks from a single workspace/config (fleet management), not just one repo per run.
- Provide the above as CLI automation, scriptable and non-interactive-friendly where possible.
- Avoid writing custom patch management logic when an existing tool can provide the functionality.

## Design decisions

- **Patch representation:** branch-pair DAG (TopGit-style) as the initial model — each patch is its own branch plus base branch, reapplied via git merge. External text patches (quilt/guilt-style) planned as a second supported mode later.
- **Conflict handling:** standard git rebase semantics — stop at the first patch that fails to reapply, leave the repo in a mid-rebase state for manual resolution, don't attempt best-effort across the rest of the stack.
- **Fleet state:** no central manifest. Each fork carries its own metadata; fleet-wide commands discover forks by scanning a directory.
- **Scope:** fork maintenance only. Pushing patches upstream as PRs is explicitly out of scope — forkctl tracks/syncs/replays, nothing more.
