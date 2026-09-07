# Easier animation and dependable proof

Date: 2026-09-07. Product design and implementation direction, not a claim that the proposed capabilities have shipped.
Authority: [Tiny3D North Star](TINY3D_NORTH_STAR.md). First consumer: P3.

## Outcome and priority

An agent supplies one eligible generated asset plus semantic motion intent, gets a reusable rig/motion package and readable preview, repairs the exact failed stage, and obtains attributable P3 proof without per-character scripting or repeated full-pipeline runs.

Priority order: reuse successful generated-character work; make authoring data-driven; fix capture readability/replay; prove complete motion and contacts; compare newer rigging methods on a bounded real corpus. Keep normal production unattended and independent of an LLM/online service.

## What already exists and what it taught

Reviewed Tiny3D main at 9f74c65a649e27e160192ccdec47b3532295beec, relevant issue/PR history and bounded Vault timeline. History is context; the source/receipt must be checked before reuse.

| Existing work | Preserve / lesson | Remaining work |
| --- | --- | --- |
| #198/#200/#201, adapter selection, body plans and benchmark | Deterministic fallback and bounded attempts already exist | Execute useful distinct techniques; do not build another selector |
| #130 animation-quality and repair owners | Contacts, loops, deformation, transitions and motion must be measured separately | Actionable region/clip/frame diagnostics and real repair execution |
| #306, merged #365/#366/#367 | Generated bird/Moth/Ethereal/Raincoat have accepted offline showcase evidence and reusable authoring code | Generalize recipes, preserve exact accepted variant identity; gameplay remains separate |
| #371/#374 avian cleanup and semantic-local weighting | Imported deformation links were cleared and generated weights constrained to semantic-local bones; the remaining birds still fail global deformation gates | Treat the merged result as the current avian baseline; route new avian edits through the live adapter/file owner rather than #10 catalog ownership |
| #129 repaired Android | Existing independent review rejected tiny, dark, unreadable framing despite numeric bone motion | Capture closer, readable deformation/contact through current P3 route; no needless rerig |
| #133 / #277/#279/#281/#291 Wyvern | Existing generated rig, offline QA and portable runtime request | Gameplay flight, physical landing and visible runtime quality |
| Snailbeast / LowVRAM #122 | Genuine source geometry recovery/regeneration belongs upstream | Source gap stays explicit; no reconstruction from static P3 assets |
| #13 / #325 / #326 | Missing media-byte verification was fixed; historical Birch replay lacked its original package | Preserve complete package plus capture bundle and remove operational capture failures |
| P3 #394 | Corrected mixed Birch/Raincoat job manifest already exists | Execute/reuse through the existing qualification owner and return real proof |

**Admission correction:** Fox is stock and excluded from all work in this direction: source inputs, motion donors, active benchmarks, inventories/qualification targets and fallback. #373 removes its two current active benchmark rows and checks the directly affected selectors. Preserve historical evidence; do not delete assets or rewrite old receipts to fabricate generated provenance. A generated quadruped is admitted only with real source identity; missing source remains a gap.

## Ownership and the agent workflow

| Boundary | Owner | Contract |
| --- | --- | --- |
| Generation/recovery | LowVRAM, on the main Windows PC | Immutable geometry/textures, source/job identity and provenance |
| Preparation and asset library | Tiny3D | Semantic recipe, rig/skin, baked clips, quality, packaging and proof projection |
| Consumer execution | P3 | Unreal materialization, IK/AnimBP/runtime physics, gameplay and actual capture |
| Review and reuse | Existing proof consumers / library | Verified bytes, explicit review scope and strongest attributable state |

Extend existing compile/author/status/repair/package/handoff surfaces rather than create another service. Desired interaction is one recipe submission, one compact result, and one supported next action if blocked. The implementation chooses compatible CLI syntax; this document does not invent an already-available command.

Recipe input must declare source/provenance, role and body plan, units/axes/rest pose, semantic regions and chains, required controls/clips/transitions, root policy, contact/event windows, secondary-motion policy and requested output/proof tier. Unknown anatomy or intended behavior is explicit review state. A filename is not anatomical evidence.

