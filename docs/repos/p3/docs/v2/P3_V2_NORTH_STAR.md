# p3 V2 North Star — Authoritative Implementation Plan

Status: **SOLE P3 PRODUCT ROADMAP + AUTHORITATIVE V2 ARCHITECTURE + BUILD ORDER**
Research synthesis date: 2026-08-18  
Repository: `organicoverlords/p3`  
V1 source-of-truth audited through: `main@35648d6862bf0167bcd4ec602a805708fc629e5f`  
Scope: **p3 only** — game/runtime/editor architecture, Unreal workflows, playtest/capture, CI, migration and feature implementation.

> **Boundary:** p3 is not the 3D-generation pipeline. External asset-generation systems may hand files/metadata into p3 through a narrow staging/import contract. Their generation, reconstruction, rigging, texture and QA internals are separate products and are not part of this architecture.

This document supersedes the earlier V2 draft at `4259233` and is the sole human-readable product-roadmap and architecture authority for p3 V2. `docs/v2/P3_V2_LANES.json` is the machine-readable execution mirror; it may not contradict this document.

---

## Product thesis - the game V2 is building

**Design shorthand, not a cloning requirement:** imagine **Dota 2 lane war and skill/ability mechanics + The Finals destruction and skills + Tribes: Ascend momentum/skiing + Fortnite rapid building + live earthworks**, combined into one server-authoritative 3D battlefield.

The point is not to ship those games side by side. The point is that their strongest interactions happen in the **same Lane War match**:

- **Lane war and skill expression.** Players fight over opposing lanes, creeps, structures and core objectives with readable, high-skill abilities, movement and counterplay rather than passive stat resolution.
- **Destruction changes tactics.** Structures and battlefield objects can be damaged or destroyed so cover, access, sight lines and defensive positions can change during the match. Destruction is gameplay-state-aware, not cosmetic-only spectacle.
- **Momentum movement matters.** Traversal should reward speed, route choice, air control and terrain reading. Skiing/momentum movement is a first-class combat and rotation mechanic, not a separate minigame.
- **Building changes the lane.** Players can rapidly place useful structures, blockers, ramps, cover, towers and fortifications during play. Construction must interact with navigation, destruction, costs and multiplayer authority.
- **The ground itself is editable.** Earthworks can raise and lower terrain in the active 3D lanes. Players can create ramps and ski lines, berms and walls, trenches and pits, choke points, cover, high ground, creep blockers and reroutes. A terrain edit can therefore affect movement, combat, construction, visibility and AI pathing at once.
- **3D verticality is part of strategy.** The lane is not a flat MOBA strip. Height, slope, airspace, destructible geometry and constructed or excavated terrain create alternate attack and defense routes.

A representative V2 product proof must eventually demonstrate these systems **composing with each other on the default production path**. Separate construction, earthworks, traversal, destruction, combat or Lane War demos are useful subsystem evidence but do not by themselves prove this product thesis.

### Explicit non-goal: no survival upkeep

V2 does **not** need or prioritize survival-maintenance mechanics such as hunger, thirst, exposure/temperature meters, shelter-as-survival pressure, or similar continuous survival upkeep. Those V1 experiments remain historical reference only and are not migration targets.

This does not remove match-relevant systems that stand on their own: defeat/respawn, combat status effects, environmental hazards, finite Lane War economy, harvesting when useful, or construction. They belong to their owning gameplay systems and must not be reintroduced through a Survival subsystem or survival meters.

### Battlefield interaction examples

These are product-intent examples, not a fixed content checklist:

1. Raise a berm across part of a lane to redirect creeps, then use it as a ski jump or defensive firing position.
2. Dig a pit or trench that changes creep routing and player traversal, then bridge or build around it.
3. Place a blocker or fortification, force an enemy detour, then destroy that structure to reopen the route.
4. Shape a downhill line for momentum, chain it into a traversal ability, and attack a lane objective from a new 3D angle.
5. Destroy cover or structures, then immediately rebuild or reshape the exposed ground to create a different tactical state.
6. Use abilities, construction and terrain edits as counters to one another so the battlefield evolves instead of settling into one solved layout.

This interaction is the product reason V2 contains Lane War, combat/GAS, construction, Chaos-backed destruction presentation, earthworks, navigation-aware AI and high-mobility traversal in one architecture.
## Finished-game product roadmap

The North Star must remain useful after the current issue graph is exhausted. The durable product path is therefore **finished game -> major player outcomes -> current milestone**. Issues and PRs are disposable execution decompositions of these outcomes; they are not the roadmap itself.

### Definition of the finished P3 game

The finished P3 release is a **fully authored, polished, replayable, server-authoritative 3D Lane War game**. It is not a prototype with every subsystem technically present. It must look, move, sound, read and play like one intentional game from ordinary launch through repeated completed matches.

A normal player can install/launch it, understand what to do, play against strong-enough AI or another player through a supported real-world session route, make meaningful tactical choices, experience a visually complete battlefield and character roster, finish the match, and immediately play again without developer intervention.

The finished game has all of these properties together:

- **Complete match loop:** enter, choose a playable character/loadout where applicable, defend/attack a Core, fight around creeps and objectives, earn/spend match economy, reshape/build/destroy the battlefield, reach a replicated result, and rematch/return cleanly.
- **Skillful movement and combat:** momentum/skiing, grapple/high-mobility traversal and readable abilities materially change positioning, attack, escape and rotation; first-person and third-person are both intentional polished playable views.
- **Custom combat identity:** shipped spells/abilities use authored P3 gameplay behavior, animation, Niagara/VFX, impact/result presentation, sound and readable telegraphing appropriate to their role. Generic debug spheres, stock-template effects, placeholder montages or text-only feedback do not satisfy final content.
- **Fully animated playable roster:** every shipped character has complete authored gameplay motion for locomotion, starts/stops/turns, skiing, grapple/air/landing, attacks/spells, hit/defeat/respawn and relevant transitions. Animation must preserve the actual generated character identity and look good in real gameplay, not only in an editor preview.
- **Distinct character/gameplay choices:** shipped characters, abilities, equipment/loadouts and movement differences create understandable strengths, counters or play styles. Content variation must change decisions rather than merely reskin the same behavior.
- **Battlefield agency:** construction, destruction and map-wide earthworks change real player access, creep navigation, cover, high ground and defensive shape instead of existing as disconnected toys.
- **Strategic lane pressure:** creeps, Core/base defense, towers/fortifications, economy and upgrades create understandable offensive/defensive choices and counterplay rather than passive timers or cosmetic numbers.
- **Fully asseted production battlefield:** the released playable world is intentionally dressed and visually coherent across the spaces players actually see and traverse. Bases, lanes, terrain, structures, vegetation/props, landmarks, sky/lighting, materials, effects, destruction states and environmental details use qualified production assets instead of greybox geometry, primitive stand-ins, missing-material repair or obvious test-map leftovers.
- **World readability and tactical art:** visual dressing reinforces gameplay. Players can read lane direction, team/base identity, Core/shop/defense roles, traversal routes, editable terrain, destructible/constructible space, hazards and important sight lines at gameplay speed. Art may never obscure collision, navigation or objective truth.
- **Polished construction/destruction/earthworks presentation:** previews, placement, rejection, building completion, damage, fracture/destruction, terrain edits and navigation consequences have clear final-quality visual/audio feedback while authoritative gameplay state remains separate from presentation.
- **Complete UI/UX:** menus, session flow, HUD, economy/shop, cooldown/resource state, objective state, character/view switching, build/earthwork controls, damage/danger feedback, result/rematch and settings are coherent, readable and styled as one product. Debug/status text is not the final interface unless deliberately retained as player-facing design.
- **Audio and feedback pass:** attacks, spells, impacts, movement, construction, destruction, objectives, UI and match transitions have coherent audio/visual feedback where it materially improves comprehension and feel. Essential information still has non-audio and non-color support.
- **Production world and atmosphere:** environmental presentation, lighting, weather/time state when used, effects and soundscape support the game's tactical mood without compromising visibility or performance. The release should not feel like a collection of showcase assets placed around a test arena.
- **Reliable ordinary use:** normal launch, controls/settings, session flow, defeat/respawn, disconnect/failure handling, match reset and packaged execution are understandable and resilient. No console command, editor repair step or hidden developer ritual is required for ordinary play.
- **Meaningful solo play:** AI can play the actual Lane War rules well enough to pressure objectives, fight, navigate changed terrain/defenses and exercise the player's core decisions. Solo is a real way to play/test the finished game, not merely a dummy bot connectivity harness.
- **Balanced replayability:** tuning produces meaningful choices among pressure, upgrades, defense, movement routes, abilities, construction and terrain manipulation. No single unfinished exploit, dominant placeholder strategy or broken economy loop invalidates the intended interaction of systems.
- **Measured release quality:** the integrated release workload meets declared frame/server/memory/network budgets on named reference hardware/settings; long-running play, repeated matches and save/schema paths do not accumulate broken state.
- **Content integrity:** every required shipped asset is hydrated, attributable and qualified for its actual role. Wrong skeletons, wrong scale, missing materials, runtime path repair, stock/primitive substitutes and silently degraded fallbacks are release blockers for required player-visible content.
- **One production authority:** V2 owns the shipped path. V1 and lab/showroom/test surfaces remain explicit reference/proof tools only and cannot be required to make the released match work.

“Finished” means the selected release scope is **coherent, authored, content-complete, polished, stable and genuinely enjoyable enough to stand as the game**, not merely that engineering acceptance boxes are green. Exact roster size, number of custom spells, build pieces, creep/tower variants, maps and tuning values are determined by playtest quality and product coherence rather than arbitrary quotas; workers must expand content until the release no longer reads as sparse, repetitive or placeholder-driven, then stop when additional breadth no longer improves the game.

### Milestone A - friend-playable integrated match (current)

Complete #803/#941 and the current playable-match direction before broad content expansion. The existing solo-AI and LAN 1v1 path must prove the whole identity at once: Lane War pressure, first-/third-person combat, skiing/grapple, generated-character animation, meaningful gold spending, construction/destruction, free map-wide earthworks, navigation response, result and rematch.

**Advance when:** a normal player can complete the declared match sequence on one compatible head with representative two-perspective runtime/visual evidence and no required subsystem is merely “implemented but not composed.”

### Milestone B - repeatable competitive core

Turn the first working match into something worth replaying before making it larger.

- Tune encounter timing, movement routes, creep pressure, Core/base defense, purchase timing, upgrade impact, build value, destruction and earthwork counterplay from observed matches.
- Make every major choice legible: why a player took damage, why a route is blocked/open, what a purchase changed, which objective matters, how to counter a defense and how to recover from a lost exchange.
- Finish onboarding-through-play: ordinary UI exposes controls, objectives, shop/economy, character/view switching, build/earthwork use, result and rematch without requiring external instructions or console knowledge.
- Harden AI enough that solo play exercises the real match and creates useful pressure/counterplay rather than only serving as a connectivity substitute.
- Establish stable integrated performance/network baselines and fix measured bottlenecks or repeated-match state leaks before increasing simulation/content breadth.

**Advance when:** repeated normal matches produce meaningful different tactical decisions, the dominant failures are balance/content questions rather than broken composition, and a fresh player can understand and complete the loop without developer coaching.

### Milestone C - shippable multiplayer product

Move from “works locally with a friend” to a declared supported multiplayer release route without speculatively building every online-service feature.

- Select and support at least one practical real-world friend-play route beyond developer-only/local-machine testing: for example a supported peer-hosted Internet route or a dedicated-server/session route. The exact online service, NAT/traversal strategy, discovery UX and hosting model are chosen from product need and current platform evidence, not assumed in advance.
- Preserve the same server-authoritative gameplay semantics under latency/loss, reconnect/failure boundaries and repeated sessions.
- Package/install/launch the game through the intended player path on supported target hardware; eliminate hidden editor/content-repair prerequisites.
- Provide clear session creation/join/failure/return behavior and document what is and is not supported. Host migration, public matchmaking, ranking and similar services become requirements only if the chosen release model actually needs them.

**Advance when:** two ordinary machines/users can reliably reach and replay the real game through the declared supported release route, and failure cases return to a usable state without manual repo/editor intervention.

### Milestone D - fully authored content-complete game

