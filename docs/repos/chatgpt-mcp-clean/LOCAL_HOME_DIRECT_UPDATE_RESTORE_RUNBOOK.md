# Local home-direct MCP update, restore and proof runbook

This is the human-facing operating runbook for changing the current local GPT1 MCP serving generation. It is intentionally narrower than historical MCP recovery reports. Current machine truth comes from `C:\Users\Lauri\Desktop\vault\04 Operating Contracts\mcp-current-topology.json`, `C:\Users\Lauri\Desktop\vault\04 Operating Contracts\mcp-recovery-state.json`, the live runtime/task state, and the exact candidate source being promoted. If those disagree with this document, stop and reconcile the current authorities before changing production.

## Current local production boundary

As verified on 2026-09-10, the production shape is:

- connector: `https://91-159-12-133.sslip.io/mcp`;
- public/auth origin: `https://91-159-12-133.sslip.io`, with owner authorization at `/authorize` in `local-edge` mode;
- serving path: ChatGPT/GPT1 -> local HTTPS Caddy -> `127.0.0.1:3022`;
- backend scheduled task: `McpV4HomeDirect3022`;
- Caddy scheduled task: `McpV4HomeDirectCaddy`;
- serving checkout: `%LOCALAPPDATA%\ChatGPTMcpV4HomeDirectStable` on `chatgpt/home-direct-stable-runtime`;
- independent local recovery target: clone-a on `127.0.0.1:3011`;
- current production tool generation: exactly `start_process`, `read_output`, `kill_process` until the issue-#235 successor is explicitly promoted;
- excluded from this production/recovery path: `5-61-91-127.sslip.io`, VPS Caddy, WireGuard, reverse SSH and Tailscale owner authorization.

The known-good tuple observed for this generation is:

- source commit: `9a0f90d96d9ed5269c355e5d9716b98f8c8355af`;
- `dist/index.js` SHA-256: `d7e3e0978b4ff839a7b72ef7e107b344cec1d5ebd49cba24e24c0b08e8018a1b`;
- `package-lock.json` SHA-256: `63f6d9413e150e9e83368aa927cbb4628836830d95dbf655af1418400fb037d3`;
- `config/home-direct.Caddyfile` SHA-256: `a46e99c0adcdb7e6673ebf8164114df716f3352dafe0eb0f5d16d67905f8a259`;
- `scripts/home-direct-supervisor.ps1` SHA-256: `904f4047ba169f58314eb3b3e8b36ce7b4ff88dc5c5dca20770737385736c5fe`;
- `scripts/home-direct-caddy-supervisor.ps1` SHA-256: `2bb1b6507761e1f76a693c44295a77581f5faff4763cc272dbf4bab01febe667`.

At the same verification point, local `3022/health` and public `/health` returned HTTP 200, unauthenticated public `/mcp` returned HTTP 401, both scheduled tasks were running with restart policy enabled, and clone-a `3011/health` returned HTTP 200. The `runtime_identity.source_dirty` field in `/health` is a launch-time identity snapshot; it must not be used alone as current Git cleanliness evidence. Re-read `git status` when cleanliness matters.

The tuple above is a recovery baseline, not permission to freeze the product forever. Before every production change, capture the then-current verified tuple again. A source SHA alone is not a rollback identity.

## Non-negotiable safety rules

1. **Never use the serving MCP route to destroy the control plane carrying that route.** A timeout, 401/403/502, stale binding, failed probe, suspected stuck process, or failed candidate does not authorize `kill_process`, `Stop-Process`, `taskkill`, broad port cleanup, task termination, launcher termination, or service termination against MCP, Caddy, Commander, their supervisors, or their recovery trees.
2. **A production transition requires an independent usable control route first.** Clone-a on `127.0.0.1:3011` is the designated local recovery target, but HTTP 200 health alone is not proof of independent control. Before any action that can make 3022 unavailable, prove a separate route can execute the exact recovery commands while 3022 is unavailable. If that proof is missing, production mutation is blocked.
3. **Do not redesign topology during recovery.** Restore only `91-159-12-133.sslip.io -> local Caddy -> 127.0.0.1:3022`. Never select the historical VPS/WireGuard/reverse-SSH/Tailscale path as rollback.
4. **Preserve identity and evidence.** Keep the stable OAuth store, shared process receipts, transport evidence, current Caddy configuration, scheduled-task definitions, baseline source commit, built-dist hash and any unique dirty work. Never clean/reset a dirty serving checkout to make an update convenient.
5. **Build and prove candidates off-path.** Do not edit or build candidate source in `%LOCALAPPDATA%\ChatGPTMcpV4HomeDirectStable` while it is serving. Use an isolated clean worktree. The current 3022 supervisor does not use generation hot-reload, so writing a new generation into the serving directory is not a supported deployment mechanism.
6. **Do not interrupt live process work casually.** Before a controlled backend transition, require `active_requests == 0` and `live_process_count == 0` unless the exact candidate has separately proven live-process handoff/reassociation across that transition. If either is nonzero without that proof, do not restart the backend.
7. **Restore first on a severe regression caused by our change.** Do not stack speculative fixes, logging or topology changes on a regressed serving generation. Restore the exact last verified behavior/topology first, then investigate from the recovered state.
8. **A green health endpoint is necessary but insufficient.** Acceptance requires tool schema, OAuth behavior and a real semantic process call through the client-visible production path.

