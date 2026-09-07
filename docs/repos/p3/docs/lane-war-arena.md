# Lane War friend-playtest

The normal friend-playable V2 Lane War launch uses the production world and the
player-facing LAN menu. From the repository root, run:

```powershell
pwsh -NoProfile -File .\scripts\launch_lane_war_human_1v1.ps1
```

The launcher starts `UnrealEditor.exe` in game mode on
`/Game/V2/Maps/Lvl_V2ProductionWorld`. Before launch it checks the required
tracked product content and may hydrate only verified objects already present in
the local Git LFS cache. It does not silently fetch missing LFS content from the
network; missing required content fails closed.

## Play with a friend

Use the in-game **V2 LANE WAR** menu:

- **HOST LAN MATCH** starts the match for the host. Wait until the Lane War HUD shows **HOST READY** before the friend joins.
- On the second PC, launch the same build on the same local network and choose **JOIN LAN MATCH**.
- The launcher prints `P3_V2_PLAYTEST_BUILD_ID`. Before hosting or joining, confirm that exact build ID is identical on both PCs; the commit, module hash, and runtime-dirty lines remain available for troubleshooting.
- **PLAY SOLO VS AI (RAINCOAT)** remains available for a local product check, but it is not the two-player milestone acceptance.
- After victory or defeat, choose **RETURN TO MATCH MENU**. The named LAN session is cleaned up and the normal menu returns so the next match can start without restarting the game.

Use the in-game HUD and world prompts for the current authored controls rather
than relying on hard-coded key documentation. The HUD exposes the match
objective, team/Core status, economy feedback, traversal/combat actions,
Earthworks controls, and construction controls as their input state resolves.

## Automated listen-server verification

`scripts\launch_lane_war_listen.ps1` is a hidden/null-RHI loopback acceptance
helper. It starts an automated listen-server verification and validates log
markers such as arena readiness and client login. It is useful for headless
regression coverage, but it is **not** the normal human friend-playtest path and
is not final player-visible acceptance for #803.