Expand only after the core interaction is fun, readable and technically stable. This milestone turns the proven game into the **fully asseted and custom-presented P3 release**, not a larger prototype. Content breadth should multiply decisions already proven by the core systems rather than introduce parallel games.

- Finish the generated playable roster through PawnData/AnimationProfile/content rather than base-framework special cases. Every shipped character needs complete gameplay-state animation, final materials/collision, intentional silhouette/readability and a coherent ability/loadout identity.
- Replace prototype combat presentation with a coherent set of **custom P3 spells/abilities**: authored cast/action animation, projectile/active-state presentation where relevant, impact/result VFX, sound, cooldown/resource feedback and opponent-readable tells/counters.
- Build a fully dressed release battlefield using qualified assets across bases, lane/road, structures, fortifications, terrain, traversal landmarks, foliage/props, tactical cover, shops/objectives and environmental presentation. No visible greybox/primitive placeholder or missing-material content remains in ordinary release play unless deliberately part of the art direction.
- Give construction, destruction and earthworks final presentation: production meshes/material variants, previews/placement feedback, damage states, fracture/destruction effects, terrain-surface response and readable before/after tactical state.
- Add creep, tower/defense, upgrade, construction and battlefield variants when each creates a new tactical choice or counter rather than a cosmetic duplicate; finish their animation/VFX/audio/readability to the same release bar.
- Complete UI art/interaction and player guidance across menus, session flow, HUD, shop/economy, abilities, build/earthwork tools, objective state, result/rematch, settings and error/recovery flows.
- Complete the game-feel pass: camera motion, hit reactions, impact timing, movement feedback, traversal contact, animation transitions, VFX timing, sound cues and response latency should make accepted actions feel deliberate rather than technically functional.
- Add coherent world/environment variation, landmarks, hazards, lighting/weather presentation and ambient detail where they improve play and atmosphere, while preserving readable lanes, editable-ground rules, navigation correctness and performance.
- Use persistence for durable player/loadout/world state only where the product actually benefits from it. Version and migration are required once durable release data exists; persistence must not leak transient match state across fresh matches.
- Keep content production/qualification repeatable through the existing Tiny3D -> P3 boundary so expanding the roster/world does not require runtime repair hacks or unidentified source substitutions.

**Advance when:** ordinary play no longer exposes obvious placeholder art, incomplete animation, generic spell presentation, debug UX, underdressed world areas or unpolished major interactions; the exact release content has enough verified variety, balance and audiovisual coherence to sustain repeated play on the same production architecture.

### Milestone E - final polish, release candidate and finished game

Stop feature expansion and prove the selected release as a product.

- All required release-scope systems are on the normal production path with no shadow implementation required for ordinary play.
- Required user-visible assets, animations, materials, effects, UI and sounds are final-quality for the declared scope or explicitly accepted release content; no stock/primitive stand-in satisfies a required user/generated-asset role.
- Clean packaged launch, session flow, repeated matches, failure/recovery, save/schema migration where applicable, and long-running stability pass on supported target configurations.
- Integrated performance budgets hold under the actual release workload; scalability/settings preserve gameplay readability and authority.
- Accessibility/usability requirements for essential information, controls and feedback are exercised through the real player path.
- Open P0/P1 defects that falsify the declared release experience are resolved, superseded by an exact accepted path, or deliberately removed from release scope through explicit product-direction change.
- V1 retirement is complete for all shipped domains; labs/showroom/proof tooling cannot be hidden runtime dependencies.
- Final acceptance is played and inspected as the game, not inferred from issue closure, PR count, test volume or subsystem receipts.

When these conditions hold for the declared release scope, the core game is finished. Subsequent work is expansion/maintenance, not retroactive completion of the first release.

### Designed future expansions - not current release gates

The architecture intentionally leaves room for features already explored or designed, but they do not block the first finished core release unless the user explicitly promotes them into release scope:

- **RTS/overhead command view:** later view/input/presentation layer over the same Pawn/PlayerState/world, never a second possession/gameplay framework.
- **Flight and additional creature/body families:** shared data-driven movement/body contracts, admitted when they create worthwhile Lane War gameplay and have complete animation/network proof.
- **Broader persistent progression/loadouts/world state:** use the existing player/inventory/persistence contracts when a concrete return-play loop warrants it; do not invent grind or survival upkeep.
- **Additional maps/world variants and larger simulation/content scale:** expand only when the current integrated performance and navigation budgets can absorb them.
- **Additional online/social/competitive services:** public matchmaking, ranking, parties, host migration, spectator/replay services or similar features require an explicit product decision and must not appear as infrastructure work merely because a finished multiplayer game could someday use them.

### Roadmap-to-issue rule

Workers own continuity from this roadmap. When the current parent issue is satisfied, exhausted or stale, they reconcile live product evidence against the next unmet milestone above, close/supersede stale work, and populate the smallest useful parent/child issues for real uncovered acceptance gaps. The user is not required to maintain the issue wall. Workers may refine execution issues freely from evidence, but they may change this product roadmap only for explicit user direction or a genuine correction to product authority.

---

## Immediate product priority - first friend-playable V2 Lane War

The next product milestone is a **visible, fully playable two-player Lane War match** on the V2 production path. Work that directly advances this integrated slice outranks isolated polish or infrastructure that does not unblock it.

### 2026-09-08 user priority refinement - visual library integration first

Within that friend-playable milestone, the user's highest current product priority is **visible integration of the qualified asset library into the real game**. When multiple ready #803 contributions are available, prefer consuming already reviewed/hash-bound Tiny3D/library assets through the existing P3 consumer paths, binding them to real gameplay roles, and proving them in normal first-/third-person play over additional infrastructure, isolated source polish, placeholder work, or catalog-only progress.

- Turn approved library assets into visible bases/defences, characters/creeps, battlefield dressing, construction pieces and other gameplay presentation where an existing owner/acceptance path calls for them; do not create a parallel asset framework.
- Preserve exact source/provenance, gameplay collision/authority and visual-QA gates. A catalog entry, hash, import receipt or generated package is not integration until the asset is visibly used by the default product path and reviewed in gameplay.
- Prefer replacement of remaining placeholders and weak/unfinished presentation when the qualified library already contains a suitable reviewed candidate. Do not substitute an unreviewed asset merely to increase coverage.
- Machine-capacity work and memory-recall work remain important enabling priorities across the swarm, but for P3 they should reduce friction for this product objective rather than become competing products.

**Current player-view priority:** implement, integrate, playtest and visually prove this milestone in **first-person and third-person**. RTS/overhead camera, input and UI work is deferred and must not consume current feature, integration, proof or polish time unless the user explicitly reactivates it. The future RTS architecture remains documented only so current work does not hard-wire a dead end.

### Game-first delivery and infrastructure stop condition

P3 is now a **game-delivery project first**. Once an existing build, runtime, proof, cleanup, routing, or worker-support path works on current `main` and has enough live evidence to trust it for the current product, stop improving that infrastructure and return to player-visible work. Infrastructure is maintenance, not a parallel product.

- Do not create another harness, validator, orchestration layer, cache, routing abstraction, dashboard, proof system, or general framework for a hypothetical future need. Repair an existing owner only when a concrete current game issue is blocked by a reproduced failure.
- Architecture/retirement/resource issues such as #599, #611, #296 and runtime-route work such as #2388 never outrank ready #803 gameplay merely because they can be improved further. They become active only for a concrete blocker or acceptance failure on the current player path, and return to maintenance/closed state when that failure is resolved.
- Keep the ready issue pool stocked with real gameplay, content, animation, combat, movement, world interaction, UI/readability, balance, friend-play and integrated acceptance work from this milestone. Prefer those issues over infrastructure when both are actionable.
- Keep available worker capacity pointed at game work. When one useful gameplay task finishes, continue with the next ready non-conflicting gameplay/content/polish task instead of idling or inventing infrastructure work.
- Better external research, alternative implementations and bounded experiments remain welcome when they can improve the game or resolve a concrete blocker; prior work narrows duplication but does not freeze solution search.

### Battlefield and bases

- Choose a qualified production asset as each team's **Core**: the heart/objective creeps and enemy players ultimately try to destroy.
- The Core is a server-authoritative **player-placeable/movable objective** so the player can choose its defensive position; exact relocation timing/cost restrictions may be tuned, but the product capability is required.
- Choose another qualified building asset as the team's main **base/house** structure.
- Each side must visibly read as a real defended base: **Core + base/house + walls/defences**, with the player able to construct additional protection around the Core.
- The two bases are connected by a clear **3D lane/road**. Default creeps use that route toward the enemy Core, while valid construction and earthworks can alter navigation and tactical access.
- Both teams receive the same complete base structure and gameplay rules; asset styling may differ later without changing authority.
**Initial concrete asset selections for #803:**

- **Core v0:** `/Game/Generated/TowerAlignment20260810/BaseFringeCleanupCandidateV2/tower_parts_aligned_base_fringe_clean_v2/StaticMeshes/base_0.base_0`, the existing Lane War Core presentation binding already locked by source/LFS contract (`sha256:6fdd62c8eb5d0990a4e20ff9de4d7bec12830bf25527cdf1a56becc8578a5910`). Keep it until a newer qualified Core replacement is actually visually proven.
- **Base/house v0:** `/Game/Building/Mechanics15/StiltHut/SM_StiltHut.SM_StiltHut` (`sha256:360fd14983c00527d1ae3ec233cab72efc2fc27315a43bebbba4c79c9d296561`). It already exists in the V2 production-world dressing and is the first house-shaped base asset to promote into gameplay. Its current dressing binding is still marked as a Tiny3D-lineage gap and no-collision presentation, so gameplay collision/qualification must be proven before final acceptance.
- **Wall/defence v0:** `/Game/Building/Mechanics15/WeatheredWoodWallBrace/SM_WeatheredWoodWallBrace`, a Building15 visual-QA PASS asset with existing wall/destruction wiring. Use it as the first readable defence wall rather than inventing a new wall asset.

These are starting selections, not permanent art lock. Replacement is allowed only with a newer qualified asset that improves the role and preserves gameplay semantics.

### Lane combat, movement and terrain

- Grappling hook, momentum skiing/surfing, earthworks, rapid construction, destruction and combat abilities must work in the **same multiplayer match**, not only in separate test Experiences.
- Earthworks can raise/lower the active lane to create ski ramps/lines, berms, pits, trenches, high ground and creep blockers/reroutes.
- Building adds walls, blockers, ramps, cover and fortifications around bases and along the lane; destruction can reopen or change those routes.
- Creeps must respond to changed navigation rather than walking through blockers or ignoring meaningful terrain edits.

### Economy and escalation

- Players earn **gold from creep-related play and over time**. Exact last-hit/assist distribution is a tuning decision; the required product loop is that lane activity plus periodic income grows spendable gold.
- Gold is spendable from the player's base economy on at least **additional allied creep/minion spawns** and **upgrades**. Upgrade categories may expand, but the first playable slice must make spending visibly change the lane war.
- Economy, purchases, spawned units and upgrades are server-authoritative and replicated to both players.

### Characters, spells and presentation

- The chosen first playable roster must be **fully animated through its real gameplay states**: locomotion, skiing/traversal, grapple/air movement where applicable, attacks/spells, hit reactions where supported, defeat and respawn. Static or partially animated placeholder characters do not satisfy the milestone.
- The live spell/ability set must have readable authored presentation: cast/start, travel or active state where applicable, impact/result, cooldown/resource feedback and clear opponent readability.
- Character motion, spell effects, destruction, construction and terrain edits must remain readable at normal gameplay distance and speed.
- Current player-facing gameplay and spell/ability work must function from both **first-person and third-person** views; RTS-view proof does not satisfy the current milestone.

### Milestone acceptance - player-visible and friend-testable

This milestone is not complete until one compatible V2 head demonstrates all of the following together:

