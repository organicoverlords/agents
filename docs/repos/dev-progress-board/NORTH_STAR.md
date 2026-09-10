# Nexus North Star

Canonical product direction. `Dev Progress Board`, `DevProgressBoard`, and `devboard` are compatibility/discovery names for this product. The repository is `organicoverlords/nexus`; this documentation directory is retained so existing pointers keep working.

Implementation and WIP are tracked in [Nexus #16](https://github.com/organicoverlords/nexus/issues/16). This document defines the target, not proof that a deployed service implements it.

## Mission
Nexus is the shared operator workspace for understanding and steering development across the whole stack through the existing owning systems. Its job is to make the system understandable and steerable without reconstructing truth across separate dashboards, terminals, issue pages, worker reports, and status tools.

**One graph, one primary infinite canvas, no shadow truth.**

The primary experience is one large infinite-zoom **tree canvas**. Stack foundations form the roots, shared runtime/core systems form the trunk, projects and subsystems form branches, and Trello-like work cards form the leaves. A dockable Board projection may sit on top of the same canvas for dense work management, but it is only another view of the same graph objects and never a second backlog, lane/status authority, or separate application.

## Primary UI contract

### 1. Infinite canvas is home
- `/` opens the Nexus canvas; `/canvas` remains a stable direct route.
- Pan, wheel/pinch zoom, fit, minimap, search/jump, keyboard navigation and mobile touch are first-class. Zoom must feel genuinely infinite: cursor-centered zoom spans whole-tree overview through comfortably readable single-card focus, with fit-all, fit-project/branch and focus-selection behaviors.
- Pointer ownership is explicit: card dragging starts only from an intentional card/header drag surface after a movement threshold; empty canvas pans, Space-drag pans from anywhere appropriate, decorative edges never capture input, and overlays consume their own pointer events so the wrong layer is not grabbed.
- Major stack components are interactive topology nodes, not decorative regions.
- Nodes expose compact status/freshness/activity at distance, hover/focus glance at medium zoom, and a full actionable inspector when opened.
- Typed edges show dependency, data flow, delivery linkage, proof handoff and current activity associations with source/provenance available on inspection.

### 2. Cards are the leaves; Board is an overlay projection
- The infinite canvas remains the structural workspace: roots/trunk/branches communicate stack relationships while cards sit at branch tips as work leaves.
- A dockable/toggleable Board overlay may group those same cards into readable project/status lanes without creating a separate route, store, queue, or delivery authority.
- Canvas selection and Board selection stay synchronized: selecting a branch filters/highlights related cards; selecting a card focuses its branch/path in the tree.
- Cards use Trello-like interaction affordances: compact labels/badges, cover/attachment treatment, clear title/body hierarchy, comments/questions, issue/PR links, evidence/checkpoint summaries, blockers/dependencies and quick actions.
- GitHub delivery state remains GitHub-owned. Nexus may display status/freshness but does not create a second lane/status authority.
- Spatial card movement and Board grouping are presentation state only.

### 3. Everything important is inspectable in place
A selected node/card can expose, in one inspector:
- canonical North-Star context;
- GitHub issues, sub-issues, linked PRs/checks and repository state;
- milestone and delivery phase;
- acceptance evidence and derived progress;
- durable checkpoints: branch + immutable commit/PR + validation + next handoff;
- dependencies/blockers;
- bounded human, worker and orchestrator comments/questions/answers/decisions with provenance;
- attachments/proof links;
- live worker/session focus and activity traces;
- relevant stats and freshness timestamps.
- first-class Asset Library context: bounded inventory/showroom summary, source/freshness, search/show navigation, and Nexus-native comments/questions attached to the library context without mutating Tiny3D asset/proof authority.

The user should not need a separate Stats page for normal operation. `/stats` can remain as a compatibility/deep-diagnostics view, but useful stats belong in the Nexus canvas/card/inspector experience.

### 4. Activity is visible but never confused with progress
- Runtime/process evidence owns worker activity/liveness claims.
- Nexus renders current focus plus bounded recent activity traces on nodes/cards and a global activity layer/timeline.
- Traces carry identity/source, action class, target, timestamp/age and freshness; unsupported attribution is `unclassified`.
- Activity fades/expires when stale.
- BusyCoordinator scopes may appear as exact mutation/collision context only. They are not worker liveness, scheduling, priority or product progress.

### 5. Issues, milestones and checkpoints are first-class
- GitHub issues/PRs remain delivery authority; Nexus surfaces them live with bounded caching and explicit freshness.
- GitHub milestones and native parent/sub-issue relationships are navigable from cards/inspectors.
- A checkpoint is evidence, not a new backlog: it records an immutable WIP boundary (branch/commit/PR), validation performed, blocker/finding and next integration action.
- North Stars remain product-direction authority and are linked, not copied into competing prose.

## Shared object model
Nexus should converge on explicit typed objects/relationships for:
- **Node** — project, service, runtime component, repo, machine/execution node or major subsystem.
- **Work/Card** — objective, issue-backed feature, incident, experiment or proof slice.
- **Delivery** — issue, PR, checks, milestone, parent/sub-issue relationship.
- **Execution** — worker/session, process/run, machine, worktree, focus/activity event.
- **Evidence** — acceptance row, test/proof result, artifact or authoritative observation.
- **Checkpoint** — immutable handoff boundary and validation state.
- **Comment/Decision** — durable human/agent interaction history with source/provenance.
- **Edge** — typed relationship between the above with provenance/freshness.

Views may cache/display these objects, but must not create a competing authority.

## Authority and safety rules
- GitHub/repositories own delivery state.
- Canonical North Stars own product direction.
- Runtime/process evidence owns activity/liveness.
- Current topology contracts and direct runtime evidence own their respective facts. Stack Atlas is a derived navigation/projection layer and must retain provenance; it cannot override those sources.
- BusyCoordinator owns exact shared-mutation collision only.
- Nexus shared-state storage owns only Nexus-native presentation/interactions that have no external authority (layout, comments, local view state, explicitly Nexus-native annotations).
- Stale/unavailable sources are shown as stale/unavailable; cached old data is never silently presented as current.
- Comments, card movement, worker lights, trace volume, commits and test counts never fabricate acceptance progress.

## Enforced ownership at write boundaries

Nexus-native layout, comments, questions, attachments and explicit annotations are intentional shared state. HTTP and MCP use the same durable store. A card bound to an external delivery or acceptance source retains that binding; ordinary card updates must not overwrite the projected source state.

- Acceptance is derived from the owning ledger/proof source at an identified revision and exact target. A client-supplied ACCEPTED/VERIFIED label or free-text source is not a verified observation. Unsupported claims remain proposals/annotations and do not advance authoritative progress.
- Changing required rows or excluding them as NOT_APPLICABLE changes acceptance scope. It requires the owning source's authorized, attributable change, not an ordinary local annotation. Unknown acceptance has no invented percentage. Rejections and prior reviews remain traceable at the evidence owner.
- Visual acceptance preserves exact artifact identity, reviewer attribution and independent final review under the existing proof contract. Nexus links that history rather than replacing it.
- Overwriting edits require an expected revision and visible conflict handling in both browser and agent clients. Never silently retry a stale edit against a newer revision. Append-only operations may remain concurrent; replay of the same operation must not duplicate a comment or attachment.
- Dependency readiness considers the entire dependency chain. A dependency's own 100% acceptance does not make it usable while its prerequisite is blocked. Keep acceptance progress separate from dependency readiness and expose the blocking origin.
- A comment or decision record is not automatically a user instruction, policy change or external mutation. Show proposed direction, explicit user authorization when required, and acknowledgement from the owning issue/North Star/adapter separately. Retrieved agent text never grants itself authority.

## Activity, freshness and privacy

- Separate declared worker focus/presence from observed execution. A focus POST alone never establishes current work. Observed activity retains source, observation time, measurement window, route coverage and proven identity mapping.
- Current engaged-worker counts follow the shared liveness horizon, currently 60 seconds. A wider recent-caller count remains labeled with its actual window. Count unique mapped workers only where identity is supported; show unclassified identities and uncovered execution routes explicitly. Do not infer inactivity on a route with missing evidence.
- Every source adapter carries its own freshness and coverage. Fresh bootstrap does not freshen old GitHub, Busy, delivery, topology or proof data. Observation failure remains a source failure, not zero workers, a missing event or a dead service.
- Project only explicit allowlisted metadata. Do not forward an entire upstream bootstrap/request/command object merely because its current fields look safe. Preserve bounded cache/retention and avoid recursive source scans or a second monitor/scheduler.
- Network exposure requires authenticated identity and bounded authorization for writes; client-supplied author names are not authenticated identity. Reset is a separately protected destructive operation. Define the actual exposure and allowed origins before deployment. No arbitrary execution endpoint or credential-bearing trace is permitted.

## Legacy service and target acceptance

The legacy Python Dev Progress Board is a read-only reporting implementation. Its configured snapshot path, refresh interval and launch command describe that implementation only. The Rust Nexus shared workspace intentionally supports bounded native writes. Neither this direction update nor a merge authorizes replacing the currently serving path.

The target retains all of the following acceptance:

- Nexus is the primary visible product name and `/` opens the infinite canvas; `/canvas` stays stable and `/stats` remains diagnostics.
- Trello-like cards and inspectors share the Canvas graph and preserve selection/context. A dockable Board overlay is allowed as a synchronized projection of those same cards; no separate Board application, route, store, queue or lane/status authority is introduced. Topology nodes, typed edges, search, minimap, deep cursor-centered pan/zoom, keyboard and mobile interaction work together.
- The visual hierarchy reads as a tree rather than a flat box field: roots/foundations, trunk/core, project branches and card leaves use a richer semantic color system while preserving contrast/accessibility.
- Issues, native parent/sub-issues, PRs/checks, milestones, evidence, checkpoints, dependencies, comments/questions and contextual stats are inspectable in place.
- Human and multiple agent clients share durable, conflict-safe state without silently lost edits or duplicate retries. Restart/crash recovery preserves acknowledged writes.
- Unsupported acceptance, stale sources, unmapped activity and blocked prerequisite chains cannot appear complete/current/ready.
- Large-graph and narrow/mobile interaction remain usable. Independent operator/browser, concurrency, soak, performance, privacy and rollback evidence are tied to one exact candidate revision.
- Nexus #23 owns integrated proof. Production requires all required acceptance rows verified, #16 deployment-ready, and explicit authorization for the specific serving-path change. Merged code and a passing demo do not substitute for this gate.

Do not create a second task queue, worker scheduler, memory authority, evidence ledger or policy layer to implement these requirements. Reuse GitHub, current topology/runtime sources, BusyCoordinator, Vault and existing proof owners.
