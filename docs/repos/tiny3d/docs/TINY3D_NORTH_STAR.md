# Tiny3D North Star and Production Phases

Status: **AUTHORITATIVE PRODUCT DIRECTION + PHASE MAP**
Repository: `organicoverlords/tiny3d`
Current campaign: reusable generated-asset animation + dependable proof; newest-150 and P3 qualification remain the production acceptance set
Primary downstream consumer: `organicoverlords/p3`

## Product identity

Tiny3D is the single post-generation 3D asset product. Historical `TinyLab` naming survives only in durable schema IDs and provenance where changing it would destroy attribution; there is no separate TinyLab product.

The product boundary is:

```text
LowVRAM / other generators
  -> geometry + textures + provenance
  -> Tiny3D
       ingest + content identity
       analysis + classification
       compile / rig / animation / deformation preparation
       validation + portable packaging
       consumer handoff missions
       returned materialization/runtime proof
  -> P3 or another real downstream consumer
```

LowVRAM owns image-to-3D generation. Tiny3D never regenerates valid upstream geometry merely because a downstream contract failed. P3 owns Unreal/game materialization and runtime acceptance; Tiny3D records and verifies returned attribution without pretending that structural compiler evidence is gameplay proof.

## North-star outcome

Given a canonical source asset and unchanged Tiny3D configuration/code, Tiny3D should deterministically recover the same content identity, classification, applicable preparation contracts, verified reusable outputs, consumer handoff and strongest attributable proof state.

Normal production operation must be unattended and must not require an LLM or online reasoning service. Ambiguity is an explicit durable state such as `NEEDS_REVIEW`; it is never silently guessed. One ambiguous asset blocks only its own unsupported capability while unrelated assets continue.

The target is not "rig everything". The target is to choose the lightest correct runtime mechanism for each real asset: static, rigid transform, authored skeletal animation, procedural bones/control rig, swimming/flight/ground locomotion, secondary motion, cloth/deformation, foliage/material wind, mechanical articulation, VFX carrier, destruction qualification, or another evidence-backed contract.

Tiny3D must also improve the mechanisms themselves. Repeatedly retrying the same adapter, rigging recipe, deformation method or animation source after it has already failed is not progress. Hard asset families are explicit research-and-productization targets: Tiny3D should compare distinct plausible techniques, preserve what each attempt taught, promote better methods when evidence supports them, and retire approaches that repeatedly fail their intended assets. The library should therefore become more capable over time rather than merely processing more assets through an unchanged pipeline.

## Current animation priority: reusable authoring and dependable proof

The immediate Tiny3D focus is **easier rigging/animation for agents and stable, uniform, readable proof**, while preserving the existing generated library and completed work. The implementation design, researched options, history and acceptance matrix are in [Animation pipeline direction](ANIMATION_PIPELINE_DIRECTION.md).

An agent should submit one generated asset plus semantic motion intent, reuse or produce the appropriate rig and clips, receive a readable preview and an actionable first gap, repair only the failed stage, and pass the exact package into P3. No per-character Python script should be necessary for a second supported mesh using the same recipe.

**Source admission:** Fox is a stock asset and excluded from pipeline inputs, motion donors, active benchmarks, generated-asset inventory/qualification targets and fallbacks. Do not use it to satisfy a generated morphology gap. Preserve historical evidence and unique source files; missing genuine generated geometry remains an explicit gap. #373 owns correcting the current active benchmark/selector references.

### Product requirements missing from the earlier phase map