1. Host starts a normal **two-player multiplayer session** and a second player can join through a user-facing flow suitable for testing with a friend; developer-only PIE is not the final user acceptance path.
2. Both players spawn at opposing visible bases containing walls/defences, a base/house asset and a movable/placeable Core.
3. A visible road/lane connects the bases; creeps spawn for both teams, follow the lane, react to blockers/terrain changes and attack the enemy Core.
4. Players fight with readable spells/abilities while fully animated characters use grappling, skiing/momentum and other accepted traversal.
5. A player reshapes lane terrain and/or builds a blocker/defence, changing creep routing or player movement; destruction/counter-building can change the route again.
6. Gold visibly increases from creep-related play and time, and a player spends it to spawn additional allied creeps/enemies or buy an upgrade that changes the live match.
7. Core destruction produces a replicated win/loss state and ends or resolves the match coherently.
8. Canonical reviewed visual proof shows the complete Lane War from **first-person and third-person gameplay viewpoints**, including both bases, moving/attacking creeps, character animation, spells, terrain/build interaction, economy feedback and match resolution. RTS/overhead-view footage is not required for this milestone.
9. The user receives a practical launch/test path for a friend session plus the representative proof media; logs, unit tests or isolated subsystem demos cannot substitute for this acceptance.

Issue **#803** owns this integrated playable milestone. Existing issues #413, #414, #205, #206 and #331 remain component owners; #803 owns composition and player acceptance, not duplicate implementations.
---

## 2026-09-07 refinement - complete, readable and replayable Lane War

The next improvement is to make the existing match easier to play, animate, validate and repeat. Preserve the product thesis, solo-AI/LAN 1v1 scope, first-/third-person priority, free map-wide earthworks and game-first delivery rule above. Implementation detail and researched options live in [Playable match direction](P3_PLAYABLE_MATCH_DIRECTION.md); that document refines this sole northstar.

### Complete-player-loop requirements

- **Ordinary launch and recovery:** solo and LAN host/join have clear loading/ready/failure states, declared late-join behavior, useful disconnect/host-loss recovery and a clean result/rematch/return path. LAN proof does not imply Internet matchmaking, NAT traversal or host migration.
- **Complete generated roster motion:** selected characters cover actual locomotion, ski/grapple/air/landing, casts/actions, defeat/respawn and swap transitions. Profile/fallback existence is not proof. Tiny3D owns rigging and portable authoring; P3 owns gameplay binding, runtime correction within that contract and real proof.
- **Source fidelity:** preserve exact selected generated asset/variant, package, skeleton and clips. Stock Fox is excluded from inputs, motion donors, roster, benchmarks, qualification and fallbacks. Missing generated content stays a gap; no stock/primitive substitution for final user-asset acceptance.
- **Readable combat and controls:** cast/impact, friend/enemy, damage/cooldown and danger remain clear at normal gameplay distance/speed in both views. Essential feedback must not rely on color or audio alone. Camera collision, view/character changes, UI focus and held input must not leave hidden aim or stuck actions.
- **Meaningful terrain/defense counterplay:** edit/build/destroy changes real traversal and creep routing. Declare pending-nav and no-path behavior, invalidate relocated Core goals, and reject/roll back stale or invalid placement without duplicate cost or permanent route soft lock.
- **Meaningful economy:** measured earn -> choice -> spend -> visible lane consequence, with exact-once authoritative transactions and clear match reset policy. Earthworks remains free; do not apply the shop/construction economy to terrain edits.
- **Network resilience:** test normal LAN and a recorded emulation profile for lag/jitter/loss. Keep player/world results coherent through purchases, edits, combat, possession and terminal-match transitions; fix defects at the actual feature owner.
- **Combined playability budget:** measure the same real match with players, creeps, spells, animation, terrain, destruction and navigation active. Declare reference hardware/settings and a frame budget from the first baseline before tuning. Preserve the existing Earthworks hitch contract; timings are not invented evidence or hardware-sensitive unit-test gates.
- **Uniform dependable proof:** reuse current capture/qualification tools with target/readiness checks, preview-before-final, readable contact/transition detail, actual gameplay sequence, atomic complete bundles and independent pixel review. Preserve exact package/raw media/replay dependencies; a capture-only defect does not require rerigging or a full pipeline rerun.
- **Deliberate technology adoption:** current AnimBP/profile + scripted IK/retargeting are the baseline. Compare Motion Matching, Motion Warping, animation budgeting or local nav generation only for a measured quality/cost gap. Traces explain defects; newer tools or model-paper results are not accepted gameplay.

### Existing-owner execution map

| Outcome | Issue authority |
| --- | --- |
| Full normal-user match and compatible-head evidence | #803 / #941 |
| Complete selected-roster animation and transition/contact quality | #2610 with #331/#394 and Tiny3D #372 |
| Measured combined workload and targeted performance correction | #2611 |
| Start/join/defeat/respawn/rematch and network edge behavior | #2442 |
| Combat feedback, viewpoint usability and opponent readability | #2441 / #1091 |
| Useful ski/grapple routes and movement feel | #2439 / #2461 |
| Creep pressure and navigation after changes | #2437 with #1012/#1033 |
| Core/defense counterplay and exactly-once rollback/cost | #2440 |
| Spend decisions and real lane consequence | #2438 |
| Coherent qualified battlefield and consumer intake/proof | #414 / #331 / #394 |

Closed foundation/migration issues are reusable work, not evidence that these broader player outcomes are complete. Reconcile current PRs before overlapping their files. Share immutable patches and proof through these issues; do not create a new integration ledger or supervisory system. Infrastructure remains blocker-only maintenance.

## 0. Executive decision

**Do not keep extending V1. Do not rewrite the whole repository in one branch either.**

V1 is a successful laboratory: it proved that the current tooling can create environments, characters, flight, abilities, survival, construction, earthworks, tower defense, VFX, UI, Unreal automation, PIE proof and parallel worker execution. It also proved the failure mode of the current architecture: every successful experiment eventually becomes another responsibility of a central class, world subsystem, raw-key router, named-map repair script or integration branch.

The production answer is a **new V2 chassis inside the same repository** with strict boundaries and staged migration. V1 remains runnable as a behavior museum until each replacement is proven, then its old authority is deleted. We preserve product requirements and proven techniques; we do not preserve prototype ownership merely because code exists.

The optimization target is **minimum long-term regret**, not minimum migration work.

### V1-to-V2 implementation reuse rule

V1 is a reference implementation and behavior catalogue, not a code donor by default. For every V1 -> V2 migration, choose deliberately:

1. **Reuse/import the implementation** only when current review shows the implementation itself is good: it already fits the V2 ownership boundary, server-authority, input/data/networking, lifecycle and proof contracts, and reuse does not carry V1 compatibility or repair architecture with it. Record the concrete reason and source lineage in the work item or PR.
2. **Reimplement the behavior** when the requirement, algorithm, tuning or lesson is valuable but the V1 code shape violates V2 architecture or would need compatibility scaffolding.
3. **Discard it** when it is prototype repair, obsolete behavior, duplicate authority or otherwise not worth preserving.

"Works in V1", "already exists", or "faster to copy" is not sufficient justification. Do not bulk-copy, rename-wrap, namespace-wrap, or temporarily transplant V1 runtime code into V2 to defer the architecture decision. Direct reuse is allowed when it is the best implementation for V2; otherwise keep the behavior or lesson and write the V2-native implementation.

### The blunt assessment

V1 is not a coherent game framework. It is a large collection of good experiments connected by increasingly expensive compatibility code.

Specific evidence:

- `Ap3Character` became the place where unrelated avatar, animation, mount, grapple, weapon, flight, camera and repair behavior accumulated.
- `p3PlayerControllerInputFix.cpp` became an arbitration engine because physical keys, gameplay actions, RTS mode, pawn swaps and feature ownership were never separated cleanly.
- RTS camera mode changes possession even though RTS is a view/control mode, creating restoration, transition, combat and survival edge cases.
- Several per-player systems were attached through PlayerController/world subsystems and `GetFirstPlayerController()` assumptions.
- Fast gameplay prototypes intentionally read raw keys from auto-wired world subsystems. That was effective for experimentation and is unacceptable as production input architecture.
- Construction/earthworks prototypes mutate important gameplay/world state from client-local paths that were not designed as server-authoritative transactions.
- Runtime content repair has repeatedly compensated for import/asset problems that should have failed staging instead.
- The procedural survival world and named showroom bootstrap paths proved useful quickly, then produced world-specific assumptions, startup fatals and overlapping ownership.
- HUD work repeatedly collided in one central rendering surface.
- Animation diagnosis repeatedly needed one-off GitHub workflows containing large embedded scripts instead of one reusable test harness.
- Parallel feature development repeatedly converged on central files and then required consolidation branches.

None of this means the experiments were wasted. They are the requirements catalogue and regression evidence for V2.

---

# Part I — Governing architecture

## 1. Eight non-negotiable rules

### 1.1 Stable core, feature-local implementation

A feature should normally add code/assets inside its own plugin and consume published core contracts. It should not add another field, switch statement or special case to the base Character, PlayerController, GameMode, GameState or HUD.

### 1.2 Player is not the body

`AP3PlayerState` is the persistent replicated gameplay identity. A Pawn is the currently controlled body. Player inventory, persistent ability system state and player-level progression survive pawn swaps naturally.

### 1.3 Client sends intent; server commits gameplay truth

Local prediction and previews are encouraged. Inventory mutation, damage, construction placement, resource harvesting, terrain edits, match-relevant status/economy state and persistent world mutation are authoritative server decisions.

### 1.4 Data identifies content; runtime code does not know content paths

Durable gameplay definitions use Primary Asset IDs and soft references. A production runtime system must not gain a hard-coded `/Game/...` path or exact actor-name repair because a new asset was added.

### 1.5 Proof is a product subsystem

A feature is not done because source compiles. V2 has reusable static, in-engine, multiplayer/session and visual/animation proof. User-visible rejection remains authoritative even when automation is green.

### 1.6 The integrated product is the unit of progress

A merged subsystem, closed child issue or green proof profile is evidence about that subsystem. It is not product readiness. The default production Experience must remain a runnable walking skeleton, and every accepted capability must be composed into and exercised through that path before the parent product can count it as delivered.

### 1.7 Work in progress follows bottleneck capacity

Heavy editor/build/runtime work is bounded by the machine capacity that can safely integrate, build and run it. That resource limit applies to the scarce heavy execution surface, not to the number of disjoint source/product tasks the swarm may advance. When heavy capacity is occupied, workers must avoid duplicate hydrated workspaces and conflicting heavy runs, but they continue safe disjoint source, test, review, content, issue, proof-preparation, or integration work instead of treating a numeric source-lane count as an admission gate or stop condition. Converge and merge ready work promptly; do not create branch churn merely to stay busy.

### 1.8 Proof must collapse uncertainty

Run the cheapest proof that can falsify the current claim, then advance to runtime only when required. After the first exact failure, an identical build or capture is forbidden until source, content, environment or route has materially changed. Proof infrastructure is shared and budgeted; workflow volume, receipt volume and repeated captures are not progress.

---

## 2. Module and plugin topology

The hard architecture boundary is **ordinary Unreal runtime/editor plugins**, which are mature engine infrastructure. We do not make the whole game dependent on Game Features/Modular Gameplay lifecycle behavior because Epic still labels those plugins Beta in UE5.8.

```text
p3 host project
│
├── Plugins/P3/P3Core
│   ├── stable IDs and Gameplay Tags
│   ├── Experience/Pawn/feature definition types
│   ├── base framework classes and interfaces
│   └── initialization contracts
│
├── Plugins/P3/P3Gameplay
│   ├── GAS integration
│   ├── inventory/item/equipment substrate
│   ├── interaction/targeting substrate
│   └── shared gameplay transactions
│
├── Plugins/P3/P3UI
│   ├── CommonUI application/screen shell
│   ├── UMG gameplay HUD hosts
│   └── presentation-model interfaces
│
├── Plugins/P3/P3World
│   ├── persistence service
│   ├── stable world/spatial service contracts
│   └── environment-state interfaces
│
├── Plugins/P3/P3Testing
│   ├── Functional Test helpers
│   ├── deterministic scenario/receipt types
│   └── test-only actors/controllers
│
├── Plugins/P3/P3Editor
│   ├── Data Validation
│   ├── staging/import/promotion tools
│   ├── deterministic editor/capture tools
│   └── commandlets
│
└── Plugins/P3/Features/
    ├── P3Combat
    ├── P3Construction
    ├── P3TowerDefense
    ├── P3Earthworks
    ├── P3Flight
    ├── P3AI
    └── P3World_<BiomeOrRuleset>
```

### Dependency direction

```text
Feature -> P3Gameplay -> P3Core -> Engine
Feature -> P3World    -> P3Core -> Engine   (only if world services are needed)
P3UI   -> P3Gameplay/P3Core public read models only
P3Testing/P3Editor -> runtime modules as needed
```

