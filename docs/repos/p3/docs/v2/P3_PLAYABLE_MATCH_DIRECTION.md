# Playable Lane War: delivery and quality direction

Date: 2026-09-07. This is a detailed refinement of [P3's sole northstar](P3_V2_NORTH_STAR.md), not a second roadmap or a runtime-readiness claim. #803 owns composition; #941 owns user acceptance. The existing V2 lanes remain the implementation boundaries.

## Product decision

Make the existing solo-AI and LAN 1v1 Lane War understandable, responsive and replayable. Its identity is the interaction of lane pressure, momentum movement, spells, rapid defenses, destruction and editable terrain. Preserve first-/third-person priority, free map-wide earthworks, chosen Core/base assets and server authority. RTS and survival upkeep remain deferred/excluded as already directed.

Ship a small coherent selected roster, battlefield and ability set through the complete match before expanding content. The goal is a useful player choice followed by a visible, authoritative consequence. A system being implemented or a label being improved does not prove that consequence.

## Prior work and evidence limits

Reviewed current main 50aa9f44df2f74bc25e5634f5e35d0535ee0503f, the current northstar/mirror, relevant issue/PR history, live source owners and bounded Vault timeline. These observations are dated; use current code and artifacts before execution.

| Evidence | Reuse / implication |
| --- | --- |
| #803 and #941 define the integrated match; recent economy feedback changes are merged | Test earn -> spend -> changed pressure; do not repeat label work or call it gameplay acceptance |
| #2442 / #2608 result-menu changes landed | Complete normal start/join/result/replay behavior using that owner |
| #602 avatar migration and P3AnimationProfile exist | Complete real ski/grapple/cast/defeat/swap motion without another avatar architecture |
| #331 / #2429 fixed materialization PASS without exact destination evidence | Preserve the fail-closed consumer path; actual newest-asset runtime acceptance remains open |
| Tiny3D #306 and #375 establish accepted offline character work and new direction | Reuse generated rigs/clips; P3 owns profile/AnimBP/runtime binding and proof, not upstream rig generation |
| #1657 static animation-proof rejection and Tiny3D #129 unreadable Android capture | Inspect actual motion and readable subject/contact detail; hashes or moving roots are insufficient |
| #2605 placement, #2600 route rollback, #2603 wave phase and #2606 ski HUD were open at review | Reconcile matching current WIP before implementing the same acceptance |
| #803 history records content/readiness/native-build route failures | Check the exact failing dependency once; do not convert old timeouts or machine observations into permanent gates |
| Earlier architecture/CI expansion left default-product readiness unproven | Keep infrastructure subordinate to a reproduced current gameplay blocker |

Fox is stock and excluded from current asset intake, donors, roster, comparisons, qualification and fallback. Historical references do not admit it. Existing selected assets/variants keep their true identities; unavailable generated content remains a Tiny3D source/capability gap.

## The complete player loop

The acceptance sequence uses one compatible source/build/content/settings set:

1. Choose solo or host/join LAN through the ordinary UI. Know whether the game is loading, waiting for a peer or ready; failure has an understandable return/retry.
2. Spawn at a readable defended base. Identify Core, house, shop, lane, opponent direction and the next useful action without console commands.
3. Meet lane pressure. Fight with readable abilities, earn gold, and see the result of a purchase or upgrade.
4. Use skiing and grapple to change approach/escape/rotation. Motion and camera communicate control and contact.
5. Change the route with terrain/defenses; witness collision and creep navigation update. Destroy/counter-build to reopen access.
6. Swap character or recover from defeat without broken input, presentation or persistent player state.
7. Destroy a Core, receive the correct result, and rematch/return through the existing route.

Demonstrate both views and both player perspectives. Solo proof does not establish multiplayer; two local instances do not establish Internet connectivity. No matchmaking, NAT traversal, host migration or new networking service is implied by this milestone.

## Missing requirements made explicit

| Product concern | Requirement and falsifying example | Owner |
| --- | --- | --- |
| Session lifecycle | Clear join/timeout/disconnect/host-loss behavior, declared late-join policy and clean rematch; no old match actors/input/timers/state leak | #2442 |
| Network resilience | Baseline LAN plus a recorded lag/jitter/loss profile; damage/purchases/edits remain exactly-once and server-owned | #2442 plus affected gameplay owner |
| Character completeness | Real locomotion/ski/grapple/air/landing/action/defeat/respawn/swap transitions on selected generated roster; idle fallbacks do not prove completeness | #2610 |
| Input/camera continuity | Held input, UI focus, cancel, view switch and pawn swap cannot leave stuck actions; camera collision and effects do not hide aim/tells | #2439/#2441/#2442 |
| Combat readability | Caster/team, danger, cast/impact, hit/miss and resource/cooldown clear at normal speed/distance | #2441/#1091 |
| Accessible feedback | Essential information has shape/text/icon/timing support beyond color and audio alone; readable size/contrast and existing settings | #2441 |
| Momentum skill | Slope/route advantage and controllable grapple entry/exit in a live fight; no dash substituted for skiing | #2439/#2461 |
| Navigation under edits | Declared pending-update and no-path behavior; correct goal invalidation after Core relocation; no tunneling/frozen creep/false rollback | #2437/#1012/#1033/#2440 |
| Defense counterplay | Placement cannot permanently soft-lock Core access; cost/rollback/support/destruction stay consistent during concurrent edits | #2440 |
| Economy meaning | First useful purchase and unit-versus-upgrade consequence measured in normal play; no duplicate purchase or terminal-match spend | #2438 |
| Battlefield readability | Cohesive base/lane silhouettes and landmarks, useful traversal slopes, clear attack/defense space; dressing preserves actual collision/nav/earthworks | #414 |
| Combined performance | Measured client/server/animation/VFX/nav/collision costs during the same match workload, not isolated subsystem FPS | #2611 |
| Content completeness | No missing material/LFS pointer, wrong skeleton/scale, unqualified substitution or runtime repair masking an import defect | #331/#394 |
| Trustworthy proof | Actual gameplay plus scoped diagnostic detail, reviewed bytes and exact package/build/subject/time attribution; complete retained replay bundle | #394 / Tiny3D #13 |
| Match reset policy | Explicit fresh-match versus player-persistent state; save features or host migration do not become prerequisites without a real requirement | #2442/#941 |

The first milestone needs the applicable rows, not a new subsystem for every cell. Implement at existing feature owners.

## Animation and character direction

Tiny3D prepares the generated mesh/rig/skin/portable motion. P3 consumes exact identities through the existing executor and binds PawnData, AnimationProfile, AnimBP, IK, sockets, PhysicsAsset/collision and gameplay state.

Map required states and transitions before adding clips. Keep root-motion ownership explicit; layer locomotion, aim/look, actions and secondary motion deliberately. Cosmetic notifies do not own damage or transactions. Preserve authored units/axes/scale and independent source/target retarget identities.

Start with the working profile/AnimBP baseline and targeted IK/retarget/contact repair. Two compatible generated bodies should differ primarily in content/profile data. Fix a camera problem in capture; fix bad skin/rig upstream; fix stale state transitions in the feature that owns them. Do not compensate with base-character per-asset switches.

Motion Matching is an option when the eligible dataset covers the required movement/transition space and a comparison improves it. Motion Warping is an option for a declared authored target/contact problem. Neither justifies replacing server movement authority or importing a stock example roster. Rewind/Animation Insights helps explain a bad transition before another blind bake.

## World, tactics and balance

The road should read as the default pressure route while slopes, cover and verticality offer purposeful alternatives. Base silhouettes distinguish Core, shop and defensible space. Preserve chosen production assets until a newer qualified replacement actually improves the role.

Tune from observed play: time to encounter, first affordable choice, route travel time, creep pressure, useful defense lifetime, response to a relocated Core and time to a win opportunity. Exact numbers are tuning results, not invented current performance. Start with comparable initial states and one specific change.

Keep edit/placement validation and authoritative terrain/collision/navigation coherent. A preview can become stale before server commit; rejection and refund must not corrupt state. Runtime nav can update locally if needed, but a partial generation radius must not erase a valid Core route. Chaos is presentation around authoritative damage/access, not a second gameplay truth.

## Stable proof and performance

Reuse Invoke-P3VisualProofCapture.ps1, Get-P3VisualProofReviewPayload.ps1, the current P3Testing scenarios and qualification executor. Uniform capture requirements already live in #394 / Tiny3D #13.

Check target/build/world/actor/component/material/animation readiness; render a cheap preview for framing/exposure; capture actual gameplay plus close diagnostic contact/transition views when needed. Distinguish those scopes. Retain raw media, frame/time mapping, exact source/package/mission/build and review evidence in an atomic completed bundle. Interrupted capture cannot publish a complete PASS; link expiry cannot erase canonical replay dependencies.

Profile the real combined workload with existing Unreal Insights tools. Record machine, build, quality/resolution/view, players/creeps, spells, terrain/defense actions and cold-versus-warm phase. Capture frame percentiles and game/render/GPU/server time, memory/VRAM and nav/collision latency. Keep the existing Earthworks 30-edit/no single >100 ms game-thread hitch contract. The broader reference-tier frame target must be declared from the first baseline before tuning; this design invents no measured FPS.

Animation budget controls, VFX scalability and local nav generation are candidates only when they address a measured hotspot. Maintain attack/contact/readability and route correctness when reducing cost. A passing workload is a reason to stop optimizing infrastructure.

## Bounded technology choices

Primary documentation checked 2026-09-07. No new engine plugin, runtime or technology was benchmarked in this design pass.

| Tool / technique | Use when | Limit |
| --- | --- | --- |
| [Scripted IK Retargeter](https://dev.epicgames.com/documentation/unreal-engine/using-python-to-create-and-edit-ik-retargeter-assets-in-unreal-engine) | Repeatable source/target chain/pose setup | Verify installed API and actual contacts |
| [Motion Matching](https://dev.epicgames.com/documentation/unreal-engine/motion-matching-in-unreal-engine) | Adequate clip coverage and demonstrated better transitions | Keep intentional AnimBP baseline until justified |
| [Motion Warping](https://dev.epicgames.com/documentation/en-us/unreal-engine/motion-warping-in-unreal-engine) | Bounded authored root/contact alignment | Not server movement/hit authority |
| [Animation debugging](https://dev.epicgames.com/documentation/unreal-engine/animation-debugging-and-optimization-in-unreal-engine) | Explain pose/state transitions and preserve a reproducible defect | A trace alone is not visual acceptance |
| [Network emulation](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-network-emulation-in-unreal-engine) | Reveal lag/loss defects hidden by ideal LAN | Record exact settings/directions; no claimed WAN proof |
| [Navigation invokers](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-navigation-invokers-in-unreal-engine) | A measured need to limit runtime-generated tiles | Prove complete objective routes, not only local movement |
| [Animation Budget Allocator](https://dev.epicgames.com/documentation/unreal-engine/animation-budget-allocator-in-unreal-engine) | A measured animation CPU bottleneck | Preserve nearby/action-critical motion and gameplay semantics |
| [Unreal Insights](https://dev.epicgames.com/documentation/unreal-engine/introduction-to-performance-profiling-and-configuration-in-unreal-engine) | Identify the real thread/GPU/memory/network cost | Reuse current tooling; no new observability product |

Pin engine/API/configuration for each experiment and compare one specific candidate with preserved baseline on the same eligible content. Newness does not justify Mover/Mass/replication/renderer/framework migration absent a demonstrated product defect.

## Contribution order and completion

1. Integrate matching existing WIP, then complete the normal match path in #803/#941.
2. #2610 closes full gameplay-state animation using current Tiny3D work; #2441/#2439 make combat/movement readable and useful.
3. #2437/#2440/#2438 close real route, defense and economy consequences.
4. #2442 exercises lifecycle/network recovery; #2611 establishes and meets the combined workload budget.
5. #394 returns attributable asset proof and #941 closes actual user acceptance.

These are dependencies of particular outputs, not permission gates. Each contributor names its exact existing file/content boundary and immutable patch/proof. Shared P3LaneWarHUDWidget.cpp, P3TowerDefenseFeatureActor.cpp, placement and avatar files serialize; distinct issue labels do not make the same file independent. Fixtures, read-only review and separate feature changes can proceed where useful.

Track completion in existing issues and receipts. No extra ledger, scheduling layer, worker rule, global queue, mirror northstar or infrastructure campaign is created. This design update is complete when published and linked; the game remains unproven wherever actual user-path evidence is missing.
