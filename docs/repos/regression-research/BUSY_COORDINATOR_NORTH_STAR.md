# BusyCoordinator North Star

Status: **COMPONENT PRODUCT DIRECTION; REFINES THE ASSISTANT STACK NORTH STAR**
Owning stack: Assistant Stack / `organicoverlords/regression-research`
Canonical human-facing authority: `organicoverlords/agents@main` at `docs/repos/regression-research/`.
Runtime authority: the installed standalone BusyCoordinator contract and canonical claims store on the execution host.

## Product identity

BusyCoordinator is the **single live authority for exact shared-mutation collision ownership**. It answers one narrow question: who currently owns this exact mutable scope?

It is not a backlog, scheduler, queue, priority system, capacity model, worker registry, liveness monitor, progress tracker, issue authority, orchestration brain, or project planner. GitHub/issues/repos own delivery work; MCP/process/connector surfaces provide transport and evidence; BusyCoordinator only prevents conflicting mutation.

## Finished-product outcome

A finished coordinator is boring and cheap enough that every worker can use it correctly without turning coordination into work of its own:

- exact scopes normalize to one canonical identity across branches, worktrees and machines;
- `inspect`, `claim`, `heartbeat`, `release`, `recover`, `snapshot` and bounded cleanup have deterministic semantics and one canonical claims store;
- read-only work requires no claim, and a collision on one scope never blocks unrelated safe work;
- claim recovery is evidence-backed and compare-and-swap safe: age alone never proves staleness, and a newer owner/heartbeat/timestamp cancels recovery;
- checkpoint metadata helps humans and workers understand the mutation but never becomes queue, priority, workload or completion state;
- legacy projections can be observed/migrated without becoming a second ownership authority;
- crashes, temp-file residue, replacement and concurrent writers fail closed without corrupting the canonical store;
- observability remains bounded and non-authoritative: audit/log output explains coordinator behavior but never becomes project truth;
- the user never has to clear claims, choose owners, reconcile stale projections or understand coordinator internals during ordinary work.

## Hard boundaries

1. **One authority, one store.** There must never be competing BUSY authorities or independent per-worker ownership stores.
2. **Exact collision control only.** Queue selection, priority, blocked/completed state, handoff scheduling, workload pressure, worker health and capacity are outside coordinator authority.
3. **No ownership inference from transport.** MCP caller/process evidence can support a bounded stale-claim recovery decision, but MCP never owns the claim lifecycle.
4. **No ownership inference from GitHub.** Issues, PRs, branches, commits and checks are work/evidence surfaces, not live mutation locks.
5. **Fail closed on ambiguity.** Unknown or malformed ownership, alias ambiguity, failed canonicalization or unavailable coordinator state must not be converted into permission to mutate contested scope.
6. **Independent work continues.** A collision or coordinator outage affects only the contested mutation; safe reads and unrelated work continue.

## Operational collision and handoff protocol

The runtime contract at `%LOCALAPPDATA%\BusyCoordinator\coordinator-contract.json` owns commands/store semantics. The shared work protocol around those exact claims is:

- **Canonical scopes.** Equivalent file/resource scopes must normalize to one identity. Filesystem scopes are absolute or namespaced logical identifiers; Git ref mutation claims the exact ref, for example `<repo>:git-ref:refs/heads/<branch>`, never repo-wide `git-ref-metadata`. Do not mint an alias to evade an equivalent claim.
- **Evidence-backed recovery.** At a designated coordination checkpoint, and before treating an exact collision as active, caller/process evidence may support recovery only when the claim is positively attributable, the caller has no live child process, and no MCP process start/read/kill/output activity has occurred for at least 60 seconds. Recover only the still-identical actor/scope/claim timestamp through CAS. Any newer activity, heartbeat, renewal, replacement, or timestamp mismatch cancels recovery; ambiguous/unmapped claims keep ordinary lease/manual-recovery semantics.
- **Collision reconciliation.** First determine whether claimant WIP already subsumes the intended mutation; if so, consume/review/prove/integrate it rather than duplicating it. When distinct conflicting work genuinely must reach the claimant before its next mutation, leave one structured `incoming change` comment on the existing issue with the exact conflicting scopes, claimant actor, intended change, and whether any mutation occurred. This is coordination context, not queue/assignment/approval state.
- **Claim lifetime.** Hold a claim only while that exact mutation needs exclusivity and release it promptly once protection is no longer required, including after commit/PR convergence; CI/review/unrelated bookkeeping does not justify retaining it.
- **Incoming-change lifetime.** An `incoming change` is unresolved work, not ownership. If the exact lease is absent/expired, a worker may claim the scope and resolve the note without waiting for the former claimant. On issue entry, resolve or explicitly supersede outstanding notes before avoidable new conflicting WIP; before issue closure, record each note's resulting commit/PR/runtime evidence or explicit supersession.

A Busy collision constrains only the exact mutation. Broader task continuation/yield behavior is outside BusyCoordinator and is intentionally not restated here.

## Rust-first implementation direction

The coordinator hot/runtime path should be native Rust.

- Rust is the preferred production core for ownership commands and the target default implementation.
- New coordinator semantics must be designed and proven Rust-first; do not add a Python-first core feature and plan to port it later.
- Python may remain temporarily as compatibility/reference/parity infrastructure while exact behavior is proven and rollout risk is retired. It is not the long-term runtime architecture.
- Rust/Python parity tests must prevent semantic drift until the compatibility path is removed.
- Non-core audit/report helpers should move off Python when doing so removes meaningful startup/runtime/deployment cost; do not rewrite stable low-frequency tooling merely for language purity without a measured benefit.
- The canonical contract, store schema and observable command behavior matter more than implementation language during migration; a Rust rollout must not fork authority or state.

## Durable milestones

1. **Canonical scope identity.** Equivalent logical/file/resource scopes converge deterministically; path aliases cannot evade a live claim.
2. **Rust production default.** The shared worker path uses the Rust core for ownership operations with parity and rollback proof; Python is compatibility-only or removed.
3. **Crash-safe single-store semantics.** Atomic writes, temp cleanup, bounded operation replay and concurrent contention remain correct under real Windows failure modes.
4. **Evidence-backed recovery.** Stale recovery consumes only positive owner/caller/process evidence and uses CAS against the still-identical claim.
5. **Cross-machine continuity.** Remote workers use the same ownership authority rather than creating an independent coordinator/store on another node.
6. **Finished coordinator.** Exact mutation ownership becomes an invisible constant-time primitive; workers stop inventing lanes, queue semantics, ownership projections or cleanup rituals around it.

## Current priority

Prefer the Rust path everywhere the ownership core already has parity, then close the remaining migration gaps without expanding coordinator scope. Keep the current contract invariants mechanically tested, eliminate accidental Python-default call sites when safe, harden exact-scope normalization/recovery, and preserve the strict boundary that workload/orchestration state lives elsewhere.