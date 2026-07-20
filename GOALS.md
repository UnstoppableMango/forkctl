# Goals

- Track one or more forked git repositories and their relationship to upstream.
- Maintain a set of custom patches per fork.
  - Branch-pair DAG (TopGit-style), reapplied via git merge. Text patches (quilt/guilt) as second mode later.
- Sync a fork with upstream (fetch new upstream commits, tags, or releases).
- Rebase/replay the maintained patch set onto the new upstream state after a sync.
- Surface merge/rebase conflicts when a patch no longer applies cleanly, for manual resolution.
  - Stop at first failing patch, leave mid-rebase state, no best-effort across rest of stack.
- Operate across multiple forks from a single workspace/config (fleet management), not just one repo per run.
  - No central manifest. Each fork carries own metadata, discovered by scanning a directory.
- Provide the above as CLI automation, scriptable and non-interactive-friendly where possible.
- Avoid writing custom patch management logic when an existing tool can provide the functionality.
- Fork maintenance only. Pushing patches upstream as PRs out of scope.
