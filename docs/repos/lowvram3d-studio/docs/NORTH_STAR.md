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

## Finished-product roadmap

LowVRAM is finished as a producer product when preserved source images can move through one boring, reproducible local production path into **visually accepted, provenance-bound, reusable 3D masters and textured handoffs** without the user reconstructing commands, recovering source identity by hand, supervising routine queue recovery, or deciding which stale ticket should exist next.

The finished LowVRAM product must provide:

- **Preserved source truth:** every generated result remains attributable to exact preserved image inputs, conditioning/matte state, frozen runtime/configuration and generation receipt.
- **Production-quality geometry and texture:** accepted assets preserve important silhouette/structure/identity, usable surface detail and intended materials rather than merely producing a syntactically valid mesh.
- **Reusable masters:** dense/master geometry and high-value intermediate work survive downstream failure; regeneration is a last resort justified by invalid source/generator evidence, never a reflex.
- **Mandatory visual QA:** the standard multi-view review is generated, readable and directly inspected for every claimed visual result; automated metrics cannot silently overrule visible defects.
- **Resource-bounded unattended execution:** the canonical path runs reliably on the actual low-VRAM workstation, resumes after ordinary interruption, respects the single TRELLIS GPU producer boundary, and fails one asset locally without stopping independent queue work.
- **Boring Tiny3D handoff:** exact source/generated artifacts, provenance and review state are sufficient for Tiny3D to ingest the asset without archaeology or LowVRAM reaching into downstream rigging/animation/runtime ownership.

The durable progression is:

1. **Recover and finish the live production queue (current).** Preserve/reconcile source identity, reuse valid masters, complete canonical generation + mandatory review, and hand accepted outputs to Tiny3D.
2. **Quality across representative asset classes.** Harden the frozen production path against the real failure families already observed—thin structures, occlusion/hidden surfaces, multipart structures, difficult texture coverage and other evidence-backed classes—without turning historical experiments into parallel production pipelines.
3. **Unattended incremental production.** New/recovered inputs are admitted deterministically, queue state resumes safely, unchanged results are reused, failed stages identify the next supported repair, and the user is not asked to operate routine recovery.
4. **Finished producer boundary.** The normal-quality path, optional higher-quality escalation, source preservation, master retention, QA and Tiny3D handoff are all reproducible from current authority; old runbooks remain historical evidence rather than required tribal knowledge.

### Roadmap continuity and issue-wall recovery

Workers own queue/issue continuity. If the current LowVRAM issue set is exhausted, stale or blocked by a narrow asset, reconcile the North Star against preserved sources, current outputs, queue state, Tiny3D demand and live machine evidence. Close/supersede dead work, preserve reusable masters, continue independent assets, and create a bounded issue only for a real uncovered producer gap. The user does not need to seed or curate LowVRAM issues to keep production moving.

Do not expand the LowVRAM boundary merely to manufacture work: rigging, animation, catalogue/runtime preparation and P3 gameplay acceptance stay downstream unless explicit user direction changes the product boundary.

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
