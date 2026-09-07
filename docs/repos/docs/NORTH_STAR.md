# Documentation North Star

Status: **PRODUCT DIRECTION.**

Canonical repository: `organicoverlords/agents`.
Canonical directory: `docs/repos/docs/`.
Legacy compatibility repository: `organicoverlords/docs`.

## What this documentation set is for

Provide one authoritative home for human-facing project direction, guides, history, and cross-repository standards. Product repositories keep implementation/runtime truth, machine-consumed contracts, and artifact-bound evidence; they do not maintain a second copy of human prose.

## What finished looks like

- Current human documentation is discoverable in `organicoverlords/agents` without reconciling mirrors.
- Historical repository documentation paths resolve to short compatibility pointers when links must remain stable.
- Machine-consumed Markdown stays in the owning repository only when a live workflow, package, runtime, or artifact contract requires it.
- GitHub issues, PRs, checks, git state, and runtime evidence remain the authority for current work and execution state.

## Out of scope

- Product source code and assets.
- Runtime, scheduler, worker, or machine state.
- Copies of shared agent policy text inside product documentation.
- Moving executable or machine-owned contracts merely because they use a `.md` extension.

## Current focus

1. Keep active product documentation under `docs/repos/<repo>/` in Agents.
2. Convert superseded human-document paths in live repositories to compatibility pointers instead of prose mirrors.
3. Preserve repo-local exceptions only when live automation or artifact contracts prove they are machine-owned.
