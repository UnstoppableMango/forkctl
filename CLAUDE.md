# forkctl

Tooling to maintain a fleet of forked git repos: track relationship to
upstream, sync new upstream commits, and replay a maintained patch set
(TopGit-style branch-pair DAG) on top. **Status: early scaffold** — no
patch-stack/sync/fleet logic implemented yet, just a stub CLI that prints a
version.

## Commands

```bash
nix build .#        # build
nix flake update    # update flake inputs
nix flake check     # lint (treefmt: actionlint, mdformat, nixfmt, ocamlformat)
nix fmt             # format
dune test           # run tests (Alcotest + qcheck), also runs via `nix build` doCheck
```

Dev shell auto-loads via direnv (`.envrc` → `use flake`), providing
`dune_3`, `ocaml-lsp`, `ocamlformat`, `odoc`, `gnumake`, `nixfmt`. No manual
opam setup needed if direnv is allowed for the directory.

## Architecture

- `bin/` — `forkctl` executable, currently just prints `Forkctl.version`
- `lib/` — `forkctl` library, currently just `let version = "0.0.1"`
- `test/` — Alcotest + qcheck tests (`test_forkctl.ml`); wired into `nix/default.nix`
  `checkInputs`/`doCheck`, so `nix build` fails on test failure
- `nix/default.nix` — `buildDunePackage` derivation used by `flake.nix`
- Dune project (`dune-project`), package name `forkctl`

## Code style

- `.ocamlformat`: `profile = conventional`
- `.editorconfig`: tabs by default; 2-space indent for `.nix`, `.ml`/`.mli`

## Key docs

- [GOALS.md](GOALS.md) — authoritative feature scope: patch-stack via
  branch-pair DAG merge, stop-at-conflict (no best-effort across the rest of
  the stack), no central fleet manifest (forks discovered by scanning a
  directory), fork-maintenance only (no pushing patches upstream as PRs).
- [docs/USE_CASES.md](docs/USE_CASES.md) — concrete scenarios extracted from
  GOALS.md, meant to drive test suites.
- [README.md](README.md) — tool-comparison table surveying existing
  patch-stack tools (quilt, StGit, TopGit, etc.).

## Gotchas

- Goal #8 in GOALS.md: prefer wrapping an existing patch-stack tool (see
  README comparison table) over hand-rolling patch-stack logic from scratch.
- `nix build` runs `dune runtest` (`doCheck = true`), so build fails on
  broken test, not just compile error.