- **Agent-facing authoring:** versioned semantic recipes with body-plan controls, explicit contacts/root policy, clip/transition coverage, additive/secondary-motion composition, dry-run/status and precise repair feedback. Generalize the working #306 owner through #372; do not create another planner or registry.
- **Rig and export integrity:** separate control/deform rigs, verify scale/axes/rest pose/hierarchy/weights and disconnected attachments, bake supported constraints, and validate round-trip materials, skin and exact clips. Retarget source/target identities stay explicit.
- **Complete motion behavior:** required and optional actions, starts/stops/turns, contacts, transition windows and animation events; P3 owns actual gameplay and authoritative event handling. One successful clip or moving root is insufficient.
- **Physics and runtime cost:** role-specific collision/PhysicsAsset/constraint requirements, animation/secondary-motion budgets, LOD remapping and update-rate behavior. Measure actual consumer quality/cost; preparation metadata is not physics or gameplay proof.
- **Uniform evidence:** shared capture recipe and durable bundle conventions for offline previews, diagnostic playback and actual gameplay, while retaining their distinct proof scopes. Bind exact subject, clip/time, camera, readiness, engine/build and source/package identities.
- **Readable review:** cheap preview before final capture; full animated bounds, contact context and sufficient light/scale. Capture neutral/extrema/seams/transitions and continuous motion. Producer pixel inspection and independent final review remain mandatory under the existing proof contract.
- **Replay and recovery:** atomic completed bundles retain the exact package and raw evidence; relocated replay works without original absolute paths or expiring delivery URLs. Partial captures remain incomplete. Failed camera/review does not invalidate a valid rig.
- **Minimal recomputation:** source, rig, motion, quality, package, runtime and capture dependencies determine invalidation; unchanged verified outputs are reused. Failures name the stage, asset and next supported action.
- **Measured advancement:** baseline/after authoring edits, time to acceptable motion, cold/warm cost, RAM/VRAM, capture retries, independent-review outcome and replay success. Counts of issues or schema checks do not establish progress.
- **Feasible new technology:** compare morphology-aware deterministic methods first; evaluate pinned UniRig, SkinTokens, Make-It-Animatable or Puppeteer only against eligible generated assets and real hardware/software constraints. A model-paper result or model download is not local capability. No new online service is required for normal operation.

### Execution map

| Priority | Owner | Concrete next result |
| --- | --- | --- |
| First | #372 | Generalize successful #306 authoring into reusable semantic rig/motion recipes; two generated meshes share a recipe without code edits |
| First | #373 corpus correction | Remove stock Fox from active comparison and freeze eligible generated inputs; the distinct-technique benchmark follows after reusable-authoring/proof baselines are available |
| First | #13 and P3 #394 | Repeatable readable capture, interrupted-capture safety, complete retained/relocatable proof and exact result reuse |
| Next | #129, #127, #133 | Close real retarget/contact/motion/gameplay gaps using preserved rigs and source identities |
| Alongside applicable roles | #19, #11 | Secondary-motion layering, events, physics/LOD and consumer budget requirements |
| Alongside handoff return | #12 | Record exact returned Unreal materialization identities; rig/export round-trip integrity remains with #372 |

Avian cleanup and semantic-local weighting from #371/#374 are merged foundations on current main. Future avian changes must start from that result and the live adapter/file owner; #10 remains the required-P3-asset-catalog issue, while its avian comments are historical implementation evidence. Accepted #306 offline motion remains reusable; it is not P3 gameplay proof. Wyvern's existing generated rig/request remains reusable; Snailbeast source recovery stays in LowVRAM #122. The historical Android capture rejection calls for readable capture, not automatic rerigging.

These priorities refine the existing phase map; they do not restart completed foundations or replace P3 acceptance ownership. See the linked design for bounded contribution boundaries and proof criteria.

## Governing invariants

1. **Content identity is durable.** Equivalent content/provenance reuses verified work; different provenance is not silently attributed to an existing asset.
2. **Upstream is immutable.** Tiny3D consumes generator outputs and provenance but does not rewrite generator-owned source state.
3. **Evidence only strengthens explicitly.** Structural/compiler proof never becomes visual/runtime/gameplay proof by implication.
4. **Profile is not runtime role.** `static`, `avian`, and future compiler profiles describe preparation; P3 roles such as prop, creature, building, foliage, destructible or VFX describe consumer expectations.
5. **No universal mechanism.** Static assets remain static; creatures are not all avian; VFX meshes are not skeletal characters; foliage need not receive armatures.
6. **Reuse before recompute.** Valid verified outputs survive downstream failure and are not rerun unless source/compiler/config evidence requires refresh.
7. **P3 acceptance remains P3 truth.** Tiny3D may require and verify P3 result attribution, but cannot infer successful Unreal materialization, animation, collision, gameplay or visual quality without returned P3 evidence.
8. **Campaigns are reproducible.** Frozen selections remain immutable historical datasets; later campaigns add new selections rather than silently changing old membership.
9. **Failure must change the next attempt.** An unchanged failed technique is not retried indefinitely. Repeated failure requires a materially different adapter, rig, animation source, deformation technique, control strategy or explicit `NEEDS_REVIEW`/gap state, with diagnostics sufficient to explain why the next approach differs.
10. **Animation means intended motion coverage, not one successful clip.** For animated characters and creatures, Tiny3D should progress toward the complete motion set their role needs: idle, locomotion, starts/stops/turns, transitions, actions and role-specific modes such as takeoff, flight, glide, hover, landing, swimming or attacks when applicable.
11. **Ambient motion is product behavior.** Grass, leaves, branches, cloth, tails, tentacles, feathers and similar assets should receive convincing low-cost motion when their intended role calls for it. Foliage may use material/WPO wind, vertex masks, procedural deformation, bones, vertex animation or another evidence-backed method; skeletal rigging is not the default merely because animation is required.
12. **The library is a user-facing product catalogue.** Canonical identity and hashes are necessary but insufficient. Assets must become easy to inspect, find, compare, reuse, package and, where commercially intended, sell or license without reconstructing technical facts by hand.

