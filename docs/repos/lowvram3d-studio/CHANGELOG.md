# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).
The rule this file follows is `organicoverlords/docs` â†’ `standards/changelog.md`.

## [Unreleased]

- [2026-09-06] [producer-manifest] Fail closed the canonical `build-singleflight` handoff when unresolved shared-geometry `SEMANTIC_CONFLICT` relations remain, while preserving the written manifest as repair evidence and allowing provenance-proven intentional aliases (#40).
- [2026-09-05] [producer-manifest] Bind each completed singleflight views12 artifact into the canonical Tiny3D producer handoff while keeping independent review state in `visual_qa` (#129).
- [2026-09-04] [queue] Preserve NFC-normalized Unicode letters/digits in queue asset names instead of collapsing non-ASCII source stems; supersedes the obsolete Aug-24 handoff-controller implementation in PR #68.
- [2026-09-05] [meta] Finished the shared agent pointer migration so LowVRAM coordination/dispatch docs and the authority check use the current `.agents` / `organicoverlords/agents` contract (#43).
- [2026-09-04] [meta] Retired the final two branch-bound product workflows and the orphan runtime-freeze helper; current production uses the canonical frozen package and live product paths instead.
- [2026-09-04] [meta] Retired 13 dead self-hosted workflows and their dedicated shaman run checker; all were pinned to deleted July/August feature branches with no runs after August 7.
- [2026-09-04] [meta] Retired the obsolete repo-local AI provider/failover launcher, simulation suite, and orchestration policy; general provider/tool routing now comes from canonical agent rules while LowVRAM keeps only product-specific runtime boundaries.
- [2026-09-04] [meta] Retired duplicated LowVRAM agent coordination/dispatch policy bodies; local rule surfaces now point to canonical `agent-rules`, while the authority gate checks pointer integrity and LowVRAM product contracts only.
- [2026-09-02] [source-recovery] Record exact requested/scanned roots, missing roots, source-image count, and deterministic scan-scope identity so P3 #456 0/8 coverage claims are reproducible (#50).

- [2026-09-03] [queue] Fail closed when external user image batches enter the main-repo batch wrapper; route them to the preserved compatibility queue instead (#121).

- [2026-09-03] [visual-qa] Bound queue 12-view output to write-once local proof runs with independent review; sheet existence no longer implies Tiny3D visual acceptance, and the queue accepts valid variable-height 5600px-wide grids (#42).

- [2026-09-02] [source-recovery] Require semantic filename-token matches so unrelated sticker names cannot satisfy P3 #456 weapon/projectile source coverage (#50).

- [2026-09-02] [producer-manifest] Added fail-closed source-byte attribution auditing for unresolved shared-geometry semantic conflicts (#40).

- [2026-09-02] [producer-manifest] Localized singleflight manifest changes to the affected producer entry plus manifest identity, with per-asset completion-time evidence instead of receipt-set-derived top-level metadata (#45).

- [2026-09-02] [producer-manifest] Added a guarded `producer_manifest.py reconcile-singleflight` command to recover legacy terminal receipt identity/source evidence without overwriting conflicting provenance.

- [2026-09-02] [meta] Generated AGENTS policy projections are changelog-exempt and README timeline projection is merge-stable.

- [2026-08-30] [meta] Synced shared agent policy v1.25 so temporary Git state is closed after work instead of accumulating as repository storage.

- [2026-08-30] [meta] Synced shared agent policy v1.24 and demoted legacy production-lane and visible BUSY-marker files to status projections under standalone BusyCoordinator ownership.

- [2026-08-29] [meta] Synced the shared Vault-continuity policy so fresh coding sessions bootstrap from the Vault while retaining standalone BusyCoordinator authority.

- [2026-08-28] [meta] Synced shared agent policy v1.21 so fresh worktrees use the standalone canonical coordinator and reject legacy MCP0 BUSY authority.

### Added

- [2026-09-02] Added deterministic producer-manifest construction from authoritative singleflight receipts and preserved producer/source identity on future failed flights so failures cannot be silently omitted (#45).

- [2026-09-02] Made producer ingest readiness fail closed on unresolved same-geometry semantic identity conflicts while provenance-proven intentional aliases remain ingest-ready (#40, #45).

- [2026-09-02] Added a collision-safe move-not-delete migration that consolidates malformed out_ingest_stage<asset> prepared-source directories into canonical out_ingest_stage/<asset>/ paths without overwriting preserved sources (#41, #73).

- [2026-09-02] Hardened producer ingest-readiness auditing so artifact paths must resolve inside the supplied production root, rejecting traversal/symlink escapes before Tiny3D handoff (#45).

- [2026-09-02] Preserved zero-byte failed artifacts as producer-manifest evidence so readiness auditing can report corruption instead of schema validation discarding the record (#39, #45).

- [2026-09-02] Added current-artifact producer ingest-readiness auditing that fails closed on missing/zero/corrupt GLBs, texture hash/size mismatches, failed validation/views12, and distinguishes upstream failure from transport corruption (#47).

- [2026-09-02] Added `geometry-audit --fail-on-conflict` so CI/library construction can fail closed when unresolved producer semantic conflicts remain, while provenance-proven intentional aliases still pass (#40).

- [2026-09-01] Added deterministic shared-geometry producer-manifest auditing so duplicate GLB hashes surface as semantic conflicts unless explicit source-provenance evidence proves an intentional alias (#48, #40).

- [2026-09-01] Added a provenance-bound compound-source crop extractor for #50 so weapon/projectile recovery leads can be isolated without losing parent SHA-256 lineage, overwriting preserved source/output paths, or being misclassified as production-ready.

- [2026-09-01] Added a deterministic, SHA-256-bound source-recovery audit for the eight-role P3 #456 weapon/projectile family so existing source libraries can be searched without treating filename matches as accepted production assets (#50).

- [2026-08-26] [meta] #51 makes exact LowVRAM heavy asset work machine-wide single-flight across queues, worktrees, and worker sessions.

- [2026-08-27] Added deterministic producer-manifest delta receipts with content/provenance/validation/semantic classification and Tiny3D refresh hints (#49).

- [2026-08-27] Added the versioned LowVRAM producer-manifest schema, deterministic `manifest_id`, standalone validator/canonicalizer, explicit failed/unknown evidence states, alias/conflict metadata, and real-record regression coverage for Tiny3D intake (#46).

- Exposed the canonical changelog on the GitHub landing page and added CI enforcement for changelog and landing-page synchronization.

- `docs/MACHINE_BUDGET.md`: measured RAM/commit/pagefile/disk/GPU state for this machine, the
  contradiction between LowVRAM's commit-first resource gate and p3's physical-first build
  admission, and the five-point sharing contract.

- Dated live-state refresh in `docs/NORTH_STAR.md`, appended without changing product intent.

- `CHANGELOG.md`, adopting the org-wide changelog standard (`organicoverlords/docs` ->
  `standards/changelog.md`). Changes from 2026-08-24 onward get an entry here; history is
  not backfilled.

### Changed

- [2026-09-01] Tightened the P3 #456 recovery audit so compound character/environment images are reported as extraction leads rather than counted as standalone source coverage (#50).

- [2026-08-31] Passed the frozen manifest explicitly to the verifier so a valid preserved package cannot fail on an empty script-root invocation (#50).
- [2026-08-31] Made frozen-production discovery require the complete single-view wrapper/verifier set and fail closed on a nonzero freeze-verification exit (#50, #97).
- [2026-08-31] Hardened intake provenance so queued source hashes must match the exact referenced source bytes (#50).
- [2026-08-24] Aligned authority policy with the canonical production docs (#71).
- [2026-08-26] [meta] Kept documentation/control-plane maintenance in CHANGELOG.md while excluding it from the README project timeline, and fixed same-day project-entry ordering.
- [2026-08-26] [meta] Hardened project-timeline enforcement so direct pushes to main validate HEAD^..HEAD instead of bypassing the dated changelog requirement.
- [2026-08-26] [meta] Removed an accidentally duplicated README timeline block and made the checker reject duplicate timelines or misplaced shared-agent-policy markers.
- [2026-08-24] Deduplicated repository agent policy while preserving LowVRAM-specific production authorities (#75).
- [2026-08-24] Made replay timeout handling tolerate process-exit races (#77).
- [2026-08-25] Gated billboards, repaired render proof, and stopped overriding requested production settings (#79).
- [2026-08-25] Documented the missing output-directory failure and recovery path (#80).
- [2026-08-26] [meta] Made CHANGELOG.md the dated project timeline and moved its latest five entries to the top of the GitHub README with enforced dated-entry checks.
- Deduplicated `AGENTS.md` so the shared policy has one owner while LOWVRAM-specific
  production authorities and integrity constraints remain local; the policy-size CI guard
  now validates the smaller contract without restating shared BUSY/governance rules.

- Replay timeout cleanup now runs `taskkill` without a visible console and judges the
  owned process's final state, avoiding false CI failures when a child exits during cleanup.

- `AGENTS.md` shared policy raised to v1.2, adding a hard rail on deleting irreplaceable data
  (masters, assets, evidence) after an agent destroyed a set of masters, plus non-blocking
  defaults for disk reclaim, branch prune-on-merge, and full-target builds for anything CI or a
  runtime loads. The visual-proof gate is explicitly excluded from those relaxations.

- `AGENTS.md` shared policy raised to v1.1: a control plane, MCP included, is transport and
  visibility and never permission, so an unavailable connector can no longer be reported as
  the reason work did not start, and BUSY stays authoritative in the GitHub issue title.

<!--
Delete the headings you do not use. Keep this section at the top at all times.

To release:
  1. Rename this heading to `## [X.Y.Z] - YYYY-MM-DD`.
  2. Open a fresh empty `## [Unreleased]` above it.
  3. Update the link block below.

Entry style â€” one line, for a human, with the issue or PR number:
  - Sprint combat effects are now server-authoritative; clients can no longer apply
    damage locally (#494).
-->

[Unreleased]: https://github.com/organicoverlords/lowvram3d-studio/commits/main