Feature-to-feature private dependencies are forbidden. If two features genuinely need the same mechanism, the reusable contract graduates downward through a separate core-change lane after demonstrated reuse.

### Game Features / Modular Gameplay decision

Epic's Game Features and Modular Gameplay solve a real problem — standalone feature activation and component injection — but both are still labeled Beta in UE5.8. V2 therefore adopts **plugin-local ownership and Experience composition** immediately, but does not require dynamic Game Feature plugin activation to boot the game.

A future `P3GameFeaturesBridge` may use GameFeatureData/`UGameFrameworkComponentManager` behind a p3-owned interface if a concrete need for runtime activation/unloading appears. Removing that bridge must not require rewriting feature gameplay.

---

## 3. Gameplay Framework ownership

| Unreal owner | V2 owns | V2 must never become |
| --- | --- | --- |
| `UGameInstance` / GI subsystem | session/bootstrap services, local profile/session state | global gameplay god object |
| `AP3GameMode` | server-only rules, spawn/respawn, Experience selection | player state storage |
| `AP3GameState` | replicated shared Experience/world/match state | UI renderer or per-player manager |
| `AP3PlayerState` | persistent replicated player identity, ASC, inventory, progression-backed state | camera/input owner |
| `AP3PlayerController` | local input, camera/view modes, UI bridge, client request entry | combat/build/inventory implementation |
| Pawn/Character | physical body, collision, movement, avatar presentation | permanent player identity or feature warehouse |
| Actor Components | bounded behavior owned by their actor | arbitrary global managers |
| World subsystems | genuinely world-scoped registries/services | hidden per-player tick loops |

### Required base classes

- `AP3GameMode`
- `AP3GameState`
- `AP3PlayerState : IAbilitySystemInterface`
- `AP3PlayerController`
- `AP3CharacterBase` for ordinary grounded humanoids
- `UP3PawnExtensionComponent` for PawnData/PlayerState ASC initialization
- `UP3ExperienceManagerComponent` on GameState

### Initialization state machine

Do not rely on lucky `BeginPlay` order or timer delays.

```text
InitState.Spawned
InitState.DataAvailable
InitState.DataInitialized
InitState.GameplayReady
```

Input binding, ability grants, UI readiness and feature actions wait for their declared dependencies. Any future timer added merely to “let another system initialize” is an architecture warning and needs a named reason.

---

## 4. Experience composition without a new god object

### `UP3ExperienceDefinition` — Primary Data Asset

Defines a runnable product/test configuration:

- default PawnData;
- feature-set assets;
- game rules/config;
- default input config;
- UI root/layout policy;
- world/environment profile;
- test/capture profile where relevant.

Examples:

```text
XP_V2Foundation
XP_Sandbox
XP_FlightLab
XP_Showroom
XP_Automation
```

### Default-product walking skeleton and readiness ledger

Exactly one Experience is the default production product at a time. It must boot from project defaults without command-line composition overrides and remain runnable after every integrated merge. Labs, showrooms and deterministic test Experiences are valuable, but they cannot substitute for the default product path.

Each required product domain is tracked against the default Experience with one of four states:

| State | Meaning | Counts toward parent readiness |
| --- | --- | --- |
| `ABSENT` | required behavior/content is missing | no |
| `IMPLEMENTED` | source/content exists, but appropriate behavior proof is missing | no |
| `SYSTEM_PROVEN` | the subsystem passes its bounded deterministic acceptance | no |
| `DEFAULT_PATH_PROVEN` | the subsystem is composed into the current default product and passes its required normal-input/runtime/session/visual acceptance | yes |

The ledger records owner, exact head, Experience/PawnData, proof level and first unmet gate. A child issue may close at `SYSTEM_PROVEN` when its bounded contract permits, but #599/#611 and V2-07 remain open until every required row is `DEFAULT_PATH_PROVEN` on one compatible head.

### `UP3FeatureSet` — Primary Data Asset

A feature-set asset may contribute data through stable contracts, for example:

- Ability Sets;
- input configs/mapping contexts;
- UI extension definitions;
- world-service/config classes;
- permitted PawnData;
- Gameplay Tags/capabilities.

All implementing code remains in ordinary feature plugins. V2 does **not** require runtime hot-unloading in the first production architecture.

---

## 5. Gameplay Tags are the semantic vocabulary

Use native/config Gameplay Tags for extensible cross-system concepts:

```text
State.Alive
State.Dead
State.Mode.RTS
State.Mode.Build
State.Movement.Flight
Capability.Build
Capability.Earthworks
Ability.Action.Interact
Ability.Action.Attack.Primary
Ability.Traversal.Grapple
InputTag.Move
InputTag.Look
InputTag.Interact
InputTag.Build.Place
Item.Resource.Wood
Build.Category.Wall
World.Weather.Storm
GameplayCue.Weapon.Fire
```

Closed, implementation-local state can remain enums. Cross-feature semantic concepts should not become competing booleans/enums in separate systems.

Each feature owns its tag source file. Core tag additions are reviewed as API changes.

---

# Part II — Engine technology decisions

## 6. Networking: Iris is the V2 target, not an indefinite experiment

Epic's UE5.8 release notes state that Iris is production-ready for licensees. Older individual Iris pages still contain Experimental-era warnings, so the documentation is internally inconsistent. For a new V2 multiplayer architecture on UE5.8, the current release-note milestone is the stronger signal.

Decision:

- **Enable and prove Iris during V2 foundation.**
- Gameplay code stays backend-agnostic: normal replicated properties, RPC semantics and authoritative state boundaries.
- Use existing Fast Array definitions initially; Iris supports them. Adopt `FIrisFastArraySerializer` only when profiling/dirty-tracking benefit is demonstrated.
- Do not design around Replication Graph: Iris and Replication Graph are mutually exclusive network-driver choices. Iris filtering/prioritization is the intended scaling route.
- If current runtime evidence exposes a concrete Iris failure, research and resolve that exact networking problem without changing gameplay authority contracts merely to satisfy old paperwork.

This is an early architecture choice because switching replication foundations after persistent world systems exist would be much more expensive. It is not a permission gate for unrelated feature work.

---

## 7. Gameplay Ability System is foundational

GAS becomes the standard substrate for **discrete gameplay actions, effects and cross-cutting state**, including:

- attacks;
- interaction/harvesting;
- dash, grapple, slam, air recovery and similar traversal actions;
- build/repair/salvage/fortify requests;
- terrain-edit commits;
- item/equipment-granted actions;
- cooldowns/costs where appropriate;
- status effects;
- action animations;
- cosmetic Gameplay Cues.

GAS does **not** replace:

- the continuous movement solver;
- inventory item counts;
- world spatial indexes;
- terrain data structures;
- save storage.

### ASC location

`UP3AbilitySystemComponent` lives on `AP3PlayerState`. The current Pawn is the ASC avatar. Pawn-specific Ability Sets are granted/revoked as bodies/equipment change.

This is deliberate: switching humanoid -> bird -> other body should not destroy the player's persistent abilities/status ownership.

### Gameplay Cues + Niagara

Gameplay Cues are cosmetic only. Use them to drive Niagara/audio/camera feedback for replicated actions. Damage, terrain changes, inventory and other gameplay truth never depend on receipt of a cue.

---

## 8. Input: Enhanced Input only for gameplay

V2 forbids raw-key polling in gameplay systems and forbids a global `InputKey` compatibility switchboard.

### `UP3InputConfig` — Primary Data Asset

Maps semantic Gameplay Tags to Input Actions. Feature-owned Input Mapping Contexts contain physical mappings.

```text
physical key/gamepad
    -> Input Mapping Context
    -> Input Action
    -> InputTag.*
    -> controller/ASC semantic dispatch
    -> ability or mode command
```

Context priority handles collisions. Gameplay code does not know that an action is currently `G`, `T`, `LMB`, etc.

### CommonUI integration caution

CommonUI is useful for p3's layered menus/navigation, but the UE5.8 page specifically covering CommonUI + Enhanced Input still carries Experimental-era caution. V2 therefore keeps **gameplay Enhanced Input and UI routing logically separate**. CommonUI owns screen navigation/Accept/Back/modal behavior; gameplay IMCs own gameplay actions. A future integration improvement can be adopted without changing gameplay semantics.

---

## 9. Camera: p3-owned stable camera-mode stack

Do not build production on the Experimental Gameplay Cameras plugin yet.

Use proven `APlayerCameraManager`, `UCameraComponent`, SpringArm and ViewTarget mechanisms behind a small p3 camera-mode abstraction.

Current player-facing priority modes are:

- first-person;
- third-person/default;
- aiming/shoulder variants only as support for first-/third-person gameplay;
- flight-specific camera behavior only where required by accepted first-/third-person traversal;
- RTS overview is deferred from current implementation and proof;
- test/capture camera as proof tooling, not a player-view milestone.

### Future RTS architecture (deferred): RTS is not possession

RTS is a **future control/view mode**, not a different player body. Do not implement, integrate, polish or prove RTS camera/input/UI during the current first-/third-person milestone unless the user explicitly reactivates RTS work.

V2 enters RTS by:

1. granting `State.Mode.RTS`;
2. activating the RTS input context;
3. switching/blending ViewTarget to a local RTS camera rig/mode;
4. keeping the gameplay Pawn possessed and server-present;
5. suppressing character movement/actions through tags/input context rules, not by losing the Pawn.

Exiting reverses the camera/input state. The exact Pawn never needs to be rediscovered or repossessed.

Actual body changes — humanoid to bird, for example — remain real possession changes backed by persistent PlayerState.

---

## 10. Movement

### Grounded humanoids

Use `ACharacter` + Character Movement Component. CMC remains Epic's battle-tested production option; Mover is still being developed toward leaving Experimental in UE5.8.

### Special bodies

Flight/swimming/unusual locomotion uses feature-owned `UPawnMovementComponent` subclasses with data profiles. The movement solver is not copied once per species.

### Mover

Maintain only an isolated technology-evaluation lane. Promote only after Epic production status and p3 benchmark evidence justify it.

---

## 11. Animation

The current research/history establishes a clear permanent rule: **fix imported scale/orientation/skeleton compatibility at the asset/animation contract, not in runtime character code.** The 100x scale regression and per-character animation overrides are examples of what V2 must prevent.

### `UP3AnimationProfile` — Primary Data Asset

Defines a body family's animation strategy:

- skeleton/body-family identity;
- IK Rig/IK Retargeter where required;
- locomotion strategy;
- action montage/slot policy;
- procedural correction policy;
- socket/equipment compatibility;
- validation requirements.

### Production hierarchy

1. Correct asset scale/orientation and skeleton metadata.
2. IK Rig / IK Retargeter normalizes supported body families.
3. Humanoid locomotion uses Motion Matching when the production animation library has enough coverage; otherwise use a conventional AnimBP deliberately, not as a failure fallback.
4. Gameplay actions/montages are triggered by abilities/tags.
5. IK/Control Rig/procedural secondary motion adds correction/presentation only.

Runtime IK Retargeting is allowed when it provides a measured product advantage; default shipping paths should prefer deterministic pre-authored/retargeted content where practical.

### Procedural animation invariant

A procedural pose writer operates relative to a cached reference/bind/base pose. It must never repeatedly read its own already-modified transform and accumulate offsets frame after frame. The Owl/Hummingbird spiral regression is the canonical failure example.

---

## 12. UI

V2 replaces the central Canvas HUD accumulation with:

- CommonUI for application/menu/modal/layer navigation;
- UMG for gameplay HUD/widgets;
- feature-local UI extensions;
- event-driven presentation models/read models.

MVVM may be used behind an adapter where useful, but the UE plugin remains Beta and is not a core dependency.

### UI rule

Widgets do not iterate the world to discover wave spawners, defense cores, inventory or build state each frame. Authoritative systems publish presentation state/events; UI renders them.

Input help is generated from active action mappings where practical. Hard-coded strings such as `G = ...` are not authoritative gameplay documentation.

---

## 13. Primary Assets and content identity

Use Primary Data Assets + Asset Manager for durable definition identity:

- `UP3ExperienceDefinition`
- `UP3PawnData`
- `UP3FeatureSet`
- `UP3ItemDefinition`
- `UP3EquipmentDefinition`
- `UP3BuildDefinition`
- `UP3AnimationProfile`
- `UP3FlightProfile`
- environment/world profiles where useful.

