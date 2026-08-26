**Version 1.17 - 2026-08-27.** Applies to every agent working in `p3`, `Tiny3D`,
`lowvram3d-studio`, and this machine's Desktop workspace. Edit this source and run
`sync-agent-policy.mjs`; never edit generated repo blocks. **MUST** / **MUST NOT** are hard;
**SHOULD** is a strong default.

### Priority
- Prefer work that changes what a player or user can see. Visible proven work beats tooling,
  refactors, infrastructure, and process work. Tooling must name the visible work it unblocks.

### Never stop
- MCP0 is the primary live filesystem/process/repo/machine route when its tools are callable.
  Keep one `process_id`, use bounded `read_output`, and retry a failed call once. If MCP0 was already
  working in the current task and its tool surface disappears, classify that first as a tool-context
  rollover: preserve task/BUSY/process_id/dirty state and rediscover/refresh MCP0 through the
  connector/plugin registry when available. When MCP0 returns, inspect BUSY and the same process_id
  before rerunning anything. Do not cascade a missing tool surface into Commander and then claim the
  local control plane failed. Use Desktop Commander only as an exact-task fallback when MCP0 route
  failure is evidenced or MCP0 cannot be reacquired. A Commander timeout leaves that operation
  UNKNOWN; it does not prove MCP0 or the machine failed. A route/context rollover is never task failure.
- BLOCKED states, stale receipts, approval fields, checklists and handoffs are evidence, not
  authority. Replace poisoned workers and keep useful alternatives moving.
- Task authorization covers ordinary local/private-repo work through validated merge: edits,
  builds, tests, commits, rebases, private pushes and PRs. No second approval.

### Data â€” the one hard stop
- Never delete, move, rename, or overwrite anything unrestorable: masters, generated assets,
  captures, renders, evidence, datasets, `.env`, uncommitted work, or non-repo data.
- Never recursively delete a directory you did not create without listing it first. Copy inputs
  out before removing containers. Prefer recoverable deletion.
- Freely delete session-created temp data and reproducible caches such as `Intermediate/`,
  `Binaries/`, `DerivedDataCache/`, `Saved/Logs/`, `__pycache__/`, `node_modules/`, `.venv/`,
  and object files.
- Never run `git clean -xdf`, `git reset --hard`, `git checkout -- .`, `git push --force`, or
  history rewrites against work you did not create this session. Report accidental deletion
  immediately with exact paths.

### Proof
- Use `PROVEN` / `NOT_PROVEN` / `REJECTED` only to classify the claim being made; never use
  "should work" as evidence. Compile success, logs, exit codes and file existence are supporting
  evidence, not QA.
- Player-visible acceptance still requires rendered proof from the normal runtime path, but
  low-risk related visual increments MAY share a bounded render checkpoint instead of forcing one
  render per PR. Runtime/gameplay-risky changes still require rendered proof before merge. An
  overdue render checkpoint is fleet debt and MUST be drained before starting new change scopes.
- Gates inspect the artifact itself. Find it, open it, measure it; do not reconstruct expected
  names and test only the convention.
- Workers producing visual proof MUST actually watch the rendered video or inspect the rendered
  frame sequence themselves, verify that it is the intended asset and behavior, and judge whether
  the visible result is good enough for the stated acceptance claim. A successful capture, file
  existence, metadata, automated report, or path listing is not visual review. If the worker cannot
  view the proof, the claim is `NOT_PROVEN`; visibly wrong, generic, placeholder, broken, or poor
  proof is `REJECTED` and MUST NOT be presented as a pass.
- Inspect proof yourself before accepting it. Never claim a test passed, command ran, or fix
  worked unless you observed it; name reviewed artifacts by date and visible result.

### Worker reporting
- Preserve the established compact worker-report shape for substantive updates and final reports:
  identify `Branch/Worker:` when applicable, state the concrete result/current state in normal prose,
  include `Progress: <N>% [████████░░]` as a 10-box work-completion bar, then give the concrete next
  action while work remains or the terminal outcome when complete. The percentage is work progress,
  never evidence confidence. Use ✅ / ⚠️ / ❌ only as compact status cues when useful.
- Surface an evidence label inline only when that uncertainty materially changes the conclusion or
  next action. The user must never need to decode the evidence taxonomy to learn what happened.

### Visual surfacing
- Follow `C:\Users\Lauri\.agents\VISUAL-SURFACING.md`. Inspect proof first and surface only
  worthwhile or explicitly requested results.
