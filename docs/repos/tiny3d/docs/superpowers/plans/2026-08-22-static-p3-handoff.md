# Static P3 Handoff Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Extend Tiny3D's deterministic P3 handoff/result workflow to verified static portable packs without weakening the avian contract or implying rigging, animation, physics, destruction, or gameplay proof.

**Architecture:** Keep the existing source-free ZIP, package identity, and generic result-attribution layer. Branch only the profile-specific evidence/artifact/mission construction and verification: avian keeps its current FBX/rig/animation/physics compiler-quality contract; static requires canonical GLB plus static compile and portable-verification evidence and derives structured render-data, bounds, and material expectations from evidence replayed against the canonical GLB.

**Tech Stack:** Python 3.11-3.13, unittest, trimesh, deterministic ZIP/JSON contracts.

**Spec:** GitHub issue #70, `Support static portable packs in the P3 handoff/test contract`.

## Global Constraints

- Preserve all existing avian handoff mission checks and structured compiler-quality/physics verification.
- Static handoffs never require or claim FBX, skeleton, animation, physics, destruction, or gameplay proof.
- Every handoff/result remains bound to exact asset ID, profile, package SHA-256, and mission SHA-256.
- Static expected measurements must be derivable from compile/portable-verification evidence, not guessed.
- Full `scripts/test-matrix.ps1` must pass on Python 3.11, 3.12, and 3.13 before integration.

---

### Task 1: Static handoff and mission RED tests

**Files:**
- Modify: `tests/test_static.py`

**Interfaces:**
- Consumes: `compile_static()`, existing P3 handoff/result APIs.
- Produces: executable acceptance tests for static package, mission, PASS/FAIL attribution, and avian-only forgery rejection.

- [x] Add a real static fixture handoff test requiring only canonical GLB, static compile report, and portable verification.
- [x] Assert the mission check set is exactly import + static render-data + bounds + materials and contains no avian-only checks.
- [x] Add attributable PASS and valid FAIL result tests plus durable result recording.
- [x] Add a self-consistent forged ZIP test that injects an avian-only mission check and updates package hashes; verifier must reject semantics rather than only ZIP hashes.
- [x] Run focused tests and confirm RED on the current avian-only implementation.

### Task 2: Profile-specific P3 export contract

**Files:**
- Modify: `src/tiny3d/avian.py`

**Interfaces:**
- Consumes: verified portable pack, `STATIC_REPORT_SCHEMA`, `STATIC_VERIFICATION_SCHEMA`.
- Produces: deterministic static P3 handoff ZIP using the existing P3 schemas.

- [x] Add a static evidence helper that cross-checks compile and portable-verification mesh/material facts and emits stable structured mission expectations.
- [x] Make `export_p3_handoff()` accept `avian` and `static`, with profile-specific required artifacts and proof scope.
- [x] Keep the avian mission body unchanged apart from explicit profile binding if needed for shared verification.
- [x] Emit static required artifacts `canonical_glb`, `static_compile_report`, and `portable_verification`; emit only supported static checks.
- [x] Bind package manifest and handoff/mission profile to the actual pack profile.

### Task 3: Profile-specific handoff and result verification

**Files:**
- Modify: `src/tiny3d/avian.py`
- Test: `tests/test_static.py`, `tests/test_avian.py`

**Interfaces:**
- Produces: static-aware `verify_p3_handoff()`, `verify_p3_result()`, and `record_p3_result()`.

- [x] Verify packed asset/profile consistency for both supported profiles.
- [x] For static, replay static compile/portable-verification evidence, require exact static artifact/check bindings, and reject avian-only artifacts/checks/contracts.
- [x] Leave current avian compile/physics/compiler-quality checks intact.
- [x] Return/bind profile in result verification and reject result recording when handoff profile differs from the originating asset pack.
- [x] Run focused static and avian P3 tests until GREEN.

### Task 4: Full validation and integration

**Files:**
- Modify: `README.md` if CLI behavior needs documentation.

- [x] Run `uv run python -m compileall -q src tests`.
- [x] Run `git diff --check`.
- [x] Run `scripts/test-matrix.ps1` and require all 119+ tests on Python 3.11/3.12/3.13 to pass.
- [x] Review complete diff against issue #70 and verify no static proof overclaim and no avian regression.
- [ ] Commit, push private branch, create/merge private PR, verify tested commit/tree on `origin/main`, close #70, release BUSY DONE.
