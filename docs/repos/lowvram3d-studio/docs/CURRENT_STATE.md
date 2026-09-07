# Current production state

**Updated: 2026-08-23 after repository/source-of-truth study.**

This file is a mutable state/evidence surface. It must describe what is actually observed now and explicitly mark anything that has not been rechecked. Durable product behavior lives in `docs/NORTH_STAR.md` and `docs/PIPELINE_CONTRACT.md`.

## Current product boundary

LowVRAM owns source recovery/intake, provenance, conditioning, frozen image-to-3D generation, preserved master geometry, textured output, generation receipts, mandatory 12-view QA, and producer handoff.

Tiny3D owns post-generation content identity/catalogue behavior, classification, rigging, skinning, animation, deformation preparation, physics/destruction preparation, validation, portable packaging, and consumer handoff missions.

P3 owns Unreal/game materialization and runtime/gameplay/visual acceptance.

TinyLab is historical naming only.

## What is proven on repository `main`

The authoritative documentation boundary above is now on `main` through commit `7b62a1c3afdb683976e428cbdf408b9acf21e7a5`.

Current repository code/config is **not yet aligned** with that documentation and must not be treated as a production-ready queue snapshot.

Observed on `main`:

- `workers/production_queue.sh` hardcodes `RES=512`, `ATLAS=4096`, and `FACES=0`.
- that legacy queue contains 10-view generation/publishing logic and publishes into `ALL_VIEWS9`.
- `tools/production-control.ps1` explicitly validates the old `512 / 4096 / FACES=0` contract and uses views9 acceptance fields.
- `production/production.json` still records resolution `512`, atlas `4096`, target faces `1000000`, and a product mode that includes a LowVRAM `rig` lane.
- the current authoritative docs instead require normal-quality intent `1024 / 8192 / 1000000`, mandatory 12-view QA, and a LowVRAM completion boundary before Tiny3D rigging/compilation.

Therefore the checked-in queue/controller/config surfaces are mutually inconsistent with current product authority.

## Current disposition

**Do not start production from repository `main` by blindly running `workers/production_queue.sh` or `tools/production-control.ps1`.** Their checked-in settings and visual gate are stale relative to current product authority.

The next queue repair must reconcile the executable queue/controller path to:

```text
normal generation intent: 1024 / 8192 / 1000000 / seed 12345
preserve master PLY
one TRELLIS GPU producer
mandatory 12-view QA
stage-aware resume / reuse valid geometry
producer handoff to Tiny3D
```

Exact launcher identity, executable/DLL/model hashes, command arguments, runtime paths, and freeze integrity must be re-read from the current frozen production package named by `AGENTS.md` before mutation or execution.

## Local runtime state

`NOT_PROVEN` in this state document as of this update.

The authorized local machine route (`kone`) was reported online by the control service but did not respond to a direct ping during this documentation pass. No current local queue PID, TRELLIS PID, frozen-package integrity result, generated-asset result, or current source-library state is claimed here.

Older local process IDs, queue liveness reports, generated counts, recovery runs, and handoff summaries remain historical evidence only until independently rechecked.

## Source recovery / intake direction

Source recovery remains active product work under issue #50. Workers should recover and reconcile source images non-destructively, preserve SHA-256/original paths, categorize only where evidence supports it, rank by current P3 value, reuse valid generated masters, and feed only actionable sources into the repaired canonical queue.

See `docs/SOURCE_RECOVERY_AND_QUEUE.md` and `docs/WORKER_ENTRYPOINT.md`.

## Queue repair acceptance

The queue path is not accepted merely because scripts parse or a process starts. Before calling the queue production-ready, independently prove:

1. checked-in settings/config/controller agree with current authority;
2. the current frozen package verifies successfully;
3. queue/controller preflight rejects stale runtime/settings rather than validating them;
4. one real actionable asset completes generation or valid geometry reuse without a second producer;
5. mandatory 12-view QA completes through the actual queue path;
6. the rendered result is directly inspected for any visual-quality claim;
7. an exact LowVRAM producer handoff is emitted for Tiny3D;
8. downstream Tiny3D/P3 proof remains separate rather than being inherited.

## Failure interpretation

A stale queue/controller/config mismatch is a repository repair problem, not evidence of a CUDA/model failure.

A launcher/transport failure before TRELLIS starts is not a generation failure.

A renderer/QA failure does not authorize regeneration of valid geometry.

A Tiny3D rig/compile/package failure belongs to Tiny3D.

A P3 Unreal/runtime/gameplay failure belongs to P3.

## Worker instruction

If told only **“go work on LowVRAM”**, read `AGENTS.md`, `START_HERE.md`, `docs/NORTH_STAR.md`, `docs/WORKER_ENTRYPOINT.md`, this file, and the current frozen production package. First repair/reconcile any stale queue/config surface that would violate current authority; then recover/reconcile sources and continue the real queue. Do not revive historical `512`, views9, or LowVRAM-rigging behavior simply because old scripts still contain it.
