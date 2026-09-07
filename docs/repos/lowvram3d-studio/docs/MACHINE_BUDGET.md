# Machine budget — one box, several workloads

LowVRAM/TRELLIS generation, Unreal builds, the Unreal editor, and every agent session run on the
same machine at the same time. Each of them currently decides on its own whether it can start,
and they use **contradictory rules**. This file is the shared picture. It is descriptive: the
numbers are measured, the contract at the bottom is the rule.

## The box, measured 2026-08-24 22:35 EEST while a UE build and TRELLIS work were both live

| Resource | Total | State then | Notes |
| --- | --- | --- | --- |
| Physical RAM | 15.34 GB | **0.83 GB free** | the binding constraint |
| Commit | 63.34 GB limit | 41.10 GB charged | 22 GB headroom, not scarce |
| Pagefile | `C:\pagefile.sys`, fixed 48 GB | peak 6.85 GB, current 5.76 GB | `AutomaticManagedPagefile=False` |
| Disk `C:` | 475.81 GB | 53.32 GB free | UE build refuses below 8 GB, warns below 25 GB |
| GPU | GTX 1660 SUPER, 6144 MiB | 2588 MiB used, 4% | 6 GB ceiling; Windows pages VRAM silently instead of failing |

**The pagefile is not the problem and does not need growing.** It is 48 GB with a lifetime peak
of 6.85 GB. Commit has 22 GB of headroom. What runs out is *free physical RAM*, and no pagefile
setting fixes that — paging is what happens after it runs out, not a way to avoid it.

## The contradiction

- **LowVRAM** — `src/lowvram3d/resource_gate.py` is commit-pressure-first by design: it blocks
  only when commit is exhausted or below the predicted peak, and available physical RAM is a
  soft `ram_pressure=ELEVATED` flag under 2048 MB that changes nothing. At 0.83 GB free physical
  it still returns `PROCEED`. That reasoning is correct for *this process avoiding an allocation
  failure* and blind to *the rest of the machine*.
- **p3** — `scripts/Invoke-P3Build.ps1` admission is physical-first: it emits
  `P3_BUILD_ADMISSION_DEFER reason=LOW_FREE_PHYSICAL_MEMORY` and waits for a slot.

So a TRELLIS run correctly concludes it may proceed, consumes physical RAM, and a UE build
concludes it may not start. Both gates are locally right and the machine deadlocks. On
2026-08-24 that surfaced as p3 PRs #467 and #486 going **red** with
`P3_BUILD_ROUTE_TIMEOUT phase=build-admission` after the wrapper's 180-second default queue
timeout — a route failure reported as a product failure. The queue timeout is now 1800 s so the
build waits instead of failing, which is the correct half of the fix on that side.

## The contract

1. **Check the box, not your process.** Any long-running job reads free physical RAM, commit
   remaining, free disk, and GPU memory before it starts, and records them in its run evidence.
   A gate that only models its own allocation is incomplete.
2. **Reserve for the neighbour.** A heavy job leaves headroom for one concurrent UE build rather
   than consuming to its own limit. Physical RAM is the shared resource that actually runs out.
3. **Announce presence.** A heavy job is discoverable while it runs — a live process the other
   side can see, or a marker it writes — so a waiting build knows it is queueing behind real
   work rather than a stall.
4. **Wait, do not fail.** When the neighbour holds the resource, queue for it. Contention is a
   scheduling fact; it is never a red check, a `BLOCKED` report, or a reason to stop.
5. **Never trade data for headroom.** Disk or memory pressure never authorises deleting masters,
   prepared sources, evidence, or anything else not regenerable by a named command. Reclaim from
   build artifacts and caches, or wait. See the "Data you must never delete" rail in `AGENTS.md`.

## Known drift to fix

- `scripts/resource_gate_dry_run.py` hardcodes `COMMIT_LIMIT` at 47,000 MB. The real limit is
  63.34 GB, so the synthetic proof is scoring against a machine that no longer exists.
- 570 directories named `out_ingest_stage<name>` sit at the repo root from a missing path
  separator on 2026-08-14 (the correct `out_ingest_stage/` appeared 2026-08-16). Each holds a
  `prepared_source.png` — a master input. They are clutter that looks exactly like garbage,
  which is how prepared sources get swept away. Consolidate them into `out_ingest_stage/<name>/`
  by moving, never by deleting.
## Disk: what actually fills it

On 2026-08-25 the drive reached 8.0 GB free with the user believing generated assets were the
cause. They were not. The space was agent scaffolding:

- **Abandoned git worktrees, 29 GB.** Eight p3 worktrees under `%LOCALAPPDATA%\Temp`, each a
  full Unreal checkout at 2.7-15.2 GB. Four were dead registrations pointing at directories
  that no longer existed.
- **Git-LFS objects, 13.1 GB** in `p3/.git/lfs`, of which 7.4 GB was unreferenced.
- Pagefile 48 GB, `AppData\Local` 70.8 GB, `Program Files` 65.5 GB, `Windows` 47.1 GB.

Reclaiming one worktree and pruning LFS took free space from 7.71 GB to 31.34 GB in minutes.


*(Disk section merged from the parallel `claude/machine-budget-20260825` draft, 2026-08-25.)*

### Ingest staging layout

Prepared source masters use the single repository-root `out_ingest_stage/<asset>/` tree. Historical directories named `out_ingest_stage<asset>` came from a missing path separator and must not be deleted or broadly ignored: they can contain the only `prepared_source.png` copy. Run `python scripts/migrate_ingest_stage.py --dry-run` first, then run it without `--dry-run` to move each malformed directory into the canonical tree. The migration refuses destination collisions rather than overwriting evidence. Consolidation keeps ordinary `git status` bounded to one top-level staging tree while leaving source/config changes visible.