Stable `FPrimaryAssetId` is what save data, replicated definitions and long-lived gameplay records reference. Object paths are an implementation detail behind soft references.

Asset redirects/migrations are handled deliberately; no persistent state derives identity from actor labels or package accidents.

---

## 14. External asset handoff boundary

p3 owns **ingestion into the game**, not upstream generation.

Accepted external handoff:

```text
external source files + optional provenance/metadata
    -> p3 staging folder
    -> P3Editor import adapter (Interchange where appropriate)
    -> p3 normalization/validation
    -> deterministic preview/capture
    -> ACCEPT or REJECT
    -> p3 production asset + Primary Asset definition
```

P3Editor validation may verify:

- file/package naming;
- scale/orientation;
- material/texture binding;
- collision;
- skeleton/retarget compatibility;
- required sockets;
- triangle/texture/performance budgets by asset class;
- invalid hard references across plugin boundaries;
- production/staging cook policy.

It does not own how the source mesh/texture/rig was generated.

Rejected/staging content must not become reachable from production Primary Assets or shipping cook by accident.

---

# Part III — Major gameplay systems

## 15. Player state, items, inventory and equipment

### PlayerState

`AP3PlayerState` owns:

- ASC;
- persistent player inventory;
- player-level progression/session identity;
- persistent gameplay state that must survive body swaps.

### Inventory

Replace the permanent C++ resource enum with generic item definitions.

`UP3InventoryComponent` owns a replicated Fast Array of item stacks/instances.

Examples:

```text
Item.Resource.Wood
Item.Resource.Stone
Item.Resource.Metal
Item.Resource.Soil
Item.Consumable.*
Item.Tool.*
```

Server mutation APIs fail closed on non-authority. Costs/refunds are atomic transactions, not a sequence of loosely related `RemoveResource` calls.

### Equipment

`UP3EquipmentComponent` lives on the current Pawn and references persistent inventory/equipment definitions from the player.

Equipment may:

- attach presentation actors/components;
- grant/revoke Ability Sets;
- provide animation/camera tags;
- expose canonical sockets;
- trigger Gameplay Cues.

Weapons therefore leave the base Character entirely.

---

## 16. Interaction

One semantic interaction path replaces one-off harvest/mount/use keys.

```text
InputTag.Interact
 -> GA_Interact
 -> target query
 -> IP3InteractableTarget returns options
 -> server validates chosen option
 -> target feature executes transaction
```

Use Smart Objects when the interaction is a reservable world activity shared by AI/players (stations, seats, work points, etc.). Simple pickups do not need a Smart Object merely because the system exists.

Harvesting, mounting, stations, doors and similar interactions share target/authority semantics while retaining feature-local execution.

---

## 17. Combat, traversal and VFX

The current kinetic pulse, gravity pull, slam, air recovery, grapple, dash, weapon and bomb experiments are **product capability evidence**, not production implementations.

V2 ports worthwhile actions as Gameplay Abilities:

- `GA_Attack_Primary`
- `GA_Attack_Secondary`
- `GA_Melee`
- `GA_Grapple`
- `GA_Dash`
- `GA_GroundSlam`
- `GA_AirRecovery`
- `GA_KineticPulse`
- `GA_GravityPull`

Exact product names/tuning can change; the framework does not.

### Damage

- server authoritative;
- common damage execution/calculation;
- team/faction/friendly-fire policy outside generic health;
- physical projectile actor only when actual projectile simulation matters;
- cosmetic tracer/impact/spell feedback via Gameplay Cues + Niagara.

GameplayCue packet loss may remove a cosmetic effect; it may never remove gameplay damage/state.

---

## 18. Construction V2

This is a full replacement of the V1 ownership model while preserving useful gameplay requirements: grid/snap placement, structural support, costs, visual variants, paint-build, repair, salvage, fortification, tower pieces and destruction.

### `UP3BuildDefinition` — Primary Data Asset

Contains:

- stable ID;
- category/tags;
- item cost;
- authoritative footprint;
- grid/rotation policy;
- snap profile;
- support rules;
- placed actor class;
- soft visual reference;
- optional destruction presentation;
- UI presentation.

No native transient catalog and no hard-coded per-asset `/Game/...` path list.

### Local preview

A dedicated non-replicated preview object/component:

- traces cursor/world;
- predicts grid/snap/support/collision;
- renders valid/invalid feedback;
- never spends inventory;
- never spawns final gameplay structures.

### Server placement transaction

```text
client sends intent:
  BuildDefinitionId
  desired transform
  optional snap/support target identity

server:
  resolves BuildDefinition
  validates player state/mode/range
  recomputes grid/snap/support/collision
  validates inventory
  atomically consumes cost
  spawns authoritative structure
  assigns BuildDefinitionId + PersistentGuid
  registers it with construction spatial service
  replicates result
```

### Spatial service and support graph

`UP3ConstructionWorldSubsystem` tracks finalized structures/spatial cells/snap points. Per-frame preview must not scan every build actor in the world.

Structural support is an explicit graph/rule service. Removing a support updates affected structures through events, not repeated whole-world scans.

### Paint-build

Shift/paint-style placement survives as a product capability, but becomes a bounded stream of ordinary placement intents. Server-side rate/spacing/validation prevents client spam and every placement is independently authoritative.

### Damage/destruction

Durable structural health/state is gameplay truth. Chaos Geometry Collections are one presentation of accepted structural damage. A structure without a GC still dies/clears collision correctly; a GC simulation never becomes the persistence record.

---

## 19. RTS V2 - deferred

RTS is a future feature layered over the same player/world, not a parallel game framework. **It is not current implementation, integration, polish or proof work. First-person and third-person gameplay take priority until the user explicitly reactivates RTS view work.** The constraints below are retained only to preserve the later architecture boundary.

- `State.Mode.RTS` controls capability/input blocking.
- local RTS camera mode/ViewTarget; no possession swap.
- dedicated Enhanced Input context for pan/zoom/build/abilities.
- gameplay Pawn remains in world, vulnerable unless game rules explicitly say otherwise.
- build selection and ability selection are presentation/controller state; inventory/ability truth stays on PlayerState/ASC.
- returning from RTS does not require pawn archaeology.

The old research requirement for smooth camera blending remains. The implementation changes because the old possession mechanism was the wrong abstraction.

---

## 20. Tower Defense V2

Tower Defense composes existing V2 systems instead of owning copies:

- Construction supplies towers/walls/core structures.
- Combat/GAS supplies attacks/damage/effects.
- AI supplies enemies and behavior.
- GameState/feature director supplies wave state.
- UI reads replicated wave/core presentation state.

### `AP3WaveDirector` / equivalent authoritative feature state

Owns:

- setup/inter-wave timing;
- wave number;
- active enemy count;
- spawn failure policy;
- defeat/core state;
- completion conditions.

Wave progression waits for actual living-enemy resolution, preserving the useful V1 contract.

### Navigation

Runtime construction must affect pathing through a deliberate Navigation System strategy. Prefer nav modifiers/dynamic updates appropriate to the test world instead of globally making every map maximally dynamic. The acceptance map must prove enemies reroute after runtime construction.

---

## 21. Match lifecycle and economy — no survival subsystem

V2 does **not** migrate or require V1 hunger/thirst/exposure/shelter upkeep. There is no required `P3Survival` feature, survival AttributeSet, depletion loop, shelter-as-survival query, or survival meter on the V2 roadmap.

### Defeat/respawn

GameMode owns respawn policy. PlayerState survives; transient Pawn state is destroyed/reset with the body. Respawn protection is an explicit Gameplay Effect/tag with a defined duration.

### Economy

Finite match economy belongs to the product rules that use it. The current Lane War economy is gold from creep-related play and time, spent on additional allied creep/minion spawns and upgrades. Unlimited/sandbox resources may exist only as explicit test/Experience configuration.

Environmental hazards and combat status effects may exist when they directly serve match gameplay, but they are not survival upkeep and must not recreate hunger, thirst, exposure, temperature, shelter-pressure, or similar maintenance meters.

---

## 22. World/environment V2

Production large worlds use Unreal's modern world stack:

- World Partition;
- One File Per Actor;
- Data Layers;
- HLOD;
- PCG for scalable procedural dressing/generation;
- partitioned/hierarchical PCG where scale requires it.

The V1 `BeginPlay` procedural survival-world actor remains a prototype reference, not the production world generator.

### Data Layer conventions

Examples:

```text
Environment.Base
Environment.Foliage
Gameplay.POI
Gameplay.Construction
Gameplay.Events.<Name>
Test.Debug
```

### Environment state vs presentation

Authoritative/shared semantics:

```text
Time phase
Weather state
Wind intensity
Hazard pressure
```

Presentation director(s) translate state into sky/fog/lights/Niagara/material/audio. Gameplay never identifies weather by exact light actor name.

---

## 23. AI V2

Default high-level architecture:

```text
AIController/Pawn
  -> perception/navigation
  -> StateTree for high-level behavior where appropriate
  -> Smart Objects for reservable world interactions
  -> GAS for actions/effects when participating in combat/abilities
  -> Gameplay Tags for shared semantic state
```

Behavior Trees remain allowed when their structure is a better fit. This is not a technology purity contest.

Mass Entity is **not** the default AI implementation. Create a Mass lane only when design/profiling proves a genuine high-agent-count requirement.

---

## 24. Earthworks V2

V1 proved the product loop: dig, fill, grade, trench, berm, brush sizes, preview-before-commit, shared view adapters and undo. Its resource-coupled soil accounting and tagged/isolated deformable-ground assumptions are not V2 product behavior. Its `UProceduralMeshComponent` implementation is not the production target; Epic still marks that component Experimental in UE5.8.

### Authoritative data model

Truth is a chunked logical heightfield/edit domain, not triangle mesh state. The production Earthworks domain covers the full ordinary playable ground area of the map (or equivalent streamed world chunks) in world space. It is not opt-in per material, biome, PhysicalMaterial, landscape layer, ground actor class/tag, or hand-authored deformable patch.

```text
FP3EarthworkCommand
  ToolTag
  Chunk/RegionId
  WorldPosition
  Direction
  BrushProfileId
  ClientSequence
```

Server validates:

- player capability/range;
- playable world/chunk bounds;
- tool/brush;
- edit bounds;
- authoritative undo conditions.

It then modifies authoritative heightfield data. Dig, fill, grade, trench, berm and undo are free terrain tools: they do not require or produce Soil, inventory items, harvested resources, gold, mana, or another affordability resource. Ordinary playable terrain is editable by default regardless of its visual/material ground type. An exception must be a deliberate world-rule exclusion such as out-of-map/void or an explicitly immutable landmark, never an incidental material/tag mismatch.

### Derived rendering/collision

Use `UDynamicMeshComponent` from Geometry Framework for runtime terrain chunks. It supports partial render updates, deferred collision regeneration and async collision cooking. Geometry Script helper functions may be used behind an isolated implementation helper, but Geometry Script itself remains Beta and is not the domain contract.

Rendering and collision are derived from logical state. Saving/replication never serializes a giant procedural triangle array as the primary truth. At production cutover, authored placeholder/static floor collision under the Earthworks domain must be disabled or removed so digging cannot expose an invisible undeformed floor; the Earthworks collision surface becomes the ground authority across its playable bounds.

### Player-view adapters

There is one Earthworks domain.

- current first-person and third-person play use the personal camera-aim preview.
- both current views commit the same authoritative command type.
- a future RTS cursor/world-preview adapter may consume that same domain after RTS work is reactivated; it is not part of the current milestone.
- release-to-commit preserves the last shown valid preview; commit does not secretly retrace to a different point.

### Undo

Undo is an authoritative inverse/record operation over terrain state. It has no resource affordability or refund requirement.

---

## 25. Flight and creature movement

Keep the useful V1 `FFlightProfile` insight, replace the static/species-controller implementation.

### `UP3FlightProfile` — Primary Data Asset

Contains movement/attitude/wingbeat/capability tuning. Species-specific values are data.

### `UP3FlightMovementComponent`

One flight movement solver handles common flight state/physics. Thin body-family Pawns provide collision/presentation differences only when genuinely required.

Animation/presentation is separate from movement truth:

- authored sequences/AnimBP where available;
- procedural secondary motion when appropriate;
- all procedural bone transforms reference base pose;
- no copy-pasted movement state machines for Eagle/Owl/Hummingbird/Macaw.