## Learning and capability-expansion contract

Tiny3D is expected to discover better ways to prepare and animate assets, not only execute already-known adapters. This is especially important where earlier attempts have been brittle or visually weak.

Required behavior:

- when the same motion family fails repeatedly, branch into a genuinely different technique rather than tuning the same failing recipe indefinitely;
- preserve failure reason, attempted method, relevant source/morphology facts and resulting evidence so later work can learn from the attempt instead of rediscovering it;
- compare techniques on real representative assets and promote the simplest method that produces robust reusable results;
- allow multiple legitimate methods for one semantic family when morphology differs materially;
- treat flight as a family of problems rather than one "avian" recipe: winged flight, gliding, hovering, flapping, takeoff/landing, banking/turning and non-winged aerial creatures may need different rigs, procedural controls, authored clips or hybrids;
- actively explore better retargeting, rig generation, skinning, IK/control-rig, procedural motion, deformation and animation-source strategies when current methods fail quality or coverage;
- for vegetation and environmental assets, prefer scalable wind/secondary-motion approaches that can animate many instances cheaply while still producing believable grass, leaf and branch motion;
- convert successful experiments into reusable deterministic contracts, and remove or demote approaches that are consistently worse.

Research is not accepted merely because a new technique was tried. Progress means the experiment changes reusable product capability, closes a real asset gap, improves quality/cost/coverage, or produces decisive evidence that narrows the next approach.

## Library and catalogue product contract

The Tiny3D library must evolve from a content-addressed store into a production-quality asset catalogue. Every reusable asset should expose, when applicable and knowable:

- canonical identity, source lineage, generator/source provenance and version;
- human-readable name, category, tags, semantic role and searchable description;
- commercial/licensing state, provenance/clearance evidence, attribution requirements and usage restrictions;
- geometry facts such as dimensions, bounds, poly/triangle counts, topology notes, LOD availability and collision expectations;
- material/texture facts such as material slots, texture maps, resolution, transparency and known rendering requirements;
- rig/deformation facts such as skeleton profile, bone/skin status, blend shapes, cloth/secondary-motion support and known limitations;
- animation capability and inventory: exact clips/states, duration/loopability, locomotion/action/flight/swim coverage, transition compatibility and strongest proof state;
- variants and family relationships so distinct meshes, skins, LODs or semantic variants are not collapsed into one opaque asset;
- preview/thumbnail/render references sufficient for humans or downstream tooling to understand what the asset is without opening raw source files;
- package/export compatibility and downstream materialization/proof state;
- sale/listing-ready metadata where commercial distribution is intended, so storefront or catalogue integration does not require manually rediscovering asset facts later.

Inventory quality is itself an acceptance target: the system should be able to answer what assets exist, what each one is, what it can do, what evidence it has, whether it is commercially usable, what variants exist, and what is still missing.

## Phase map

Phases describe product progression and issue seeding. They are not permission gates: independent work can proceed whenever its actual technical dependencies are satisfied.

### T3D-00 — Product consolidation and deterministic foundation

Purpose: establish one Tiny3D product and preserve the useful historical compiler/library work without maintaining a separate TinyLab product.

Foundation already present on current main includes generator-descriptor normalization/provenance, content-addressed library behavior, static and avian portable profiles, deterministic package import/verification, batch reuse, P3 handoff/result attribution, release audit, ground locomotion preparation, rigid-vehicle contracts, jellyfish swimming preparation, mechanical articulation and destruction qualification.

Current disposition: **substantially complete foundation**. Historical schema names remain compatibility identifiers only. New product work belongs in Tiny3D.

### T3D-01 — Canonical production intake and classification

Purpose: make the current production dataset explicit, reproducible and actionable.

Current campaign:

