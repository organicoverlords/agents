# LowVRAM3D One-Command Asset Pipeline

**Version 1.0.3 - frozen 2026-09-04.** See `ONE_COMMAND_RUNNER_FREEZE.json`
in this folder for the runner content hashes this version locks (PowerShell runner text is hashed after CRLF-to-LF normalization so Windows checkout style cannot invalidate the freeze).

**1.0.2 adds proof integrity without changing TRELLIS generation semantics:** finished 12-view outputs publish to a write-once local proof run, review stays non-blocking, Tiny3D acceptance requires independent review, and the queue validates the renderer's width/minimum-height contract instead of one historical exact height.

## Real incident this version fixes (2026-08-17)

The frozen wrapper (`Invoke-TrellisRun.ps1`) returned `exitCode=-1` for one
queue item while its `trellis-cli.exe` child was still alive and actively
generating. The queue trusted that return and launched the next item
immediately — two GPU jobs fought over one 6GB card for ~30 minutes before
anyone noticed (visible as step times that kept *climbing*: 232s, 496s,
766s, 1087s... — a healthy single job has roughly constant per-step time;
climbing step times are the signature of GPU contention, not a bigger mesh).

**Fix:** neither script trusts an exit code alone anymore.
- `run_one_asset.ps1` refuses to launch if `trellis-cli.exe` is already
  running (pre-flight), and force-kills + fails loudly if the child is
  still alive after the wrapper returns (post-flight) — it no longer
  reports a status the process table contradicts.
- `run_queue.ps1` runs a `Wait-GpuIdle` gate between every item: polls the
  process table for up to 60s, then force-kills anything still there,
  before launching the next item. Every transition is independently
  verified, never assumed from a return code.

The whole tool. One thing to know: **drag an image onto
`GENERATE_ASSET.cmd`** (in the repo root, one level up from this file).
That's it. Multiple images can be dragged on at once — they queue and run
one at a time automatically.

If you'd rather use a terminal:

```powershell
pwsh -File tools\run_one_asset.ps1 -Image "C:\path\to\source.png"
```

or for several images as a real, live-checkable queue:

```powershell
pwsh -File tools\run_queue.ps1 -Images @("C:\a.png","C:\b.png")
```

## What it does, every time, no flags required

1. Stages the source image into `out\<slug>_<date>\`.
2. Runs `matte_router.py` unedited — auto-routes between real source alpha,
   backdrop measurement, and `rembg`, whichever the plate actually needs.
3. Generates the 3D model through the **frozen production wrapper only**
   (`Run-SingleViewProduction.ps1`) at Res=1024 / Atlas=8192 / Faces=1,000,000
   / Seed=12345 — the settings proven good this session. The frozen install
   is auto-discovered and SHA256-verified before anything runs; the script
   refuses to run at all if that verification fails.
4. Renders the 12-view turnaround grid and keeps only the real 4+4+4 gridded
   sheet (`..._FULL.png`) in `C:\Users\Lauri\Desktop\ALL_VIEWS12\` — the flat
   ungridded strip is deleted automatically, it is not useful output.

Every run gets a fresh timestamped output filename. Nothing that already
exists is ever overwritten.

## Live status while something is running

- `out\QUEUE_STATUS.json` — which item of the queue is running, and the
  status of every other item (`PENDING` / `RUNNING` / `DONE` / `FAILED`).
- `out\RUN_STATUS.json` — the stage the currently-running item is at
  (`MATTE` / `GENERATING` / `RENDER12` / `DONE` / `FAILED`).
- The frozen wrapper's own per-run `.stdout.log` next to the output GLB has
  the live `[flow] N/12` progress bar straight from `trellis-cli.exe`.

## Overriding a setting

Only do this if you have a specific reason to:

```powershell
pwsh -File tools\run_one_asset.ps1 -Image "C:\path.png" -Res 512 -Atlas 4096
```

If the auto-matte picks the wrong method for a plate with no real alpha:

```powershell
pwsh -File tools\run_one_asset.ps1 -Image "C:\path.png" -ForceRembgMatte
```

## Why it refuses to run sometimes

If `verify_freeze.ps1` doesn't report the frozen production install intact,
the script stops instead of guessing. Do not tell it to substitute, rebuild,
or patch anything — see the `trellis-production-frozen-pipeline-discipline`
memory for why. If the frozen install has moved, the script searches
`C:\Users\Lauri\Desktop` for it automatically; if that also fails, it reports
the exact failure rather than improvising a replacement.

## Backups

This is a two-file tool (`run_one_asset.ps1`, `run_queue.ps1`) plus two
`.cmd` wrappers (`RunAsset.cmd` here, `GENERATE_ASSET.cmd` at repo root). A
mirror copy of all four plus this README lives outside git at
`C:\Users\Lauri\Desktop\lowvram3d-one-command-runner-BACKUP-20260816\`, in
case this repo/branch ever becomes unreachable the way
`lowvram3d-closeout-20260815` did mid-session on 2026-08-16 (see
`weqww-priority-queue-launch-and-pause` memory).
