# LOWVRAM3D canonical producer pipeline contract

`PIPELINE_CONTRACT_V3`

This document defines durable LowVRAM product behavior from source recovery through accepted generated-asset handoff. It is not a machine-state snapshot. Current runtime identity, paths, hashes, queue state, ports, PIDs, and recovery incidents belong to their current owning sources.

`AGENTS.md` owns operating policy and authority resolution. `docs/NORTH_STAR.md` owns current product direction. The current frozen production package owns live TRELLIS launcher/runtime identity. Current source/tests own exact implementation entrypoints, renderer math, filenames, and other implementation details.

## 1. Normal LowVRAM producer contract

```text
SOURCE IMAGE
  -> recover / preserve source and provenance
  -> canonical name/category/priority where evidence supports it
  -> hash-backed dedupe / reconcile existing outputs
  -> matte / framing / conditioning
  -> canonical frozen TRELLIS generation when generation is actually required
  -> dense/master PLY + textured deliverable + generation receipt
  -> geometry/output sanity QA
  -> MANDATORY 12-VIEW VISUAL QA
  -> direct visual inspection for visual-quality claims
  -> provenance-bound producer handoff to Tiny3D
```

That handoff is the LowVRAM completion boundary.

Tiny3D owns post-generation content identity/catalogue behavior, classification, rigging, skinning, animation, deformation preparation, physics/destruction preparation, validation, portable packaging, and consumer handoff missions. P3 owns Unreal/game materialization and runtime/gameplay/visual acceptance. TinyLab is historical naming only, not a separate current product.

No worker may redefine LowVRAM completion to include Tiny3D rigging or P3 runtime acceptance, and no downstream failure may be used as an excuse to regenerate valid upstream geometry.

## 2. Source recovery, identity, naming, and dedupe

Source recovery is first-class production work. Preserve original bytes and original path before consolidation. Prefer hardlinks or copies for reversible intake. Ordinary recovery does not delete originals.

For every source retain, at minimum:

- original path;
- canonical path/name;
- SHA-256;
- byte size;
- semantic category or explicit uncertain state;
- duplicate relationship;
- priority;
- strongest production stage.

SHA-256 is the durable dedupe key. Human-readable names aid operators and queue readability but do not replace content identity.

Do not invent semantics. If a source cannot be classified confidently from available evidence, keep it explicitly uncategorized/review-needed and continue unrelated work.

Before TRELLIS admission, reconcile the source hash and provenance against existing valid masters, receipts, and accepted outputs. Reuse valid geometry and resume from the first missing LowVRAM stage.

## 3. Prioritization and queue admission

Queue order is driven by immediate product value rather than filename order. Prefer current P3 blockers and explicitly required gameplay assets, then reusable environment/architecture, core creatures/characters, vehicles/gameplay props, supporting nature/set dressing, and finally decorative/redundant variants.

A source is actionable when the intended source is preserved and unambiguous, the input satisfies or can deterministically satisfy the current frozen input contract, the same asset/output is not owned by another active BUSY scope, the intended generation settings come from current authority, and queueing it will not start a second conflicting TRELLIS producer.

One ambiguous or missing source blocks only that asset. Continue independent recovery, reconciliation, rendering, and queue work.

## 4. Current production intent and frozen runtime

Before any TRELLIS production command, diagnosis, retry, cleanup, or production explanation, follow the frozen-production read gate named by `AGENTS.md`. The current frozen package owns executable identity, DLL/model identity, launcher behavior, and exact command details.

The current user-confirmed normal-quality intent is:

```text
resolution = 1024
atlas = 8192
target faces = 1000000
seed = 12345
preserve master PLY = true
```

`1536` is an explicit higher-quality upgrade, not the default. Historical `512 / 4096 / 450000` recovery runs remain historical evidence only.

**These are defaults, not a veto over the caller.** A default is the value used when the request did not specify one; an explicit request outranks it. If a run is asked for 512, it runs at 512. On 2026-08-25 a 26-item queue was asked for 512 and generated at 1024 -- roughly four times the work per item on a 6 GB card -- because the settings file describes itself as the only place generation settings exist, and that was read as authority over the request. It is the single source of *defaults*. If a requested setting genuinely cannot be honoured, stop and say why; never silently substitute one.

If repository configuration, historical docs, or old queue scripts disagree with current authority, preserve the contradiction, repair the stale surface, and do not silently revive an older setting.

The production runtime is a frozen artifact. Never rebuild it in place, partially substitute one executable/DLL/model, bypass the canonical launcher, or let an experiment overwrite production.

## 5. TRELLIS generation contract

Generation produces at minimum:

- textured deliverable;
- dense/master PLY;
- generation log/receipt/provenance;
- state required for mandatory 12-view QA.

Process liveness is not generation proof. Required outputs and receipts must be sane.

