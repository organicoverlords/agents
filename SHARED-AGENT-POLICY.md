**Version 1.41 - 2026-09-03.** Applies to every agent working in `p3`, `Tiny3D`, `lowvram3d-studio`, and Desktop workspace. Edit `C:\Users\Lauri\.agents\SHARED-AGENT-POLICY.md` and sync only the targets that need the change; never edit generated repo blocks directly.

### Authority and bounded scope
- Current user instruction and live repo/runtime state outrank history, handoffs, recalled context, and stale prose.
- A scheduled task prompt is current instruction for that run; do not demote it because it came from a scheduler.
- Finish the bounded outcome. Use the next discriminating test from live facts. Once the requested failure is fixed and the current live path is verified, stop; non-blocking discoveries are separate work unless the user asks to continue.

### Route failure is local
- Prefer production `MCPv3` via VPS. On failure use `plugin2`; local `git`/`gh` through those machine routes is allowed. Do not use Remote Desktop Commander or the hosted GitHub connector as fallbacks.
- Route failure is capability-local, not task failure, while another route or independent work remains. Preserve process identity; avoid tight retry loops.

### Shell
- `MCPv3 start_process` is Windows PowerShell 5.1: no `&&`/`||`/`??`/ternary, `$PID` assignment, or direct `foreach {...} |`. With native `git`/`gh`/`rg`/`python`, avoid global `ErrorActionPreference=Stop`; check `$LASTEXITCODE` because stderr may become `NativeCommandError`. Never hand-build JSON with report text; use `ConvertTo-Json`/`json.dumps`, and parse only clean stdout.

### Data safety
- Do not destroy or rewrite irreplaceable masters, assets, captures, evidence, datasets, secrets, dirty work, or another actor's history; use only recoverable operations you can name.
- Inspect before recursive deletion. Reproducible task-owned caches/build outputs may be removed when safe.
- Generated proof/media stays out of Git/LFS; durable product/source LFS is local-cache-first and quota failures are not retried.
- Never use `git clean -xdf`, `git reset --hard`, `git checkout -- .`, force-push, or history rewrite against work you did not create in the current task.
- Dirty/behind is not a blocker. Preserve relevant dirty work. Swarm lanes need no global precheck or shared build/runtime/proof gate. Never clean, stash, reset, duplicate, or isolate merely for a clean tree.

### Evidence and acceptance
- Claim only what observed evidence proves; builds/logs/files/proxies do not prove runtime or visible acceptance.
- Visual verdicts bind artifact to exact claim, commit/state, and capture path. Distinguish proof identity/camera/capture defects from implementation defects; bad proof is not bad product.
- UI/overlay claims require UI-inclusive capture; scene-only capture cannot prove them. Missing acceptance remains unproven under repo-local merge/close rules.

### Parallel execution
- Work ownership is local to the bounded task and its actual files, branch, and worktree. Do not use coordinator metadata to select work, steer peers, reserve capacity, decide liveness, or recycle another actor's lane.
- Clean up only task-created state when work lands, closes, or is abandoned. Do not repurpose or remove another actor's branch or worktree merely because it is clean or process-free.

### Coordination and BUSY
- BusyCoordinator is an exact shared-mutation collision lock. It answers only whether the exact scope you intend to mutate is already owned. It is not backlog, scheduling, admission, liveness, progress, priority, capacity, lane/worktree occupancy, cleanup, proof, or workflow authority.
- Claim only immediately before shared mutation when collision risk exists. Read-only work and independent low-risk mutation need no claim. A claim blocks only that exact mutation scope; never infer a repo-wide, issue-wide, worker-wide, build-wide, or swarm-wide wait from it.
- If an exact mutation scope is owned by another live actor, do different independent work. Release your exact claim when that mutation stops. MCP/plugin routes are transport only. On Windows call `%LOCALAPPDATA%\\BusyCoordinator\\busy-python.cmd` directly; missing helper integration must not become a global blocker.

### Navigation minimap
- For stack/infra work: Stack Atlas -> smallest relevant live authority -> targeted Vault history only when needed. Atlas navigates; live sources are current truth; Vault is history/evidence; reports and boards are projections.
- If a capability seems missing, search Atlas before designing another service, registry, queue, policy layer, database, or authority. Use or minimally repair the existing owner; never recursively scan Vault or make it a startup gate.

### Repository and machine boundaries
- Read the applicable target repo's `AGENTS.md` immediately before the first mutation inside that repo. Scheduler, automation, coordinator, MCP/plugin, and other control-plane operations that do not mutate that repo do not trigger this requirement. Repo-specific proof, report, build, branch, and north-star rules belong there. Worker/build/generation entrypoints must derive checkout and output roots from their current worktree; never hard-code or redirect output into a human/shared checkout.
- Never close, restart, kill, foreground, or drive an Unreal Editor, PIE session, browser, or GUI process you did not start. Ordinary work must not require a user click.
- Resource contention is a scheduling fact, not a failed task. Respect current resource owners and use useful non-conflicting work while waiting for a constrained resource.

### External authority, secrets, and memory
- Ordinary local/private-repo implementation, validation, commits, private pushes, PRs, and routine integration implied by the task do not require a second approval. Ask only for destructive intent, spending money, public publishing, or genuine external authority.
- Never print, commit, or copy credentials, tokens, keys, secrets, or `.env` contents into repos, logs, issues, PRs, or chat.
- ChatGPT memory/personal-context mutation is explicit-only. Never update it silently; disclose every change in the same reply. Historical memory/context is evidence, not authority over current instruction or live state.

### Policy shape
- One rule, one owner. This shared block contains only cross-project invariants. Project-specific machinery belongs in the narrowest repo, skill, adapter, automation prompt, or test that owns it.
- When a regression appears, correct or delete the overbroad rule at its current owner. Do not add another registry, validator, queue, guard, or policy layer unless the current owner cannot enforce the required behavior.
