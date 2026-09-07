# Generator Descriptor Provenance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Tiny3D portable `static` and `avian` compile profiles accept `tinylab.generator-output.v1` descriptors without losing generator/material/texture/provenance identity, while preserving direct-mesh compatibility and deterministic reuse.

**Architecture:** Reuse `normalize_generator_input()` as the single descriptor boundary. Descriptor invocations derive profile-scoped asset IDs from normalized generator identity and embed `receipts/generator_input.json`; direct mesh invocations retain legacy source-hash identity. Directory and ZIP verification replay descriptor identity source-free, while batch preflight normalizes descriptors and locks/reuses by the same expected asset ID.

**Tech Stack:** Python 3.11-3.13, stdlib `unittest`, `uv`, trimesh test dependency, Tiny3D portable pack/ZIP verifier.

**Spec:** historical compiler issue #68, preserved in the merged Tiny3D Git history — Preserve generator descriptors and provenance through portable compile profiles.

## Global Constraints

- Portable compile profiles accept either a direct mesh path or a `tinylab.generator-output.v1` descriptor.
- Reuse existing generator normalization, hash verification, and path-safety checks.
- Generator-owned input files remain read-only.
- Static profile remains self-contained `.glb`, unskinned, and unanimated; descriptor-declared external texture payloads are rejected rather than dropped.
- Descriptor-derived reuse must not attribute another invocation's provenance or descriptor bytes.
- Batch manifests may name descriptors directly.
- Direct mesh callers retain existing asset identity and behavior.
- Canonical validation is `scripts/test-matrix.ps1` on Python 3.11, 3.12, and 3.13.

---

### Task 1: Portable descriptor evidence verification and static constraints

**Files:**
- Modify: `src/tiny3d/core.py`
- Modify: `src/tiny3d/static.py`
- Modify: `src/tiny3d/avian.py`
- Test: `tests/test_static.py`

**Interfaces:**
- Consumes: `normalize_generator_input()`, `portable_generator_input_evidence()`, `portable_generator_input_errors()`.
- Produces: source-free directory and ZIP verification of descriptor identity/provenance, with static external texture rejection.

- [x] **Step 1: Write failing tests** for static descriptor relocation/package round-trip, external texture rejection, and forged packaged provenance.
- [x] **Step 2: Run focused tests and confirm RED**: external textures currently compile, packaged provenance forgery is accepted.
- [x] **Step 3: Reject descriptor-declared external textures in `compile_static()`** with a precise error before any output is published.
- [x] **Step 4: Teach `verify_portable_pack()` to require/read `generator_input` when descriptor markers are present and call `portable_generator_input_errors()`; bind compile report input kind/identity to the receipt.
- [x] **Step 5: Apply the identical semantic checks inside `_verify_embedded_portable_pack()` so ZIP verification remains source-free and tamper-evident.
- [x] **Step 6: Run the focused static tests and confirm GREEN.**

### Task 2: Avian descriptor compile and exact reuse attribution

**Files:**
- Modify: `src/tiny3d/avian.py`
- Test: `tests/test_avian.py`

**Interfaces:**
- Consumes: normalized descriptor mesh, `portable_descriptor_asset_id("avian", identity_sha)`, generator evidence.
- Produces: avian pack whose `asset_id`, source `input_kind`, compile receipt, and `generator_input` evidence bind to the descriptor context.

- [x] **Step 1: Write failing avian descriptor compile test.**
- [x] **Step 2: Run it and confirm RED**: `.json` input is rejected before normalization.
- [x] **Step 3: Normalize the input in `compile_avian()` before format validation; keep direct mesh source-hash identity unchanged and derive descriptor identity when applicable.**
- [x] **Step 4: Extend `_compile_avian_candidate()` to write descriptor evidence and identity metadata, and to re-read descriptor context before publication to reject mid-compile mutation.**
- [x] **Step 5: Extend `_existing_pack_is_reusable()` with optional exact generator evidence matching so a semantically identical but byte-changed descriptor cannot reuse a receipt for different descriptor bytes.**
- [x] **Step 6: Run avian focused tests and existing reuse/transaction tests.**

### Task 3: Descriptor-aware batch preflight, race detection, and reuse

**Files:**
- Modify: `src/tiny3d/batch.py`
- Test: `tests/test_batch.py`

**Interfaces:**
- Consumes: manifest item source path (direct mesh or descriptor), normalized mesh SHA, optional generator evidence.
- Produces: expected asset ID identical to profile compiler identity and a per-ID lock/reuse decision that distinguishes provenance.

- [x] **Step 1: Write failing batch test using the same mesh with two different descriptor provenance records.**
- [x] **Step 2: Run it and confirm RED**: static preflight rejects descriptor `.json` paths.
- [x] **Step 3: Normalize every batch source during preflight; validate profile format against the normalized mesh and derive expected ID from descriptor identity when present.**
- [x] **Step 4: Re-normalize immediately before reuse/compile and compare mesh SHA, descriptor SHA, input kind, and expected ID to detect source/provenance changes after preflight.**
- [x] **Step 5: Pass the original manifest source (descriptor when supplied) to profile compilers and bind avian reuse to current generator evidence.**
- [x] **Step 6: Run batch focused tests and all existing resume/reuse tests.**

### Task 4: Acceptance, documentation, review, and integration

**Files:**
- Modify documentation only if existing CLI docs incorrectly state that portable compile accepts only direct meshes.
- Verify all source/test changes above.

**Interfaces:**
- Produces: validated issue #68 implementation ready for normal PR/merge workflow.

- [x] **Step 1: Add explicit compile-profile tests for descriptor hash mismatch/path traversal if existing generic normalization tests do not prove the compile entry points propagate those errors.**
- [x] **Step 2: Run focused unit suites for `test_static`, `test_avian`, `test_batch`, and pipeline descriptor tests.**
- [x] **Step 3: Run `git diff --check` and the full `scripts/test-matrix.ps1`.**
- [x] **Step 4: Review the complete diff against issue #68 and preserve inherited valid work.**
- [ ] **Step 5: Commit, push branch, open/update PR, merge after required checks, and verify `origin/main` contains the merge.**
- [ ] **Step 6: Release BUSY claim as DONE and update issue #68 with concrete verification evidence.**
