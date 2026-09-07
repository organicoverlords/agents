# P3 development history

This is a curated historical chronology for the P3 game and its supporting
content/proof pipelines. It was assembled for [issue #207](https://github.com/organicoverlords/p3/issues/207)
from the `main` commit history, committed receipts, and the durable docs already
in this repository.

The repository history currently starts at the 2026-08-10 bootstrap commit; no
earlier project origin is inferred here.

## How to read this history

- **Proven** means a committed receipt or test explicitly supports the claim.
- **Implemented** means the source commit establishes the feature, but this
  timeline does not silently upgrade it to runtime or visual acceptance.
- **Partial / pending** preserves the status recorded by the original evidence.
- Commit dates are chronology anchors, not claims that every experiment began or
  ended on that exact day.
- Large binaries and screenshots stay at their existing repository paths. The
  companion [visual and artifact manifest](./manifest.md) records context,
  provenance, and missing-capture work without copying them into this folder.

## Recorded product milestones

Structured milestone receipts are preserved directly under [`events/`](./events/). They are append-only historical evidence; inspect the receipts and their referenced artifacts directly rather than a generated projection.

## Timeline

### 2026-08-10 — project bootstrap and the first traversal experiment

P3 begins as an Unreal project in [`8cc17fd6`](https://github.com/organicoverlords/p3/commit/8cc17fd6).
The first gameplay-facing repair is grapple physics and cable alignment in
[`dd562269`](https://github.com/organicoverlords/p3/commit/dd562269).

This establishes the early pattern: a small playable experiment lands beside a
targeted proof/repair rather than waiting for a complete framework.

### 2026-08-11 to 2026-08-13 — showroom, playable roster, and evidence-first tooling

The showroom and initial playable roster take shape: Ice Mountain becomes
playable, showroom geometry/import is repaired, and weapon effects are added
([`a48b258f`](https://github.com/organicoverlords/p3/commit/a48b258f),
[`8cc22e76`](https://github.com/organicoverlords/p3/commit/8cc22e76),
[`e264ca0d`](https://github.com/organicoverlords/p3/commit/e264ca0d)).

On 2026-08-12 the project formalizes an MCP-first, evidence-gated Unreal
workflow ([`dec49d1a`](https://github.com/organicoverlords/p3/commit/dec49d1a)) and
consolidates the first production-pass evidence
([`6b4af5e2`](https://github.com/organicoverlords/p3/commit/6b4af5e2)).

On 2026-08-13, character normalization and source assets become durable
project content: uniform playable variant sizing, editor Python audits, the
canonical Fennec asset/pawn, Asylum Demon/Fennec/Ice Mountain content, and
showroom evidence land in [`52282ca1`](https://github.com/organicoverlords/p3/commit/52282ca1),
[`9e214f8e`](https://github.com/organicoverlords/p3/commit/9e214f8e),
[`01aa95dd`](https://github.com/organicoverlords/p3/commit/01aa95dd), and
[`d82307ec`](https://github.com/organicoverlords/p3/commit/d82307ec).

Visual anchors: the [showroom evidence set](../../evidence/), grass/ability
captures under `evidence/abilities/`, and the production-pass receipts in
[`evidence/production-pass-20260813.md`](https://github.com/organicoverlords/p3/blob/main/evidence/production-pass-20260813.md)
and [`evidence/production-pass-20260814.md`](https://github.com/organicoverlords/p3/blob/main/evidence/production-pass-20260814.md).

### 2026-08-14 — asset acceptance becomes a runtime/proof discipline

Fennec selection, authored sit behavior, and movement receive dedicated source
and runtime receipts. The committed Fennec acceptance evidence records canonical
mesh/AnimBP selection, MCP gameplay input, movement, and inspected captures while
also preserving the rejected source-freshness/toolchain gate
([`evidence/fennec-live-runtime-acceptance.json`](https://github.com/organicoverlords/p3/blob/main/evidence/fennec-live-runtime-acceptance.json),
[`evidence/fennec-sit-runtime-acceptance.json`](https://github.com/organicoverlords/p3/blob/main/evidence/fennec-sit-runtime-acceptance.json)).

Macaw flight and bomb behavior are measured as an authored full-chain animation
and a gameplay path, but the receipt keeps the visual-subject capture pending
([`evidence/macaw-runtime-acceptance.json`](https://github.com/organicoverlords/p3/blob/main/evidence/macaw-runtime-acceptance.json)).
Asylum material/runtime inspection likewise keeps deformation and fresh visual
proof separate from offline inspection
([`docs/asylum-demon-live-mcp-inspection.md`](../asylum-demon-live-mcp-inspection.md),
[`evidence/asylum-demon/live_mcp_inspection_receipt.json`](https://github.com/organicoverlords/p3/blob/main/evidence/asylum-demon/live_mcp_inspection_receipt.json)).

This is the first clear pipeline lesson: an imported asset, a static validator,
an observed runtime asset, and a visually accepted gameplay capture are four
different evidence states.

### 2026-08-15 — the V1 gameplay laboratory becomes a game slice

The core gameplay substrate expands in one concentrated pass:

- construction pieces, inventory, snapping, and an RTS camera/build view;
- tower-defense lanes, health, lane routing, enemies, and waves;
- shared combat/projectiles and survivor combat routing;
- survival vitals, weather/sky/grass, seeded survival lanes, resources, and
  deterministic defense environments.

Representative source anchors are [`6c43f84b`](https://github.com/organicoverlords/p3/commit/6c43f84b),
[`dc60a7b4`](https://github.com/organicoverlords/p3/commit/dc60a7b4),
[`4ef117b7`](https://github.com/organicoverlords/p3/commit/4ef117b7),
[`a4ea457b`](https://github.com/organicoverlords/p3/commit/a4ea457b),
[`ca6f210d`](https://github.com/organicoverlords/p3/commit/ca6f210d), and
[`e09085c3`](https://github.com/organicoverlords/p3/commit/e09085c3).

The [basebuilding/RTS/tower-defense foundation](../basebuilding-rts-towerdefense-foundation.md)
is the durable narrative anchor for this era.

### 2026-08-16 — earthworks, mobility, flight, destruction, and the first asset catalog

This is the broadest V1 feature-expansion day. Gameplay and pipeline strands
advance together:

- earthworks gain a deformable collision heightfield, dig/fill/flatten/salvage,
  trenches, berms, sculpt history, material accounting, personal preview, and
  rapid paint-build ([`963e5f1b`](https://github.com/organicoverlords/p3/commit/963e5f1b),
  [`daf04553`](https://github.com/organicoverlords/p3/commit/daf04553),
  [`f6c3b944`](https://github.com/organicoverlords/p3/commit/f6c3b944),
  [`786434d8`](https://github.com/organicoverlords/p3/commit/786434d8));
- grapple/dash and the rapid gameplay sprint make traversal feel testable
  ([`ff544f16`](https://github.com/organicoverlords/p3/commit/ff544f16),
  [`e28e955a`](https://github.com/organicoverlords/p3/commit/e28e955a));
- Owl/Hummingbird flight, Macaw combat presentation, and weapon authority land
  alongside the existing Eagle/Fennec work
  ([`5811e852`](https://github.com/organicoverlords/p3/commit/5811e852),
  [`410e3148`](https://github.com/organicoverlords/p3/commit/410e3148));
- deterministic Chaos fracture and the first Building15 native playable catalog
  establish destruction as an authored pipeline, not only a runtime effect
  ([`dee643ac`](https://github.com/organicoverlords/p3/commit/dee643ac),
  [`9ca08388`](https://github.com/organicoverlords/p3/commit/9ca08388));
- the animated jellyfish becomes a true flying lane enemy with idempotent,
  receipted import/verification
  ([`80ad1d29`](https://github.com/organicoverlords/p3/commit/80ad1d29),
  [`7a3557e6`](https://github.com/organicoverlords/p3/commit/7a3557e6),
  [`cdf86cc7`](https://github.com/organicoverlords/p3/commit/cdf86cc7));
- low-memory asset handling produces a Building15 registration map, visual QA
  receipt, and editor handoff in [`2c39a4ff`](https://github.com/organicoverlords/p3/commit/2c39a4ff).

The detailed playtest contracts are [`docs/EARTHWORKS_FIELDCRAFT_20260816.md`](../EARTHWORKS_FIELDCRAFT_20260816.md),
[`docs/EARTHWORKS_PERSONAL_PREVIEW_20260816.md`](../EARTHWORKS_PERSONAL_PREVIEW_20260816.md),
[`docs/BASEBUILDING_MATERIALS_EARTHWORKS_20260816.md`](../BASEBUILDING_MATERIALS_EARTHWORKS_20260816.md),
and [`docs/GAMEPLAY_SPRINT_20260816.md`](../GAMEPLAY_SPRINT_20260816.md).

### 2026-08-17 — pipeline scale-up, animation normalization, UI/VFX polish, and proof lanes

The content pipeline moves beyond one-off imports. The catalog expands past the
14-item Building15 ceiling, and a generalized importer covers 349 finished
non-building assets ([`7d2a9069`](https://github.com/organicoverlords/p3/commit/7d2a9069),
[`f291003a`](https://github.com/organicoverlords/p3/commit/f291003a)).

Characters are re-rigged onto the UE skeleton and share a retargeted animation
set ([`31307cc9`](https://github.com/organicoverlords/p3/commit/31307cc9),
[`c6d3d1db`](https://github.com/organicoverlords/p3/commit/c6d3d1db)). The durable
retarget receipt later records the repair of corrupt leg chains, 180-degree pose
alignment, root/pelvis policy, and **40/40 clips forward on both legs**, while
explicitly retaining the lack of a visual/PIE witness
([`proof/claude_humanoid_retarget_20260817/README.md`](https://github.com/organicoverlords/p3/blob/main/proof/claude_humanoid_retarget_20260817/README.md)).

The UI evolves from native/debug presentation to custom survival/RTS composition,
construction cards, resource clusters, ability glyphs, and clearer HUD hierarchy
([`597d9408`](https://github.com/organicoverlords/p3/commit/597d9408),
[`123c5d53`](https://github.com/organicoverlords/p3/commit/123c5d53),
[`e7176a20`](https://github.com/organicoverlords/p3/commit/e7176a20)).
The same day also consolidates terrain preview, retarget, survival/RTS, catalog,
Fennec, and proof lanes into one integration spine
([`7065919a`](https://github.com/organicoverlords/p3/commit/7065919a)).

### 2026-08-18 — proof infrastructure and the V2 architectural break

Proof becomes a reusable product subsystem: owned-PIE witness harnesses,
verification receipts, live UI proof, and retained failed-witness diagnostics are
added on the main line ([`d7b67ca6`](https://github.com/organicoverlords/p3/commit/d7b67ca6),
[`17e94e0f`](https://github.com/organicoverlords/p3/commit/17e94e0f),
[`83ecc314`](https://github.com/organicoverlords/p3/commit/83ecc314),
[`fe8b2d60`](https://github.com/organicoverlords/p3/commit/fe8b2d60)).

The LOWVRAM3D visibility work is explicitly treated as a private/operational
pipeline concern, not a product-state claim
([`901d7265`](https://github.com/organicoverlords/p3/commit/901d7265),
[`f65456b2`](https://github.com/organicoverlords/p3/commit/f65456b2)).

The V2 north star records the architectural conclusion: preserve V1 as a
behavior museum, but move toward stable plugins, Experience composition,
PlayerState-owned persistence, server-authoritative transactions, data-defined
content, and reusable proof. See [`docs/v2/P3_V2_NORTH_STAR.md`](../v2/P3_V2_NORTH_STAR.md).

### 2026-08-19 — V2 chassis: Experience, UI, input, camera, multiplayer substrate

V2-01 becomes real repository structure: P3Core/P3Gameplay/P3World/P3UI
contracts, Experience/FeatureSet/PawnData composition, semantic input, CommonUI
root shell, dedicated-server target, Iris settings, non-possession camera modes,
and runtime observation receipts land across the V2 foundation commits. The
central integration points are [`376f1619`](https://github.com/organicoverlords/p3/commit/376f1619),
[`73cbd52d`](https://github.com/organicoverlords/p3/commit/73cbd52d),
[`50b9b297`](https://github.com/organicoverlords/p3/commit/50b9b297),
[`36dab6e9`](https://github.com/organicoverlords/p3/commit/36dab6e9),
[`4e2fcd29`](https://github.com/organicoverlords/p3/commit/4e2fcd29), and
[`8a9e754f`](https://github.com/organicoverlords/p3/commit/8a9e754f).

V2-02 then proves a deliberately small vertical slice: finite resource nodes,
authoritative harvesting, PlayerState inventory authority, event-driven HUD,
Pawn-swap persistence, and save/load restore
([`0990b1e6`](https://github.com/organicoverlords/p3/commit/0990b1e6),
[`9ffd7579`](https://github.com/organicoverlords/p3/commit/9ffd7579),
[`e5ac12c5`](https://github.com/organicoverlords/p3/commit/e5ac12c5),
[`ab4a71ed`](https://github.com/organicoverlords/p3/commit/ab4a71ed)).

### 2026-08-20 — V2 vertical slices converge on production gameplay

The V2 lanes move from chassis to product systems:

- V2-03C establishes a playable production world, semantic environment state,
  environment dressing, and deterministic HLOD rebuild acceptance
  ([`065eeb31`](https://github.com/organicoverlords/p3/commit/065eeb31),
  [`972aca97`](https://github.com/organicoverlords/p3/commit/972aca97),
  [`f0cf046b`](https://github.com/organicoverlords/p3/commit/f0cf046b));
- V2-03A adds data-driven avatar animation profiles and canonical Manny assets
  ([`a6a42f40`](https://github.com/organicoverlords/p3/commit/a6a42f40),
  [`09f2625e`](https://github.com/organicoverlords/p3/commit/09f2625e));
- V2-04A adds primary melee, equipment/faction policy, traversal dash, projectile
  authority, and a shared flight substrate/profile/camera/input path
  ([`a7abcdef`](https://github.com/organicoverlords/p3/commit/a7abcdef),
  [`25ddbbba`](https://github.com/organicoverlords/p3/commit/25ddbbba),
  [`46b84388`](https://github.com/organicoverlords/p3/commit/46b84388),
  [`db5e7650`](https://github.com/organicoverlords/p3/commit/db5e7650),
  [`01c46800`](https://github.com/organicoverlords/p3/commit/01c46800));
- V2-04B/C adds StateTree/SmartObject AI, authoritative wave direction, tower
  combat/presentation, survival defeat and shelter semantics, and a proof that
  RTS view preserves gameplay possession
  ([`b4d8452c`](https://github.com/organicoverlords/p3/commit/b4d8452c),
  [`4de799e1`](https://github.com/organicoverlords/p3/commit/4de799e1),
  [`99c0436e`](https://github.com/organicoverlords/p3/commit/99c0436e),
  [`448bb5a8`](https://github.com/organicoverlords/p3/commit/448bb5a8),
  [`b341d59e`](https://github.com/organicoverlords/p3/commit/b341d59e));
- V2-05 turns earthworks into a representation-independent, authoritative,
  chunked/persisted system with a preview ghost and a measured 30-edit budget
  ([`017eec25`](https://github.com/organicoverlords/p3/commit/017eec25),
  [`f8f227ed`](https://github.com/organicoverlords/p3/commit/f8f227ed),
  [`cfe7cca8`](https://github.com/organicoverlords/p3/commit/cfe7cca8),
  [`f235a352`](https://github.com/organicoverlords/p3/commit/f235a352));
- two-client authoritative combat, earthworks replication, survival-pawn-swap
  persistence, and Lane War team assignment/core state become explicit runtime
  proof targets ([`5e718c23`](https://github.com/organicoverlords/p3/commit/5e718c23),
  [`36334f77`](https://github.com/organicoverlords/p3/commit/36334f77),
  [`12d50e96`](https://github.com/organicoverlords/p3/commit/12d50e96),
  [`249f6397`](https://github.com/organicoverlords/p3/commit/249f6397)).

### 2026-08-21 — Lane War and the current multiplayer-facing slice

The current `main` snapshot adds readable Lane War HUD presentation, a
deterministic arena launch slice, stronger survival attribute replication,
runtime earthworks collision/navigation integration, and playable roster
movement-transition fixes. The culminating merge is
[`71f66b78`](https://github.com/organicoverlords/p3/commit/71f66b78), with the
feature commits [`a9c4817e`](https://github.com/organicoverlords/p3/commit/a9c4817e),
[`34231211`](https://github.com/organicoverlords/p3/commit/34231211),
[`f8cbdec7`](https://github.com/organicoverlords/p3/commit/f8cbdec7),
[`81faee41`](https://github.com/organicoverlords/p3/commit/81faee41), and
[`ff770d61`](https://github.com/organicoverlords/p3/commit/ff770d61).

The durable feature narrative is [`docs/lane-war-arena.md`](../lane-war-arena.md).
The repository now has a meaningful server-authoritative multiplayer foundation,
but this timeline does not claim a final inspected Lane War beauty capture until
one is added to the evidence tree.

## Coverage of the issue brief

| Requested history area | Covered by this snapshot |
| --- | --- |
| Playable characters | Seal/Panda/Titan foundation; Fennec, Asylum Demon, Ice Mountain, Macaw, Eagle, Owl, Hummingbird, and jellyfish milestones |
| Combat | Shared combat/projectile foundation, authoritative damage/faction policy, melee, weapon/VFX, two-client combat proof |
| Flight and grapple | Grapple contract, Eagle/Macaw/bird flight, shared V2 flight profiles and server-authoritative control |
| Survival and tower defense | V1 survival/lane world, vitals/resources, waves, tower enemies, AI, shelter/defeat semantics |
| Base building, destruction, earthworks | Construction inventory/snap, Building15 catalog, Chaos fracture, material economy, sculpt/preview/chunk persistence |
| V2 multiplayer and Lane War | Experience/PlayerState/Iris/CommonUI chassis, inventory/save vertical slice, replication, teams/cores, arena/HUD |
| Pipeline and tooling | Showroom/editor audits, low-memory registration, generalized importer, retargeting, MCP/PIE/temporal proof, HLOD acceptance |
| Failed or funny experiments | Explicitly preserved in [manifest section 4](./manifest.md#4-failed-broken-and-funny-artifacts); obsolete does not mean deleted |

## Next evidence work

The actionable capture backlog is maintained in the manifest. The highest-value
gaps are fresh repository-local visuals for the already implemented systems:
Fennec/Macaw/Asylum comparison, grapple in motion, jellyfish lane flight,
Building15 fracture, earthworks edit/undo, tower-defense wave/core state, and
the two-client Lane War arena. The backlog also calls out the materialization of
existing Git LFS screenshot paths and the zero-byte grapple shot so future work
can close a named gap rather than rediscovering it.
