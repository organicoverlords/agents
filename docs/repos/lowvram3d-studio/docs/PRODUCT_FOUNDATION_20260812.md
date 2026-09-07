# LowVRAM3D product foundation

**Status:** foundation freeze, 2026-08-12

This document defines the product architecture. Production runtime identity is in `production/production.json`. Human controls are in `app/LowVRAM3D-Control.ps1`. Jobs use `production/job.schema.json`.

## Product rule

The default product is deliberately simple:

**image -> TRELLIS 1024 -> 8K atlas -> preserve PLY master -> approximately 1M-face deliverable -> Unreal**

1024 is the production default. Do not automatically regenerate every asset at 1536; 1536 is an explicit upgrade for assets the game or operator actually needs at higher quality.

The PLY master is always preserved. Unreal/Nanite is the target runtime and is expected to handle dense assets; do not spend the generation budget building unnecessary traditional LOD chains by default.

## One backbone, multiple modes

All user-facing operations enter the same job system. Features are modes, not separate pipelines with independent state.

### Asset

Input: one image.

1. validate / frame / matte
2. TRELLIS 1024
3. 8192 atlas
4. save dense PLY master
5. produce approximately 1M-face deliverable
6. QA
7. optionally publish to Unreal

Every published asset also receives a descriptive, stable asset identity from
the offline intake path when the source does not provide one. The source image
itself is never renamed or modified. Identity metadata records the semantic
class and size basis; physical metres come only from an explicit measurement or
the class prior, otherwise the range is marked unknown.

The production render may write inline and full-resolution intermediates under
the asset output directory. Publishing exposes exactly one human-facing
3x3 grid per completed model in
`C:\Users\Lauri\Desktop\ALL_VIEWS9`:
`<publish_slug>__views9.png`. The browsing folder never receives an inline
strip, a `__views9_FULL.png` duplicate, an `UNNAMED_*` alias, or a hash/UUID
alias. There is no generic latest-file alias: the semantic slug is part of the
deliverable path.
The review renderer uses a dark slate backdrop and restrained lighting
so pale/high-key meshes remain readable; this is presentation-only and does not
change TRELLIS generation settings or geometry.

### Frozen naming and view-library state (2026-08-13)

The proven completed-model library contains 307 completed models, 307 semantic
identities, 307 current human-facing sheets, 307 grid layouts, zero inline
human-facing sheets, zero current `UNNAMED` aliases, and zero duplicate current
aliases. A completed GLB remains generation-complete regardless of downstream
naming, publishing, view, metadata, or legacy-matte debt. Those states are
repaired downstream and never schedule TRELLIS regeneration.

### Upgrade

Input: an existing asset/source identity.

Regenerate only when explicitly requested at 1536. Preserve the 1024 version and its PLY; upgrades are versions, never destructive replacements.

### Rig

Input: generated asset.

1. articulation/anatomy analysis
2. semantic moving-part detection
3. articulation repair/separation when fused geometry would prevent motion
4. skeleton generation
5. skin weights
6. deformation QA
7. animation profile setup
8. Unreal runtime proof

Profiles include biped, quadruped, winged, serpentine, tentacle/tail, mechanical articulation and vegetation sway/bend.

A rig is not considered successful merely because a skeleton exists. Required moving geometry must actually articulate without catastrophic tearing/fusion. Winged subjects must be able to spread/flap; serpentine subjects must bend; mechanical joints must retain intended rigid parts.

### Large Structure / Segment-Stitch

Input: one large object or structure image that is poorly represented by one object-centric TRELLIS volume.

Production design:

1. generate a coarse whole-object TRELLIS scaffold
2. segment the source into meaningful overlapping structural regions
3. generate detailed TRELLIS pieces independently
4. estimate scale against the global scaffold
5. robustly register pieces (RANSAC-first; ICP only as refinement where useful)
6. retain separate aligned meshes rather than forcing a destructive monolithic weld
7. import the aligned set as Nanite meshes in Unreal

The coarse mesh is a spatial scaffold, not disposable evidence. The detailed parts are local-resolution replacements.

The coupled-chunk TRELLIS experiment remains an R&D implementation behind this mode: neighboring overlapping chunks share a latent coordinate frame, predictions are mapped into shared coordinates, overlap velocities are averaged at each flow step, and the shared state is integrated once. It must not replace the proven independent-piece route until 6GB behavior is demonstrated.

### Scene Decompose

Input: a larger scene image containing multiple independently useful assets.

Goal: automatically turn one scene image into an asset set plus layout metadata.

1. semantic/object decomposition of the scene image
2. identify independently useful objects/structures/vegetation
3. create a source crop/mask and stable identity for each component
4. route each component to Asset or Large Structure mode
5. preserve scene-relative transform/layout metadata
6. generate assets independently so each can be regenerated/upgraded/rigged later
7. compose/import the resulting asset set in Unreal

The scene source is not treated as one giant texture-painted mesh. The output is an editable collection of assets.

Examples:

- jungle scene -> trees, plants, rocks, ruins/infrastructure as independent assets
- settlement -> buildings, props, structures, vegetation
- large fantasy structure -> whole scaffold plus structural chunks
- creature group -> separate creature assets, each independently riggable

## Human application

`app/LowVRAM3D-Control.ps1` is the first operator shell. It deliberately starts small:

- Status
- Start
- Pause after current
- Resume
- Verify runtime
- Open logs
- Freeze runtime
- Emergency stop (separate and confirmed)

The full 3D Model Studio UI should grow on the same backend rather than inventing new execution paths.

Planned primary screens/actions:

- **Generate Asset**
- **Generate Scene Assets**
- **Large Structure**
- **Rig / Animate**
- **Upgrade Quality**
- **Send to Unreal**
- asset library with thumbnails, PLY/master status, generated versions and QA state

The operator should never need to know about Git Bash, CMake, CUDA architecture flags, queue locks, DLL hashes or MagicMusic. Those are backend invariants verified automatically.

## Runtime separation

Production runtime and experimental runtime are different concepts.

Production runtime:

- complete co-located runtime directory
- exact EXE and DLL hashes
- read-only frozen copy
- one GPU producer
- no in-place rebuilds

Experiments:

- separate directories
- may use different binaries/models/settings
- must never overwrite the frozen runtime
- may only become production through a new versioned freeze plus one completed real-asset proof

## Current production defaults

See `production/production.json`; current intended product policy is:

- resolution: 1024
- seed: 12345
- atlas: 8192
- target faces: 1,000,000
- save PLY master: always
- automatic resolution escalation: off
- optional explicit upgrade: 1536

Hunyuan Paint and ComfyUI texturing are not default production dependencies. ComfyUI may remain available as an optional experimental/plugin surface.

## Release gate

A future production release is valid only when all are true:

1. entire runtime directory is frozen and hashed
2. manifest hashes verify
3. exactly one producer can be started through the human control layer
4. one real asset completes and publishes from a fresh process
5. its PLY master exists
6. the queue automatically advances to the next asset
7. Start/Pause/Resume/Status work without manual shell knowledge
8. docs point to this contract, not historical build directories

After that, feature work happens above the production service rather than by modifying the proven runtime.