- freeze exactly the newest 150 canonical production assets from evidence-backed recency;
- ingest them into the canonical Tiny3D library without duplicate payload lineages;
- classify every asset by runtime role, locomotion, secondary motion/deformation, intended runtime mechanism and proof requirement;
- preserve explicit ingestion failures and `NEEDS_REVIEW` states rather than substituting easier assets.

Current GitHub authority: issues **#16, #17, #18**.

Exit evidence:

- 150/150 frozen selection membership is reproducible;
- every selected asset has a canonical Tiny3D identity or explicit ingestion failure;
- every selected asset has a deterministic classification or explicit review state;
- rerun against unchanged source state is idempotent.

### T3D-02 — Runtime-capability preparation contracts

Purpose: close the adapter gaps revealed by the real production set rather than inventing speculative compiler families.

Adapter selection is coordinated through the hash-bound `tiny3d.animation-adapter-registry.v1` and `tiny3d.animation-adapter-selection.v1` contracts. Persisted morphology, motion-mode, capability, priority, and global attempt-limit fields determine a stable fallback order of distinct adapters. Failed attempts carry actionable diagnostics; unchanged terminal results suppress retry until source, semantic request, registry, adapter, or proof state changes. Selection and declared outputs never promote rendered or P3 runtime proof.

Current contract families include:

- walking/running/ground locomotion, including starts/stops/turns/transitions where the consumer role needs them;
- flying/gliding/hovering, including distinct takeoff/landing/banking/wing-beat or non-winged aerial strategies where morphology requires them;
- swimming/floating;
- cloth/fabric, tentacles/tails and feathers/wings;
- grass, leaf, branch and whole-plant wind/secondary motion using the cheapest robust mechanism appropriate to the asset rather than defaulting to a skeleton;
- rigid vehicle root motion;
- mechanical articulation;
- destruction qualification;
- VFX mesh carriers and downstream motion/effect expectations.

Adapter coverage is not a fixed checklist. If a representative asset exposes a failure that the current family cannot solve well, T3D-02 includes researching a materially different approach and productizing the better result. The existence of an adapter does not close the family while that adapter repeatedly produces faulty motion on the assets it is meant to support.

Current GitHub authority: issues **#19, #20, #22**, plus cross-phase reusable-authoring owner **#372** and generated-corpus/research owner **#373**. Merged contract work is represented by current main. Issue **#21** is the campaign-wide adapter/coverage burn-down view.

Exit evidence:

- every capability family actually present in the newest-150 set has either a reusable implemented Tiny3D contract or an explicit per-asset adapter gap;
- real representatives are used where the dataset contains that family;
- repeated failures demonstrate a changed technique or a justified terminal gap rather than another unchanged retry;
- flight and foliage/vegetation have representative coverage for the materially different motion modes present in the real library;
- Tiny3D preparation remains deterministic and does not claim downstream rendered motion.

### T3D-03 — P3 required-asset lifecycle and proof graph

Purpose: connect Tiny3D identities to the assets P3 actually needs and preserve proof through the complete consumer boundary.

Current work:

- derive required P3 3D assets from live runtime/V2 references;
- map each requirement to one canonical Tiny3D identity or evidence-backed exception;
- generate role-qualified P3 handoff missions;
- record exact Unreal materialization identities returned by P3;
- return attributable intended-runtime and rendered proof where the role requires it;
- expose strongest proof state and exact gaps through Tiny3D library/audit tooling.

Current GitHub authority: issues **#9, #10, #11, #12, #13, #14**. The current animation priority routes reusable authoring through **#372**, generated-corpus/method comparison through **#373**, and repeatable proof through **#13** without changing these phase owners.

Exit evidence:

- required P3 catalog is reproducible from current P3 evidence;
- handoff and result attribution are hash-bound to exact Tiny3D identities/packages/missions;
- materialization and runtime/visual proof states remain distinct;
- Tiny3D coverage can answer exactly what P3 requires, what is resolved, and what remains unproven.

### T3D-04 — Full production qualification campaign

Purpose: prove the product on the complete current campaign rather than on isolated fixtures.

Current GitHub authority: issue **#15** is the closure campaign, with **#21** as the adapter/coverage burn-down view.

Exit evidence:

- all newest-150 assets have terminal intake/classification states;
- every live P3-required external/generated asset has a closed contract state;
- each required contract family has representative end-to-end proof;
- player-visible required assets have attributable intended-runtime rendered proof where required;
- unresolved gaps are zero for the declared P3-required set, while non-required newest-150 assets retain explicit preparation/coverage states rather than being hidden.

