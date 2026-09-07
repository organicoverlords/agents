# Source Recovery and Queue Contract

Status: **AUTHORITATIVE LOWVRAM RECOVERY/INTAKE CONTRACT**

Source recovery is part of LowVRAM production. The goal is not merely to find files; it is to reconstruct a reversible, hash-backed source corpus that the generation queue can consume without losing provenance or regenerating valid work unnecessarily.

## Recovery principles

Never delete or destructively rename an original source as part of ordinary recovery. Preserve byte identity and original location before consolidation. Prefer hardlinks when source and library are on the same filesystem; otherwise copy. A canonical library path is an additional production reference, not permission to erase the original.

A recovered source record must retain at least:

```text
original_path
canonical_path
sha256
bytes
semantic_category
canonical_name
duplicate_of
priority
production_state
```

If classification is uncertain, use an explicit `uncategorized` or review state. Do not infer semantics from a parent directory or weak filename token when that creates a false category.

## Canonical naming

Canonical names should be concise, stable, lowercase, filesystem-safe, and descriptive only when the source provides enough evidence. Preserve meaningful source names. Strip transport noise such as duplicated download suffixes and obvious resolution/transparency packaging tokens when doing so cannot merge distinct subjects.

The SHA-256 is the durable dedupe key. Names are for humans and queue readability; names do not establish identity by themselves.

## Suggested semantic categories

Use the smallest useful category set rather than creating a taxonomy that workers cannot maintain:

```text
characters/human
characters/creatures
vehicles
props/objects
environment/architecture
environment/nature
vfx/reference
uncategorized
```

Add a more specific category only when a repeated production need justifies it.

## Priority model

Priority is about game value and unblock power, not image resolution or recency alone.

Use this ordering unless current P3 evidence gives a more specific need:

```text
P0  current P3 blocker / immediately required gameplay asset
P1  reusable environment, architecture, core creature/character, vehicle, gameplay prop
P2  useful secondary prop, foliage/nature, supporting set dressing
P3  decorative variant, speculative asset, redundant alternate
HOLD unclear source, duplicate decision, unsuitable framing, or insufficient evidence
```

Within a priority tier, prefer sources already suitable for the frozen input contract and sources whose generation can reuse existing valid outputs.

## Reconcile before regenerate

Before queueing a source for TRELLIS, search authoritative existing outputs and receipts by source hash, asset identity, and provenance. If a valid generated master already exists, reuse it and resume at the first missing downstream LowVRAM stage, normally visual QA or producer handoff.

A render, naming, metadata, Tiny3D, or P3 failure does not make valid geometry eligible for regeneration.

## Queue admission

A source is actionable when:

- the source bytes are preserved and hashable;
- the intended canonical source is unambiguous;
- the input satisfies or can deterministically satisfy the frozen conditioning contract;
- no current BUSY scope owns the same asset/output;
- the intended generation settings come from current authority rather than stale literals;
- queueing it will not start a second conflicting TRELLIS producer.

Queue entries must carry enough provenance to reconnect the generated output to the exact source record.

## Queue execution

The queue is resumable and stage-aware. For each asset, record the strongest completed stage and restart only from the first invalid or missing LowVRAM stage. Preserve partial evidence that remains valid.

The canonical single-asset entrypoint also enforces machine-wide exact-input single-flight across worktrees and worker sessions: concurrent duplicates share one execution, verified PASS artifacts are reused, and a failed flight permits a later fresh retry.

Normal stage order is:

```text
source preservation / provenance
  -> conditioning / matte
  -> frozen generation
  -> master geometry + textured deliverable + receipt
  -> output sanity checks
  -> mandatory 12-view render
  -> direct visual review for visual claims
  -> producer handoff to Tiny3D
```

Only one TRELLIS GPU producer may run at once unless current production authority explicitly changes that invariant. Rendering or CPU-side recovery work may proceed independently when it does not contend with the active producer or corrupt shared outputs.

## LowVRAM completion

An asset is complete at the LowVRAM boundary only when the exact source/provenance is retained, generation output is sane, the required master geometry is preserved, the textured deliverable exists, mandatory 12-view QA has completed, visual output has been directly inspected for any visual-quality claim, and a producer handoff names the exact artifacts for Tiny3D.

Rigging is not a LowVRAM completion requirement. Tiny3D owns rigging, skinning, animation, deformation, physics/destruction preparation, catalogue/library state, validation/package lifecycle, and downstream consumer missions. P3 owns game/runtime acceptance.

## Recovery work is never a reason to stop production globally

One missing or ambiguous source blocks only that asset. Record it as HOLD/needs-review, continue reconciling other sources, and keep the queue supplied with independent actionable work. The user should be asked only when an actual decision is required, not to perform file archaeology or routine recovery steps.
