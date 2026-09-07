# Tiny3D

Tiny3D is the single post-generation 3D asset product. LowVRAM produces geometry, textures and provenance; Tiny3D owns compilation, validation, adapters, packaging, lifecycle evidence, catalogue operations, and the asset library after that boundary. P3 is the downstream game/consumer.

`src/tiny3d/animation_adapters.py` provides the coordinator-only adapter selection contract. `scripts/select_animation_adapter.py` turns persisted adapter capabilities and a semantic motion request into a deterministic, hash-bound fallback plan of distinct adapters with an explicit global attempt ceiling. Adapter failures carry diagnostics, unchanged terminal results are not retried, and declared artifacts do not imply rendered or P3 runtime proof.
Authoritative product direction and phase progression live in [`docs/TINY3D_NORTH_STAR.md`](docs/TINY3D_NORTH_STAR.md). The README describes current capabilities; the North Star defines how those capabilities progress into the newest-150 campaign, P3 qualification, and continuous production.

## MVP vertical slice

Tiny3D currently performs a deterministic round trip:

1. ingest a direct mesh **or** a `tinylab.generator-output.v1` bundle from any generator;
2. content-address mesh + textures;
3. inspect real topology, bounds, components, watertightness and degenerates;
4. conservatively qualify requested capabilities without inventing semantics;
5. emit a generator-independent Unreal validation mission;
6. ingest the matching Unreal result and refuse PASS when required tests are missing or failed.

This is the seam future semantic segmentation, rigging/skinning, physics, destruction and animation adapters plug into. A downstream failure never implies regenerating valid upstream geometry.

## Generator boundary

Example generator output descriptor:

```json
{
  "schema": "tinylab.generator-output.v1",
  "generator": {"name": "lowvram3d", "version": "frozen-production"},
  "mesh": {"path": "asset.glb", "sha256": "optional-but-verified-if-present"},
  "textures": [
    {"semantic": "base_color", "path": "basecolor.png"}
  ],
  "provenance": {"job_id": "generator-owned-id"}
}
```

Tiny3D does not call back into the generator. Humanoid post-generation rigging is owned here: `src/tiny3d/workers/humanoid_blender.py` wraps the preserved LowVRAM rigging lineage without modifying it, floors seam welding, validates the prepared mesh, uses surface-geodesic binding plus deterministic rigid attachment for disconnected unweighted components, applies support-preserving upper-body smoothing, and normalizes the serialized GLB once after export. `evidence/issue130-android-humanoid-rig-repair.json` binds that route to the real LowVRAM-generated Angular Android source, exact neutral-bone-free artifact hash, and unchanged stress-deformation thresholds; exact regenerated visual deformation and P3 runtime acceptance remain separate proof gates.

## Run

Tiny3D is the canonical package, CLI, repository, and product name. Historical `tinylab.*.v1` schema IDs remain readable compatibility identifiers so existing durable artifacts do not lose attribution; they do not name a separate product.

```bash
python -m pip install -e .
tiny3d run output.json --workspace ./work --intent rig --intent destructible
tiny3d run output.json --workspace ./work --resource-observations
tiny3d verify-run ./work/<asset-id>
tiny3d status ./work/<asset-id>
tiny3d accept-result ./work/<asset-id> unreal-result.json
```

`--resource-observations` adds machine-readable elapsed-time and Python traced-heap peak observations for compile stages that actually execute. These values are informational only: Tiny3D regression acceptance uses bounded I/O, cache reuse, and concurrency contracts rather than hardware-sensitive wall-clock thresholds.

Portable compiler profiles are explicit. Both `static` and `avian` accept either a direct mesh path or a `tinylab.generator-output.v1` descriptor; descriptor inputs are normalized and hash/path-checked before compilation, and generator/material/texture/provenance context is retained as portable evidence. `static` preserves the normalized self-contained GLB byte-for-byte and adds deterministic Tiny3D integrity/engine-validation evidence without inventing rigging, animation, or physics. `avian` is the semantic rigged/animated compiler and uses Blender 5.x.