### T3D-05 — Continuous incremental production operation

Purpose: turn the successful finite campaign into a sustainable production system.

After the first full campaign, Tiny3D must no longer depend on manually defining another one-off batch every time assets change. The system should detect evidence-backed new/changed canonical source assets, preserve prior frozen campaigns, compute the minimal affected work, reuse unchanged verified results, classify/prepare only changed identities, and refresh downstream P3 coverage only where the required contract changed.

Required behavior:

- new/changed/removed upstream assets are detected deterministically from canonical provenance and hashes;
- prior campaign manifests remain immutable historical evidence;
- incremental runs do not rescan/recompile/repackage unaffected valid assets unnecessarily;
- changed compiler/config identity invalidates only the evidence it actually affects;
- new `NEEDS_REVIEW` or adapter-gap states are surfaced without stopping unrelated work;
- recurring failure patterns feed adapter improvement work so continuous operation gets better rather than accumulating identical failed attempts;
- library inventory/catalogue metadata refreshes with changed assets and exposes missing commercial, technical, preview or animation metadata as explicit gaps;
- P3-required coverage refreshes when P3 references or selected Tiny3D identities change;
- normal operation remains unattended and LLM-free.

This phase must have a dedicated GitHub implementation issue before T3D-04 closure so the queue does not end at the first successful campaign.

### T3D-06 — Additional consumer contracts when real demand exists

Purpose: keep Tiny3D consumer-agnostic without speculatively building export frameworks.

P3 is the current acceptance authority and first real consumer. A second consumer-specific materialization/proof contract is created only when an actual downstream product needs it. Shared evidence/package contracts may then be generalized from demonstrated reuse.

Do not seed generic "support every engine" work before a real consumer exists.

## Roadmap and GitHub maintenance contract

The orchestrator owns continuity between this document and GitHub.

On every orchestration pass for Tiny3D:

1. inspect this North Star, current README/design plans, current main, open/merged PRs, issues/BUSY, newest campaign evidence and P3 contract state;
2. determine the actual current phase(s), strongest acceptance already proven and exact remaining gaps;
3. close issues only when their acceptance is genuinely proven; rewrite stale wording when product intent remains but the implementation/evidence contract changed;
4. close or supersede duplicate/obsolete issues and PRs; never keep dead queue items merely to preserve issue count;
5. keep enough independent, roadmap-backed issues available for the active worker fleet without manufacturing filler;
6. do not let the queue degenerate into repeated retries of the same animation technique: when evidence shows a recurring failure, seed a bounded alternative-method experiment or reusable capability improvement;
7. keep library/catalogue quality progressing alongside compiler coverage, including inventory completeness, search metadata, previews, variants, licensing/commercial fields and animation capability metadata;
8. before a phase queue empties, seed the next documented phase with bounded issues tied to product outcome, design authority and acceptance evidence;
9. if this document no longer describes the product implied by current user direction, research/design evidence or implementation truth, update the North Star first and then reseed GitHub from the new authority.

Issue counts, commit counts and PR throughput are operational signals, not product targets. A smaller queue with clear phase coverage is healthier than a large queue of duplicate or obsolete work.

## Current next action

Move Tiny3D from a mostly implemented compiler/library into an adaptive production asset system. Continue closing real campaign and P3 gaps, but prioritize work that increases reusable capability rather than repeatedly exercising a known-bad path. In particular:

1. turn recurring animation failures into alternative-method work, with flight as a high-value example: test materially different rigging/retargeting/procedural/hybrid approaches across different flying morphologies instead of assuming one avian solution;
2. make environmental motion first-class by proving scalable grass, leaf, branch and tree wind behavior on representative assets and productizing the cheapest robust method;
3. expand animated-role coverage from isolated clips toward complete intended motion sets and transitions where P3 or another real consumer needs them;
4. make the canonical library genuinely useful as an inventory and catalogue: searchable identity/category/tags, variants, previews, technical facts, animation capabilities, proof state, provenance, commercial clearance/licensing and sale/listing-ready metadata where applicable;
5. use failed experiments as durable input to the next method so the product demonstrably learns and improves instead of cycling through the same faulty preparation.

The finish line is not merely "150 assets processed" or "an adapter exists." It is a growing library whose assets are understandable, reusable, appropriately animated, commercially describable where intended, and backed by a preparation system that becomes better when reality exposes its mistakes.
