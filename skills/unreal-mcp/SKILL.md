---
name: unreal-mcp
description: >
  Generic Unreal Engine live-editor automation guidance. Use when a task needs
  editor/PIE control, viewport capture, actor or asset inspection/editing, or
  Unreal automation through the currently available repo-native or MCP/CLI route.
---

# Unreal Engine automation

## Authority

Current user instruction, the target repo's `AGENTS.md`, and verified live
editor/runtime state own the task. This skill is only generic Unreal automation
guidance; it must not duplicate project launchers, ports, paths, provider routing,
or repo-specific acceptance policy.

## Fast path

1. Read the target repo's `AGENTS.md` immediately before the first repo mutation.
2. Identify the exact project and existing editor/PIE ownership from live state.
3. Prefer the target repo's own launcher, scripts, and automation entrypoints.
4. Discover the currently available Unreal control route at use time. If `ue-cli`
   or an Unreal MCP tool is available, use it only after confirming it targets the
   intended editor/project; do not assume a stored executable path or port.
5. Make the smallest bounded change and verify the requested runtime or visual
   result with evidence appropriate to the claim.

## Safety and ownership

- Never adopt, close, restart, kill, foreground, or drive an editor/PIE session
  that the current task did not start unless the user explicitly authorizes it.
- Project Browser, recovery dialogs, or an editor attached to the wrong project
  are not evidence that the requested project is ready.
- Keep generated proof/media out of source control unless the repo explicitly
  requires it.

## Failure handling

- Tool/transport failure is local to that route. Use another supported route or
  continue independent source/test work instead of exporting routine recovery to
  the user.
- A broken capture, camera, or proof path does not by itself prove the product is
  broken; distinguish evidence failure from implementation failure.
- Do not create a new Unreal wrapper, launcher, bridge, registry, or policy layer
  until the repo and live tool surface have been checked for an existing owner.