```bash
tiny3d compile prop.glb --workspace ./work --profile static
tiny3d verify-pack ./work/<static-asset-id>
tiny3d request-unreal-pack ./work/<static-asset-id>
tiny3d package ./work/<static-asset-id> --output ./dist/prop.zip
tiny3d verify-package ./dist/prop.zip
tiny3d import-package ./dist/prop.zip --workspace ./work
tiny3d library list --workspace ./work
tiny3d library search prop --workspace ./work --profile static --usable-only
tiny3d library show <static-asset-id> --workspace ./work
tiny3d unpack-package ./dist/prop.zip --output ./imported/prop
```

Static asset IDs are profile-specific, so the same source content can coexist with the legacy avian content identity. A direct static input must be `.glb`; a generator descriptor is also accepted when its normalized mesh is a self-contained `.glb` and it does not declare external texture payloads that the byte-preserving static pack cannot carry. Static compilation performs no Blender work and rejects external dependencies, skinned inputs, or animated inputs instead of silently downgrading them.

The deterministic avian profile remains the body-plan compiler for semantic rigging, skinning, animation, and neutral physics preparation:

```bash
tiny3d compile bird.glb --workspace ./work --profile avian
tiny3d prepare-physics ./work/<asset-id>
tiny3d verify-pack ./work/<asset-id>
tiny3d request-unreal-pack ./work/<asset-id>
tiny3d package ./work/<asset-id> --output ./dist/bird.zip
tiny3d verify-package ./dist/bird.zip
tiny3d import-package ./dist/bird.zip --workspace ./work
tiny3d unpack-package ./dist/bird.zip --output ./imported/bird
tiny3d p3-handoff ./work/<asset-id> --output ./dist/bird-p3.zip
tiny3d verify-p3-handoff ./dist/bird-p3.zip
tiny3d verify-p3-result ./dist/bird-p3.zip ./dist/bird-p3-result.json
tiny3d accept-p3-result ./work/<asset-id> ./dist/bird-p3.zip ./dist/bird-p3-result.json
tiny3d audit ./work/<asset-id> --p3-package ./dist/bird-p3.zip --p3-result ./dist/bird-p3-result.json --output ./dist/bird-audit.json
```

Finite production batches reuse the same content-addressed single-asset compiler and remain resumable after partial failure or interruption:

```json
{
  "schema": "tinylab.batch-compile-manifest.v1",
  "profile": "avian",
  "config": {"concurrency": 2},
  "assets": [
    {"id": "eagle", "source": "inputs/eagle.glb"},
    {"id": "macaw", "source": "inputs/macaw.glb"}
  ]
}
```

```bash
tiny3d batch batch.json --workspace ./work
```

Batch manifests accept `profile: "avian"` or `profile: "static"`, and each asset `source` may be either a direct mesh path or a `tinylab.generator-output.v1` descriptor. Static batch items still normalize to self-contained GLB payloads and do not accept Blender configuration. Descriptor identity participates in preflight, locking, reuse, and race detection, so identical mesh bytes with different generator provenance are not misattributed. Concurrency defaults to 1 and is bounded to 4. Each item writes an independent receipt under `work/batches/<batch-id>/receipts/`; reruns re-verify and reuse valid completed outputs while retrying failed or incomplete items.

