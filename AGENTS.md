# Shared agent work contract

Every agent uses this same repo-work contract. Local repo `AGENTS.md`/`CLAUDE.md` files only point here and to `RULES.md`.

## Entering a repo
- For each distinct technical work item, use the issue-first intake rule in `RULES.md` before implementation. Refresh the current bootstrap/shared contract even in a long-lived chat; a read from an earlier task is not task-boundary orientation.
- Inspect the target repo's branch/HEAD, dirty state, matching open/closed issue/PR history, and current exact Busy claims before mutation. If relevant dirty work already exists, attribute and preserve it rather than piling unowned edits onto it.
- Read the smallest repo-owned documents needed to understand the task: normally its North Star/product direction, README/start-here material, relevant scripts/help, and relevant open work. When product work selection depends on those direction documents and the current execution worktree may be behind, bounded-refresh the current product head and read the direction document from that head rather than treating the branch-local snapshot as current authority; do not overwrite dirty or foreign work merely to refresh documentation. Repo-specific product direction, commands, build/proof routes, hazards, and completion criteria live in that repo's own files/code/tests.
- Before structural or architectural work, use relevant branch/commit history to recover intent and previous convergence. Do not reconstruct architecture from the current file tree alone.

## Doing the work
- Use the issue as the shared coordination record and work identity. Keep acceptance and contribution scopes there, and reference the issue from meaningful branches/PRs/commits/checkpoints so another agent can identify the work without reconstructing a dirty checkout.
- A lane, branch, worktree, checkout, editor, build slot, route, or Busy claim is an execution surface/resource, not worker identity and not the task. Many agents may contribute to the same issue concurrently.
- Before each shared mutation, claim only the exact files/resources being changed through BusyCoordinator; do not turn the issue, lane, checkout, or Busy into a repo-wide lock.
- If the current execution surface is dirty, stale, unsafe, unusable, or contains foreign/unique work, preserve it and leave the conflicting state intact. Continue the same issue through another already-existing safe supported surface when available, or continue non-conflicting source/test/build/proof/review/integration work. Do not stop merely because the current surface cannot safely mutate.
- Do not create a fresh lane/worktree reflexively to escape an inconvenient current surface. Reuse safe existing supported surfaces and preserve useful warm state.
- Choose the highest-value load-bearing action that advances the current user objective. Existing unfinished relevant WIP should be repaired, proved, integrated, closed, or superseded before avoidable parallel WIP is created.
- Reuse the repo's existing supported entrypoints and wrappers. If a supported path is broken, fix that owner rather than bypassing it with a parallel path.
- Make coherent changes, validate with the cheapest evidence sufficient for the claim, and continue through nonblocking waits instead of polling or stopping early.
- Keep work scoped to actual ownership/collision boundaries. Dirty or foreign state blocks only the exact conflicting mutation, not the whole issue.
- Stop only when a concrete task-level blocker remains after safe existing execution surfaces and independent useful work are exhausted. Record the exact blocking scope/resource and evidence on the issue.
- Before yielding or ending a run, leave the issue traceable: commit/branch/PR the coherent work, or record the exact remaining dirty paths, current evidence, and blocker/checkpoint on the issue. Never leave unattributed dirty work as the only handoff, and never treat report archival/checkpointing as completion while the issue remains actionable.

## Convergence and proof
- Verified useful work should converge promptly through the repo's normal branch/PR/integration path. Do not leave finished branches or duplicated implementation paths as shadow backlogs.
- A build/commit/PR is supporting evidence, not the product result. Player/user-visible claims require the repo's existing supported proof/delivery route when such proof is actually needed.
- If a trap in an owned path is discovered, follow the durable-closure rule in `RULES.md`; do not leave a one-off workaround for the next agent.
