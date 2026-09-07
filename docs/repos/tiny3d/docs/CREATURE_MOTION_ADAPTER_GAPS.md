# Creature motion adapter gaps

Tiny3D records unsupported production creature topologies as exact asset-bound gaps instead of silently compiling them as static meshes or borrowing an unrelated humanoid/avian preset. A gap is not motion proof: it names the real asset, the evidence that fixes its identity, the missing adapter, and the acceptance work still required.

## Snailbeast: serpentine/crawling

`snailbeast_trellis512_tex1024` is the first explicit serpentine/crawling gap for #133. Its production identity is no longer ambiguous:

- LowVRAM commit `9ef80934ce5d6c922c6c7df849770016d8b945eb` preserves the Snailbeast source preview, matte check, and two nine-view proof sheets.
- The preserved 960x1280 source preview is an exact resize of `creature_01_snail_house_beast_8k_sharp.jpg`, SHA-256 `8729881db78f04cbbb1094c8061f7f932e24fc7bac9b236d3cf714b5cb7c7aa1`: MAE 0.0, RMSE 0.0, exact-pixel fraction 1.0.
- P3 still contains five Snailbeast Git LFS objects: the static package, material, static mesh, and two textures. There are zero skeletal assets in that materialization.

The central adapter registry now marks `serpentine_crawling` as `PREPARATION_CONTRACT_ONLY`, not `MISSING`. Tiny3D has a materially different method for this morphology: `spline_body_wave_mesh_deformer`. It requires no invented skeleton. `idle`, `crawl`, `turn`, and `stop` use distinct low-energy settle, traveling-wave, curvature-biased turn, and damped-stop strategies while world translation, collision/grounding, and final tuning remain P3-owned. The preparation contract requires explicit deformable-body region evidence and explicit rigid-region masks when shell or other rigid regions are present.

This does **not** make Snailbeast implemented. No tracked/recoverable Snailbeast mesh exists in the preserved LowVRAM lineage, and the current machine evidence is source imagery plus historical static P3 materialization. Snailbeast therefore remains `STATIC_ONLY` with no Tiny3D asset identity. Its blockers are now precise: ingest a real mesh, bind deformable/rigid regions, materialize the deformer motion, prove rendered deformation/contact, and prove P3 gameplay crawl. Static fallback remains forbidden.

The deterministic producer handoff is generated with `uv run --locked --python 3.11 python scripts/prepare_creature_motion_adapter_requests.py`. For serpentine assets it requests a deformer-capable animated materialization rather than a skeletal asset, carries the exact gap-contract hash and source lineage, and keeps final adapter/runtime proof fail-closed. The generic preparation method is implemented in `src/tiny3d/serpentine_crawling.py`; it does not fabricate a Tiny3D mesh identity, semantic region masks, rendered proof, or runtime proof.

## Wyvern Saddled Rust: non-avian winged flight

`00_wyvern_saddled_rust` remains bound to the real LowVRAM static source SHA-256 `2d8b4a5715239de61ac832b13f0d75b79f53c0afa3e1240efb35aac1ef73508f` (8,328,732 bytes). Tiny3D now implements `nonavian_winged_flight` for that exact asset without borrowing the avian compiler: a `1e-6` TRELLIS seam weld converts 108,339 source vertices into one connected 69,514-vertex surface, followed by an asset-derived 21-bone draconic core/wing/tail/hindlimb rig with zero unweighted vertices and at most four influences per vertex.

The canonical Tiny3D GLB SHA-256 is `1a4440bb34f3e8aa43292b556ea9c36a67018adf392652c819c4fe17c752d9a7` (10,591,108 bytes) and reproduced byte-identically across two clean Blender 5.2 runs. `idle`, `fly`, `glide`, `turn`, and `land` all pass the `nonavian_flight_v1` numeric quality profile, and all six required transitions pass. A separate 24-capture front/side/three-quarter review passes catastrophic-tearing, wing-membrane-continuity, action-distinctness, and landing approach/settle visual checks.

This closes the Tiny3D adapter, skeletal-derivative, numeric-animation, and offline rendered-deformation gaps only. P3 still exposes the historical static-only materialization with zero skeletal assets; physical landing contact, P3 skeletal materialization, gameplay flight, and family acceptance remain **NOT_PROVEN**. Avian preservation remains reference-only and is not evidence for this non-avian morphology.

The producer-handoff command now emits only still-missing adapters such as Snailbeast. Wyvern is omitted because its Tiny3D adapter is implemented; `avian_adapter_substitution` remains forbidden and P3 runtime proof remains mandatory downstream.

For the implemented Wyvern derivative, `uv run --locked --python 3.11 python scripts/prepare_wyvern_p3_runtime_request.py --output <request.json>` emits the exact hash-bound P3 acceptance request. It requires the real skeletal mesh/skeleton/AnimBlueprint, all five materialized clip identities, gameplay-driven flight states, physical landing contact, and direct rendered gameplay capture; it does not mark any of those downstream gates proven.

Run `uv run --locked --python 3.11 python scripts/verify_creature_motion_adapter_gaps.py` before changing this contract.
