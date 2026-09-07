# LowVRAM 3D Studio

<!-- CHANGELOG-LANDING:BEGIN -->
## Project timeline

Canonical history: [CHANGELOG.md](CHANGELOG.md)
<!-- CHANGELOG-LANDING:END -->

LowVRAM is the source-recovery and image-to-3D producer for the asset pipeline. It preserves source provenance, runs the canonical frozen generation path on the target low-VRAM machine, preserves reusable master geometry, produces textured deliverables, and requires mandatory 12-view visual QA before producer handoff.
LowVRAM does **not** own downstream rigging, animation, asset-library compilation, Unreal materialization, or gameplay acceptance.

## Product boundary

```text
source images
  -> LowVRAM
       source discovery / recovery / intake
       source preservation + provenance
       matte / framing / conditioning
       frozen image-to-3D generation
       dense/master geometry + textured deliverable
       generation receipts
       mandatory 12-view visual QA
       producer handoff
  -> Tiny3D
       content identity / catalogue
       classification
       rigging / skinning / animation / deformation preparation
       physics / destruction preparation
       validation / portable packaging
       consumer handoff missions
  -> P3
       Unreal/game materialization
       runtime / gameplay / visual acceptance
```

TinyLab is historical naming only. Current post-generation compiler/library work belongs to Tiny3D.

## Worker entry

Agents and workers read, in order:

1. `AGENTS.md`
2. `START_HERE.md`
3. `docs/NORTH_STAR.md`
4. `docs/PIPELINE_CONTRACT.md`
5. `docs/WORK_COORDINATION.md` before mutation
6. the current frozen production package named by `AGENTS.md` before any TRELLIS command or diagnosis

If the instruction is only **Ã¢â‚¬Å“go work on LowVRAMÃ¢â‚¬Â**, use `docs/WORKER_ENTRYPOINT.md`. The default mission is to recover/reconcile sources, prioritize actionable P3-facing assets, resume or repair the canonical queue, complete mandatory 12-view QA, and leave exact producer outputs ready for Tiny3D.

## Current normal-quality intent

The current user-confirmed normal-quality policy is:

```text
resolution: 1024
atlas:      8192
faces:      1000000
seed:       12345
master PLY: preserve
```

`1536` is an explicit higher-quality upgrade, not a universal default. Exact launcher identity, runtime paths, executable hashes, and command details come from the current frozen production package, not from remembered commands or historical runbooks.

## Core production rules

Preserve source bytes and provenance before consolidation. Reconcile by SHA-256 before regenerating. Reuse valid geometry when only a downstream stage failed. Run only one TRELLIS GPU producer at a time unless current authority explicitly changes that invariant. Mandatory 12-view QA is part of LowVRAM completion on every supported generation path. Any visual-quality claim requires direct visual inspection.

A GLB/PLY existing is not by itself a completed LowVRAM result. A Tiny3D compile result is not P3 runtime proof. A P3 runtime result is not evidence that LowVRAM should own those downstream stages.

## Source recovery

Source recovery is first-class production work. Consolidation must be reversible and hash-backed. Prefer hardlinks or copies; ordinary intake does not delete originals. Preserve original path, canonical path/name, SHA-256, byte size, category, duplicate relationship, priority, and production state.

See `docs/SOURCE_RECOVERY_AND_QUEUE.md`.

## Queue behavior

The queue is stage-aware and resumable. It should restart an asset at the first invalid or missing LowVRAM stage rather than regenerate from scratch. One bad or ambiguous source blocks only that asset; unrelated recovery, rendering, and queue work continues.

A downstream naming, rendering, Tiny3D, packaging, Unreal, or gameplay failure does not authorize silent regeneration of valid upstream geometry.

## LowVRAM completion boundary

A LowVRAM asset is ready for Tiny3D when:

- the exact intended source and provenance are preserved;
- generation output is sane or a valid reusable master is proven;
- required master geometry is preserved;
- the textured deliverable exists;
- mandatory 12-view QA has completed;
- visual output has been directly inspected for any visual-quality claim;
- the producer handoff identifies the exact source and generated artifacts.

Rigging, skinning, animation, deformation, physics/destruction preparation, content-addressed catalogue/library state, package lifecycle, and consumer missions are Tiny3D responsibilities. Unreal/game materialization and runtime acceptance are P3 responsibilities.

## Historical material

Older product-foundation, installer, one-click, rigging, showroom, and recovery documents remain useful for lineage and diagnosis. They do not override `AGENTS.md`, `START_HERE.md`, `docs/NORTH_STAR.md`, `docs/PIPELINE_CONTRACT.md`, the current frozen production package, current source/tests, or current runtime evidence.