The avian profile derives semantic body regions from geometry, builds a portable armature and constrained skin, authors idle/spread/flap/glide clips, derives deterministic bone-aligned collision capsules, topology-relative semantic mass weights, and detachable wing/tail break seams, exports canonical GLB plus an FBX derivative, and writes machine-readable compile/verification receipts. `prepare-physics` can add that engine-neutral physics/destruction preparation to an existing avian pack without rerunning Blender; engine adapters remain responsible for engine-specific mass units and break thresholds. Valid content-addressed outputs are reused on repeat runs instead of re-running Blender. `verify-pack` independently rechecks the artifact/evidence contract required by each concrete profile after a pack is copied, moved, or archived; portable artifacts and evidence must remain inside the pack, while the original upstream source path/hash is provenance-only and cannot invalidate an otherwise intact relocated pack.
Avian reuse is also compiler-current: each successful compile records an automatic fingerprint of the Tiny3D avian-producing code/Blender worker plus the actual Blender version/build identity. A repeat compile reuses the source-hash asset only when those identities still match. Older avian packs without this identity remain valid portable artifacts, but a new compile request refreshes them instead of silently treating output from an older compiler as current. Avian refreshes and missing-physics upgrades are built and fully verified in a sibling staging directory before publication; replacing an existing canonical pack uses a same-filesystem rename transaction that preserves the prior pack in a temporary sibling backup and restores it if the staged publication fails. The canonical pack is therefore not modified by compiler, staged-verification, or handled publication failures. Static byte-preservation packs do not use this avian toolchain invalidation or refresh path.
`request-unreal-pack` then analyzes the verified canonical GLB and emits the same deterministic Unreal import/skeleton/animation validation contract used by the generic pipeline, without depending on P3 or rewriting the portable pack. The request explicitly delegates runtime execution to the downstream consumer canonical verifier and forbids worker-owned GUI proof; if no designated executor exists, runtime proof stays pending rather than spawning a one-off Tiny3D renderer. When deterministic physics preparation is present, the mission is hash-bound to that receipt and carries expected PhysicsAsset body bones/count plus detachable-constraint bones/count so the consumer verifier can check materialization against the neutral compiler contract. `package` produces a deterministic relocatable ZIP containing only the portable artifacts and machine-readable evidence (never the upstream generator source); `verify-package` checks declared membership, sizes and SHA-256 hashes, then deep-replays the embedded static or avian pack contract directly from archive members. Its JSON separates `package_errors` from `embedded_pack` semantic/evidence errors, and large GLB/FBX members remain stream-hashed rather than buffered whole. `import-package` installs a verified ZIP into `<workspace>/<canonical-asset-id>`, deriving and checking that ID from the profile/content hash rather than trusting an archive-chosen directory name. Re-import reuses an equivalent verified pack without rewriting it, conflicting existing content is rejected untouched, publication uses same-filesystem staging, and deterministic source-free package provenance is recorded under `.tiny3d/imports/<asset-id>/<package-sha256>.json`. `p3-handoff` produces a separate deterministic, source-free proof/test ZIP with a profile-specific P3-owned mission contract. Avian handoffs carry canonical GLB, FBX, physics preparation, and existing rig/animation/compiler-quality checks; static handoffs carry canonical GLB plus static compile/portable-verification evidence and only evidence-backed import, render-data, finite-bounds, and material checks. `verify-p3-handoff` checks declared membership, hashes, schemas, profile-specific artifact/check bindings, and rejects avian-only claims in static missions without extraction. P3 can return a `tinylab.p3-test-result.v1` JSON containing the package SHA-256, mission SHA-256, executor, and one result for every required check; `verify-p3-result` distinguishes invalid attribution from a valid run whose checks failed or were skipped. `accept-p3-result` stores that verification and the returned result at `receipts/p3_test_result.json` beside the originating asset without changing the content-addressed pack or pretending to prove gameplay. The handoff and result checks prove Tiny3D preparation, transfer integrity, and declared result attribution, not independent P3 gameplay acceptance, runtime physics behavior, subjective visual quality, or shipping readiness. `unpack-package` remains the explicit caller-chosen extraction path: it verifies first, extracts into a transient sibling staging directory, re-verifies the materialized pack, and atomically publishes it only to a destination that did not already exist. Package member names are also constrained to a cross-platform-safe namespace: no case-fold collisions, Windows reserved names, trailing dots/spaces, alternate separators, control characters, or drive/ADS colon syntax.
`library list/search/show` treats those canonical workspace directories as the asset library rather than copying payloads into another store. Library records expose static/avian profile, source/display name when present, portable artifacts, compile/import provenance, integrity state, Unreal state, headless preview metadata, and the existing package/status/Unreal actions. Invalid content-addressed directories remain visible diagnostics but are never marked usable. The index cache lives under `.tiny3d/library/index-v1.json`: unchanged entries are reused from file size/mtime signatures so listing does not re-hash large GLB/FBX payloads; changed metadata triggers the existing portable-pack verifier, while `library show` always forces current verification. Indexing never launches a renderer. `tiny3d library preview <asset-id> --workspace <library>` is the explicit approved headless preview producer: it deep-verifies the exact asset, renders its SHA-bound GLB/glTF through Blender 5.x in background/windowless mode, writes `preview/thumbnail.png` plus `receipts/library_preview.json`, and the library/catalogue exposes the thumbnail only while both artifact identity and PNG hash still match. Until that command succeeds, preview remains `not_generated_headless`.
`audit` is the release gate: it replays the generic pipeline or portable-pack verifier, optionally verifies the P3 handoff and result, reconciles asset identities, and emits one machine-readable PASS/FAIL report. Missing optional P3 evidence is a warning; supplied but invalid evidence is blocking. The audit is intentionally bounded and never upgrades a structural or declared check into visual, runtime, gameplay, or shipping proof.
Engine acceptance receipts are bound to the exact Unreal request and stored result receipt; `status` also replays the bound result decision and rejects a tampered acceptance status/reason set, so later request/evidence/result/decision drift cannot remain visible as current acceptance.

