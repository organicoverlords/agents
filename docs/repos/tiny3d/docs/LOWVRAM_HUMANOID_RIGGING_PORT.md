# LowVRAM humanoid rigging preservation

Issue #131 makes the existing LowVRAM humanoid rigging stack a deliberate Tiny3D input instead of disposable historical code.

The immutable source refs are recorded in `contracts/lowvram-humanoid-rigging-port-v1.json`. Exact source snapshots live under `vendor/lowvram_humanoid_rig/`; each capability records its original ref, commit, path, SHA-256, Git blob ID, Tiny3D ownership path, and disposition.

The CPU-only production policy is ported as `tiny3d.humanoid_rigging`. Humanoids retain the measured LowVRAM policy: MIA first, UniRig fallback, textured LOD0 preservation, no mandatory pre-rig segmentation, deformation QA before retarget/export, and all five deformation poses (`rest_pose`, `elbow_bend`, `knee_bend`, `hip_crouch`, `shoulder_raise`) required for promotion. Missing skin weights, lost materials, failed deformation poses, or a measured VRAM ceiling violation fail closed.

The preserved Blender rigger includes measured humanoid bone placement, UE5 naming, automatic-weight verification, geodesic surface weighting before proximity fallback, and the original animation authoring path. The preserved proof source includes the five-pose deformation/weight gate and the conservative stance/readiness utilities.

Tiny3D already supersedes the older LowVRAM research assetization seam for immutable asset identity, P3 handoff identity, and rendered proof gating through current `lineage.py`, `ground.py`, and `showcase.py`; those original research sources are still vendored so the transition remains auditable.

Run `uv run --locked --python 3.11 python scripts/verify_lowvram_humanoid_rigging_port.py` before changing humanoid rigging or animation ownership. This verification is structural/provenance evidence; it does not itself prove visual deformation quality or P3 runtime behavior.