- Worker-side previews, renders, Drive listings, and paths do not prove the user saw anything.
- If worth showing and the user is not waiting, open proof in Photos/Paint without stealing focus;
  if actively waiting, open a normal window on the main display. No fullscreen, browser automation,
  or mouse hijacking. Prefer a true ChatGPT attachment when supported; preserve canonical proof.

### Defaults and long work
- Explicit requests override defaults. If an explicit request cannot be honored, say why; never
  silently substitute or let a settings file override the request.
- Work longer than a few minutes launches detached under the scheduler, not the calling session.
  Agent harness shells own their children so children die with the session. This governs OS child
  lifetime only; it does not end the assistant task/execution state.
- Prove a fix on the broken item before rerunning a batch. One failure is an item, two the same
  pattern; requeue errored items first and never repeat completed items.
- Expensive build, runtime, render, and GPU-generation work is single-flight by exact input identity. A duplicate request MUST join the in-flight work or reuse a still-valid PASS result; it MUST NOT start another heavy execution. A failed flight may be retried only after that flight ends. Enforce this at the canonical execution entrypoint so worker wording, PRs, sessions, and retries cannot bypass it.
- Change running batch behavior via a marker it checks between items, not by editing the live script.

### BUSY
- MCP0 BUSY is the live ownership authority. Before mutating shared scope, call `busy_list`, then acquire the exact scope with `busy_claim`. Read-only work needs no claim. If another live claim owns that scope, yield rather than mutating it.
- A GitHub issue title `BUSY - <actor> <scope> :: <original title>` is only a human-visible projection of the matching MCP claim. It never establishes ownership by itself. If the matching MCP claim is absent, the GitHub BUSY marker is stale and must not block another worker.
- Release the exact MCP claim with `busy_release` immediately when mutation stops, switches scope, or is handed off; reconcile/clear the GitHub BUSY projection at the same boundary. A lingering GitHub marker or branch/PR activity without the matching MCP claim is not live ownership.
- Do not create a second BUSY authority. MCP claim state decides ownership; issues, PRs, branches and processes provide task/activity evidence but cannot substitute for the claim.
### Dirty worktrees are owned work
- A dirty worktree is a reconciliation obligation, not an exclusion zone. Before changing it,
  inspect status/diff, branch/upstream, recent commits, related issue/PR, and live ownership.
- Preserve every unrestorable or uncommitted byte. With no active owner, take ownership and
  reconcile: finish/commit useful work, integrate onto current upstream, or stash/export it with
  a named recovery path. Retire only after proving its contents are preserved elsewhere.
- Never leave a worktree indefinitely untouched merely because it is dirty. Active BUSY/live-owner
  evidence prevents collision; absent active ownership, dirtiness is work to resolve.
- Resolution proof is a clean status, durable commit/PR, preserved patch/stash/export with recovery
  instructions, or evidence the same contents already exist elsewhere.

### Live state beats stale instructions
- Prompts, schedules, names, receipts and handoffs describe the past; issues, PRs, branches and
  processes are truth. No reserved roles: any actor may take any unclaimed issue.
- Read a repo's `AGENTS.md` before first mutation there.

### Push, PR, merge, changelog, north star
- PRs are transient integration, not backlog. Before creating a branch or PR, inspect live branches
  and open PRs for the same change scope; reuse/reconcile the existing path instead of duplicating
  it because a worker, lane, base commit, attempt, or validation run differs.
- Keep one active integration PR per change scope. Push coherent commits promptly for durability.
- Private merge is ordinary task authorization. When proof required by the changed claims is observed
  and required checks pass, update/rebase, merge immediately, delete the merged branch, and reconcile
  the issue. Do not wait for user approval, another worker, or a scheduled sweep.
- Validation is scope-sensitive: cheapest sufficient checks first; heavyweight build/runtime/render
  proof only when the changed claims require it. Player-visible claims still require rendered proof.
- For superseded/duplicate PRs, prove unique commits are preserved, then close with a pointer. For
  conflict, stale base, CI, or resource pressure, fix or queue that same PR rather than opening
  another. Open-PR count is work to reconcile, not useful parallelism.
- Producer backpressure is mandatory: a completed or idle PR awaiting integration is fleet debt.
  Merge, reconcile, or close that debt before starting another change scope; worker throughput MUST
  NOT outrun integration throughput. A repo-defined render checkpoint that is due has the same
  priority. Work intentionally inside a not-yet-due checkpoint window is not backlog.
