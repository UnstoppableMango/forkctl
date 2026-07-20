# forkctl

Tooling to maintain a fleet of forked git repos: track relationship to upstream, sync new upstream commits, and replay a maintained patch set on top.

## Status

Ideating.

See [GOALS.md](GOALS.md) for full goals and design decisions.

## Comparison

Tools considered when scoping forkctl.
Per goal #8, prefer wrapping/using one of these over writing patch-stack logic from scratch.

| Tool | Patch stack | Git-native storage | Fleet (multi-repo) | Auto upstream sync | Conflict surfacing | Maintained |
|---|---|---|---|---|---|---|
| [quilt](https://savannah.nongnu.org/projects/quilt) | yes | no (text diff files + series) | no | no | manual | yes |
| [guilt](https://github.com/jeffpc/guilt) | yes | partial (text patches, per-branch dir) | no | no | manual | **no** |
| [StGit](https://stacked-git.github.io/) | yes (linear) | yes (commits) | no | no | stop-at-conflict (rebase) | yes |
| [TopGit](https://github.com/mackyle/topgit) | yes (DAG) | yes (branch pairs) | no | no | merge-based | yes |
| [gbp pq](https://manpages.debian.org/testing/git-buildpackage/gbp-pq.1.en.html) | yes | yes (patch-queue branch ↔ quilt series) | no | no | manual | yes (Debian ecosystem) |
| [myrepos (mr)](https://myrepos.branchable.com/) | no | n/a | yes | via arbitrary commands | n/a | yes |
| [gita](https://github.com/nosarthur/gita) | no | n/a | yes | via arbitrary commands | n/a | yes |
| [vcstool](https://github.com/dirk-thomas/vcstool) | no | n/a | yes (manifest) | checkout only | n/a | yes |
| [west](https://docs.zephyrproject.org/latest/develop/west/index.html) | no | n/a | yes (manifest) | checkout only | n/a | yes |
| `gh repo sync` / GitHub fork sync | no | n/a | no | yes | n/a | yes |
| **forkctl** (planned) | yes (DAG, TopGit-style) | yes | yes (per-repo discovery) | yes | stop-at-conflict | — |
