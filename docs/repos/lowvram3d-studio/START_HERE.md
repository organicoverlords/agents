# START HERE — LowVRAM product and production entry

LowVRAM is the source-recovery and image-to-3D producer. Its accepted output is a provenance-bound generated asset with preserved master geometry, textured deliverable, generation evidence, and mandatory 12-view visual QA ready for Tiny3D.

LowVRAM does not own downstream rigging/animation, catalogue/library compilation, Unreal materialization, or gameplay acceptance.

## Read order

1. `AGENTS.md` — authority hierarchy, safety, proof, frozen-production discipline, and current named authorities.
2. `docs/NORTH_STAR.md` — current LowVRAM product direction and ownership boundary.
3. `docs/PIPELINE_CONTRACT.md` — durable LowVRAM producer behavior and acceptance.
4. `docs/WORKER_ENTRYPOINT.md` — default autonomous mission when the worker is told only “go work on LowVRAM”.
5. `docs/WORK_COORDINATION.md` — required live-work claim/release behavior before mutation.
6. The **current frozen production package** named by `AGENTS.md`. Before any TRELLIS command, diagnosis, retry, cleanup, or production explanation, read its current `production/README.md`, freeze manifest, and canonical launch scripts.
7. `docs/SOURCE_RECOVERY_AND_QUEUE.md` for source reconstruction, categorization, prioritization, dedupe, queue admission, and resume behavior.

Historical foundation/runbook/current-state documents are lineage and diagnostic evidence. They do not override the authority chain above.

## Product boundary

```text
source images
  -> LowVRAM
       recover / preserve / name / categorize source inputs
       hash-backed provenance and dedupe
       conditioning / matte
       frozen TRELLIS generation
       dense/master geometry + textured deliverable
       generation receipts
       mandatory 12-view visual QA
       producer handoff
  -> Tiny3D
       post-generation identity/catalogue
       classification
       rigging / skinning / animation / deformation preparation
       physics / destruction preparation
       validation / portable packaging
       consumer handoff missions
  -> P3
       Unreal/game materialization
       runtime / gameplay / visual acceptance
```

TinyLab is historical naming only; there is no separate current TinyLab product.

## Default worker behavior

If no narrower task is given, inspect live state and current BUSY ownership, recover/reconcile source inputs, rank the highest-value actionable P3-facing sources, reuse valid generated masters, resume or repair the canonical queue, complete mandatory 12-view QA, directly inspect visual results for visual claims, hand accepted producer outputs to Tiny3D, and continue with the next independent asset.

Do not wait for the user to reconstruct commands, locate sources, or decide routine queue mechanics.

## Current normal-quality production intent

The current user-confirmed normal-quality policy is resolution `1024`, atlas `8192`, target faces `1000000`, seed `12345`, with the master PLY preserved. `1536` is an explicit higher-quality upgrade.

Exact executable identity, runtime path, DLL/model hashes, launcher arguments, and freeze integrity come from the current frozen production package. If repository configuration disagrees with the current frozen runtime or current user direction, preserve the conflict and repair the stale authority surface rather than silently choosing an older value.

## Frozen production discipline

Production is a frozen artifact, not an improvised build. Never bypass the canonical frozen launcher with a hand-built lower-level TRELLIS command. Never rebuild the frozen runtime in place or partially substitute one executable/DLL/model. A new runtime becomes production only through the current controlled freeze/proof process.

A downstream naming, render, handoff, Tiny3D, Unreal, or gameplay failure does not authorize regeneration of valid LowVRAM geometry.

## Source recovery is production work

Recover scattered or missing inputs before assuming they are lost. Preserve originals, hash by SHA-256, maintain original and canonical paths, deduplicate by content identity, categorize only when evidence supports it, and rank by current game value. Prefer hardlinks or copies for consolidation; ordinary intake does not delete originals.

Reconcile sources with existing masters/receipts before queueing TRELLIS. If valid geometry exists, resume at the first missing LowVRAM stage.

## Mandatory 12-view QA

The canonical 12-view QA gate is mandatory on every supported LowVRAM generation path and has no production opt-out. A generated GLB/PLY remains incomplete at the LowVRAM boundary until the required 12-view result exists and the relevant visual claim has been directly inspected.

Renderer failure repairs the renderer/QA stage; it does not automatically rerun TRELLIS.

## LowVRAM completion

LowVRAM completion requires the intended source/provenance, sane generated or reusable master geometry, textured deliverable, generation receipt/provenance, mandatory 12-view QA, direct visual review for visual claims, and an exact producer handoff to Tiny3D.

Tiny3D completion and P3 runtime acceptance are separate downstream proof states. Do not report them as inherited from LowVRAM.