Important outputs:

```text
manifest.json
receipts/mesh_analysis.json
receipts/capability_qualification.json
requests/unreal_validation.json
receipts/unreal_validation_result.json   # after engine response
receipts/acceptance.json                 # after engine response
receipts/p3_test_result.json             # after P3 result recording
release-audit.json                       # optional --output report
```

## Intended architecture

```text
LowVRAM / another generator
   mesh + textures + provenance
                |
                v
             Tiny3D
 ingest -> geometry analysis -> semantic parts -> rig/skin
       -> physics/destruction -> animation/capability compile
       -> Unreal validation mission -> consumer canonical verifier -> package
                |
                v
      optional real-game acceptance (P3, etc.)
```

Production/runtime behavior must not require an LLM or online reasoning service. Learned models may be optional offline compiler adapters; their outputs still go through deterministic contracts and validation.
## Asset library

The asset library is a Tiny3D subsystem, not a separate product. The external content store lives at `C:\Users\Lauri\Desktop\Tiny3D_LIBRARY` and is keyed by content identity; binaries remain outside Git while this repository owns the compiler, catalogue, lifecycle contracts, tests, and operational tooling.

`python scripts/audit_library.py` validates index/directory identity, summarizes compile/verification/secondary-motion/VFX coverage, discovers upstream LowVRAM GLBs not already referenced by the library, and deterministically selects newest primary candidates. `scripts/index_compiled_asset.py` indexes already-verified Tiny3D asset directories after rechecking source hashes and structural evidence.

## Newest-150 production campaign

`scripts/report_newest150_adapter_coverage.py` joins the frozen selection/classification with the current asset-library index and adapter registry. `scripts/query_newest150_adapter_coverage.py` browses the saved deterministic report without rerunning expensive work. `scripts/promote_newest150_recovery.py` performs validated recovery promotion. `scripts/prepare_vfx_mesh_contracts.py` writes hash-bound Niagara mesh contracts for classified VFX carriers while leaving runtime timing, scale, spawn count, and material overrides explicit rather than guessed.

