# P3 single-machine swarm

P3 has many logical workers but only three physical resource classes:

1. **Source lanes** are cheap Git worktrees with LFS pointers. They own branches and tests, not Unreal build products.
2. **Build capacity** is the existing persistent hot-source pool plus the single machine-wide build mutex. A worker submits a source checkpoint; it does not make another warm project copy.
3. **Editor/runtime capacity** is one reusable editor-class lane. It is the only ordinary lane allowed to hydrate Content, cook, stage, run PIE, or produce visual proof.

BusyCoordinator remains the ownership authority for task scopes. OS mutexes remain the crash-safe authority for physical build capacity. GitHub Actions keeps one integration cohort through its existing concurrency group. These are complementary; no new scheduler or state database is required.

## Admission and release

- `New-P3Lane.ps1` first reuses a clean, process-free, fully pushed, unclaimed lane. New source lanes are bounded; editor lanes default to one.
- Every disk-growing build, editor launch, or LFS hydration reserves its expected growth and must still leave 25 GB free. An unreadable disk probe refuses the growing operation.
- Before refusing a build or worker-owned editor launch, the wrapper runs the existing cache-only sweep. It can remove only cold, gitignored `Intermediate/Binaries` from lanes with no attributed process. It cannot remove Content, Saved evidence, dirty work, assets, branches, or whole worktrees.
- Build pressure is resource contention, not task failure. Workers continue source edits, focused tests, review, and integration work without allocating another Unreal workspace.
- When work lands or stops, its owner releases the exact BusyCoordinator scope. Clean fully pushed source lanes are recycled by the next worker; worker-owned runtimes retain their receipt and deadline reaper.

This follows Unreal's normal cache shape: derived data belongs in a managed local/shared DDC rather than being copied into every workspace, while compile concurrency is bounded independently from logical task concurrency. P3 already uses the local Zen DDC and the canonical UBT/UBA wrapper; this contract concentrates project-local state instead of introducing Horde or another service for one machine.

## LowVRAM and Tiny3D boundary

The asset pipeline fans in through data, not through shared processes or workspaces:

```text
LowVRAM producer manifest + immutable source hashes
    -> Tiny3D content identity, qualification mission and hash-bound handoff package
    -> P3 preflight in a source lane
    -> accepted package materialized once in the reusable editor lane
```

LowVRAM does not start P3 builds or editors. Tiny3D does not receive a hydrated P3 checkout. P3 verifies the declared package and mission hashes before materialization, binds reuse to the exact P3 commit and semantic target, and keeps runtime/visual PASS separate from producer or package PASS. A downstream rejection does not regenerate valid upstream geometry.

README timeline blocks in all three repositories are merge-stable links to `CHANGELOG.md`; changelog entries are not copied into README. This removes the shared generated hotspot that made unrelated concurrent PRs fail or conflict while retaining the substantive-change changelog gate.