## 1. Capture the pre-change recovery bundle

Run these reads without mutating production and save the results with the change/PR evidence:

```powershell
$stable = "$env:LOCALAPPDATA\ChatGPTMcpV4HomeDirectStable"
$topology = 'C:\Users\Lauri\Desktop\vault\04 Operating Contracts\mcp-current-topology.json'
$recovery = 'C:\Users\Lauri\Desktop\vault\04 Operating Contracts\mcp-recovery-state.json'

Get-Content -Raw $topology
Get-Content -Raw $recovery
git -C $stable status --short --branch
git -C $stable rev-parse HEAD
Get-FileHash "$stable\dist\index.js" -Algorithm SHA256
Get-FileHash "$stable\package-lock.json" -Algorithm SHA256
Get-FileHash "$stable\config\home-direct.Caddyfile" -Algorithm SHA256
Get-FileHash "$stable\scripts\home-direct-supervisor.ps1" -Algorithm SHA256
Get-FileHash "$stable\scripts\home-direct-caddy-supervisor.ps1" -Algorithm SHA256
Get-ScheduledTask -TaskName 'McpV4HomeDirect3022','McpV4HomeDirectCaddy'
Get-ScheduledTaskInfo -TaskName 'McpV4HomeDirect3022'
Get-ScheduledTaskInfo -TaskName 'McpV4HomeDirectCaddy'
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:3022/health
Invoke-WebRequest -UseBasicParsing https://91-159-12-133.sslip.io/health
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:3011/health
```

Expected public unauthenticated behavior is HTTP 401 on `https://91-159-12-133.sslip.io/mcp`; a 200 response is not expected proof. Record the actual status.

The bundle is valid only if the current topology/recovery contracts still describe the same local-only path and the serving checkout has no unexplained tracked modifications. If the checkout is dirty, preserve and reconcile it before continuing.

## 2. Prove the independent recovery route

Before touching 3022, prove an independent route that does not traverse the 3022 backend can run local commands. Record the route identity and timestamp in the change evidence. The minimum proof is:

- independent route is reachable;
- it can read the `McpV4HomeDirect3022` task state;
- it can read the serving checkout HEAD and `dist/index.js` hash;
- it can read clone-a `3011/health`;
- it remains usable if the normal GPT1/3022 connector is unavailable.

Do not simulate this by issuing the proof through the same GPT1 connector being changed. If the independent route cannot be established, stop here. Do not terminate or restart MCP to "see if recovery works".

## 3. Build the candidate in an isolated worktree

Normal maintenance starts from the currently verified stable runtime commit. A feature lineage such as issue #235 must first be reconciled onto the current stable lineage so it cannot silently drop later local-home-direct fixes.

Example candidate setup:

```powershell
$repo = "$env:LOCALAPPDATA\ChatGPTMcpClean"
$stable = "$env:LOCALAPPDATA\ChatGPTMcpV4HomeDirectStable"
$baseline = (git -C $stable rev-parse HEAD).Trim()
$candidate = "$env:LOCALAPPDATA\Temp\mcp-home-direct-candidate-<issue>"

if (Test-Path $candidate) { throw "candidate path already exists: $candidate" }
git -C $repo worktree add -b chatgpt/<issue>-home-direct-candidate $candidate $baseline
Push-Location $candidate
npm ci
npm run build
```

