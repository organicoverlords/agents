# p3-android North Star

Status: **SOLE PRODUCT DIRECTION FOR `organicoverlords/p3-android`**  
Parent identity: P3 V2 keeps the broader lane-war / earthworks / momentum thesis. This repo is a deliberately smaller Android-first reinterpretation, not a direct feature-for-feature port.

## Product thesis

Make a 3D mobile game where **the ground is the movement system**.

The player should be able to reshape terrain almost anywhere, immediately use the new slope/berm/trench as a route, and preserve satisfying momentum through sliding/skiing. Combat exists to create pressure and progression while the player's touch attention stays mostly on traversal and earthworks.

Design shorthand: **P3 earthworks + Tribes-like momentum + Vampire Survivors / Megabonk-style automatic combat + lane pressure**.

The proof is not three isolated demos. A representative session must compose them: reshape a lane, ski the changed terrain, survive/push an enemy wave through automatic attacks, gain power, and make a new terrain/movement decision because of combat pressure.

## Priority order

1. **Movement feel.** Sliding/skiing must be smooth enough that simply traversing slopes is fun.
2. **Earthworks anywhere.** Raising/lowering terrain is a normal moment-to-moment verb, not a scripted construction socket.
3. **Lane autobattle.** Enemies create readable directional pressure while attacks largely resolve automatically.
4. **Android ergonomics and performance.** Touch controls, readable camera behavior, fast boot, and stable frame pacing outrank desktop-only complexity.
5. **Depth after composition.** More abilities, terrain tools, enemies, art and meta-progression come only after the first loop works as one game.

## Sprint 0 game loop

A 5-10 minute session should already support this loop:

1. Spawn into one compact 3D battlefield with two or three readable enemy lanes.
2. Move with a left thumb stick and camera with right-side drag.
3. Hold/toggle slide-ski to preserve downhill/tangent velocity; use slope reading and air control to route efficiently.
4. Raise/lower/smooth terrain with a small touch-friendly brush inside the playable editable bounds.
5. Immediately ride the changed ground: build a ramp, berm, bowl, trench or escape line and have collision/movement respect it.
6. Enemy waves advance along lane pressure toward a friendly objective/core.
7. The player automatically acquires targets and attacks while moving; kills grant a simple run resource/XP.
8. Pick lightweight upgrades that alter attack cadence/damage/area or movement/earthwork utility.
9. Survive or push long enough that combat pressure forces repeated movement and terrain decisions.

## Input philosophy

Touch bandwidth is scarce. Sprint 0 therefore avoids twin-stick manual aiming.

- Left thumb: movement.
- Right drag: camera/look.
- Slide/ski: one hold or toggle control, tuned for low-friction momentum rather than a short canned dash.
- Earthworks: compact mode selector (raise / lower / smooth) plus press/drag placement through the camera reticle or touch world hit.
- Combat: automatic targeting and firing; the player influences outcomes primarily by route, proximity, terrain, build choice and positioning.

Controller/keyboard support is useful for development but cannot define the feel or UI contract.

## Technical starting point

Sprint 0 starts on **Godot 4.x + GDScript**, single-player/offline, with Android as the first packaging target. This is a speed-of-iteration choice for the derivative repo, not a rewrite mandate for main P3.

### Terrain

Use a chunked heightfield mesh with a CPU-authoritative height buffer and brush operations. Rebuild only dirty chunks and throttle expensive collision refreshes. Terrain queries expose height/normal and mutation through one narrow surface API.

Sprint 0 intentionally supports heightfield terrain only: ramps, berms, bowls, trenches, ridges and pits. **No caves, tunnels, voxel overhangs or arbitrary topology** until the core loop proves those are worth the cost.

### Movement

Use a custom player controller rather than stock friction alone. Preserve horizontal/tangent momentum, project velocity along traversable slopes, reduce braking while skiing, keep bounded air control, and prevent sticky transitions at slope/ground contact. Camera feedback should communicate speed without destabilizing touch aim/look.

### Combat

Keep the simulation small and data-driven: lane spawners, simple enemies, health/damage, automatic target selection, projectile or hitscan attacks, XP/resource drops and upgrade choices. Combat must tolerate player speed and changed terrain without becoming the first architecture bottleneck.

## Repository mutation boundaries for Sprint 0

These boundaries exist so parallel workers can produce mergeable slices without piling onto the same files.

- `src/player/**`, `scenes/player/**`: movement, touch input, camera and player tuning.
- `src/terrain/**`, `scenes/terrain/**`: heightfield data, brushes, chunk mesh/collision and terrain queries.
- `src/combat/**`, `scenes/combat/**`: lane waves, enemies, targeting, attacks, damage, XP/upgrades.
- `src/game/**`, `scenes/main.tscn`, project/export configuration: composition/integration only.

Shared contracts should be narrow and stable. Cross-subsystem changes go through the integration issue rather than each worker editing another lane's implementation.

## Sprint 0 acceptance

Sprint 0 is complete when one normal Android build can demonstrate all of the following in the same playable scene:

- Boots directly into the playable 3D slice without editor-only setup.
- Touch movement and camera are usable; skiing/sliding preserves understandable momentum across slopes and feels materially different from ordinary walking.
- Raise/lower/smooth edits work across the declared editable battlefield rather than only fixed sockets.
- Visible terrain and player collision converge quickly enough for an edit to become a usable ramp/berm/trench during active play.
- The player can immediately ski/slide over terrain they just reshaped.
- At least two lane directions produce recurring enemy pressure toward a friendly objective/core.
- Automatic attacks acquire valid enemies while the player keeps moving; damage, kills and a minimal XP/resource upgrade loop function.
- A continuous five-minute run does not require restart, console commands or manual repair.
- The composed loop is legible: terrain changes movement; movement changes combat positioning; combat pressure creates reasons to reshape terrain.

Frame pacing is a product requirement. Optimize from measured Android behavior; do not trade away movement feel or terrain responsiveness for decorative fidelity.

## Explicit non-goals for Sprint 0

- Full P3 parity or migration of the Unreal project.
- Multiplayer, replication, dedicated servers or accounts.
- Manual precision aiming, complex weapon inventories or hero ability kits.
- Caves/voxel overhangs/destructible arbitrary meshes.
- Large open world, procedural world generation or persistence.
- Final art, content breadth, monetization or live-service systems.
- Sophisticated enemy navigation over arbitrary deforming terrain unless the first lane proof needs it; simple lane steering and local avoidance are sufficient initially.

## Decision rule

When choosing between breadth and feel, choose **movement + terrain interaction**. When choosing between combat complexity and touch clarity, choose **autobattle pressure**. When choosing between generalized terrain technology and a responsive mobile battlefield, choose the **smallest system that makes earthworks usable everywhere we currently play**.