Prepared VFX contracts can be bound directly into the normal static P3 proof handoff with `tiny3d p3-handoff <static-pack> --output <proof.zip> --vfx-mesh-contract <vfx_mesh_contract.json>`. The package embeds and re-verifies the hash-bound VFX contract and adds a `vfx_runtime_motion` visual-motion check; static import/render-data/material PASS results cannot satisfy that check without rendered capture evidence.

`scripts/prepare_ground_locomotion_contract.py` prepares the bounded humanoid route for a classified newest-150 `ground_creature_or_character`. It rehashes the frozen source, binds the LowVRAM rig producer revision/script/recipe and derivative hashes, and requires TinyLab structural evidence for skinning, measured joints, and a discoverable `walk_loop`. Rendered deformation, Unreal skeletal import acceptance, and gameplay locomotion remain explicitly `NOT_PROVEN`; mechanical walkers and unsupported morphologies remain separate routes.

`scripts/prepare_flight_locomotion_contract.py` prepares the bounded flight route for classified `flying_creature` and `flying_ground_creature` assets. It binds the route to verified Tiny3D source, mesh-analysis and Unreal-request evidence, preserves every classified flight mode, and declares the required `idle`, mode-specific, `turn`, and `land` action roles. Rig production, rendered deformation, Unreal import acceptance, runtime tuning and gameplay flight remain explicitly `NOT_PROVEN`.

`scripts/generate_p3_qualification_jobs.py` reconciles a live P3 required-asset catalog into hash-bound qualification jobs. When a catalog omits a Tiny3D identity, an optional `tiny3d.p3-identity-resolution.v1` map may supply only an explicitly `verified` one-to-one mapping; unresolved or unverified identities remain gaps, and identity resolution does not imply P3 materialization or runtime proof.

`scripts/resolve_p3_asset_identities.py` produces that map from an explicit P3-to-source candidate manifest. It rehashes each declared source, requires a hash-bound visual-review receipt, runs `scripts/inspect_p3_asset_geometry.py` to reject large planar bottom surfaces, checks the matching content-addressed library entry is usable and `TINY3D_VERIFIED` with positive material/image evidence, and rejects missing, duplicate, reused, or ambiguous candidates instead of guessing from display names.

`scripts/project_p3_coverage.py` projects the required catalog onto an existing Tiny3D library index and its lifecycle receipts without rescanning binaries. It emits explicit `LIBRARY_IDENTIFIED`, `TINY3D_COMPILED`, `TINY3D_VERIFIED`, `P3_HANDOFF_VERIFIED`, `P3_MATERIALIZED`, `P3_RUNTIME_PROVEN`, `P3_FAILED`, `UNRESOLVED`, and `NOT_APPLICABLE` states plus per-asset gaps. `scripts/query_p3_coverage.py` provides deterministic list/search/show filters over the saved projection; neither command promotes weaker evidence into runtime proof.

The campaign data, compiler profiles, adapter implementation, library records, P3 handoff contracts, and validation receipts all belong to this Tiny3D repository and product.

For T3D-05 incremental operation, `tiny3d plan-refresh <previous-inventory.json> <current-inventory.json>` emits a deterministic minimal-work plan. Unchanged content/provenance emits no work and reuses its Tiny3D identity; content or provenance changes restart at ingest, semantic-only changes restart at classification, and optional stage dependency identities invalidate only the changed stage and its downstream evidence. Frozen input inventories are read-only; the plan is a separate receipt.

`tiny3d snapshot-sources <authoritative-manifest.json> --previous <prior-inventory-or-selection.json> --output <inventory.json>` builds the manifest-authoritative source inventory consumed by that planner. It does not scan arbitrary output folders. Existing path/size/mtime signatures reuse durable hashes and Tiny3D identities; only changed candidates with a prior content hash are re-hashed, while new or missing sources become explicit per-asset states. Repeating an unchanged manifest/source state produces the same `inventory_id` and zero planned work.

