# Stack Atlas North Star

Status: **COMPONENT PRODUCT DIRECTION; REFINES THE ASSISTANT STACK NORTH STAR**
Owning product/repository: `organicoverlords/regression-research`
Canonical human-facing authority: `organicoverlords/agents@main` at `docs/repos/regression-research/`.

## Product identity

Stack Atlas is the **derived operational map of the assistant stack**. Its job is to let a worker cheaply discover what already exists, which component owns a capability, where current status must be read, what can recover independently, and what a proposed change could disrupt.

Atlas never owns the facts it points at. Current explicit user direction, canonical shared/project rules, live repo/runtime/scheduler state, exact issues/PRs and the owning component's source remain authoritative. Atlas is navigation and safety context only.

## Finished-product outcome

A finished Atlas lets a fresh worker answer, with bounded reads and without broad machine archaeology:

- **What is this thing?** component identity, role/capabilities and product boundary;
- **Who/what owns the truth?** canonical source and live-status entrypoint, with authority semantics explicit;
- **What depends on it?** meaningful upstream/downstream dependencies and shared resources;
- **Can I change it safely?** blast radius, exact mutation surface, production-change gate where applicable and independent rollback/recovery route;
- **Is the evidence current?** source freshness, generated-view freshness and explicit unknown/degraded states instead of silently stale prose;
- **How do I recover?** the smallest supported recovery entrypoint that does not depend only on the broken path itself;
- **Where do I continue work?** route the worker to the owning North Star/issue/PR/live evidence rather than storing assignments or progress inside Atlas.

The compact bootstrap view must remain small enough to use routinely. Deep detail is demand-driven through lookup/find/blast-radius rather than pushed into every worker prompt.

## Governing invariants

1. **Derived, never authority.** Atlas may summarize and link; it may not decide product direction, ownership, scheduler membership, issue priority or completion.
2. **No duplicate control plane.** No task queue, worker registry, assignment store, second Busy, orchestration daemon or manually maintained current-WIP database belongs here.
3. **Live facts stay live.** Status that can change is fetched from the named owner or marked stale/unknown. Generated snapshots expose freshness and never masquerade as current truth.
4. **Bounded orientation first.** Bootstrap is compact; deep lookup is component/query scoped; recursive filesystem/GitHub archaeology is not the default orientation path.
5. **Recovery is independently reasoned.** For disruptive stack components, Atlas names an independent recovery/rollback route and enough dependency/blast-radius context to avoid repairing the wrong layer.
6. **Safety gates are evidence, not permission.** A production-change gate can prove prerequisites; user authorization and owning-product rules still govern the actual mutation.
7. **Unknown is useful.** Missing supervisor, recovery, dependency or live-status evidence is surfaced explicitly and can block a disruptive mutation without blocking unrelated safe work.
8. **Tests protect the map.** Important component/feature entries, freshness semantics, bootstrap budget and safety boundaries have regression coverage so Atlas does not drift into persuasive stale fiction.

## Durable milestones

1. **Complete useful component map.** Every load-bearing stack component has identity, authority/source, capability, live status, dependencies, resources, supervisor/self-heal semantics and recovery where applicable.
2. **Reliable feature discovery.** Natural-language `find` routes common needs to existing owners before workers propose duplicate infrastructure.
3. **Fresh operational truth routing.** Bootstrap/lookup expose freshness and route volatile facts to live owners; stale source hashes and incomplete observations cannot silently become decisions.
4. **Change/recovery safety.** Blast-radius and production-change preflight cover the components where a wrong mutation can disrupt shared production, with off-path proof and rollback expectations explicit.
5. **Swarm navigation without supervision.** Atlas helps workers discover current direction/work/recovery surfaces quickly enough to self-direct while AFK, but issues/North Stars/live evidence remain the places work is reconciled and advanced.
6. **Finished Atlas.** Ordinary stack work starts with a cheap trustworthy map, deepens only where necessary, and rarely requires the user or a worker to rediscover topology, ownership or recovery from scratch.

## Current priority

Keep Atlas aligned with the actual simplified stack: current North-Star authorities, GitHub issue/project convergence, exact Busy collision control, 10-worker topology/recovery invariants, MCP production/recovery paths, current-WIP evidence semantics and Vault history boundaries. Prefer correcting missing/stale owner mappings and executable safety checks over adding dashboards or speculative orchestration features.

## Roadmap continuity and issue-wall recovery

Workers own Atlas maintenance. When a real stack change exposes an Atlas gap, update the smallest owning component/feature mapping and its focused tests; if the gap requires tracked work, create or reconcile the smallest existing issue. Do not ask the user to maintain Atlas entries or seed maintenance tickets. Do not create work solely to increase map completeness when the missing entry has no current operational value.
