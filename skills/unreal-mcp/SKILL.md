---
name: unreal-mcp
description: Drive a running Unreal Engine editor - move the viewport, render off-screen PNGs, inspect or edit actors, run Python inside the editor, and diagnose a broken agent-to-editor connection. Use whenever a task touches Unreal Engine, the UE editor, a .uproject, an Unreal MCP server, the UE_MCP_Bridge plugin, or when mcp__unreal-engine__* tools return empty results or "plugin_not_connected".
---

# Driving Unreal Engine

## Policy boundary

Global operating policy is defined by the active project `AGENTS.md`. This
skill contains only Unreal/MCP domain procedure; if it conflicts with
`AGENTS.md`, `AGENTS.md` wins. Provider/model selection belongs to the live
Traycer selection guide, not this skill.

For p3, use the repository launcher and verify the exact project identity
before live editor work. Project Browser / Select Project is a failure state,
not a loading state. The launcher and `AGENTS.md` define the applicable safety
and bounded-wait rules.

Verified against UE 5.8.0, embedded Python 3.11.8, project
`C:\Users\Lauri\Desktop\UnrealAITest58`.

The toolkit lives at:

```
C:\Users\Lauri\Desktop\lowvram3d-scene-smoke-20260803\unreal
```

Run every command from that directory. Full reference:
`C:\Users\Lauri\Desktop\lowvram3d-scene-smoke-20260803\docs\unreal-mcp\README.md`.

## Fast path

1. Identify the exact project and existing editor process.
2. Perform the requested edit/build/run operation.
3. Verify the user-visible result through the live editor/PIE path.

For automated p3 launches and recovery, use the repository's single-source
launcher: `scripts/windows/start-p3-agent-editor.ps1`. Keep the executable,
project, flags, ownership receipt, and recovery logic in that script; do not
copy command-line syntax into a skill or agent prompt. Run safe checks first:

```powershell
pwsh -File scripts/windows/start-p3-agent-editor.ps1 -Mode ValidateArguments
pwsh -File scripts/windows/start-p3-agent-editor.ps1 -Mode Inspect
pwsh -File scripts/windows/start-p3-agent-editor.ps1 -Mode CrashPolicy -MockExitCode 3
```

The launcher uses .NET `ProcessStartInfo.ArgumentList`, unattended startup,
package-recovery suppression, exact-project proof within 20 seconds, and
automation ownership receipts. It reuses exact p3, ignores other projects,
never adopts user-owned editors or PIE, and only gracefully closes an
automation-owned wrong instance. It never force-kills Unreal. `Restore Packages`
is an immediate automation failure, never a user prompt or an unbounded wait.

Its recovery markers are boolean: `CANONICAL_LAUNCHER`,
`PROJECT_BROWSER_ONLY` (only when no `.uproject` argument is present),
`LAUNCH`, `EDITOR_CRASHED`, `AUTO_RELAUNCH`, `CRASH_LOOP`, `BLOCKING_MODAL`,
`RESTORE_POPUP_SUPPRESSION`, `CRASH_REPORTER_INTERACTIVE`,
`PACKAGE_RECOVERY_INTERACTIVE`, `CRASH_REPORTER_CLOSE_SUCCEEDED`,
`RESTORE_POPUP_SUPPRESSION_FAILED`, `LAUNCH_FAILURE`, and
`NO_USER_INPUT_REQUIRED`.

Read `Saved/UE_MCP_Bridge/port.json` when a bridge call is needed. Run the
doctor only after that call fails or resolves the wrong project:

```bash
python -m uemcp doctor
```

Do not use Git Bash, `bash`, `cmd` wrappers, `start`, the project browser, or a
bare `UnrealEditor.exe` for automated p3 launches. Point agents to the repo
launcher instead.

## Automated PIE frame pacing

Agent-owned PIE is for bounded gameplay acceptance, not an uncapped benchmark.
Before starting it, apply and verify session-scoped `t.MaxFPS 30`, `r.VSync 1`,
and `rhi.SyncInterval 1` through the editor control plane. Ordinary PIE and
visual QA must not run uncapped; use uncapped rendering only when the user
explicitly requests performance profiling. Do not persistently rewrite user
settings for this rule, and end the owned PIE session gracefully after proof.

