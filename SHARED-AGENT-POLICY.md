**Version 1.25 - 2026-08-30.** Applies to every agent working in `p3`, `Tiny3D`, `lowvram3d-studio`, and this machine's Desktop workspace. Edit `C:\Users\Lauri\.agents\SHARED-AGENT-POLICY.md` and run `sync-agent-policy.mjs`; never edit generated repo blocks directly. A shared-policy repair is incomplete until `node sync-agent-policy.mjs --check-remotes` proves all git-backed origin defaults match.

### Authority and bounded scope
- Current user instruction and live repo/runtime state outrank historical prompts, receipts, handoffs, recalled context, and stale project prose where higher-priority constraints permit.
- A currently scheduled task prompt is current task instruction for that run. Do not demote it to stale history merely because it came from a scheduler.
- Finish the bounded requested outcome. Unrelated dirty work, PR debt, backlog, reports, and nearby defects do not enter the completion set unless required for acceptance, collision safety, data safety, or explicit scope expansion.

### Route failure is local
- A failed route is not task failure while supported recovery, fallback, or independent work remains.
- Preserve returned process identity. Refresh/re-discover/reacquire and retry at natural boundaries as evidence warrants; no fixed retry-count cutoff and no tight-looping.
- Do not infer backend/tool absence from missing bindings, a few failures, or another actor's report. Inspect or attempt the capability first.

### Data safety
- Never delete, move, rename, overwrite, reset, or rewrite anything you cannot restore by a command you can name: masters, generated assets, captures, evidence, datasets, `.env`, uncommitted work, or another actor's history.
- Before recursively removing a directory you did not create, inspect it. Prefer recoverable deletion. Reproducible caches/build outputs you own may be removed when safe.
- Never use `git clean -xdf`, `git reset --hard`, `git checkout -- .`, force-push, or history rewrite against work you did not create in the current task.
- Dirty state is neither disposable nor a universal blocker. Mutate it only when the task owns and needs those changes; otherwise use the repo's admitted clean worktree route. Never clean, stash, reset, or duplicate a checkout merely to pass a clean-tree gate.

### Evidence and acceptance
- Never claim a test ran, a fix worked, a task completed, or a user-visible result exists unless you observed evidence appropriate to that claim.
- Builds, logs, exit codes, file existence, and proxy receipts support narrower claims; they do not automatically prove runtime or user-visible acceptance.
- Missing acceptance keeps that claim unproven. It does not create a universal merge/close prohibition: follow the bounded task and repo-local acceptance contract instead of inventing a stronger global gate.

### Ownership, scheduling, and fan-in
- Task ownership includes cleanup. Branches, worktrees, stashes, and recovery refs are task state, not storage: preserve unique work once, then remove task-created Git state when work lands/closes/is abandoned. Keep feature branches only for active work/open PRs; leave primary checkout clean on current default.
- Do not centralize routine resilience. Each actor owns its current task and exact BUSY lifecycle; peer task steering or reassignment requires explicit current scope.
- If a scout or parallel worker cannot mutate because another live owner holds the scope, an actionable finding MUST become scope-visible pending work with provenance and survive claim release. The next owner of that scope consumes it; a prose-only "someone can pick this up" handoff is not accepted fan-in.

### Coordination and BUSY
- The standalone coordinator defined by current live repo/runtime state is the single ownership, job, and checkpoint authority for shared mutable scope. Read-only work needs no claim. Before mutation, inspect it and acquire the exact scope. On Windows use `%LOCALAPPDATA%\\BusyCoordinator\\busy-python.cmd` through any shell/process transport; do not search for an MCP `BusyCoordinator` or require legacy MCP BUSY tools.
- Every mutation claim actor must identify its harness (`ChatGPT`, `Codex`, `Claude`, `OpenCode`, `CommandCode`, or `Traycer`) plus a task/session suffix; generic anonymous actor names are forbidden.
- MCP/plugin connectors are transport, not schedulers or ownership authorities. Any worker may call the standalone coordinator through its shell; missing legacy `busy_*` tools must not block mutation after the canonical check succeeds. Aggregate process/worktree counts are diagnostics, not claims.
- If another live owner holds the scope, yield mutation there, preserve actionable findings in coordinator-visible pending state, and continue safe non-conflicting work where possible. Release or complete the exact scope through the same canonical authority immediately when mutation stops, switches scope, completes, or is handed off.
- Legacy BUSY claims may remain durable until explicit release; age alone does not prove staleness. Issue titles, branches, PRs, processes, schedules, receipts, and legacy claims are projections/evidence, not competing ownership authorities. If canonical coordinator state is temporarily unavailable, preserve existing ownership evidence and do not assume the scope is free.

### Vault continuity
- At the first task of a fresh local coding session, run `python C:\Users\Lauri\Desktop\vault\tools\memory_bank.py bootstrap` before substantive reply or mutation; harness-local memory/seeds are evidence only.
- If its route fails, use the repeatable recovery rule above and continue safe work from current instruction, policy, and live state. One or two failures are not terminal.
- After genuine compaction/continuity loss, bootstrap again; a surviving summary alone does not retrigger startup.

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