Do not point Caddy or either production scheduled task at this worktree during candidate construction.

## 4. Candidate acceptance gates

At minimum, all relevant current-generation gates must pass in the clean candidate worktree:

```powershell
node scripts/verify-process-contract.mjs
node scripts/test-read-window.mjs
node scripts/test-owner-auth-origin.mjs
pwsh -NoLogo -NoProfile -NonInteractive -File scripts/test-home-direct-caddy-supervisor.ps1
node scripts/test-supervisor-continuity.mjs
node scripts/process-guard.mjs
git diff --check
```

Also run the candidate's maintained local/off-path semantic smoke against an isolated non-production port and state root. It must prove the intended generation's exact `tools/list` schema and real `start_process -> read_output` behavior without touching the production OAuth store or shared production process state.

For the current three-tool generation, acceptance includes:

- tools are exactly `start_process`, `read_output`, `kill_process`;
- `read_output.max_chars.maximum == 32000`;
- default `start_process` bounded wait remains 750 ms;
- live-process cap remains five per caller and is caller-isolated;
- no rolling launch/token bucket reappears;
- local-edge OAuth and PKCE/refresh continuity pass;
- home-direct Caddy continues to proxy to 3022 and does not inject a fake authorization header;
- unexpected backend child exit is supervisor-recoverable in isolated test mode;
- shared process receipt/control semantics required for replacement remain intact.

A test-harness cleanup failure is not silently converted into PASS. Distinguish a behavioral assertion failure from a post-test cleanup failure, fix or explicitly disposition the harness defect, and keep every relevant behavioral gate green before promotion. As of the 2026-09-10 baseline check, `verify-process-contract`, `test-read-window`, `test-owner-auth-origin`, and `test-home-direct-caddy-supervisor` passed; `test-minimal-clone-identity-guard` reached its behavioral assertions but then hit a Windows temp-directory `EPERM` cleanup failure, and the old `test-local-smoke` contained a stale launcher-identity expectation. Those are not production-pass claims.

## 5. Freeze the candidate identity

Before promotion, record all of the following:

- candidate commit SHA;
- candidate tracked-tree cleanliness;
- `package-lock.json` SHA-256;
- rebuilt `dist/index.js` SHA-256;
- exact intended tool generation;
- candidate test results;
- baseline commit and baseline dist hash;
- exact list of topology/config/task files intentionally changed, if any.

Rebuilding the 2026-09-10 baseline commit in an isolated worktree reproduced the live `dist/index.js` hash exactly (`d7e3e097...e8018a1b`), so dist equality is a usable mechanical check for this baseline.

Any unexplained difference between source identity, dependency lock, built dist, Caddy config, supervisor scripts or declared topology blocks promotion.

## 6. Promotion gate

Promotion is a deliberate control-plane change. It must not be executed from the serving MCP path itself.

Immediately before handoff, re-read production health and require:

- independent recovery route still usable;
- current serving tuple still equals the captured baseline;
- no unreviewed serving-directory edits;
- `active_requests == 0`;
- `live_process_count == 0`, unless the exact transition has explicit live-process continuity proof;
- candidate acceptance is still green;
- rollback commands and baseline identity are already recorded.

If any item changed, do not "push through". Reconcile the changed state first.

For a backend-only update, keep local Caddy running. Do not restart or rewrite `McpV4HomeDirectCaddy` unless the Caddy edge itself is part of the reviewed change.

The supported simple handoff is a controlled restart of the exact `McpV4HomeDirect3022` scheduled task from the independently proven control route, with the serving checkout moved to the already-tested candidate generation while the backend is stopped. Do not use `kill_process`, `taskkill`, `Stop-Process`, broad name/port cleanup, or parent-tree termination as the transition mechanism.

Because the serving checkout is a protected runtime and its `dist/` output is not tracked by Git, the handoff must preserve source/build identity mechanically:

1. stop only the exact backend scheduled task from the independent control route;
2. confirm the 3022 listener is gone and the independent control route still works;
3. fast-forward the clean `chatgpt/home-direct-stable-runtime` worktree only to the reviewed candidate commit; never merge unrelated main/master drift during the handoff;
4. run `npm ci` and `npm run build` in the stopped serving checkout;
5. verify the rebuilt `dist/index.js` hash equals the frozen candidate dist hash and rerun `verify-process-contract.mjs` before starting production;
6. start only `McpV4HomeDirect3022`;
7. immediately execute the post-promotion proof below.