## Resource gates

Use commit pressure, not free physical RAM, as the capacity gate. Record
`COMMIT_LIMIT`, `COMMIT_CHARGE` / `COMMITTED_BYTES`, `COMMIT_REMAINING`,
`AVAILABLE_PHYSICAL_MB`, `PAGEFILE_USAGE`, `PROCESS_PRIVATE_BYTES`, and
`PROCESS_WORKING_SET`. A low physical-RAM reading, nonzero pagefile usage,
another Unreal process, or a UE memory estimate is not by itself a reason to
wait. If commit headroom is healthy, use `RAM_PRESSURE=ELEVATED`,
`PAGING_ALLOWED=true`, and `ACTION=PROCEED`.

Block only when commit remaining is below a measured/predicted operation peak
plus a modest margin, commit is exhausted, an actual allocation/OOM occurs, or
severe paging coincides with no measurable progress. Unknown estimates proceed
with monitoring. Do not use a global heavy-Unreal mutex; evaluate RAM/commit,
VRAM, CPU, and disk/paging independently. Any wait must state the resource,
current value, hard limit, required estimate, estimate source, measured prior
peak, why waiting is required, and a bounded timeout. “Waiting for RAM to
free” is not a valid standalone gate.

It checks the editor process, the bridge lockfile and port, bridge health,
editor-side Python, the MCP server on port 8000, and env wiring — and prints a
specific repair for each failure. Do not guess at a diagnosis before running it.

## Viewport and capture

```bash
python -m uemcp viewport
python -m uemcp focus <ActorLabel>
python -m uemcp look-at --eye "0 0 500" --target "0 0 0"
python -m uemcp orbit --target "0 0 200" --distance 1200 --yaw 35 --pitch -20
python -m uemcp shot out.png --width 1280 --height 720 [--focus-actor <Label>]
python -m uemcp camera <CameraLabel>
python -m uemcp camera-shot <CameraLabel> out.png --width 1448 --height 1086
```

`shot` and `camera-shot` are off-screen scene renders: no editor UI, no window
focus required, independent of PIE and the player pawn. They return the output
byte size, so verify it before claiming a capture succeeded. Prefer them over
any screenshot tool for visual evidence.

`camera-shot` reads the named CameraActor's real transform and FOV first, and
fails if the label does not resolve to exactly one camera — so a render can
never silently come from the wrong actor.

## Editor Python

```bash
python -m uemcp python "import unreal; result = str(unreal.SystemLibrary.get_engine_version())"
python -m uemcp python @script.py --json
python -m uemcp purge <module-prefix>
```

Code runs with `ExecuteFile` semantics in `__main__`: a top-level `return` is a
syntax error. Assign a variable instead — the CLI reads back `result` by
default. After editing an editor-side Python module, `purge` it or the editor
keeps running the cached copy for the rest of the session.

## Structured toolsets

Epic's in-editor MCP server on port 8000 carries ~54 toolsets (Sequencer,
Niagara, PCG, materials, assets, Slate automation) but no arbitrary Python.

```bash
python -m uemcp toolsets
python -m uemcp call <bare_tool_name> --toolset <Toolset.Name> --arguments '{}'
```

Pass the toolset and the **bare** tool name separately; a fully-qualified
`Toolset.tool` string as the tool name returns "Tool not found".

## When things are broken

| Symptom | Cause and fix |
|---|---|
| Every `mcp__unreal-engine__*` tool returns `{}` or `plugin_not_connected` | The server's `UE_PROJECT_ROOT` is unset so it targets the wrong project. Configs are already fixed; restart the client. |
| Editor log: repeated "Connected / Lost connection" | Plugin idle-probe defect. Patched in source, needs a rebuild. Use `uemcp` meanwhile. |
| Port 8000 returns an empty body | Unterminated event stream. Use `uemcp.EditorMCP`, never `urllib`/`requests`. |
| Duplicate MCP servers | `pwsh -File scripts/windows/ue-mcp-cleanup.ps1` |

Never hardcode bridge port `55557`. The real port is derived from the project
path and published to `<project>/Saved/UE_MCP_Bridge/port.json`.