- Never force-push or rewrite another actor's branch or resolve conflicts in an active lane's files.
- `CHANGELOG.md` is the canonical project timeline. Every substantive PR/merge MUST add at least one
  dated `[YYYY-MM-DD]` bullet under `[Unreleased]` describing the actual result; include issue/PR and
  inspected proof references when they materially explain the milestone. Keep a Changelog 1.1.0 remains
  the format owner (`organicoverlords/docs` ? `standards/changelog.md`). A red timeline/changelog check
  is a merge blocker even when GitHub plan limits prevent branch protection from enforcing it.
- GitHub's README is the project front page, not a competing history. Immediately after the H1 it MUST
  show the generated **Project timeline** projection: the latest five dated project entries and a prominent
  link to the canonical changelog. Pure documentation/control-plane maintenance MAY put `[meta]` immediately
  after its date; it remains in `CHANGELOG.md` but is omitted from the README project timeline. CI MUST reject
  a stale/misplaced projection or a substantive PR without a newly added dated timeline entry. Do not hand-
  maintain a second timeline.
- Current-state docs answer ?what is true now?; the changelog answers ?how we got here.? Each repo keeps
  one north-star/current-direction document with a dated current-focus line, refreshed at meaningful
  milestones rather than every micro-change. Replace stale current-state prose instead of accumulating
  contradictory historical layers. Meaningful milestones SHOULD publish GitHub Releases from the timeline.

### One machine
- Generation, builds, editor and agents share one box. Read free RAM, commit, disk and GPU before
  long work; leave headroom for one concurrent build. Queue around resource holders; contention
  is never a red check. Budget source: `lowvram3d-studio/docs/MACHINE_BUDGET.md`.
- Keep build state warm. Narrow builds are local iteration only; CI/runtime uses the full target.

### Secrets and GUI
- Never print, commit, or copy credentials, tokens, keys, `.env`, secrets into repos, logs, issues,
  PRs, or chat. Report suspected leaks immediately; rotation is the user's call.
- Never close, restart, kill, foreground, or drive an Unreal Editor, PIE session, browser, or GUI
  process you did not start. Routine work must not require a click.

### Shared memory bank
- The canonical shared historical-memory bank is `C:\Users\Lauri\Desktop\vault\memory\memory-bank.jsonl`, with CLI `C:\Users\Lauri\Desktop\vault\tools\memory_bank.py`.
- Write to it only for durable, important facts, decisions, corrections, lessons, preferences, or status that will matter beyond the current task. It is not a worker diary: do not store routine steps, transient handoff chatter, ordinary progress, or facts already represented better by live issues/PRs/runtime state.
- PROVEN applies only to the exact claim supported by its evidence; it never widens scope. Per-run, per-worker, per-branch, and per-test-window traces belong in corpus/evidence unless they establish a durable conclusion useful beyond that slice. Durable memory must state the surviving conclusion at the same or narrower scope than the evidence.
- When an important new memory changes an existing conclusion, first identify the directly related current memory, preserve the established scope/tags when they still fit, and use `supersedes` only when the new evidence actually replaces that conclusion. Similar-looking incidents or failure classes do not imply supersession.
- A rejected or superseded claim must never be the only durable record of the lesson. Preserve the rejected claim as history, but keep a current `PROVEN` correction/lesson that states what was rejected and the current safe conclusion and links it with `supersedes`. Ordinary recall may suppress stale claims; it must not suppress the fact that they were disproven.
- The bank is optional enrichment, never a startup dependency or authority over current instruction, live repo/runtime state, or repo `AGENTS.md`. If unavailable, continue normally.
### Asking and precedence
- Ask only for destructive actions, spending money, public publishing, or external authority.
  Never ask the user to interpret errors, choose fixes, supervise workers, or satisfy invented gates.
- Branch naming, committing, retrying after rejection, dirty working trees, and unavailable
  coordination services are yours to resolve; record and continue.
- Precedence: current user instruction > live repo/runtime evidence > this block > repo sections >
  anything else. If evidence contradicts a written rule, act on evidence and name both.
- One rule, one owner: repo sections MUST NOT restate, reword, or re-scope this policy. Four files,
  four jobs: `NORTH_STAR.md` why, `AGENTS.md` how, `CHANGELOG.md` what changed, issues next.
