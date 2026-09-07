# p3 branch consolidation — 2026-08-15

Integration target: `implementation/basebuilding-rts-towerdefense-20260815`

This branch is the active convergence lane. Proven work from agent/checkpoint branches should be folded here before release instead of remaining indefinitely isolated. Do not merge whole historical branches blindly: compare from the current integration HEAD, identify only the genuinely unique delta, and transplant only work that is proven, self-contained, or clearly superseded by a newer implementation already present here.

## Rules

1. Fetch/re-read the integration HEAD immediately before every write.
2. Never force-update the integration ref.
3. If a source commit is pure-additive and its target paths are absent here, an exact blob/tree transplant is acceptable and should preserve the source SHA in the commit message.
4. If the same paths changed on both sides, do not mechanically copy the old blob. Port the intended clauses/code into the newer file or resolve through a reviewed PR.
5. A branch that is already an ancestor needs no cherry-pick.
6. A historical commit whose behavior is already present in a newer implementation is `SUPERSEDED`, not missing.
7. Mixed commits containing known-broken work are `HOLD`; extract only independently proven files after inspection.
8. Runtime/visual claims keep their original proof classification. Moving a commit does not create new proof.

## Inventory

| Source branch | Source HEAD | State vs integration | Action |
| --- | --- | --- | --- |
| `main` | `dd562269e8bad68adf35e0992f9c28493416d271` | ancestor | No action. Already contained. |
| `agent/validate-mcp-645f45f-20260813` | `645f45fb4bbe5ff31d3bcee826770751a0de5b9f` | ancestor | No action. Already contained. |
| `agent/showroom-spawn-and-effects` | `6b4af5e2f0658f06d209e373614e6f8e41e58e3f` | ancestor | No action. Already contained. |
| `agent/claude-character-and-showroom-20260813` | `c5a14f06d03fd5d2675b126d6c8eef230a1a8b97` | ancestor | No action. Already contained. |
| `agent/fennec-runtime-production-20260814` | `e25e6cbce39aae6f53b94cc4bcfea49b59370acc` | ancestor | No action. Authored Fennec runtime/input work is already in the integration history. |
| `agent/eagle-bird-rig-20260814` | `18012d5b8b9c815a1d7cf9c5070df83cf6389642` | one unique, pure-additive proven commit | **TRANSPLANTED** as integration commit `591698fb2d58145988d0299dd90ccca1f823b4d4`. Exact Eagle content/source/proof blobs copied; no existing integration path replaced. |
| `agent/trellis-ring-review` | `cbf08f58ac8182396a18ff90d8263e807c67f0f5` | two historical unique commits | **SUPERSEDED / HOLD**. `65169287df31cb0609807102addbee9cd1cfb92e` added showroom validation/canonical selection, but the integration branch already contains a newer, more capable `showroom_asset_ring.py` and menu implementation. `cbf08f...` is a broad checkpoint with mixed policy/config/review content; do not transplant wholesale. |
| `agent/claude-character-and-showroom-publish-20260813` | `e1955863beaaecae058bcacfe831a893a2b1e08f` | one mixed unique asset commit | **HOLD**. Its own commit message records the Asylum Demon as white/deformed in play and its three clips as non-moving. Do not transplant the whole asset dump. Audit/select independently proven assets only if they are still missing. |
| `checkpoint/preserve-ubt-toolchain-20260813` | `7bd7374a30e756deee3071d1a265119167036d0c` | two valid policy commits, conflicting `AGENTS.md` history | **PORTED** into the newer `AGENTS.md` as integration commit `f25e5740a86a9c26947326a2f0c0b774b3340068`. The port preserves ownership classes, desktop-input safety, local-failure scope, scope-based serialization, independent editor/worktree concurrency, and the `-NoHotReloadFromIDE` Live Coding mutex workaround without replacing later project contracts. PR #2 was used only as a conflict/audit receipt and was not force-merged. |

## Consolidation decisions already proven

### Eagle

The Eagle source branch was one commit ahead of the common ancestor and the compare against integration showed no modified or removed paths. Its unique commit was therefore safe to transplant exactly. The integration commit records the original SHA and is single-parent/fast-forward from the prior integration HEAD.

### Fennec and older showroom/MCP work

These branch heads are ancestors of the integration lane. Their functionality is already present in history; attempting to cherry-pick them again would only create duplicate conflicts.

### Showroom ring

Do not cherry-pick `65169287...` merely because Git ancestry calls it unique. The current integration implementation already contains its useful concepts plus later behavior (validation, registry rescans, canonical mesh selection, stable first-seen ordering/signage, etc.). This is a semantic supersession case.

### Toolchain/ownership policy

The useful rule is **scope-based serialization**: protect the exact editor/PIE/package/source/build output that can collide; do not globally halt unrelated projects, worktrees, editors, commandlets, Blender jobs, or offline work. Missing ownership proof for one process must not convert unrelated work into a blocker. Never control or close another agent's/user's process without proven ownership and a real need.

This policy is now durable on the integration branch at `f25e5740a86a9c26947326a2f0c0b774b3340068`; the old branch remains historical provenance only.

## Before release / production-freeze candidate

Re-run this inventory against all current remote branches. For every non-ancestor branch:

- enumerate unique commits;
- classify each as `PROVEN`, `SELF_CONTAINED`, `SUPERSEDED`, `HOLD`, or `REJECTED`;
- transplant only `PROVEN`/`SELF_CONTAINED` deltas;
- compile after reflected/C++ consolidation;
- run the relevant owned PIE acceptance for runtime claims;
- only then nominate the integration HEAD for the production/release branch.
