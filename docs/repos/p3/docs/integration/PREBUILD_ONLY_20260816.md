# PREBUILD ONLY gate — 2026-08-16

User directive: continue building/integrating as far as possible, but **do not start gameplay tests yet**.

## Allowed now

- source integration and conflict resolution;
- UE5.8 editor compilation/builds;
- Python/C++ syntax and static checks;
- deterministic editor/setup scripts;
- map/bootstrap/data preparation that does not enter PIE or simulate gameplay;
- asset/compiler/view-contract integration that does not launch GPU production renders unless separately required by its own active lane;
- preservation and reconciliation of Asylum Demon, birds, character, renderer and RTS/basebuilding work;
- documentation/receipts that make later acceptance one-command or minimal-step.

## Explicitly held

Do not enter PIE, Standalone, Simulate, automated gameplay-input dispatch, runtime traversal, tower-defense wave execution, resource-placement acceptance, combat acceptance, RTS camera acceptance, or other gameplay/runtime proof until the user explicitly releases this hold.

A successful source build is **BUILD_PROVEN**, not GAMEPLAY_PROVEN. Any runtime/visual claim remains at its previous proof state.

## Current target

Prebuild the Survival/RTS/Basebuilding/Tower Defense lane so that, when the hold is released, acceptance is reduced to a narrow owned-PIE proof pass rather than additional implementation work.