Only one TRELLIS GPU producer may own generation at a time unless newer explicit production authority deliberately changes that invariant. Do not start a second producer merely because a wrapper returned or a caller timed out; verify the actual producer state first.

A valid generated master remains reusable when any later LowVRAM or downstream stage fails.

## 6. Mandatory 12-view visual QA

The 12-view stage is a fail-closed LowVRAM completion gate, not an optional convenience. Current renderer/runner source owns canonical view order, labels, camera math, panel resolution, filenames, and grid construction.

Policy requires the complete canonical 12-view set, the required review grid, readable human labels, consistent inspectable framing/lighting, semantic orientation where evidence supports it, and direct visual inspection for any visual-quality claim. Each completed render publishes a write-once local run under `C:\LowVRAMProofs\<run-id>` with `manifest.json` and the exact 12-view sheet. Queue execution records that run as `PENDING_REVIEW` and continues; only an independent `reviewed.json` may promote the visual claim to `PROVEN`, `REJECTED`, or `NOT_PROVEN`.

A GLB/PLY without successful mandatory views12 remains incomplete at the LowVRAM producer boundary. A 12-view file existing is render evidence, not visual acceptance and not by itself Tiny3D-ready visual QA.

Render/QA failure repairs or reruns the render/QA stage. It does not rerun TRELLIS unless geometry is independently proven bad.

## 7. Stage-aware resume and failure isolation

Resume from the first invalid or missing LowVRAM stage. Preserve all earlier evidence that remains valid.

Use this failure routing:

```text
source/recovery failure -> recover/reconcile source only
conditioning failure -> repair conditioning only
generation/runtime failure -> diagnose frozen generation/runtime
views12/render failure -> repair/rerun visual QA
producer-handoff failure -> repair handoff metadata/artifact linkage
Tiny3D rig/compile/package failure -> Tiny3D owns repair
P3 Unreal/runtime/gameplay failure -> P3 owns repair
```

A launcher, transport, wrapper, rendering, Tiny3D, or P3 failure does not automatically become a CUDA/model or geometry failure.

Never silently substitute another asset, runtime, model, or consumer because the intended target is inconvenient.

## 8. Producer handoff contract

A LowVRAM producer handoff must identify the exact source/provenance and generated artifacts being handed downstream. It should preserve enough information for Tiny3D to ingest deterministically and to avoid regenerating upstream geometry when its own compile or consumer contract fails.

At minimum the handoff should bind:

- canonical source identity/path and source hash;
- generated asset identity/path;
- master PLY identity/path;
- generation settings/runtime provenance or receipt reference;
- mandatory 12-view QA artifact identity/path;
- strongest LowVRAM proof state;
- any explicit unresolved LowVRAM caveat.

Tiny3D may add its own durable content identity and package provenance after ingestion; that downstream identity does not retroactively change LowVRAM source provenance.

## 9. Rigging and animation are downstream

LowVRAM does not own rigging, skinning, animation, deformation preparation, physics/destruction preparation, or post-generation catalogue/library compilation.

When a generated asset is riggable, LowVRAM completes its producer contract and hands the asset to Tiny3D. Tiny3D then chooses the lightest correct runtime mechanism for that asset rather than assuming every object requires a skeleton.

A rigging failure never authorizes silent LowVRAM geometry regeneration.

## 10. P3 acceptance is downstream

LowVRAM may prioritize assets because P3 needs them, but P3 materialization and runtime acceptance remain P3 truth. LowVRAM completion must not claim that an asset imports, animates, collides, looks correct in-game, or satisfies gameplay merely because the producer handoff exists.

Likewise, a P3 failure does not erase valid LowVRAM evidence.

## 11. Default unattended worker mission

If a worker receives only **“go work on LowVRAM”**, it must inspect current authority and live state, recover/reconcile sources, rank actionable P3-facing assets, reuse valid masters, resume/repair generation and views12, directly inspect visual outputs for visual claims, publish exact producer handoffs to Tiny3D, and continue with the next independent asset.

Workers do not stop globally because one asset is ambiguous or one downstream stage is unavailable.

## 12. Completion and proof

For each changed LowVRAM stage identify its input, output, execution owner, and proof gate. Verify that the stage actually runs in the live path; `code exists` is not `pipeline uses it`.

A LowVRAM asset is complete only when the exact intended source/provenance is retained, generation output is sane or a valid reusable master is independently proven, required master geometry is preserved, the textured deliverable exists, mandatory 12-view QA has completed, direct visual inspection supports any visual-quality claim, and the producer handoff identifies the exact artifacts for Tiny3D.

Tiny3D compile/rig/package success and P3 runtime/visual/gameplay success are separate downstream proof states and must not be inherited by implication.

Historical reports, old counts, old view folders, old handoffs, old branches, and recovery recipes remain useful for lineage and diagnosis only. They do not override `AGENTS.md`, `docs/NORTH_STAR.md`, this contract, the current frozen production package, current source/tests, or current runtime evidence.
