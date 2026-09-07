# Dev Progress Board ? Agent Contract

This board is a read-only user/operator reporting cockpit, not worker coordination and not task authority. GitHub/repos own delivery work. BusyCoordinator owns only exact live mutation collision control. The board may display those facts, but coordinator state never becomes goals, priority, workload pressure, or proof of progress.

## Normal operation

Workers do not maintain this board. State is derived from live GitHub, Git, runtime/process, CI, proof, scheduler, worker-report, and exact coordinator ownership evidence. A claim alone never makes work active.

`state/snapshot.json` is the board's only live generated state and is intentionally Git-ignored. Retired status/event snapshots are not current repository surfaces. The board exposes no mutation endpoints: it does not create GitHub work, edit Vault memory, accept worker event POSTs, or provide manual progress writes.

## Progress rule

Never invent percentages. A milestone is 100% only when supported by the configured evidence/state; otherwise it contributes 0% unless a real measured progress value is available from an authoritative source.

## Product acceptance ledgers

When a project config names a GitHub `acceptance_ledger`, that GitHub issue owns product-readiness rows. For P3, #611 is the current ledger. Integration workers update rows on GitHub using the structured `p3-acceptance-row:v1` comment protocol documented on that issue. The board only reads and validates those receipts.
