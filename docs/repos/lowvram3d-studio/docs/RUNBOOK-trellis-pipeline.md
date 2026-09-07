# TRELLIS production queue runbook

**Canonical as of 2026-08-12.**

This file is for running or recovering the production queue. It is not a research notebook and it does not contain historical tuning advice.

## 1. Production baseline

Machine:

- Windows
- GTX 1660 SUPER 6 GB
- TU116 / reported sm_75

Worker repo:

Use a clean worker checkout. The supported launcher resolves one automatically
from the current checkout and refuses to start from a dirty tree:

`tools\launch-production.cmd`

For a direct Git Bash invocation, set `LOWVRAM3D_WORKER_ROOT` to the clean
worker checkout and run from that directory. The preserved production checkout
`C:\Users\Lauri\Desktop\lowvram3d-repo` is not a worker output target.

Queue:

`workers/production_queue.sh`

Python:

`C:\AI\HY3D2\python_standalone\python.exe`

Models:

`C:\AI\trellis-cpp\models`

### Runtime package

Executable:

`C:\AI\trellis-cpp\build-tu116-126-mmq\Release\trellis-cli.exe`

SHA-256:

`3b61e8767ec96f202ef257768e36e2db26305d5e9428c4f0511a0b10e109ca4a`

CUDA backend:

`C:\AI\trellis-cpp\build-tu116-126-mmq\Release\ggml-cuda.dll`

SHA-256:

`7674e79da47afba961f5b611d9506d5d928bb3e36ec1430199d307e862661b0e`

These two files are one runtime. Do not swap the EXE while leaving an unrelated DLL package beside it.

Do not run or rebuild production from `C:\AI\trellis-cpp\build-mmq`.

The TU116-safe build family is:

- `CMAKE_CUDA_ARCHITECTURES=61-virtual;80-virtual`
- `GGML_CUDA_FORCE_MMQ=ON`

## 2. Production settings

### Current queue defaults

The current user-confirmed queue policy is:

- `RES=1024`
- `SEED=12345`
- `ATLAS=8192`
- `FACES=1000000`
- exactly one producer

The live queue reads these values from `production/production.json`. Do not
duplicate them into another queue/config file; on resume, verify the generation
log shows the values above.

### Historical recovery proof

The 2026-08-12 recovery run was proved at `RES=512`, `ATLAS=4096`, and
`FACES=450000`. Those settings remain useful evidence for that recovery event
only; they are not the current production defaults and must not be restored over
the current queue policy.

### Repository warning

GitHub HEAD `f30440a` still contains an older queue file with `FACES=1000000` and `--voxply`. That remote file is not the exact queue that completed the recovery asset.

Do not overwrite the live local `workers/production_queue.sh` with the Git version until the proven local file has been committed verbatim.

## 3. Before starting the queue

Check all of these first:

1. No live `production_queue.sh` process.
2. No live `trellis-cli*` process.
3. Whether `out/.QUEUE_PAUSED` exists.
4. Whether `C:\Users\Lauri\AppData\Local\LowVRAM3DStudio\locks\queue.lock` exists and who owns it.
5. Exact runtime hashes above.
6. The latest per-asset log and receipt.

Do not launch a second producer because a wrapper or terminal timed out. A timed-out parent process may leave the GPU child alive.

## 4. Correct Windows launcher

Do not call bare `bash.exe`.

Use the installed Git Bash explicitly:

`C:\Program Files\Git\bin\bash.exe`

When starting it from PowerShell or another process supervisor:

- pass `-lc` and the complete shell payload without splitting that payload into tokens;
- provide a valid stdin handle or pipe;
- capture stdout/stderr separately from the per-asset TRELLIS log.

The 2026-08-12 recovery found three launcher-only failures:

- WSL `bash.exe` resolution -> `ERROR_PATH_NOT_FOUND`;
- split `Start-Process -ArgumentList` -> only the first shell token executed;
- hidden Git Bash with invalid stdin -> Python `WinError 6 (invalid handle)`.

None of those are TRELLIS failures.

## 5. Start / pause / resume

Pause after the current asset:

```bash
touch out/.QUEUE_PAUSED
```

Resume eligibility:

- no existing queue producer;
- no existing TRELLIS GPU child;
- no live owner of a stale queue lock;
- runtime hashes match the proven package.

Remove the pause marker only immediately before starting the single producer.

The shell-level intent is:

```bash
export LOWVRAM3D_WORKER_ROOT=/c/Users/Lauri/Desktop/lowvram3d-worker-clean
cd "$LOWVRAM3D_WORKER_ROOT"
bash workers/production_queue.sh
```

On Windows automation, invoke that through the explicit Git Bash executable and the launcher contract above.

## 6. What counts as a successful resume

Do not declare success at `GEN_START` and do not declare success because bash is alive.

Minimum proof:

1. queue process alive;
2. lock held by that process;
3. pause marker absent;
4. exactly one `trellis-cli.exe` active;
5. a real asset log advances through TRELLIS stage lines.

Strong proof:

- first real asset completes a non-empty GLB;
- publish step completes;
- queue advances to the next asset automatically.

The 2026-08-12 recovery achieved the strong proof with:

`5d_1e3196f2_4272_4949_9069_ef6182d1fc2e`

That asset completed and published, then the queue started the next real asset.

## 7. Failure handling

### A. Failure before `trellis-cli` starts

Examples:

- `ERROR_PATH_NOT_FOUND`
- `WinError 6 (invalid handle)`
- empty queue stdout/stderr with no GPU child

Classification: **launcher failure**.

Fix the launcher. Do not touch CUDA, models, seeds, pagefile, atlas, or face budget.

### B. Broad immediate sparse-flow failure

If multiple real subjects fail at sparse-structure flow `0/12` with the same CUDA error, especially within seconds:

Classification: **production runtime incident**.

Stop the queue. Do not cycle subjects or seeds.

Verify:

- EXE path/hash;
- `ggml-cuda.dll` path/hash;
- exactly one producer;
- correct Git Bash launcher;
- conditioning statistics and per-asset log.

The incident that triggered this runbook was initially misclassified as the old stochastic TU116 fault. That was wrong because unrelated subjects were all failing immediately at the same stage.

### C. Later subject-specific failure

A later failure after the proven runtime has already progressed through flow normally may be handled by the queue's normal ledger/backoff logic. Do not convert one later subject failure into a system-wide rebuild.

## 8. Things not to do during recovery

Do not:

- rebuild `build-mmq`;
- change NVIDIA drivers;
- change the pagefile;
- recommend a reboot/power cycle;
- change atlas because of a flow-0 crash;
- change face budget because of a flow-0 crash;
- blame `--voxply` for a flow-0 crash;
- run repeated demon tests;
- run multiple producers;
- restore `production_queue.sh` from stale Git history;
- treat an EXE-only backup as a complete runtime backup.

## 9. Source of truth hierarchy

For a running production session:

1. actual per-asset generation log and receipt;
2. live local queue file that launched it;
3. exact EXE/DLL hashes;
4. `docs/CURRENT_STATE.md`;
5. Git history and historical documents only as evidence.

A repository file can be stale while a long-running shell still executes an older parsed function body. Verify changed settings from output, not only from source text.

## 10. Next configuration-management fix

After the live local queue is committed verbatim, freeze the complete working runtime into one immutable production directory and hash every EXE/DLL/model required to reproduce it.

Production should then point only to that immutable package. Experiments should never share the production runtime directory.
