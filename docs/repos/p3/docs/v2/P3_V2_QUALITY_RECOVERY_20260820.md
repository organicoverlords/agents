# P3 V2 quality recovery — 2026-08-20

Status: active audit and reorientation companion to `P3_V2_NORTH_STAR.md`.

This is not a redesign. It exists to reconcile the V2 implementation with the original August 15–16 gameplay design records, current code, current tests, current Unreal Engine 5.8 behavior, and actual end-user value.

The V2 chassis remains the default direction unless a concrete code/runtime defect proves otherwise. Existing functioning systems are preserved and polished before replacement is considered.

## Product objective

P3 optimizes for end-user functionality, automation and observability. Architecture and tests serve that objective; they are not substitutes for it.

Prototype design records remain authoritative evidence for intended player behavior where V2 did not explicitly change the product decision. V2 may replace ownership or implementation while preserving the useful loop.

A feature is valuable when it produces a coherent player-visible capability, removes a real production limitation, or provides reusable automation/observability that materially accelerates those outcomes.

## Review standard

Every implemented slice is judged on actual behavior, usefulness, uniqueness, architecture fit, maintenance cost, integration depth, failure behavior and proof quality.

Unconventional code is not a defect by itself. Refactor only when there is a concrete correctness, integration, maintenance, performance or future-product cost.

Do not pad a feature merely to satisfy architecture prose. Do not create parallel frameworks when a functioning path can be extended cleanly.

## Proof vocabulary

Proof descriptions must name what was actually exercised. A compile proves compilation. A pure Automation Test proves the tested contract. A transient-world test proves that in-engine composition. A playable-map test proves that user-facing path. A multi-client test proves the observed network behavior. Visual/animation acceptance requires actual rendered or traced behavior.

These are descriptions, not blocking process tiers. Missing higher-order proof means the corresponding claim remains unproven; it does not stop unrelated implementation.

## Current feature orientation

V2 runtime foundation, semantic input, PlayerState-owned ASC/inventory, Experience/PawnData composition and the reusable verification spine are retained. They have real architectural value and are consistent with UE5.8 patterns.

V2-02 inventory/resource/persistence/UI is retained and should be finished as an actual coherent player loop rather than expanded into infrastructure.

V2 avatar/animation is retained; priority is real movement/animation quality and asset correctness, not additional profile abstraction.

Construction/RTS/Tower Defense is retained. Existing V1 gameplay knowledge—snap/support, material cost, RTS feel, wave behavior and runtime pathing—remains the behavior target. Runtime navigation must be proven in the actual target map configuration before claiming rerouting.

Combat/traversal is retained. Prefer polishing the existing melee/projectile/dash/GAS paths into satisfying user-facing actions over adding more ability substrate.

AI StateTree/SmartObject substrate is retained but should not expand until consumed by actual AI gameplay. Smart Objects are optional where reservation semantics provide value, not a technology requirement.

Survival is retained. Its next value comes from playable finite-resource pressure, environment response, defeat/respawn and shelter integration, not more framework code.

Earthworks is retained. The logical command/domain, shared personal/RTS path and DynamicMesh direction are sound. Renderer-facing tessellation data should remain feature-internal where practical; collision and chunk performance need actual runtime proof. Preserve the original dig/fill/grade/trench/berm/undo/material-conservation feel.

Flight is retained. Shared data-driven movement is the right direction; current reflection/stateless tests are contract tests, not replicated-flight or procedural-animation acceptance. Next work should wire a real species, camera/input and actual animation path before adding more flight abstraction.

Production world work is retained. Prefer making the existing V2 world increasingly playable and visually coherent over multiplying world-framework layers.

## Worker behavior

Workers continue from current `AGENTS.md`, current code/runtime truth and the current task. They do not wait for this audit to finish unless they would collide with an actively modified scope.

Workers may merge bounded improvements when their exact claims are truthful and the change preserves the functioning design. They must not promote a narrow test into a broader runtime/playable claim.

When a large design correction is genuinely required, update the North Star and the affected issue first so every worker sees one clear forward path. Otherwise prefer local refactors and issue wording corrections over policy churn.

## Immediate audit targets

Review V2 commits and PRs chronologically from the first North Star commit through current main. Correlate implementation throughput, proof quality, merge behavior and product integration with changes in worker prompts/context.

Review every active V2 issue and recent V2 PR against the original design records and current implementation. Correct stale acceptance wording, overclaims and obsolete dependency language without rewriting working code merely for conformity.

Produce the final timeline only after the code/doc/issue audit is complete so the deterioration curve reflects observed evidence rather than a preselected narrative.