Separate the authoring control rig from the portable deform skeleton. Bake supported constraints and validate transforms after export. Reuse existing rig/clip identities first; then use morphology-specific rigging, region/geodesic binding, supported rigid attachments, contact-aware retargeting and IK correction. Body/head look, feet/stance, locomotion/turn, wing modes and appendage controls compose in a declared order. A successful head turn is not a locomotion set.

## Gaps the complete motion contract must close

| Concern | Required design / acceptance | Existing issue |
| --- | --- | --- |
| Rig suitability | Real anatomy/regions, scale, axes, rest pose, bone lengths/hierarchy, deform/control separation, influence limits and attachments | #372, #129, #133 |
| Skin robustness | Detect inherited armatures/weights, disconnected parts, loose clothing/appendages and severe collapse; preserve source topology/provenance | #372, #373 |
| Motion coverage | Explicit required and optional roles, starts/stops/turns/actions, loops and transition matrix; absent actions stay gaps | #127, #133, #20 |
| Contacts and root motion | Foot/hand/landing targets and windows, root extraction versus in-place policy, trajectory and IK residuals | #127, #129, #133 |
| Events and gameplay semantics | Footfall/action/contact events with timebase; P3 owns authoritative hit/gameplay decisions, not a generated clip | #11, P3 #394 |
| Layering | Base locomotion, look/aim, additive action and secondary motion with masks/order; avoid double-transform and duplicated root motion | #372, #19 |
| Retargeting | Source/target skeleton/pose and chain identities, scale policy, contacts and installed-engine API version | #129 |
| Physics handoff | Collision/PhysicsAsset requirements, constraints, bounds and ragdoll/recovery only for roles that need them; preparation is not runtime physics proof | #11, #19; #12 records exact returned materialization identities |
| Runtime budget | Bone/influence/texture limits, LOD/remapping, animation update rate and secondary-motion budget; demonstrate no severe popping/collapse on actual consumer | #11, #19, P3 #394 |
| Import/export fidelity | Round-trip material/texture, skin, axes/units, root, clip/events and bounding volumes; explicit unsupported features and versioned schema compatibility | #372; #12 verifies exact Unreal objects returned by the consumer |
| Capture and review | Stable target/readiness, readable subject/contact context, exact clips/times and raw media; independent visible-motion review | #13 |
| Incremental repair | Explicit source -> rig -> motion -> quality -> package -> runtime -> capture dependencies and smallest invalidation | #372, #13 |
| Rights and provenance | Generated-source admission; separate code/model/motion-source terms through existing clearance owner; no inferred sellability | #373, existing #216 owner |
| Failure/recovery | Typed source, adapter, quality, resource, capture and review gaps; resumable atomic outputs, bounded retries and retained diagnostics | #372, #13 |

These requirements apply when the role needs them; do not add physics, full motion sets or elaborate rigs to static props. Networking-specific gameplay behavior stays P3-owned and needs a real scenario before it becomes an asset requirement.

## Uniform capture and proof

One recipe and bundle convention spans three distinct purposes: cheap offline deformation preview, P3 diagnostic playback, and intended P3 gameplay. They are not interchangeable acceptance scopes.

Capture recipe binds source/rig/clip/package/mission, engine/build/runtime identity, exact actor/component, requested claim, FPS/timebase/frame windows, camera/lens/full animated bounds, lighting/exposure/background, render settings, readiness and warmup. Keep backend-specific settings explicit.

1. Validate identity and source/mesh/material readiness before capture; bind to the expected process and world. Readiness failure reports the stage and cause instead of blind sleeps.
2. Render a cheap preview. Inspect subject identity, scale, silhouette, exposure and feet/ground/appendage visibility; adjust camera before expensive capture.
3. Capture neutral reference, action extrema, contact windows, loop seam and transitions plus continuous motion. Clean frames and diagnostic overlays are separate.
4. Decode/check expected frames and hashes, then atomically publish the completed bundle. Partial/failed output never becomes complete by directory presence.
5. Producer inspects pixels and records findings; independent review alone awards final PROVEN under the existing contract. Motion metrics, hashes and camera movement do not replace inspection.
6. Retain exact package, raw sequence/video, derived contact sheet, frame-to-time mapping, quality/producer/independent review receipts and replay dependencies. Relative references must work after relocation. Expiring delivery links do not own retention.
7. Capture/framing failure reruns capture; retarget/contact failure reruns the affected motion stage; rig/skin failure invalidates its dependents. Keep unrelated assets and accepted upstream work.

