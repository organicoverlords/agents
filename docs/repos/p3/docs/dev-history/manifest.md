# P3 visual and artifact manifest

This manifest is the companion to [`README.md`](./README.md). It maps each
representative visual or proof artifact to its source path, context, and current
status. Paths are referenced in place; large assets are not duplicated into
`docs/dev-history/`.

New milestones are no longer dependent on this table being edited by hand. The
append-only structured receipts under [`events/`](./events/) are the machine-readable
capture index and remain directly inspectable historical evidence. This file remains
the curated cross-era visual map and backlog.

Status vocabulary:

- **durable** — committed and usable as a repository reference;
- **durable, partial** — committed evidence exists but the receipt limits the claim;
- **candidate** — committed visual exists, but its exact milestone context needs a
  later caption or re-capture;
- **external** — the receipt points to a capture outside this repository;
- **missing** — the expected artifact is absent, empty, or explicitly pending.

## 1. Representative visual and artifact map

| ID | Milestone/context | Visual or artifact | Source commit / receipt | Status and interpretation |
| --- | --- | --- | --- | --- |
| V-001 | Showroom floor, grass, ring, and early asset presentation | [`evidence/grass_foliage_test.png`](https://github.com/organicoverlords/p3/blob/main/evidence/grass_foliage_test.png), [`evidence/grass_foliage_test_reduced.png`](https://github.com/organicoverlords/p3/blob/main/evidence/grass_foliage_test_reduced.png), [`evidence/abilities/`](../../evidence/abilities/) | [`d82307ec`](https://github.com/organicoverlords/p3/commit/d82307ec); [`production-pass-20260813.md`](https://github.com/organicoverlords/p3/blob/main/evidence/production-pass-20260813.md) | candidate; the receipt says the floor/grass are readable but the horizon/ring are not a beauty-pass success |
| V-002 | Grapple activation, hook, cable, and release contract | [`evidence/automation_specs/grapple_contract/report.json`](https://github.com/organicoverlords/p3/blob/main/evidence/automation_specs/grapple_contract/report.json) and [`mid_grapple.png`](https://github.com/organicoverlords/p3/blob/main/evidence/automation_specs/grapple_contract/mid_grapple.png) | [`report.json`](https://github.com/organicoverlords/p3/blob/main/evidence/automation_specs/grapple_contract/report.json) | durable, partial; contract passes, but the recorded PNG is zero bytes and must be re-captured |
| V-003 | Fennec canonical mesh, movement, and AnimBP | Repository receipt [`evidence/fennec-live-runtime-acceptance.json`](https://github.com/organicoverlords/p3/blob/main/evidence/fennec-live-runtime-acceptance.json) | [`f8cbdec7`](https://github.com/organicoverlords/p3/commit/f8cbdec7) ancestry; receipt captured 2026-08-14 | external; the receipt names four inspected PNGs under the isolated acceptance project, not under this repo |
| V-004 | Fennec seated pose and sit/stand movement block | [`evidence/fennec-sit-runtime-acceptance.json`](https://github.com/organicoverlords/p3/blob/main/evidence/fennec-sit-runtime-acceptance.json) | receipt captured 2026-08-14 | external; the seated proof is named and hashed outside this checkout |
| V-005 | Macaw authored full-chain flight animation and bomb path | [`evidence/macaw-runtime-acceptance.json`](https://github.com/organicoverlords/p3/blob/main/evidence/macaw-runtime-acceptance.json), [`evidence/macaw_wing_fix_receipt.json`](https://github.com/organicoverlords/p3/blob/main/evidence/macaw_wing_fix_receipt.json) | receipts committed in the 2026-08-14/16 asset work | durable, partial; animation geometry passes, but visual-subject capture is explicitly pending |
| V-006 | Asylum Demon material/physics/runtime inspection | [`docs/asylum-demon-live-mcp-inspection.md`](../asylum-demon-live-mcp-inspection.md), [`evidence/asylum-demon/`](../../evidence/asylum-demon/) | [`cf65fee1`](https://github.com/organicoverlords/p3/commit/cf65fee1) and receipt files | durable, partial; material repair is recorded, deformation/runtime visual proof remains not proven |
| V-007 | Foliage material and early ability test series | [`evidence/abilities/`](../../evidence/abilities/) | [`d82307ec`](https://github.com/organicoverlords/p3/commit/d82307ec) | candidate; retain as historical visual experiments even when superseded |
| V-008 | Jellyfish animation/import/proof artifact | [`jelly_proof.png`](https://github.com/organicoverlords/p3/blob/main/jelly_proof.png), [`evidence/`](../../evidence/) jellyfish-related receipts | [`d651aaf9`](https://github.com/organicoverlords/p3/commit/d651aaf9); [`80ad1d29`](https://github.com/organicoverlords/p3/commit/80ad1d29) | durable, partial; repository image is preserved, but no current captioned lane-flight frame exists |
| V-009 | Building15 asset catalog and destruction pipeline | [`docs/BUILDING15_CATALOG_REGISTRATION.md`](../BUILDING15_CATALOG_REGISTRATION.md), [`scripts/building15_registration_map.json`](https://github.com/organicoverlords/p3/blob/main/scripts/building15_registration_map.json), [`scripts/chaos_fracture_wallbrace.py`](https://github.com/organicoverlords/p3/blob/main/scripts/chaos_fracture_wallbrace.py) | [`2c39a4ff`](https://github.com/organicoverlords/p3/commit/2c39a4ff); [`dee643ac`](https://github.com/organicoverlords/p3/commit/dee643ac) | durable, partial; catalog/registration and fracture scripts exist, but a captioned intact-to-fractured visual pair is missing |
| V-010 | Humanoid IK retarget repair | [`proof/claude_humanoid_retarget_20260817/README.md`](https://github.com/organicoverlords/p3/blob/main/proof/claude_humanoid_retarget_20260817/README.md), [`proof/claude_humanoid_retarget_20260817/receipts/`](../../proof/claude_humanoid_retarget_20260817/receipts/) | [`5dcb98b4`](https://github.com/organicoverlords/p3/commit/5dcb98b4) | durable, partial; 40/40 clip geometry is proven, but the README explicitly records no valid visual/PIE witness |
| V-011 | UI/VFX evolution from native/debug HUD to custom composition | Source commits and existing UI assets under `Content/` | [`597d9408`](https://github.com/organicoverlords/p3/commit/597d9408), [`e7176a20`](https://github.com/organicoverlords/p3/commit/e7176a20) | missing repository-local screenshot; add before/after HUD captures with the source commit and inspected verdict |
| V-012 | V2 production-world HLOD acceptance | [`evidence/v2-world-hlod-determinism.json`](https://github.com/organicoverlords/p3/blob/main/evidence/v2-world-hlod-determinism.json) | receipt `proof_head=7e06ac8d`; [`f0cf046b`](https://github.com/organicoverlords/p3/commit/f0cf046b) | durable, partial; deterministic steady-state rebuild is recorded, but raw fresh delete/recreate bytes are correctly not claimed identical |
| V-013 | V2 inventory/resource/save vertical slice | [`evidence/v2/v1-baseline/index.json`](https://github.com/organicoverlords/p3/blob/main/evidence/v2/v1-baseline/index.json), V2 source/tests | [`0990b1e6`](https://github.com/organicoverlords/p3/commit/0990b1e6), [`ab4a71ed`](https://github.com/organicoverlords/p3/commit/ab4a71ed) | durable, partial; baseline index is historical evidence and explicitly does not become current-main acceptance |
| V-014 | Earthworks preview, edit, undo, persistence, and two-client state | [`docs/EARTHWORKS_FIELDCRAFT_20260816.md`](../EARTHWORKS_FIELDCRAFT_20260816.md), [`docs/EARTHWORKS_PERSONAL_PREVIEW_20260816.md`](../EARTHWORKS_PERSONAL_PREVIEW_20260816.md) | [`cfe7cca8`](https://github.com/organicoverlords/p3/commit/cfe7cca8), [`0359b918`](https://github.com/organicoverlords/p3/commit/0359b918) | durable, partial; source and runtime acceptance commits exist, but no compact edit/undo/replication visual sequence is committed |
| V-015 | Tower-defense wave, tower, core, and readable HUD state | [`docs/basebuilding-rts-towerdefense-foundation.md`](../basebuilding-rts-towerdefense-foundation.md), [`docs/lane-war-arena.md`](../lane-war-arena.md) | [`245729bf`](https://github.com/organicoverlords/p3/commit/245729bf), [`34231211`](https://github.com/organicoverlords/p3/commit/34231211) | missing repository-local capture; add wave-in-progress, core health, and target/faction proof |
| V-016 | Lane War two-client arena and first human 1v1 | [`docs/lane-war-arena.md`](../lane-war-arena.md), [`2026-08-22-first-human-1v1-host.png`](https://github.com/organicoverlords/p3/blob/main/evidence/lane-war/2026-08-22-first-human-1v1-host.png), [`2026-08-22-first-human-1v1-client.png`](https://github.com/organicoverlords/p3/blob/main/evidence/lane-war/2026-08-22-first-human-1v1-client.png), [`recovery receipt`](https://github.com/organicoverlords/p3/blob/main/evidence/lane-war/2026-08-22-first-human-1v1.md) | [`e570d128`](https://github.com/organicoverlords/p3/commit/e570d128fd7d46bf66ea5b14ca239f9835b3be1a), runtime head [`b4264cba`](https://github.com/organicoverlords/p3/commit/b4264cbaaf6d606b0a693a807f1769efe02a487c) | durable, partial; both clients visually agree on Team 1 victory / Team 2 core destruction, but the recovered world render is black so arena beauty/scene presentation remains unproven |
| V-017 | TRELLIS/LowVRAM asset-generation and staging context | Historical/main-line anchors [`d82307ec`](https://github.com/organicoverlords/p3/commit/d82307ec), [`2c39a4ff`](https://github.com/organicoverlords/p3/commit/2c39a4ff), [`901d7265`](https://github.com/organicoverlords/p3/commit/901d7265) | [`NEXT_EDITOR_HANDOFF.md`](../../NEXT_EDITOR_HANDOFF.md) plus commit history | durable historical context only; operational paths/processes are not current product-state evidence and should not be treated as live |

## 2. Visual capture backlog

| Priority | Capture | Destination and minimum context |
| --- | --- | --- |
| P0 | Re-capture grapple mid-action | `evidence/automation_specs/grapple_contract/mid_grapple.png`; record non-zero bytes, dimensions, source SHA, map, hook/cable state, and inspected verdict |
| P0 | Add Lane War arena beauty/launch frame | `evidence/lane-war/`; current first-human-1v1 end-state symmetry is durable, but add a readable world/arena launch frame tied to the same source/runtime provenance |
| P0 | Add earthworks edit sequence | `evidence/earthworks/`; preview, committed edit, undo/persistence or replicated-client frame, with authoritative-state notes |
| P1 | Add Building15 fracture pair | `evidence/building15/`; intact wall, fractured wall, collision/damage state, and Chaos receipt link |
| P1 | Add Fennec/Macaw/Asylum comparison | `evidence/characters/`; canonical mesh/material/pose plus movement or flight frame; do not reuse external Saved paths without copying the inspected artifact into the repo |
| P1 | Add jellyfish lane-flight frame | `evidence/jellyfish/`; animated mesh, route movement, lane target, and import/verification receipt |
| P1 | Add tower-defense/HUD frame set | `evidence/tower-defense/`; wave, tower target, core state, and readable HUD presentation |
| P2 | Add UI/VFX before/after | `evidence/ui-vfx/`; native/debug baseline and custom composition/current VFX frame, each tied to source commit |
| P2 | Add retarget visual witness | `evidence/animation/retarget/`; owned PIE or Sequencer frame, target/clip names, and the existing geometry receipt |
| P2 | Add TRELLIS/LowVRAM provenance board | `evidence/pipeline/`; only durable input/output metadata and representative images, with private operational paths omitted or redacted |

## 3. Provenance rules for future entries

Every new row should include:

1. the repository-relative path of the visual or receipt;
2. the source commit or PR/issue/doc that caused it;
3. map/world and asset identifiers when applicable;
4. capture route and ownership (for example, owned PIE, commandlet, or static);
5. dimensions, byte count, and SHA256 for image/video artifacts;
6. an inspected verdict that distinguishes pixels from source/static claims;
7. a short note when a claim is partial, pending, stale, or intentionally not made.

Do not overwrite an ugly or broken artifact with a polished replacement. Add the
new capture and keep the old path in the historical record.

## 4. Failed, broken, and funny artifacts

These are historical evidence, not cleanup targets:

- [`mid_grapple.png`](https://github.com/organicoverlords/p3/blob/main/evidence/automation_specs/grapple_contract/mid_grapple.png)
  is retained even though its receipt says it is zero bytes; the failure tells
  the next capture worker exactly what to repair.
- [`proof/claude_humanoid_retarget_20260817/README.md`](https://github.com/organicoverlords/p3/blob/main/proof/claude_humanoid_retarget_20260817/README.md)
  records the failed render routes, bind-pose trap, and the important distinction
  between changing PNG bytes and changing animation pose. Those failed attempts
  are part of the lesson and must not be erased because the geometry metrics pass.
- The Asylum Demon and Macaw receipts preserve attempted-but-not-proven visual
  paths, rather than converting missing screenshots into green claims.
- The showroom/grass/ability candidates remain available as visual experiments,
  including partial or unattractive frames, because they explain the evolution of
  the presentation pipeline.

When a later capture supersedes one of these, append the new row and link the old
row; do not delete the historical artifact merely because it is obsolete or ugly.