`tiny3d ingest-manifest <producer-manifest.json> --workspace <library>` is the durable producer boundary. It accepts the versioned Tiny3D producer contract and the current LowVRAM 401 manifest, validates every referenced mesh/texture hash, preserves producer/job/provenance/upstream QA evidence, detects verified library reuse and semantic conflicts, and writes a hash-bound intake receipt plus planner-compatible inventory under `<library>/.tiny3d/intake/`. Intake accepts valid records without copying upstream payloads; downstream compilation remains explicit scheduled work.

`tiny3d snapshot-dependencies --output <dependencies.json>` hashes the checked-in `data/incremental-dependency-map-v1.json` stage ownership contract into planner-compatible dependency identities. Stage evidence lists the exact repository-relative files, byte sizes, SHA-256 hashes and ownership policy behind each identity. Shared monolithic modules are deliberately assigned to the earliest stage they can affect, so invalidation is conservative rather than falsely precise; stage-specific files still invalidate only that stage and downstream work.

`tiny3d refresh <previous-inventory.json> <current-manifest.json> --workspace <workspace>` composes source discovery, automatic current dependency capture, minimal refresh planning, and an optional P3 coverage projection delta into one durable receipt under `<workspace>/.tiny3d/refresh/`. It preserves prior inventories, reports added/changed/removed/unchanged source identities, and schedules P3 coverage only when the selected Tiny3D identity or required P3 contract changes.

`tiny3d continuous-refresh <current-manifest.json> --workspace <workspace>` runs the same planner from `<workspace>/.tiny3d/refresh/latest.json`, so restartable cycles do not require hand-authored prior paths. Each source manifest, optional `--current-intake` receipt/inventory, and P3 coverage input is copied once into a hash-addressed immutable snapshot; the latest pointer and run receipt preserve the exact state chain. Receipts expose source and P3 gap rows, including `NEEDS_REVIEW`, adapter gaps, materialization gaps, and runtime-proof gaps. `refresh-cycle` is an alias.

`tiny3d continuous-production <current-manifest.json> --workspace <workspace> [--current-coverage <coverage.json>]` advances the refresh plan into per-identity execution. It executes only identities that are new, changed, invalidated, or retryable; verified unchanged identities are reused without recompilation, failed identities retry independently up to `--max-attempts`, and newly completed identities emit durable P3 qualification candidates in the same cycle. Candidates are not dispatchable P3 jobs: the existing canonical `tiny3d.p3-qualification-jobs.v1` generator remains the sole job authority once hash-bound handoff/package and mission evidence exist. Pass the saved production cycle to `scripts/generate_p3_qualification_jobs.py generate --production-cycle <cycle.json>` to scope canonical job generation to only READY changed identities; an unchanged/empty cycle emits zero P3 work, blocked candidates remain local gaps, and non-required identities never enter the required P3 catalog. Artifact-quality preflight checks structural/material/UV/texture evidence and obvious support/base geometry only; it is not rendered visual proof. Player-visible P3 acceptance still requires the downstream worker-owned runtime capture path and attributable screenshot/video evidence.

`tiny3d production-status --workspace <workspace>` (alias `production-heartbeat`) reads only durable production/refresh metadata and reports the current cycle/state IDs, added/changed/removed/unchanged counts, Tiny3D execution and P3 qualification backlog counts, P3 materialization/runtime-proof gaps, the oldest pending identity, and the last successful advancement. It does not open or rehash source asset payloads; an unchanged cycle reports `state=IDLE` while any downstream P3 backlog remains explicit.

## Humanoid retarget contracts

`src/tiny3d/humanoid_retarget.py` defines the deterministic humanoid skeleton/retarget contract used by the preserved LowVRAM rig path. It records source and target skeleton identities, unit scale, signed forward/up axes, bind/reference pose, root orientation, canonical logical hierarchy, physical bone lengths, exact bone-name mapping, optional UE-style IK/helper parity, root-motion policy, and explicit tolerances. Missing, duplicate, orphaned, cyclic, zero-length, axis-flipped, grossly mis-scaled, or helper-incompatible skeletons fail closed instead of silently remapping.