---

# Part IV — Persistence, testing and production tooling

## 26. Persistence

Introduce persistence before large construction/earthworks worlds accumulate.

### `UP3PersistenceSubsystem`

Server-authoritative serialization coordinator. Domain systems provide versioned records.

Use `USaveGame`/`AsyncSaveGameToSlot` for local/server-file persistence initially. The storage backend can be abstracted later if an online service becomes a real requirement; do not build a database layer speculatively.

Example durable schema:

```text
SaveVersion
ExperienceId
WorldId
PlayerRecords[]
  PlayerStableId
  Inventory
  progression/loadout
WorldState
  semantic environment/progression
Buildings[]
  PersistentGuid
  BuildDefinitionId
  Transform
  durable structural state
EarthworkChunks[]
  ChunkId
  base version
  compact checkpoint/delta state
FeatureRecords[]
```

Never save raw UObject pointers or transient actor names.

Every schema change has an explicit version migration or an explicit reset decision.

---

## 27. Showroom is a test/showcase product, not a gameplay foundation

The existing showroom work taught an important ownership lesson: one writer per floor/grass/lighting/sign surface and visual proof paired with live state. Keep that principle.

V2 creates a dedicated `XP_Showroom` / showcase map whose purposes are:

- present accepted game assets;
- inspect materials/scale/collision/animation;
- deterministic camera/capture;
- benchmark representative asset load;
- user visual review.

Showroom scripts do not become production world/environment authority. Named `SHOWROOM_Sun`, exact map names and ring repair compatibility paths remain V1-only.

---

## 28. Testing/playtest/capture architecture

The current p3 workflow research is one of the strongest things to preserve, but the implementation must stop multiplying giant feature-specific workflow YAMLs and embedded Python scripts.

### Four proof layers

**L0 — static/unit**

- C++ Automation Tests;
- native Data Validation for required Primary Assets, soft dependencies, package loadability, authored metadata and promoted-content hydration before expensive runtime work;
- dependency/path checks;
- pure calculation/transaction tests;
- save migration tests.

**L1 — in-engine Functional Tests**

Canonical deterministic test maps prove possession, abilities, inventory, construction, AI, save/load, etc.

**L2 — session/multiplayer**

Gauntlet launches the appropriate server-mode + client or packaged/editor sessions for end-to-end lifecycle, travel, replication, late join, crash/hang and long-running smoke.

**L3 — visual/animation/user-path**

- screenshot functional tests/comparison for deterministic visuals;
- Rewind Debugger/Animation Insights for animation failures;
- deterministic mid-action capture;
- MCP/live Unreal proof when the acceptance requires actual local user-path/editor truth.

### Two kinds of acceptance are deliberately distinct

1. **System acceptance** may call a semantic gameplay/test API to prove a subsystem deterministically.
2. **User-path acceptance** drives the normal Enhanced Input/action path and captures the real result.

A test-only shortcut can never satisfy a user-path contract.

### Mandatory default-product smoke

Every merge that changes product composition, a required gameplay domain, production content or project defaults runs one stable smoke profile against the actual default map/GameMode/Experience. It records the selected Experience and PawnData, reaches normal gameplay input, exercises the changed domain at the strongest bounded level available, and fails closed when required content cannot load. System-specific profiles supplement this smoke; they never replace it.

Proof retries follow a change ledger. The first exact blocker is preserved with head, route and environment. A rerun must name the source/content/environment/route change expected to invalidate that blocker. Repeating the same capture or workflow without such a change is control-plane churn.

### One reusable verification runner

Replace per-feature workflow proliferation with:

```text
.github/workflows/v2-verify.yml
scripts/v2/verification/Invoke-P3Verification.ps1
P3Testing scenario definitions
P3VerificationReceipt.json schema
```

The workflow accepts a scenario/profile and exact ref. Feature lanes add test scenarios, not entire bespoke workflow engines.

### Receipt minimum

- repo/branch/SHA;
- map + Experience ID;
- server/client topology;
- exact PawnData;
- semantic action/input exercised;
- authoritative before/mid/after state;
- relevant Primary Asset IDs;
- screenshot/trace artifact IDs when applicable;
- build/test results;
- editor/PIE owner;
- cleanup/release state;
- final proof result; an unavailable proof route is recorded as `PENDING`/`NOT_RUN` and never grants permission to stop implementation.

### Existing Unreal ownership policy remains

- never force-kill Unreal;
- never stop user-owned PIE;
- only end an agent-owned PIE still owned by the agent;
- Project Browser is launch failure;
- static proof is not runtime proof;
- Editor Python/commandlets are editor/batch tools, not fake gameplay input;
- user-visible `still broken`/`no change` = `REJECTED / NOT_PROVEN`.

---

## 29. CI and GitHub

GitHub remains the p3 control plane/source of truth.

### Main protection

Branch protection and stable CI checks are useful repository safeguards, but their configuration state is not permission to implement or continue product work.

One reusable V2 verification status should:

- verify V2 dependency/path rules;
- validate lane metadata;
- run fast tests for every PR;
- detect whether C++/content changes require self-hosted Unreal compile/validation;
- always report one stable required-check name so conditional workflows do not bypass protection.

### Worker topology

```text
main
 -> short-lived bounded branch/worktree
 -> draft PR immediately
 -> feature-local paths
 -> reusable verification profile
 -> merge OR explicit disposition
```

No long-lived `integration/*` or “master-unification” branch is the normal V2 route.

One named owner holds the current default-product integration path, but branch/lane count is not an admission-control mechanism. Resource limits are specific to the scarce operation: only heavy editor/build/runtime work is serialized or throttled by heavy-capacity availability. When that capacity is full, the swarm continues safe disjoint source implementation, review, repair, test reduction, asset validation, proof preparation, issue work, or integration without starting duplicate hydrated Unreal workspaces or conflicting heavy runs. Existing ready WIP should still be converged promptly, and workers should avoid unnecessary branch fan-out, but no fixed numeric source-lane ceiling may force idle time.

The queue exposes branch age, owner, readiness-ledger row, first unmet gate and integration destination. No lane may hide behind a closed child issue or a locally green receipt. The reusable verifier has a run budget and deduplicates equivalent exact-head events; adding another workflow is an architecture decision requiring evidence that the stable verifier cannot express the scenario.

When useful, a lane records one of:

```text
MERGED
SUPERSEDED_BY=<ref>
REJECTED=<reason>
ABANDONED=<reason>
```

### Core-change rule

If a feature requires modifying `P3Core`, `P3Gameplay`, base framework actors or another feature's public API, keep that shared change narrow and explicitly owned. Feature workers do not silently redesign the chassis, but paperwork does not stop independent implementation.

---

# Part V — p3 research/branch disposition

The following is the synthesis of p3's accumulated research/prototype lanes. This is deliberately a **requirement disposition**, not a merge plan.

| Research/prototype family | Product knowledge retained | V1 implementation disposition |
| --- | --- | --- |
| gameplay sprint / mobility | pulse, pull, slam, recovery, grapple, dash, shoulder camera experiments | **REBUILD** as GAS abilities/camera modes; discard raw-key world auto-wire |
| input/combat router + InputFix | contextual mode ownership and conflicting-action evidence | **DISCARD** routers/raw-key arbitration; Enhanced Input + tags/abilities replaces it |
| basebuilding / Building15 | visual QA gating, recipes, snap/support, costs, variants, paint-build, repair/salvage/fortify | **REBUILD** around Primary Assets + server transaction + spatial service |
| RTS camera | smooth transition, no visible cut, mode-specific controls, player remains at risk | **REBUILD** without possession swap |
| tower defense | core/waves, runtime construction affecting pathing, setup window, wave-clear gating | **PORT CLEANLY** onto Construction + AI + Combat + GameState |
| survival | V1 hunger/thirst/exposure/shelter experiments; independent defeat/respawn/economy lessons may still be useful | **DISCARD** survival upkeep as a V2 product requirement; retain only independently owned non-survival mechanics where current product needs them |
| earthworks | common RTS/personal domain, preview/commit, conservation, brushes, trench/berm, undo | **REBUILD** logical heightfield + DynamicMesh chunks; discard ProceduralMesh/raw keys |
| flight profile | species tuning belongs in data | **KEEP IDEA / REBUILD** as PrimaryDataAsset + shared movement component |
| procedural bird pose | base-pose-relative secondary motion | **KEEP INVARIANT**; discard duplicated per-species controller/state machines |
| character import/retarget fixes | authored scale/orientation, IK Retargeter, no runtime 0.01 repair | **KEEP INVARIANT**; V1 per-character runtime repair becomes deletion target |
| combat/projectile | server-authority, projectiles only when physical, friendly-fire policy | **PORT SEMANTICS** into GAS/equipment/damage policy |
| Chaos building work | gameplay health/state authoritative, Chaos presentation | **KEEP SEMANTIC BOUNDARY** |
| HUD/VFX polish | information hierarchy, readable effects, visual inspection matters | **REBUILD** UMG/CommonUI + presentation models + GameplayCue/Niagara |
| showroom ownership | one writer per presentation surface; live state + inspected PNG | **PORT PRINCIPLE** into dedicated showcase/test Experience |
| procedural survival-world bootstrap | deterministic seeded world experiments | **REPLACE** with World Partition/Data Layers/PCG production authoring |
| humanoid runtime workflow branches | deep diagnostics/retarget inspection are necessary | **PRODUCTIZE TOOLING** into P3Testing/P3Editor; discard one-off giant workflow YAMLs |
| consolidation/master-unification lanes | provenance/lineage inspection prevented blind merges | **KEEP POLICY**, eliminate consolidation branch as normal architecture |

No old divergent branch is a V2 merge target merely because it contains useful research.

---

# Part VI — Dependency-ordered build sequence

## V2-00 — Governance freeze and test spine

**Purpose:** provide coordination and regression tooling without turning governance into an implementation prerequisite.

Build:

1. maintain one stable V2 verification status for useful CI evidence;
2. wire `.github/WORKER_DISPATCH.md` to this North Star + lane registry;
3. create the parameterized `v2-verify` workflow/runner skeleton;
4. create `P3Testing` receipt/scenario schema;
5. mark V1 gameplay as legacy/reference: no new production feature extends V1 god classes;
6. capture baseline V1 compile and a minimal existing playtest receipt for regression reference.

**Acceptance contract:**

- V2 architectural paths/rules are machine-checkable;
- a sample no-op scenario produces a GitHub-inspectable verification receipt;
- the stable verification status can report trustworthy evidence without becoming a prerequisite merely because it exists;
- worker dispatch records lane ID and allowed paths when useful for coordination;
- no integration branch is created.

**Relationship:** V2-01 can consume this tooling, but V2-00 status does not grant or withhold permission to implement V2-01.

---

## V2-01 — Runtime foundation

**Purpose:** establish and verify the ownership/network/input/camera architecture used by V2 features.

Build:

1. `P3Core`, `P3Gameplay`, `P3UI`, `P3World`, `P3Testing`, `P3Editor` plugin skeletons;
2. `AP3GameMode`, `AP3GameState`, `AP3PlayerState`, `AP3PlayerController`, `AP3CharacterBase`;
3. native core Gameplay Tags;
4. `UP3ExperienceDefinition`, `UP3FeatureSet`, `UP3PawnData`, Experience manager;
5. PlayerState-owned ASC + Pawn extension init states;
6. Enhanced Input semantic dispatch + one basic InputConfig;
7. p3 camera-mode stack with first-person and third-person gameplay views; RTS-camera proof is deferred;
8. UMG/CommonUI root shell with no feature-specific HUD;
9. enable Iris and add server-mode multiplayer runtime verification using the installed UE5.8 development/test surfaces;
10. `XP_V2Foundation` + deterministic test map.

**Acceptance contract:**

- clean UE5.8 editor/game-module build;
- server-mode test session + **2 clients** connect under Iris;
- both clients receive correct PlayerState/Pawn ownership;
- initialization reaches `InitState.GameplayReady` without timing sleeps;
- PlayerState ASC survives Pawn A -> Pawn B -> Pawn A possession changes;
- switching between first-person and third-person **does not change possessed Pawn or player-owned gameplay state**, and accepted actions work in both views;
- remapping the test action in its IMC requires no gameplay-code change;
- no V1 `Ap3Character`, `p3PlayerControllerInputFix`, V1 HUD or V1 gameplay subsystem is required for the proof;
- late join receives correct shared/player state;
- if Iris fails for a concrete engine/project reason, research and resolve that exact networking route; do not silently introduce a second networking model and do not stop unrelated work.