If the stable runtime cannot fast-forward cleanly to the candidate, promotion is blocked. Reconcile off-path; do not force/reset the live runtime to make the branch fit.

## 7. Post-promotion proof

A promotion is not accepted until all layers agree on the new generation:

1. `McpV4HomeDirect3022` is running under its supervisor and its task restart policy is unchanged.
2. `http://127.0.0.1:3022/health` returns HTTP 200 and reports the frozen candidate source commit and dist hash.
3. `https://91-159-12-133.sslip.io/health` returns HTTP 200 and reports the same backend generation/identity.
4. Unauthenticated `https://91-159-12-133.sslip.io/mcp` returns HTTP 401.
5. Authenticated client-visible `tools/list` matches exactly the generation declared in `mcp-current-topology.json`.
6. Through the real GPT1/client-visible path, run one disposable semantic proof: `start_process` emits a unique marker, `read_output` using the same process ID returns that marker and terminal exit code 0. Test `kill_process` only on a disposable task-owned process whose tree is positively known not to contain protected control-plane infrastructure.
7. If the change affects paging/process semantics, repeat the relevant 32 KB/concurrency/receipt proof against the promoted generation.
8. Re-read Caddy/backend task state and confirm no unexpected task/config/topology drift.

Only after these pass should `mcp-current-topology.json`, recovery state and derived Atlas projections be updated to the new proven generation where the change actually altered those facts.

## 8. Immediate rollback / restore

Rollback is triggered when the promoted generation causes a severe recurring regression, cannot satisfy the post-promotion proof, changes the client-visible tool contract unexpectedly, breaks local-edge OAuth, enters a supervisor restart loop, or is measurably worse than the captured baseline on equivalent evidence.

On trigger:

1. stop speculative MCP/edge changes;
2. preserve failure evidence, current receipts, OAuth state, candidate commit/hash and any unique work;
3. use the already-proven independent control route;
4. if the backend is still serving live requests/processes, do not terminate it blindly; either wait for the bounded safe drain condition or use an already-proven live-process handoff mechanism;
5. stop only the exact `McpV4HomeDirect3022` task when the safe transition condition is satisfied or the backend is already down;
6. restore `chatgpt/home-direct-stable-runtime` to the exact captured baseline commit without deleting unique work; a destructive Git reset is not a generic recovery shortcut;
7. run `npm ci`, rebuild, and require the restored `dist/index.js` hash to equal the captured baseline dist hash;
8. require `verify-process-contract.mjs` to pass before restart;
9. start `McpV4HomeDirect3022`;
10. rerun the complete post-promotion proof against the restored baseline.

If the working tree or branch cannot be returned to the captured baseline without destroying unique work, create/reuse an isolated worktree containing the exact baseline, build and prove it there, and use the existing reviewed recovery mechanism rather than deleting or overwriting the conflicting work.

Never "restore" by routing GPT1 through VPS/WireGuard/reverse SSH/Tailscale. That is a new topology design and requires separate explicit authorization; it is not recovery under this runbook.

## 9. Caddy/edge changes

A Caddy change has a larger blast radius than a backend-only update. In addition to the backend gates:

- preserve the currently proven `home-direct.Caddyfile` and its hash before editing;
- test the candidate Caddy configuration off-path;
- prove `/authorize` remains local/private-only and other `/authorize` requests fail closed;
- prove the ordinary handler still proxies to the intended local backend;
- do not mutate the backend and Caddy simultaneously unless one reviewed change genuinely requires both;
- keep the backend recovery/control route independent from the edge transition;
- restore the previous Caddy config immediately if public health/auth routing regresses after the edge change.

Do not add VPS, WireGuard, reverse SSH or Tailscale owner-auth dependencies to fix a local-edge Caddy problem.

## 10. Closure record

For every production change, record one compact evidence block containing:

- old source commit + dist hash;
- new source commit + dist hash;
- exact changed files/contract generation;
- independent recovery route proof;
- candidate test results;
- pre-change and post-change local/public health;
- client-visible `tools/list` result;
- semantic `start_process -> read_output` proof;
- rollback target and whether rollback was exercised;
- any relevant harness failure kept distinct from runtime failure.

The production change is complete only when the runtime, client-visible contract, machine-readable topology/recovery state and durable human documentation agree. Historical reports remain evidence; they never override the current local contract.