`scripts/normalize_asylum_production_skeleton.py` now binds the real Goblin source skeleton to the P3 Asylum production humanoid map and emits hash-bound GLB/FBX plus the retarget contract. `scripts/verify_humanoid_retarget_glb.py` independently compares mapped animation tracks, interpolation, key times, and transform values. `evidence/issue129-goblin-retarget-glb-proof.json` proves the current Goblin `idle` and `walk_loop` preserve all 60 mapped tracks with zero key-time drift and at most `5.14e-6` transform-value error; a clean Blender regeneration reproduced the exact target GLB SHA-256. This is deterministic asset/animation retarget evidence only: P3 materialization and live gameplay playback remain `NOT_PROVEN` until returned by the downstream runtime proof path.

## Skeletal animation quality receipts

`src/tiny3d/animation_quality.py`, `contracts/animation-quality-profiles-v1.json`, and `scripts/measure_glb_animation_quality.py` turn animated GLBs into deterministic, hash-bound quality receipts. Numeric gates cover loop endpoint seams, in-place root drift, nontrivial moving-joint coverage, declared transition continuity, sampled skin-deformation prevalence, joint segment/step stability, bind-relative severe self-intersection introduced by animation, shared-ground contact spread, foot penetration/floating, morphology-aware compensated stance residuals for foot-slide/plant stability, and explicit interaction contact-target drift against persisted effector/anchor/frame/FPS/target declarations. Self-intersection sampling is deterministic and bounded by the profile, excludes geometric seam adjacency and non-strict boundary/coplanar contact, and measures only sampled faces newly crossing versus bind pose. Malformed booleans, thresholds, sampling policy, duplicate transitions, missing joints, ambiguous roots, absent declared clips, malformed contact-target declarations, unresolved target nodes, out-of-range target windows, or missing stance coverage fail closed. Numeric `PASS` still does not prove rendered visual deformation acceptance; that remains `NOT_PROVEN` until attributable rendered evidence is supplied.

`src/tiny3d/animation_runtime_binding.py` is the shared source-side policy for P3 animation bindings. The qualifier and returned-runtime verifier consume one canonical list of exact assets, states, gameplay inputs, action requests, required captures, receipt schema, and timer prohibition; missing, extra, reordered, or weakened policy fields fail closed. This contract describes intended bindings and attribution only: actual P3 materialization, gameplay transitions, and runtime proof remain downstream-owned.

`src/tiny3d/animation_repair.py` and `scripts/plan_animation_repair.py` turn those measured failures into a deterministic, bounded adapter policy. Each failed gate maps to an ordered repair strategy, and each action is keyed by the exact source hash, quality receipt, parent artifact/compiler identities, scope, and repair configuration. Persisting the attempt key prevents regenerating an unchanged failing input with the same policy; a later plan consumes completed keys and advances only to the next bounded alternative. Attempt receipts record exact `field`/`before`/`after` changes, preserve the parent identities, and bind any re-evaluation to the parent or declared output hash. Missing strategies and exhausted attempts become actionable `GAP` rows. Deferred rendered/runtime proof remains `PENDING` with a `do_not_rerun_until_relevant_state_change` policy and is never promoted by numeric repair.

## Multi-morphology animation benchmark corpus

