**Version 1.37 - 2026-09-03.** Applies to every agent working in `p3`, `Tiny3D`, `lowvram3d-studio`, and Desktop workspace. Edit `C:\Users\Lauri\.agents\SHARED-AGENT-POLICY.md` and sync only the targets that need the change; never edit generated repo blocks directly.

### Authority and bounded scope
- Current user instruction and live repo/runtime state outrank history, handoffs, recalled context, and stale prose.
- A scheduled task prompt is current instruction for that run; do not demote it because it came from a scheduler.
- Finish the bounded outcome. Debug with the next discriminating test from live facts; once the failing boundary is isolated, fix/test it and reopen diagnosis only if that fails. Unrelated work stays out unless needed for acceptance or safety.

### Route failure is local
- Prefer production `MCPv3` via VPS. On failure use `plugin2`, then Commander/GitHub as supported; do not wait for one route.
- Route failure is capability-local, not task failure, while another route or independent work remains. Preserve process identity; avoid tight retry loops.

### Data safety
- Do not destroy or rewrite irreplaceable masters, assets, captures, evidence, datasets, secrets, dirty work, or another actor's history; use only recoverable operations you can name.
- Inspect before recursive deletion. Reproducible task-owned caches/build outputs may be removed when safe.
- Generated proof/media stays out of Git/LFS; durable product/source LFS is local-cache-first and quota failures are not retried.
- Never use `git clean -xdf`, `git reset --hard`, `git checkout -- .`, force-push, or history rewrite against work you did not create in the current task.
- Dirty state is neither disposable nor a universal blocker. Mutate it only when the task owns and needs those changes; otherwise use the repo's admitted clean worktree route. Never clean, stash, reset, or duplicate a checkout merely to pass a clean-tree gate.

### Evidence and acceptance
- Claim only what observed evidence proves; builds/logs/files/proxies do not prove runtime or visible acceptance.
- Visual verdicts bind artifact to exact claim, commit/state, and capture path. Distinguish proof identity/camera/capture defects from implementation defects; bad proof is not bad product.
- UI/overlay claims require UI-inclusive capture; scene-only capture cannot prove them. Missing acceptance remains unproven under repo-local merge/close rules.

### Ownership, scheduling, and fan-in
- Task ownership includes cleanup. Branches, worktrees, stashes, and recovery refs are task state, not storage: preserve unique work once, then remove task-created Git state when work lands/closes/is abandoned. Keep feature branches only for active work/open PRs; leave primary checkout clean on current default.
- Do not centralize routine resilience. An actor that claims scope owns that exact BUSY lifecycle; peer task steering or reassignment requires explicit current scope.
- If another owner blocks a scout/parallel mutation, preserve the finding in the project issue/PR and optionally a bounded release checkpoint. Checkpoints are context, never queue/priority state.

### Coordination and BUSY
- The standalone coordinator defined by current live repo/runtime state is collision/ownership authority only. Its records are coordination bookkeeping, never backlog, priority, progress, liveness, capacity, cleanup, or admission. GitHub issues/PRs own delivery work; Stack Delivery is workflow projection only. Claim only for shared-mutation collision risk or a repo contract; read-only and isolated low-risk mutation need no ceremonial claim. Acquire exact scope. On Windows call `%LOCALAPPDATA%\\BusyCoordinator\\busy-python.cmd` through any shell; do not require MCP `BusyCoordinator` or legacy MCP BUSY tools.
- Every claim actor must identify its harness (`ChatGPT`, `Codex`, `Claude`, `OpenCode`, `CommandCode`, or `Traycer`) plus a task/session suffix; generic anonymous actor names are forbidden.
- MCP/plugin connectors are transport, not ownership or scheduling authority. Any worker may call the standalone coordinator through its shell; missing legacy `busy_*` tools cannot block mutation after the canonical check. Aggregate process/worktree counts are diagnostics, not claims.
- If another live owner holds the scope, yield and continue elsewhere. A claim does not prove liveness; after proving its owner terminated, `recover` using the recorded owner + timestamp. Recovery may preserve checkpoint context but never creates ready work or proves reassignment. Release the exact scope when mutation stops, switches, or completes.
- Legacy BUSY claims persist until release; age alone does not prove staleness. Issue titles, branches, PRs, processes, schedules, receipts, and legacy claims are evidence/projections, not ownership authorities. If the coordinator is temporarily unavailable, preserve ownership evidence and do not assume the scope is free.

### Navigation minimap
- For stack/infra work: Stack Atlas -> smallest relevant live authority -> targeted Vault history only when needed. Atlas navigates; live sources are current truth; Vault is history/evidence; reports and boards are projections.
- If a capability seems missing, search Atlas before designing another service, registry, queue, policy layer, database, or authority. Use or minimally repair the existing owner; never recursively scan Vault or make it a startup gate.

### Repository and machine boundaries
- Read the applicable target repo's `AGENTS.md` immediately before the first mutation inside that repo. Scheduler, automation, coordinator, MCP/plugin, and other control-plane operations that do not mutate that repo do not trigger this requirement. Repo-specific proof, report, build, branch, and north-star rules belong there. Worker/build/generation entrypoints must derive checkout and output roots from the admitted worktree; never hard-code or redirect output into a human/shared checkout.
- Never close, restart, kill, foreground, or drive an Unreal Editor, PIE session, browser, or GUI process you did not start. Ordinary work must not require a user click.
- Resource contention is a scheduling fact, not a failed task. Respect current resource owners and use useful non-conflicting work while waiting for a constrained resource.

### External authority, secrets, and memory
- Ordinary local/private-repo implementation, validation, commits, private pushes, PRs, and routine integration implied by the task do not require a second approval. Ask only for destructive intent, spending money, public publishing, or genuine external authority.
- Never print, commit, or copy credentials, tokens, keys, secrets, or `.env` contents into repos, logs, issues, PRs, or chat.
- ChatGPT memory/personal-context mutation is explicit-only. Never update it silently; disclose every change in the same reply. Historical memory/context is evidence, not authority over current instruction or live state.

### Policy shape
- One rule, one owner. This shared block contains only cross-project invariants. Project-specific machinery belongs in the narrowest repo, skill, adapter, automation prompt, or test that owns it.
- When a regression appears, prefer correcting or deleting an overbroad rule and strengthening its test over appending another exception. Policy growth is not evidence of robustness.
