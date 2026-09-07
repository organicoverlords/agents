# Producer manifest contract

`schemas/producer_manifest_v1.schema.json` defines the LowVRAM -> Tiny3D producer evidence envelope. The canonical schema identifier is `tiny3d.producer-manifest.v1`.

`manifest_id` is SHA-256 over compact UTF-8 JSON after removing `manifest_id`, sorting object keys, sorting assets by `asset_id`, texture members by path, and alias/conflict/reason lists deterministically. Unknown future fields remain in the canonical payload and therefore remain attributable, but v1 validation ignores them for acceptance: they cannot turn `UNKNOWN` or `FAILED` validation/visual-QA evidence into `PASS`.

`generated_utc` may be the literal `UNKNOWN` when legacy evidence has no trustworthy timestamp; consumers must not synthesize one.

Every record separates source provenance (`source.sha256` + `source.provenance_id`) from generated content (`artifacts.glb.sha256` and texture hashes). Successful generation requires a hash/size-bound GLB. Failed or unknown generation may explicitly carry `glb: null`; failure remains durable evidence instead of being replaced with an older asset. Intentional aliases and semantic conflicts are explicit record metadata.

Build the canonical manifest from the machine-wide singleflight receipt store without scanning arbitrary output folders:

`powershell
python tools/producer_manifest.py build-singleflight $env:LOCALAPPDATA\LowVRAM3DStudio\singleflight\asset --output producer_manifest.json
`

The builder preserves PASS and FAIL records, re-hashes current source/GLB bytes, binds mandatory views12 evidence, and fails closed if a legacy receipt lacks enough identity to represent it rather than silently omitting the failure. It also audits the completed manifest for shared-geometry semantic conflicts before reporting success: unresolved `SEMANTIC_CONFLICT` relations still leave the requested manifest output intact as forensic evidence, but `build-singleflight` exits with code `3` and reports the deterministic relation ids so a library publisher cannot treat that catalog as accepted. Proven intentional aliases remain non-conflicting through the existing two-source provenance rule. Singleflight manifests keep top-level `generated_utc` and `producer.job_id` stable so one receipt change is localized to that asset plus `manifest_id`; per-asset `generation.completed_utc` carries receipt recency evidence. Legacy terminal receipts may be enriched only from recovered source evidence with `python tools/producer_manifest.py reconcile-singleflight STATE SOURCE --asset-id ASSET_ID`; the command refuses conflicting existing identity/source data and replaces the receipt atomically.

Validate independently of generation:

```powershell
python tools/producer_manifest.py validate path\to\producer_manifest.json
python tools/producer_manifest.py id path\to\producer_manifest.json
python tools/producer_manifest.py canonicalize path\to\producer_manifest.json --output canonical.json
```

Unknown fields are preserved by canonicalization for forward compatibility. Consumers must base v1 acceptance only on fields defined by the v1 contract.
## Deterministic delta receipts

`tools/producer_manifest.py geometry-audit MANIFEST [--output relations.json]` audits duplicate canonical GLB hashes across distinct producer identities. Each deterministic relation contains the shared geometry SHA-256 plus both asset ids, display names, source names, and source provenance ids. Duplicate geometry defaults to `SEMANTIC_CONFLICT`; it is emitted as `INTENTIONAL_ALIAS` only when an alias declaration names the counterpart and supplies `provenance_ids` matching both source provenance ids. The relation id is a SHA-256 of the canonical relation payload, so ordering and ids are stable across reruns.

Alias proof is deliberately additive for v1 compatibility: legacy alias records remain valid manifest data, but shared geometry is not classified as `INTENTIONAL_ALIAS` unless `provenance_ids` contains exactly the two source provenance ids for the colliding records. A corrected source mapping is repaired by updating the producer record to the intended source/provenance and regenerating the manifest/audit; previously published manifests and relation receipts remain historical evidence and are not rewritten.

`tools/producer_manifest_delta.py OLD NEW [--output delta.json]` compares two valid v1 manifests without mutating either one. The receipt schema is `tiny3d.producer-manifest-delta.v1`; `delta_id` is SHA-256 over the canonical receipt with `delta_id` omitted. It preserves the exact old/new `manifest_id` values and emits one sorted record per `asset_id`.

Each record separates content, provenance, validation, and semantic identities. Primary classification precedence is `CONTENT_CHANGED`, `SEMANTIC_CHANGED`, `VALIDATION_CHANGED`, `PROVENANCE_CHANGED`, then `UNCHANGED`; `ADDED` and `REMOVED` are explicit lifecycle states. Content identity uses artifact hashes/sizes, not paths, so relocation or source/provenance metadata changes can reuse payload bytes. Validation transitions carry explicit `RECOVERED` / `REGRESSED` direction, including failed-to-valid recovery and valid-to-failed regression. Consumer-effect flags tell Tiny3D whether new content identity is required, payload reuse is possible, dependent evidence must be invalidated, or current coverage must be retired.

The delta is evidence only. Tiny3D may feed its own ingestion / `plan-refresh` from the work-bearing records without rescanning unrelated producer folders, but LowVRAM does not trigger downstream work itself.
