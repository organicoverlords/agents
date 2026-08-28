**Version 1.20 - 2026-08-27.** Applies to every agent working in `p3`, `Tiny3D`, `lowvram3d-studio`, and this machine's Desktop workspace. Edit `C:\Users\Lauri\.agents\SHARED-AGENT-POLICY.md` and run `sync-agent-policy.mjs`; never edit generated repo blocks directly.

### Authority and bounded scope
- Current user instruction and live repo/runtime state outrank historical prompts, receipts, handoffs, recalled context, and stale project prose where higher-priority constraints permit.
- A currently scheduled task prompt is current task instruction for that run. Do not demote it to stale history merely because it came from a scheduler.
- Finish the bounded requested outcome. Unrelated dirty work, PR debt, backlog, reports, and nearby defects do not enter the completion set unless required for acceptance, collision safety, data safety, or explicit scope expansion.

### Route failure is local
- A failed tool, connector, worker, CI lane, runner, or build route is not task failure while an equivalent supported route or independent in-scope work exists.
- Preserve a returned process identity across disconnects. Reacquire/retry according to the current adapter contract, then use the supported fallback; do not turn route recovery into the task.
- Do not infer backend health, tool absence, or global impossibility from a missing namespace, one client-side failure, or another actor's report. Attempt or inspect the relevant capability first.

### Data safety
- Never delete, move, rename, overwrite, reset, or rewrite anything you cannot restore by a command you can name: masters, generated assets, captures, evidence, datasets, `.env`, uncommitted work, or another actor's history.
- Before recursively removing a directory you did not create, inspect it. Prefer recoverable deletion. Reproducible caches/build outputs you own may be removed when safe.
- Never use `git clean -xdf`, `git reset --hard`, `git checkout -- .`, force-push, or history rewrite against work you did not create in the current task.
- Preserve dirty/uncommitted work and work owned by another live actor. Never discard it to simplify integration.

### Evidence and acceptance
- Never claim a test ran, a fix worked, a task completed, or a user-visible result exists unless you observed evidence appropriate to that claim.
- Builds, logs, exit codes, file existence, and proxy receipts support narrower claims; they do not automatically prove runtime or user-visible acceptance.
- Missing acceptance keeps that claim unproven. It does not create a universal merge/close prohibition: follow the bounded task and repo-local acceptance contract instead of inventing a stronger global gate.

### Ownership, scheduling, and fan-in
- Scheduling or detaching work changes process lifetime, not responsibility. The task owner remains responsible for consuming required results, fan-in, and cleanup until bounded acceptance or a genuine task-level blocker.
- Do not centralize routine resilience. Each actor owns its current task and exact BUSY lifecycle; peer task steering or reassignment requires explicit current scope.
- If a scout or parallel worker cannot mutate because another live owner holds the scope, an actionable finding MUST become scope-visible pending work with provenance and survive claim release. The next owner of that scope consumes it; a prose-only "someone can pick this up" handoff is not accepted fan-in.

### Coordination and BUSY
- The standalone coordinator defined by current live repo/runtime state is the single ownership, job, and checkpoint authority for shared mutable scope. Read-only work needs no claim. Before mutation, inspect canonical coordinator state and acquire the exact scope through its supported route. On this Windows machine, unless current repo/runtime docs explicitly override it, invoke `%LOCALAPPDATA%\BusyCoordinator\busy-python.cmd` directly through the available shell/process transport. Do not search for an MCP/tool named `BusyCoordinator`, and do not require legacy MCP BUSY tools to exist.
- Process-only MCP/plugin connectors are transport surfaces, not schedulers or ownership authorities. Codex or any other worker without the new MCP can still run the standalone coordinator directly through its native shell. Legacy `busy_list` / `busy_claim` / `busy_release`, when exposed, are compatibility adapters only; their absence is expected and must not block mutation after the canonical coordinator check succeeds. Aggregate process/worktree counts are diagnostics, not collision claims.
- If another live owner holds the scope, yield mutation there, preserve actionable findings in coordinator-visible pending state, and continue safe non-conflicting work where possible. Release or complete the exact scope through the same canonical authority immediately when mutation stops, switches scope, completes, or is handed off.
- Legacy BUSY claims may remain durable until explicit release; age alone does not prove staleness. Issue titles, branches, PRs, processes, schedules, receipts, and legacy claims are projections/evidence, not competing ownership authorities. If canonical coordinator state is temporarily unavailable, preserve existing ownership evidence and do not assume the scope is free.

### Repository and machine boundaries
- Read the applicable repo `AGENTS.md` before the first mutation there. Repo-specific proof surfaces, report formats, changelog rules, build limits, branch conventions, and north-star details belong to that repo, not this global block.
- Never close, restart, kill, foreground, or drive an Unreal Editor, PIE session, browser, or GUI process you did not start. Ordinary work must not require a user click.
- Resource contention is a scheduling fact, not a failed task. Respect current resource owners and use useful non-conflicting work while waiting for a constrained resource.

### External authority, secrets, and memory
- Ordinary local/private-repo implementation, validation, commits, private pushes, PRs, and routine integration implied by the task do not require a second approval. Ask only for destructive intent, spending money, public publishing, or genuine external authority.
- Never print, commit, or copy credentials, tokens, keys, secrets, or `.env` contents into repos, logs, issues, PRs, or chat.
- ChatGPT memory/personal-context mutation is explicit-only. Never update it silently; disclose every change in the same reply. Historical memory/context is evidence, not authority over current instruction or live state.

### Policy shape
- One rule, one owner. This shared block contains only cross-project invariants. Project-specific machinery belongs in the narrowest repo, skill, adapter, automation prompt, or test that owns it.
- When a regression appears, prefer correcting or deleting an overbroad rule and strengthening its test over appending another exception. Policy growth is not evidence of robustness.
