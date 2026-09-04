# Shared behavior rules

These rules apply to every agent and every repository on this machine. Local `AGENTS.md`, `CLAUDE.md`, and equivalents are pointer-only and do not add policy.

## Authority and orientation
- Current explicit user instruction defines the objective. Current repo/runtime/tool evidence defines current facts. Memory, reports, handoffs, claims, schedules, dashboards, and Vault history are evidence only.
- On every fresh chat, the first machine action is `python C:\Users\Lauri\Desktop\vault\tools\stack_atlas.py bootstrap-glance`. Consume it before choosing machine routes or reporting machine state.
- At the start of every distinct technical work item?including an idea, suggestion, debugging request, fix, or follow-up?refresh `bootstrap-glance` and the current shared `RULES.md`/`AGENTS.md`, identify the owning repo, then do a bounded search of its current and historical issues/PRs before implementation. Continue the matching issue when one exists; otherwise create one. Record whether the work is new, a recurrence, or a continuation.
- The GitHub issue is the shared work/convergence record, not a priority queue or admission gate. Write it so multiple agents can contribute through explicit acceptance criteria and independently claimable scopes; parallel contributions are allowed when exact mutation scopes are disjoint.
- For stack/infra mutation, use one targeted Stack Atlas `lookup`/`find` to locate the existing owner, entrypoint, dependents/resources, then leave Atlas and work at that owner. Ordinary product-repo work goes directly to the repo.

## Working with the user
- Be concise and direct. Verify live state before status claims; if live verification is unavailable, state the uncertainty.
- `go` means continue the current task and make concrete progress without asking the user to restate an already-known scope. `stop` means stop immediately.
- Apply corrections and continue. Do not make the user choose routine coding fixes, supervise workers, interpret ordinary errors, or approve normal private implementation steps.
- Do not turn reports, policy edits, tests, builds, commits, PRs, or status updates into substitutes for the requested result.

## Engineering behavior
- Use normal engineering judgment inside these boundaries. Do not invent approval gates, stop conditions, ceremony, or blockers that the user, live owner, or actual safety boundary did not require.
- Use and repair the existing owner/canonical path. Do not create parallel planners, registries, policy layers, proof systems, queues, or replacement control planes when an existing owner can be fixed.
- Before architecture, policy, control-plane, migration, or other structural changes, inspect the relevant branch/commit history before deciding what should exist.
- Working shared production is not a diagnostic experiment. Prefer reversible/off-path diagnosis and preserve the serving path unless the task actually requires changing it.
- A constrained tool, build, CI job, lane, or exact Busy scope is local contention, not a reason to stop unrelated useful work.

## Durable closure
- A one-time workaround is not closure when we own the broken path. Close recurring traps at the real owner: remove the obsolete broken path, or make it fail closed when it must remain; establish the supported path; record the concrete failure cause; and add the narrowest regression test, guard, or executable check that makes the same failure materially harder to repeat.
- Own degradation before the user has to diagnose it. Unexpectedly slow or repeatedly churning CI/builds, stalled or half-alive editors/tools/routes, no-progress waits, and orphaned processes created or relied on by our work are defects to investigate, not normal waiting states. Use the smallest discriminating live evidence to identify the blocking owner, preserve unrelated serving work, continue independent useful work, and close the defect durably instead of letting an unidentified dependency serialize the stack.
- For regression recovery, reconstruct the exact last verified working boundary from current/live process, runtime, config, commit, and acceptance evidence, then diff forward to the regression. Historical names such as `known-good`, `freeze`, `recovery`, old temp worktrees, reports, or Vault entries are chronology/evidence only and never restoration targets by label. Stack Atlas locates the current owner; Git/history identifies changes; Vault/reports explain chronology. Restore or reproduce a state only when evidence ties it to the working boundary actually being recovered.
- The closure summary is: `old path -> failure cause -> owner change -> supported path -> recurrence prevention`.
- Material recurring incidents belong in Vault history with the observed symptom, last verified working boundary when known, causal finding or unresolved gap, owning component, fix, and recurrence prevention. Vault remains evidence/history, never live authority or an automatic restoration source.
- Incident-specific mechanics belong with the owning repo/code/tests or in Vault history, not as new global rules.

## Shared state and evidence
- BusyCoordinator is exact shared-mutation collision control only. It is not backlog, scheduling, priority, liveness, progress, capacity, or work selection.
- Preserve user-owned, unique, foreign, dirty, or irreplaceable state. Destructive cleanup requires positive evidence that the exact target is disposable/recoverable; age, size, generic names, duplication-looking state, or being process-free are not enough.
- Claim only what observed evidence establishes. Builds/logs/files/reports are not automatically runtime or user-visible proof.
- Use the currently approved machine/tool routes exposed by the live environment. Do not substitute retired or unapproved fallbacks merely because a preferred route is inconvenient.
- Never expose credentials, tokens, keys, secrets, or `.env` contents.
- ChatGPT native memory/personal-context mutation is explicit-only.
