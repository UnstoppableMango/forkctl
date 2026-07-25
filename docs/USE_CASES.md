# Use Cases

Concrete scenarios derived from [GOALS.md](../GOALS.md).
These drive test suites; kept intentionally brief, not exhaustive.

- **Track a fork**: register a forked repo and record its relationship to an upstream remote/ref.
- **Sync with upstream**: fetch new upstream commits, tags, or releases into a tracked fork.
- **Maintain a patch stack**: define a branch-pair DAG (TopGit-style) of custom patches on top of upstream.
- **Replay patches after sync**: reapply the patch stack onto the new upstream state via merge.
- **Stop at first conflict**: when a patch fails to reapply cleanly, halt and leave mid-rebase state; do not attempt the rest of the stack.
- **Operate on a fleet**: run sync/replay across every fork found by scanning a workspace directory (no central manifest).
- **Run non-interactively**: drive sync/replay from the CLI in a scriptable, non-interactive way (e.g. CI).
