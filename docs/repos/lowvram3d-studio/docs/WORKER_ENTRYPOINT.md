# LowVRAM Worker Entrypoint

This file answers one question: what should a worker do when the instruction is only **“go work on LowVRAM”**?

## Read before mutation

Read in this order:

1. `AGENTS.md` for authority, safety, proof, and live-work coordination.
2. `START_HERE.md` for current product/runtime entry context.
3. `docs/NORTH_STAR.md` for product ownership and default mission.
4. `docs/PIPELINE_CONTRACT.md` for LowVRAM producer acceptance.
5. `docs/WORK_COORDINATION.md` before claiming a mutation scope.
6. The current frozen production package named by `AGENTS.md` before any TRELLIS command, diagnosis, retry, cleanup, or production explanation.

Do not reconstruct the production command from remembered flags, old branches, old issue comments, or build-folder names.

## Default autonomous work loop

When no narrower task is supplied, use this order:

```text
inspect authority + live state
  -> recover/reconcile source inputs
  -> rank actionable P3-facing assets
  -> reuse valid generated masters where possible
  -> repair/resume canonical generation queue
  -> run mandatory 12-view QA
  -> directly inspect visual results for visual claims
  -> emit exact producer handoff for Tiny3D
  -> continue to next independent asset
```

A worker should not stop merely because one asset is ambiguous or one downstream consumer stage is unavailable. Record the exact per-asset state and continue unrelated work.

## Source recovery rules

Treat source recovery as first-class production work. Search current approved source locations and recovery evidence, preserve original bytes and paths, hash before deduplication, and build/update a reversible manifest. Prefer hardlinks or copies when consolidating scattered sources. Do not delete originals as part of ordinary intake.

For each source record preserve at least:

- original path;
- canonical path/name;
- SHA-256;
- byte size;
- semantic category or explicit `uncategorized` state;
- duplicate relationship;
- priority;
- production state.

See `docs/SOURCE_RECOVERY_AND_QUEUE.md` for the detailed contract.

## Prioritization

Rank by immediate game value, not filename order. Prefer assets that unblock current P3 work, then reusable environment/architecture, gameplay creatures/characters, gameplay props/vehicles, and finally decorative or duplicate variants. Uncertain semantic classification must remain explicit rather than guessed.

## Generation rules

Use the current frozen launcher. Preserve valid master geometry. Do not start a second TRELLIS producer without proving the first is no longer active. If identity, naming, rendering, metadata, Tiny3D, or P3 fails, repair that stage; do not regenerate valid geometry by default.

## Mandatory visual QA

Every supported LowVRAM generation path requires the canonical 12-view review output before LowVRAM producer completion. File existence or command success is supporting evidence only. Each completed render must expose its exact write-once `C:\LowVRAMProofs\<run-id>` pointer as `PENDING_REVIEW`; workers continue unrelated queue work while an independent reviewer inspects that run. Any claim about appearance requires `reviewed.json`, and reviewers must distinguish proof/camera/identity defects from implementation defects.

## Handoff boundary

LowVRAM hands generated geometry, textures, source/generation provenance, receipts, and visual-QA evidence to Tiny3D. Tiny3D owns post-generation content identity/catalogue behavior, rigging, skinning, animation, deformation, physics/destruction preparation, validation, packaging, and consumer missions. P3 owns Unreal/game materialization and runtime acceptance.

Do not add a LowVRAM rigging lane merely because an asset is riggable. Route the accepted LowVRAM producer output to Tiny3D instead.

## What counts as done

For one asset, LowVRAM completion means preserved source/provenance, sane canonical generation output or evidence-backed reusable output, preserved master geometry, textured deliverable, mandatory 12-view QA, direct visual review for visual claims, and an exact producer handoff.

For an unattended worker pass, “done” means there is no independent actionable LowVRAM work left in the claimed scope. If work remains, leave an actionable non-BUSY state naming the next concrete action.
