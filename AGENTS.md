# Shared agent work contract

Every agent uses this same repo-work contract. Local repo `AGENTS.md`/`CLAUDE.md` files only point here and to `RULES.md`.

## Entering a repo
- Read `RULES.md`, then inspect the target repo's live state and the smallest repo-owned documents needed to understand the task: normally its North Star/product direction, README/start-here material, relevant scripts/help, and relevant open work.
- Repo-specific product direction, commands, build/proof routes, hazards, and completion criteria live in that repo's own files/code/tests. Do not create a second policy document for them here.
- Before structural or architectural work, use relevant branch/commit history to recover intent and previous convergence. Do not reconstruct architecture from the current file tree alone.

## Doing the work
- Choose the highest-value load-bearing action that advances the current user objective. Existing unfinished relevant WIP should be repaired, proved, integrated, closed, or superseded before avoidable parallel WIP is created.
- Reuse the repo's existing supported entrypoints and wrappers. If a supported path is broken, fix that owner rather than bypassing it with a parallel path.
- Make coherent changes, validate with the cheapest evidence sufficient for the claim, and continue through nonblocking waits instead of polling or stopping early.
- Keep work scoped to actual ownership/collision boundaries. Preserve foreign dirty work and useful warm state.

## Convergence and proof
- Verified useful work should converge promptly through the repo's normal branch/PR/integration path. Do not leave finished branches or duplicated implementation paths as shadow backlogs.
- A build/commit/PR is supporting evidence, not the product result. Player/user-visible claims require the repo's existing supported proof/delivery route when such proof is actually needed.
- If a trap in an owned path is discovered, follow the durable-closure rule in `RULES.md`; do not leave a one-off workaround for the next agent.
