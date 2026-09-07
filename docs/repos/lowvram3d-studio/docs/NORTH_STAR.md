# LowVRAM North Star

Status: **AUTHORITATIVE PRODUCT DIRECTION**

LowVRAM exists to turn preserved source images into visually reviewed, provenance-bound 3D producer outputs. Its job ends at a trustworthy generated asset handoff. It does not own downstream rigging, animation, Unreal materialization, or gameplay acceptance.

## Product boundary

```text
source images
  -> LowVRAM
       source discovery / recovery / intake
       source preservation + provenance
       framing / matte / conditioning
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

TinyLab is historical naming only. New post-generation compiler/library work belongs to Tiny3D.

## North-star outcome

Given a preserved source image and unchanged LowVRAM runtime/configuration, LowVRAM should be able to recover or reproduce the same source identity, run the canonical generation path, preserve reusable masters, generate mandatory review views, and publish a provenance-bound producer handoff without requiring the user to reconstruct old commands or history.

## Default worker mission

If a worker is told only **“go work on LowVRAM”**, it must not wait for a more detailed task. It should:

1. read `START_HERE.md`, `AGENTS.md`, this North Star, and the current frozen production package;
2. inspect live queue/recovery state and current BUSY ownership;
3. recover scattered or missing source inputs non-destructively and reconcile them by hash with existing outputs;
4. choose the highest-value actionable P3-facing source assets;
5. resume or repair the canonical generation and mandatory 12-view queue, preserving valid geometry when only downstream stages fail;
6. leave accepted LowVRAM producer outputs ready for Tiny3D;
7. continue with the next independent actionable asset until the queue is exhausted or a real user decision is required.

## Governing invariants

- Preserve sources before renaming, moving, deduplicating, or regenerating.
- Prefer reuse of valid masters over regeneration.
- Only one TRELLIS GPU producer may own generation at a time unless a newer explicit production authority changes that rule.
- Mandatory 12-view QA is part of LowVRAM completion; a GLB/PLY alone is not a completed producer result.
- Visual claims require direct visual inspection.
- Downstream Tiny3D or P3 failure never authorizes silent TRELLIS regeneration.
- Rigging, skinning, animation, deformation, physics, destruction, catalogue ownership, and consumer runtime acceptance are downstream responsibilities.
- Historical runbooks and branches are evidence, not current authority, unless current authority explicitly points to them.

## Current production intent

*Live-state refresh 2026-08-24 by `claude`, appended without changing the intent below: no actor is currently live in this repo and both stale BUSY markers (#53, #65) have been cleared. The master-preservation requirement in this section is now also a hard rail in shared policy v1.2, `Data you must never delete`, after an agent deleted a set of masters and asset files.*

The current user-confirmed normal-quality policy is resolution `1024`, atlas `8192`, target faces `1000000`, seed `12345`, with the master PLY preserved. `1536` is an explicit higher-quality upgrade, not a universal default. Exact executable identity, launcher arguments, paths, and frozen runtime integrity come from the current frozen production package named by `AGENTS.md`.

## Completion boundary

A LowVRAM asset is ready for downstream handoff when its intended source/provenance is preserved, generation output is sane, required master geometry is retained, the textured deliverable exists, mandatory 12-view QA has completed, visual review has been performed for any visual-quality claim, and the producer handoff identifies the exact source and generated artifacts.

Tiny3D acceptance and P3 runtime acceptance are separate proof states and must never be implied from LowVRAM completion.
