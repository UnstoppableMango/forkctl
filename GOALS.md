# Goals

- Track one or more forked git repositories and their relationship to upstream.
- Maintain a set of custom patches per fork, represented as commits/branches on top of upstream in the fork itself.
- Sync a fork with upstream (fetch new upstream commits, tags, or releases).
- Rebase/replay the maintained patch set onto the new upstream state after a sync.
- Surface merge/rebase conflicts when a patch no longer applies cleanly, for manual resolution.
- Operate across multiple forks from a single workspace/config (fleet management), not just one repo per run.
- Provide the above as CLI automation, scriptable and non-interactive-friendly where possible.