P3 uses its current Invoke-P3VisualProofCapture.ps1, Get-P3VisualProofReviewPayload.ps1 and qualification executor. Extend those owners for observed gaps. MRQ/Movie Render Graph may provide diagnostic warmup/render presets behind that path; cinematic output does not establish gameplay execution.

## New technology: feasibility before adoption

Primary sources checked 2026-09-07; requirements can change. No model was installed or benchmarked in this design pass.

| Method | Why evaluate | Current disposition |
| --- | --- | --- |
| Existing deterministic rigs + contact-aware IK/retargeting | Fastest path to reusable controls with current QA and modest resources | First implementation priority; preserve successful generated derivatives |
| [Unreal scripted IK Retargeter](https://dev.epicgames.com/documentation/unreal-engine/using-python-to-create-and-edit-ik-retargeter-assets-in-unreal-engine) | Automate source/target rigs, chain maps and poses in the actual consumer | P3 integration candidate; verify installed-version API and contact quality |
| [UniRig](https://github.com/VAST-AI-Research/UniRig) | Diverse skeleton/skin proposals | Official generation minimum 8 GB VRAM; not established on main PC's 6 GB. Other hardware still requires CUDA/kernel compatibility proof |
| [SkinTokens / TokenRig](https://github.com/VAST-AI-Research/SkinTokens) | Newer unified skeleton plus skin-weight generation; existing-skeleton skinning option | Official inference minimum 14 GB; research-only until a compatible authorized surface exists |
| [Make-It-Animatable](https://github.com/jasongzy/Make-It-Animatable) | Humanoid rig/pose preparation alternative | Humanoid scope; local memory/platform fit unverified |
| [Puppeteer](https://github.com/Seed3D/Puppeteer) | Video-guided rig/animation optimization for difficult cases | Exploratory; inspect reproducibility, source-video rights, contacts and total cost |
| [MRG/MRQ warmup](https://dev.epicgames.com/community/learning/tutorials/l4OR/unreal-engine-movie-render-queue-warmup-and-first-frame-issues) | First-frame and diagnostic-render consistency | Compare only if it solves a specific existing capture defect |

Use #373 and the existing benchmark/adapter registry. Pin version, weights, dependency/device settings and seed; compare the same small generated corpus, motion request and camera against preserved baselines. Measure visible quality, contacts, deformation, transitions, manual edits, elapsed time, RAM/VRAM and output size. Report unsupported/OOM/rejected outcomes. Paper gains are not local gains.

Stochastic research outputs may become pinned approved artifacts for deterministic downstream reuse; no cross-device byte-determinism promise without evidence. Normal production must still work without online reasoning. Do not route LowVRAM generation elsewhere, provision cloud resources, or introduce outside agents as part of this design.

## Delivery order and measures

| Order | Deliverable | Evidence |
| --- | --- | --- |
| 1 | #373 eligible-corpus correction; #372 reuse #306 semantic authoring | Fox excluded from active comparison; exact generated identities; two meshes reuse one recipe without new per-asset Python |
| 2 | #13/P3 #394 readable repeatable capture and relocatable bundle | Bounded three consecutive captures, second morphology, interruption/wrong-target/static-motion negatives, retained package replay |
| 3 | #129/#127/#133 complete role motion and actual consumer behavior | Contacts/transitions and independently readable P3 scenario on the exact materialized generated asset |
| 4 | #373 distinct feasible technique comparison | Measured winner productized into existing adapter, or decisive rejection and next specific candidate |
| 5 | #19/#11 consumer cost and secondary-motion composition | Role-appropriate foliage/appendage/LOD/physics performance with visible quality retained |

Record baseline and after-results on the same inputs: time to first acceptable motion, per-asset manual edits, cold/warm stage time, peak RAM/VRAM, capture retries, first-pass independent-review result, required clip/transition coverage and full-bundle replay success. Unknown values stay unknown; targets are not measurements. Fixed-fixture CI checks determinism and correctness; hardware timings remain observed benchmark results rather than flaky unit-test gates.

Success means easier authoring and cheaper trustworthy proof on real generated assets. More scripts, schemas, issues, downloads or renders are not the outcome.