`contracts/animation-benchmark-manifest-v1.json` is the frozen, hash-bound corpus for fox quadruped, eagle avian, humanoid, jellyfish tentacled, Snailbeast serpentine, and wyvern winged animation coverage. `src/tiny3d/animation_benchmark.py` validates source/evidence hashes, expected capabilities, motion roles, known-bad fixtures, and the distinct `FAST_DETERMINISTIC`, `EXPENSIVE_RENDERED`, and `P3_RUNTIME` proof tiers. Checked-in source absence remains an explicit gap; it cannot be promoted to PASS. Results bind manifest, revision, compiler, adapter, and proof configuration identities, skip identical attempts, and compare revisions without erasing lower-level PASS evidence when rendered or P3 proof is pending. Validate the corpus with `uv run --locked --python 3.11 python scripts/validate_animation_benchmark.py`.

`src/tiny3d/nonavian_winged.py` and `src/tiny3d/workers/nonavian_winged_blender.py` implement the real Wyvern Saddled Rust non-avian flight adapter against its exact LowVRAM source. The reproducible 21-bone derivative provides `idle`/`fly`/`glide`/`turn`/`land`, bounded four-influence skinning, numeric quality PASS, and reviewed offline deformation. `evidence/issue133-wyvern-nonavian-flight.json` binds the exact canonical GLB and proof scope; P3 skeletal materialization, physical landing contact, gameplay flight, and family acceptance remain `NOT_PROVEN`.

## Rigid vehicle contracts

`scripts/prepare_rigid_vehicle_contracts.py` converts classified newest-150 rigid
vehicles into deterministic P3 root-movement contracts backed by the verified Tiny3D
mesh, compiled-asset receipt, mesh-analysis receipt, and Unreal validation request.
The source remains an unskinned `StaticMesh`; whole-vehicle motion is explicitly
consumer-owned actor-transform motion, while speed, acceleration, turning, buoyancy,
and rail/path constraints remain unset until the consumer supplies them.

The contract preserves each asset's classified locomotion modes and keeps mechanical
articulation separate from rigid root motion. Structural evidence is `PROVEN`, while
runtime and rendered vehicle motion remain `NOT_PROVEN` until downstream proof exists.

## Jellyfish swimming contracts

`scripts/prepare_swimming_contracts.py` binds classified aquatic-creature locomotion
to the verified Tiny3D source and existing prepared secondary-motion receipt. Whole-
body `swim`/`float` movement stays separate actor-transform motion; tentacle and bell-
pulse deformation reuse the receipt's deterministic spatial selectors and expose only
normalized phase/weight inputs. Physical speed, cycle timing, deformation amplitude,
buoyancy, and phase relationships remain unset instead of being guessed.

The preparation proves the source and deformation-region contract, not visible motion.
Rendered tentacle/bell deformation and P3 gameplay swimming remain `NOT_PROVEN` until
the downstream runtime executes and captures them.

## Mechanical articulation contracts

`scripts/prepare_mechanical_articulation_contracts.py` prepares the newest-150 assets
classified for rigid mechanical articulation. The contract binds the verified source,
compiled asset, mesh analysis, and Unreal request, preserves the classified P3
mechanism and role, and records which semantic inputs a later decomposition or rigging
stage must supply. It deliberately leaves part decomposition, pivot/joint frames,
axes, limits, motion ranges, runtime articulation, and rendered articulation
`NOT_PROVEN` rather than inferring them from an undifferentiated static mesh.

## Destruction qualification contracts

`scripts/prepare_destruction_contracts.py` prepares classified newest-150 building and
environment structures for conditional P3 destruction. It re-hashes the frozen source,
cross-checks the campaign topology facts against current TinyLab analysis, and binds the
manifest, compiled asset, mesh-analysis receipt, and Unreal validation request into a
deterministic `destruction_qualification.json` request. Source connected-component
counts remain topology observations and are never promoted into fracture-piece counts.

The request deliberately leaves whether gameplay destruction is required, fracture
method/seed/piece count, clustering, damage thresholds, support graph, collision and
mass settings, break thresholds, debris lifetime, runtime break behavior, and rendered
destruction to P3. Tiny3D therefore proves source eligibility and preparation only;
fracture materialization, runtime destruction, and visual proof remain `NOT_PROVEN`.