**Current multiplayer execution rule:** the server-authoritative 1v1 Lane War product proceeds from current code/runtime evidence on the V2 production path. No historical V2-01 acceptance sentence, receipt, issue state, packaging task, or older single-player-first assumption can create a prerequisite without a proven causal dependency for the exact work.

**Provides foundation for:** V2-02 and p3-only content/animation staging support.

---

## V2-02 — First complete vertical slice: interaction -> inventory -> UI -> save

**Purpose:** prove the chassis end-to-end with a deliberately small real feature before construction/combat complexity.

Build:

1. `UP3ItemDefinition`;
2. Fast-Array `UP3InventoryComponent` on PlayerState;
3. atomic inventory transaction API;
4. `IP3InteractableTarget` + `GA_Interact`;
5. one server-authoritative resource node/pickup;
6. one feature-local Enhanced Input context/action;
7. one gameplay HUD resource read model/widget;
8. `UP3PersistenceSubsystem` + save version 1;
9. save/load inventory;
10. feature Functional Test + Gauntlet scenario.

**Acceptance contract:**

- client cannot mint resources through local mutation;
- two clients can interact independently and server owns final stacks;
- simultaneous interaction cannot duplicate the same finite resource;
- inventory survives Pawn swap;
- inventory survives save -> shutdown/load -> restore;
- HUD updates by event/read model, not actor scan;
- changing physical input does not change feature code;
- feature paths do not modify base framework classes except through an already-approved public extension;
- user-path capture shows the real input -> resource disappears/changes -> inventory HUD updates.

**Relationship:** V2-03A, V2-03B and V2-03C can use this foundation where current code/runtime dependencies actually require it.

---

## V2-03A — Avatar and animation foundation

**Purpose:** prove one production-quality controllable humanoid without V1 runtime repair architecture.

Build:

1. p3 staging/validation for accepted external character source;
2. one canonical humanoid `UP3PawnData`;
3. `UP3AnimationProfile`;
4. correct authored scale/orientation in asset, never component-scale repair;
5. IK Rig/IK Retargeter path where needed;
6. production locomotion choice: Motion Matching if dataset coverage meets requirements, otherwise intentional AnimBP baseline;
7. canonical sockets/equipment compatibility;
8. Rewind/Animation Insights + visual proof scenario.

**Acceptance contract:**

- Pawn asset is at intended world scale with component scale `(1,1,1)` unless the design asset intentionally says otherwise;
- forward direction is correct without per-character runtime yaw repair;
- idle/walk/run/turn start/stop are visually coherent and movement-speed matched;
- 60-second locomotion stress has no cumulative bone drift/explosion;
- required sockets resolve and persist after reload;
- animation remains correct during real input movement, not only idle editor preview;
- trace + mid-action capture identify the active animation state;
- adding a second compatible humanoid is principally PawnData/AnimationProfile/content, not a base-class code switch.

**Relationship:** V2-04A combat/traversal and later humanoid migration can consume this work where current code/runtime dependencies require it.

---

## V2-03B — Construction foundation

**Purpose:** prove the first large persistent world transaction on the V2 substrate.

Build:

1. `UP3BuildDefinition` assets;
2. local nonreplicated preview;
3. server-authoritative placement target data/transaction;
4. construction spatial registry;
5. snap/support rules;
6. persistent BuildDefinitionId + PersistentGuid;
7. save/load;
8. repair/salvage/fortify transaction framework;
9. paint-build intent stream;
10. Chaos presentation adapter.

**Acceptance contract:**

- malicious/invalid client transform, unaffordable cost, unsupported wall and overlap all fail on server;
- valid placement consumes cost exactly once and all clients see one structure;
- preview object never replicates;
- adjacent snap result is deterministic between prediction and server;
- spatial query cost does not scale by whole-world actor iteration per frame;
- support removal updates dependent structures correctly;
- paint-build places only server-accepted cells and stops cleanly when cost/validity fails;
- save/load recreates exact definitions/transforms/states by stable IDs;
- structure death clears gameplay collision even with no Chaos asset;
- Chaos fracture cannot change authoritative health/persistence on its own.

**Relationship:** V2-04B RTS/TowerDefense and V2-05 Earthworks integration can consume this work where current code/runtime dependencies require it.

---

## V2-03C — Production world foundation

**Purpose:** stop building production gameplay on a runtime-spawned demo world.

Build:

1. V2 World Partition test/open-world template;
2. OFPA conventions;
3. Data Layer conventions;
4. PCG biome/dressing example using partitioned generation where appropriate;
5. HLOD profile/build commandlet;
6. replicated semantic environment state + presentation director;
7. world performance/capture scenario.

**Acceptance contract:**

- world streams cells without loading the entire production domain;
- PCG output follows declared Data Layer/HLOD ownership;
- HLOD commandlet rebuilds the sample domain deterministically;
- weather/time gameplay state is readable without locating named light actors;
- changing presentation light/fog actors does not change authoritative gameplay/environment semantics;
- two workers can edit separate OFPA/Data Layer feature areas without touching one shared level blob for ordinary work.

**Relationship:** V2-04C1 AI and V2-05 Earthworks can consume this work where current code/runtime dependencies require it.

---

## V2-04A — Combat, equipment, traversal and VFX

**Depends:** V2-03A + V2-02.

Build:

- item/equipment definitions + Pawn equipment component;
- primary/secondary/melee GAS path;
- damage/faction policy;
- physical projectile path;
- one traversal ability (Grapple or Dash) then remaining accepted mobility abilities;
- GameplayCue/Niagara presentation;
- action animation/camera integration.

**Acceptance contract:**

- server owns damage/cooldowns/costs;
- equipment grant/remove cleanly grants/revokes ability sets and presentation;
- friendly-fire/faction rule is centralized, not Health-component special cases;
- cosmetic cue loss cannot alter gameplay result;
- grapple/dash uses normal input and cancels/blocks according to Gameplay Tags;
- Pawn swap removes body-only equipment/abilities without losing player-persistent state;
- two-client combat proof covers hit, miss, cooldown and death/respawn edge.

---

## V2-04B - Tower Defense; RTS view deferred

**Depends:** V2-03B + V2-03C + P3AI baseline.

Build:

- Tower Defense gameplay and presentation usable/readable from first-person and third-person; RTS camera/input/UI is deferred;
- WaveDirector;
- tower targeting/attack via shared combat substrate;
- defense core;
- StateTree enemy behavior;
- runtime navigation response to construction;
- replicated wave/core presentation model.

**Acceptance contract:**

- Tower Defense interaction/readability is proven from first-person and third-person without requiring an RTS view;
- player remains damageable during normal first-/third-person play unless Experience rule explicitly grants immunity;
- wave does not advance while a living accepted enemy remains;
- repeated spawn failures fail visibly rather than silently advancing;
- newly placed blocking construction causes enemy reroute in the acceptance map;
- tower acquires only valid faction/target candidates and kills through shared damage path;
- UI wave/core values come from replicated feature state, not world scanning.

---

## V2-04C1 - AI baseline

**Depends:** V2-03C + V2-02.

Build:

- reusable StateTree/SmartObject/navigation AI substrate;
- navigation/perception integration reusable by Lane War and Tower Defense;
- deterministic AI verification scenario.

**Acceptance contract:**

- one deterministic AI pawn uses the reusable StateTree path in the V2 world domain;
- one reservable Smart Object flow is proven where reservation semantics are useful;
- AI proof is available through the reusable V2 verification spine;
- Tower Defense and Lane War can consume the accepted AI substrate without private feature coupling;
- no survival subsystem, hunger/thirst/exposure/shelter work, or survival upkeep is required by this lane.

---

## V2-05 — Earthworks

**Depends:** V2-03B + V2-03C.

Build:

- chunked heightfield truth;
- DynamicMesh render/collision chunks;
- server EarthworkCommand;
- first-person + third-person personal preview adapters; future RTS adapter deferred;
- brush definitions;
- dig/fill/grade/trench/berm;
- map-wide free terrain edits with no inventory/resource gate;
- production-world cutover from authored placeholder/static floor collision to Earthworks-owned terrain collision;
- bounded undo;
- save/load chunk state;
- performance scenario.

**Acceptance contract:**

- preview never mutates terrain;
- release/commit uses the last shown valid preview location/direction;
- server rejects invalid commands and coordinates outside the configured playable terrain domain, not edits based on affordability or ground material/type;
- dig/fill/grade/trench/berm/undo require no inventory item or resource balance;
- ordinary playable ground across the configured map bounds is editable regardless of material, biome, landscape layer, ground actor class/tag, or former deformable-ground patch membership;
- the production world instantiates the Earthworks domain over its full playable ground bounds and leaves no authored/static floor collider underneath that can block a committed dig;
- first-person and third-person modes mutate exactly the same domain state; future RTS must reuse that domain rather than fork it;
- affected render/collision chunk updates without rebuilding every terrain chunk;
- collision update is deferred/async where possible and does not leave stale invisible collision volumes after completion;
- 30 standard edits in the performance scenario produce no single >100 ms game-thread hitch and maintain a measured p95 frame budget recorded in the receipt; if this fails, chunk/collision strategy is revised before feature expansion;
- save/load reproduces logical terrain state independent of render mesh serialization.

---

## V2-06 — Flight and other body families

**Depends:** V2-01 + V2-02; combat-enabled flight additionally depends V2-04A.

Build:

- shared flight movement component;
- FlightProfile assets;
- one authored-animation bird and one procedural-secondary-motion bird;
- flight camera/input config;
- body-specific PawnData/AnimationProfile;
- network flight proof.

**Acceptance contract:**

- species tuning can change through FlightProfile without movement-code edit;
- straight input does not create arbitrary timed bank/pitch unrelated to motion;
- procedural bones remain bounded around base pose for 60 seconds;
- takeoff/flight/glide/brake/landing transition deterministically;
- two clients observe acceptable replicated flight path/state;
- adding the second species does not copy the movement state machine.

---

## V2-07 — Product Experiences and V1 retirement

**Depends:** preceding features chosen for the actual product slice.

Build:

- the default V2 Lane War product Experience;
- `XP_Showroom`;
- migration of accepted assets/content definitions;
- removal of replaced V1 authorities;
- packaged/end-to-end Gauntlet + visual acceptance;
- performance baseline.

Delete as replacements pass:

- `p3PlayerControllerInputFix.cpp` / raw-key arbitration;
- feature-specific behavior in V1 `Ap3Character`;
- RTS camera possession path;
- PlayerController-owned V1 construction/inventory authority;
- per-player world subsystems that poll `GetFirstPlayerController()`;
- native build catalogs/hard-coded production object paths;
- ProceduralMesh earthwork implementation;
- Canvas HUD feature aggregation/world scanning;
- V1 procedural survival world as production world authority;
- duplicated flight movement controllers;
- named-map/light compatibility ownership that is not explicitly showroom-only;
- feature-specific one-off workflow YAMLs superseded by `v2-verify`.

**Acceptance contract:**

- product Experience launches from clean checkout/build without V1 gameplay bootstrap;
- player identity, PawnData/avatar/animation, semantic input and camera work on the same default path;
- interaction, inventory and persistence compose with combat, abilities, traversal and GameplayCue/VFX presentation;
- construction and earthworks compose with world state, navigation, costs and multiplayer authority;
- defeat/respawn, Lane War, tower defense and AI compose without restoring a second host authority;
- production world/environment and UI read models expose the integrated state without repair bootstrap or central HUD scanning;
- required major loops pass dedicated-server/2-client Gauntlet where networked;
- representative normal-input user flows have inspected capture evidence on the same compatible head;
- performance baseline is recorded;
- every migrated V1 system has exactly one authority, never a permanent dual path;
- remaining V1 code is either explicit reference/test content or has a named migration lane/disposition.

Sealdiver selection and Grapple/Dash traversal are current examples that can falsify avatar/composition and traversal readiness. They are not the whole product contract and proving them alone cannot close V2-07.

---

# Part VII — Worker attachment contract

Every V2 worker receives:

```text
V2_AUTHORITY=docs/v2/P3_V2_NORTH_STAR.md
V2_LANE_REGISTRY=docs/v2/P3_V2_LANES.json
LANE_ID=<resolved lane>
BASE=main@<current SHA>
DESTINATION=main via short-lived PR
ALLOWED_PATHS=<from lane registry>
FORBIDDEN_PATHS=<from lane registry>
DEPENDENCIES=<planning relationships to verify against current causal evidence>
ACCEPTANCE_CONTRACT=<verbatim lane contract>
V1_REFERENCE_PATHS=<read-only reference; code-level reuse requires the V1-to-V2 implementation reuse rule's concrete V2-fit justification>
```

For significant work, capture the useful context below when it materially helps avoid collisions or churn. Missing paperwork is not permission to stop implementation:

```text
TRUTH
HISTORY
CHURN
ACCEPTED PROVENANCE
LINEAGE + INVARIANTS
BOUNDED CHANGE
DISPOSITION
```

A worker implements from current evidence rather than silently inventing a replacement architecture. If current engine evidence materially contradicts this document, verify it, repair stale architecture text when appropriate, and stop only the exact unsafe/conflicting route while independent work continues.

---

# Part VIII — Current delivery course correction

The 2026-08-27 through 2026-09-02 architecture program showed that the technical direction can be correct while delivery flow is wrong. From the #599 baseline to the 2026-09-02 audit head, main advanced 473 commits; 99 PRs merged in the six-day window; GitHub recorded 4,601 Actions runs; and the main #603 convergence PR alone contained 74 commits across 62 files. These are historical incident measurements, not throughput targets. They coincide with the default product still being `NOT READY`.

Historical 2026-09-02 response for #599/#611 (the following five points record that intervention; current game-first priorities above supersede any blanket fan-out freeze or named-integration-owner prerequisite):

1. Freeze new horizontal product fan-out until the default-product readiness ledger exists and one integration owner is named.
2. Populate every V2-07 domain as `ABSENT`, `IMPLEMENTED`, `SYSTEM_PROVEN` or `DEFAULT_PATH_PROVEN` from current evidence; never infer the last state from child closure.
3. Pull the oldest blocked default-path row through native asset validation, focused system acceptance, default smoke and required multiplayer/visual acceptance.
4. Run one stable verifier and one default-product smoke per meaningful exact head. Deduplicate event storms and stop identical proof retries.
5. Reopen feature fan-out only when measured integration/build/editor capacity can absorb it without increasing branch age or the number of unintegrated rows.

### Machine capacity, cleanup and build-lock contract

The machine is part of the delivery system. Logical worker count never creates physical editor, build, disk or UBA capacity.

The 2026-09-02 live audit established:

- the volume had about 47.6 GiB free and no active Unreal/UBT/compiler process;
- the guarded lane sweep found zero eligible cache and reclaimed nothing;
- the primary P3 checkout held about 2.67 GiB of `Intermediate` and 0.15 GiB of `Binaries`, while five local P3 runner roots occupied about 3.9 GiB total;
- the sweep excludes the primary checkout and does not inventory runner roots, yet reported that every remaining cache was warm or attributed to a running build;
- the two named hot-source workspaces contained no build cache, while `Invoke-P3HotSourceBuild.ps1` held one global mutex across slot selection, source synchronization, inner build-queue waiting and the complete build. Until per-slot concurrency is implemented and proven, the source hot pool has **one effective build lane**, not two;
- `Invoke-P3Build.ps1` may expose two canonical build slots, but slot two disables UBA and UBA exclusive-storage failure remains a separate capacity collision, not a compile defect.

Required behavior:

1. Cleanup inventory covers every admitted P3-owned cache class—registered lanes, hot-source slots, runner workspaces and the primary checkout—while default deletion remains limited to proven cold, reproducible, non-user-owned output.
2. Cleanup output distinguishes `RECLAIM`, `PRESERVE_ACTIVE`, `PRESERVE_WARM`, `PRESERVE_DIRTY`, `PRESERVE_PRIMARY`, `NO_CACHE` and `REVIEW`; it never collapses them into a false “all warm/running” explanation.
3. The 75/100 GiB operating trigger/target is proactive cleanup policy, not build admission. The hard default build requirement remains the measured floor plus growth reserve (currently 25 + 8 GiB). Failure to reach 100 GiB cannot block an otherwise admitted build.
4. Cleanup runs before acquiring scarce build/UBA slots. A build may not hold one scheduler lock while waiting indefinitely for another resource.
5. Every queue wait reports the held resource, awaited resource, owner/receipt, elapsed time and bounded timeout. An unchanged timeout is retried only after observed capacity changes.
6. The hot-source route reports its **effective** concurrency. If one global mutex serializes both named slots, admission and orchestration must advertise capacity one.
7. UBA exclusive-storage contention routes to the non-UBA slot or waits for verified UBA release; it does not trigger a duplicate workspace/build or masquerade as source failure.
8. Cleanup ownership is part of task completion. Each task records generated roots and restore commands, then removes task-created state after merge/closure while preserving masters, Content, dirty work and user-owned editor state.
9. Low free physical RAM alone is not a build stop. Admission records commit limit, commit charge/remaining, measured or predicted operation peak and margin. Healthy commit headroom proceeds with paging/monitoring; only insufficient commit headroom, an allocation failure, or severe paging with no measurable progress blocks that build route.
10. A cleanup scanner may only describe the roots it inspected. “No eligible candidates” means no eligible candidates in that scanner's inventory; it never proves that all remaining disk is tracked product data or that no other owned reproducible cache exists.

Issue #296 owns the cleanup/build-resource implementation gaps. This contract does not authorize deleting the audited primary cache or runner roots; they remain `REVIEW` until ownership and restore evidence are recorded.

### What the research got right and execution missed

| Research/architecture decision | Correct intent | Execution gap now corrected |
| --- | --- | --- |
| Lyra-style Experience/PawnData composition | assemble a runnable product from explicit data and feature contracts | subsystem lanes were accepted without continuous default-Experience composition |
| feature-local plugins and stable core | avoid V1 central-class accumulation | parallel work exceeded the one-machine integration bottleneck and converged late |
| GAS, Enhanced Input and semantic tags | preserve authority, prediction and contextual input | existence/system tests were allowed to stand in for the normal default user path |
| Data Validation and staged assets | fail bad content before runtime | LFS hydration/package validity failures surfaced late during expensive proof attempts |
| Automation, Gauntlet and visual proof | layer evidence to match the claim | workflows and captures multiplied without a retry/change budget |
| short-lived branches and reusable verification | integrate continuously in small batches | heavy editor/build/runtime capacity was not separated cleanly from lightweight source WIP, so a later numeric lane ceiling became an unintended admission/stop gate |

The original build sequence below remains useful history. It is no longer permission to create duplicate heavy execution surfaces merely because a foundation subsystem passed. New heavy editor/build/runtime work requires available heavy capacity; disjoint lightweight source/product work may continue while that heavy capacity is occupied.

# Part IX — Original first-action history

The sequence below records the original architecture build-up; it is planning history, not a permission chain. Current work starts from current `main` and the highest-value in-scope product work.

Historically the foundation work created the plugin/test skeleton and reusable verification status. Its representative runtime proof is:

```text
server-mode test session + 2 clients
 -> V2 Experience loads
 -> PlayerState ASC initializes
 -> PawnData spawns body
 -> semantic input works
 -> Pawn swap preserves player state
 -> RTS camera mode blends without possession
 -> receipt proves lifecycle under Iris
```

If that path is awkward, racy or requires V1 compatibility hacks, fix the actual foundation defect that affects the current scope; do not convert it into a blanket stop on independent features.

The first real gameplay feature was V2-02 resource interaction/inventory/save/UI. It was intentionally boring. The original assumption that a clean feature automatically made broad construction/combat/world fan-out safe was incomplete: future fan-out also requires the default-product smoke to remain green and integration WIP to stay within measured capacity.

---

# Primary current-engine research basis

Official Unreal Engine 5.8 documentation used to resolve architecture choices:

- UE5.8 Release Notes (Iris production-ready; Mover status): https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes
- Migrate to Iris: https://dev.epicgames.com/documentation/en-us/unreal-engine/migrate-to-iris-in-unreal-engine
- Gameplay Ability System overview: https://dev.epicgames.com/documentation/en-us/unreal-engine/understanding-the-unreal-engine-gameplay-ability-system
- Lyra Sample Game: https://dev.epicgames.com/documentation/en-us/unreal-engine/lyra-sample-game-in-unreal-engine
- Game Framework Component Manager: https://dev.epicgames.com/documentation/en-us/unreal-engine/game-framework-component-manager-in-unreal-engine
- Gameplay Tags: https://dev.epicgames.com/documentation/en-us/unreal-engine/using-gameplay-tags-in-unreal-engine
- Game Features / Modular Gameplay: https://dev.epicgames.com/documentation/en-us/unreal-engine/game-features-and-modular-gameplay-in-unreal-engine
- Game Features API (Beta status): https://dev.epicgames.com/documentation/en-us/unreal-engine/API/PluginIndex/GameFeatures
- Modular Gameplay API (Beta status): https://dev.epicgames.com/documentation/en-us/unreal-engine/API/PluginIndex/ModularGameplay
- CommonUI: https://dev.epicgames.com/documentation/en-us/unreal-engine/common-ui-plugin-for-advanced-user-interfaces-in-unreal-engine
- Enhanced Input: https://dev.epicgames.com/documentation/en-us/unreal-engine/enhanced-input-in-unreal-engine
- CommonUI + Enhanced Input caution: https://dev.epicgames.com/documentation/en-us/unreal-engine/using-commonui-with-enhnaced-input-in-unreal-engine
- Asset Management: https://dev.epicgames.com/documentation/en-us/unreal-engine/asset-management-in-unreal-engine
- Data Validation: https://dev.epicgames.com/documentation/en-us/unreal-engine/data-validation-in-unreal-engine
- World Partition: https://dev.epicgames.com/documentation/en-us/unreal-engine/world-partition-in-unreal-engine
- PCG + World Partition: https://dev.epicgames.com/documentation/en-us/unreal-engine/using-pcg-with-world-partition-in-unreal-engine
- StateTree: https://dev.epicgames.com/documentation/en-us/unreal-engine/overview-of-state-tree-in-unreal-engine
- Smart Objects: https://dev.epicgames.com/documentation/en-us/unreal-engine/smart-objects-in-unreal-engine---overview
- Dynamic Mesh Component: https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/GeometryFramework/UDynamicMeshComponent
- Procedural Mesh Component Experimental status: https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Plugins/ProceduralMeshComponent/UProceduralMeshComponent
- Geometry Script Beta status: https://dev.epicgames.com/documentation/en-us/unreal-engine/geometry-scripting-reference-in-unreal-engine
- Game Animation Sample: https://dev.epicgames.com/documentation/en-us/unreal-engine/game-animation-sample-project-in-unreal-engine
- Runtime IK Retargeting: https://dev.epicgames.com/documentation/en-us/unreal-engine/runtime-ik-retargeting-in-unreal-engine
- Async SaveGame: https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/UGameplayStatics/AsyncSaveGameToSlot
- Automation Framework: https://dev.epicgames.com/documentation/en-us/unreal-engine/automation-test-framework-in-unreal-engine
- Gauntlet: https://dev.epicgames.com/documentation/en-us/unreal-engine/gauntlet-automation-framework-overview-in-unreal-engine
- Screenshot Comparison: https://dev.epicgames.com/documentation/en-us/unreal-engine/screenshot-comparison-tool-in-unreal-engine
- Rewind Debugger: https://dev.epicgames.com/documentation/en-us/unreal-engine/animation-rewind-debugger-in-unreal-engine

Delivery-flow research used for the 2026-09-02 course correction:

- DORA — Trunk-based development: https://dora.dev/capabilities/trunk-based-development/
- DORA — Working in small batches: https://dora.dev/capabilities/working-in-small-batches/
- DORA — Continuous integration: https://dora.dev/capabilities/continuous-integration/
- The Official Kanban Guide (WIP limits and pull): https://resources.kanban.university/wp-content/uploads/2021/06/The-Official-Kanban-Guide_US.pdf

# Governing rule

When an implementation shortcut conflicts with this architecture, convenience does not win.

When better current evidence proves this architecture materially wrong, sunk cost does not win either. Stop, produce the evidence, change the architecture deliberately through an ADR/core lane, then continue from one new authority.
