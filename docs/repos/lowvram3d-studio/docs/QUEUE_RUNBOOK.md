# Queue runbook

The one operational document for running the asset queue. If something here
disagrees with a saved memory, a chat scrollback, or another worker's notes,
this file wins — that is the point of it existing.

These facts lived only in ChatGPT saved memory until 2026-08-25, which made
them unverifiable, invisible to every other worker, and lost whenever memory
was trimmed.

---

## 1. Launch

Always launch **detached**, so the batch outlives the session that started it:

```powershell
pwsh -NoProfile -File tools\launch_queue_detached.ps1 -ImageList C:\path\queue.txt -Res 1024
```

`-ImageList` is a UTF-8 file, one source image path per line. It registers a
scheduled task (`LowVRAM3D_AssetQueue`). Stop it with
`schtasks /End /TN LowVRAM3D_AssetQueue`.

A batch launched as a child process dies with its launcher. On 2026-08-25 a
26-item queue died at item 3 that way.

Single asset: drag an image onto `GENERATE_ASSET.cmd` in the repo root.

**Settings.** Defaults are resolution 1024, seed 12345, atlas 8192, 1,000,000
faces. *Default means the value used when nobody asked.* **An explicit request
wins** — if a run is asked for 512, it runs at 512. `production.json` is the
single source of defaults, not a veto over the caller. If a requested setting
cannot be honoured, stop and say why; never silently substitute.

**One GPU producer at a time.** `tools/run_one_asset.ps1` now enforces machine-wide
single-flight for the exact source hash + semantic name + settings + frozen/runtime pipeline
identity. Concurrent duplicates wait for that flight and reuse a still-valid PASS instead of
launching another TRELLIS/render execution. Non-identical GPU work still must serialize;
`launch_queue_detached.ps1` refuses to start on top of a live `trellis-cli.exe`.

---

## 2. Never regenerate what already exists

**Judge by the artifact, not by the name, the receipt, or the output folder.**
A folder, a receipt, or a matching filename is a proxy. Every one of them has
lied here.

An asset counts as already generated **only** when all four hold:

| check | how |
|---|---|
| matte exists and is real | `matte.json` present, and `method` names the matter that actually ran |
| GLB is a GLB | first four bytes are `glTF` (`676c5446`) |
| geometry is not a sheet | `check_asset_sane.py --glb <file>` exits 0 |
| proof exists | a `*__views12*_FULL.png` in `ALL_VIEWS12\`, 5600x4721 |

```powershell
# the whole test, per asset
& C:\AI\HY3D2\python_standalone\python.exe workers\check_asset_sane.py --glb <file>
```

Both directions have burned real time:

- **Regenerating good work.** On 2026-08-25 a worker re-ran a finished bonsai
  at 512 when a verified 1024 master already existed — 210 MB GLB, 155 MB PLY,
  rembg matte, proof sheet rendered. Nothing was gained and an hour of GPU went
  to a lower-quality duplicate.
- **Skipping unfinished work.** The same day, an item was classified "already
  generated" from outputs and receipts while it had **no valid matte at all**.
  A receipt is not a matte.

The durable dedupe key is the **source SHA-256**, not the name
(`docs/SOURCE_RECOVERY_AND_QUEUE.md`). A render, naming, or metadata failure
does **not** make valid geometry eligible for regeneration — fix the failed
stage, keep the master.

---

## 3. White backgrounds

A flat white studio plate is the **preferred** source. It is the case the
threshold matter handles best, and most of this library is exactly that. White
is not the problem.

The problem is white **behind fine internal structure**. A global threshold
keeps whatever shows *through* the subject, and a subject that is mostly
internal negative space is mostly backdrop by area — foliage, a lattice truss,
a railing, an antenna array, fronds, a canopy.

Measured on one bonsai panel, flat white plate, both matters on the same image:

| matte | coverage | backdrop retained inside the subject |
|---|---|---|
| backdrop threshold | 32.91% | **5.96%** |
| rembg birefnet | 29.22% | **0.00%** |

That 3.7-point coverage difference *is* the retained backdrop. TRELLIS read it
as solid and returned a flat sheet. Nothing else separated the two: the plate
measured flat with no vignette, coverage was normal, the router verdict was
`pass`.

**Rule: if the subject has fine internal structure, force segmentation, however
clean the plate measures.**

```powershell
& $py workers\matte_router.py --image <src> --outdir <dir> --force rembg
```

Expect `method: rembg:birefnet-general` and **no** `enclosed_fill_percent` key.

The router chooses from the *plate* — flatness and vignette depth — and that
choice can be right about the plate and wrong about the subject. It has no
subject-structure test of its own beyond the gate below.

**Automatic escalation** (`plate_retained_percent`, PR #79) measures retained
backdrop and escalates to rembg through MATTE_GATE_V2 when it exceeds 3%. Until
that merges, `main` has no such gate and white-plate foliage subjects will keep
collapsing silently — force rembg by hand.

**If a receipt says `rembg` but carries `mode`, `threshold` or
`enclosed_fill_percent`, rembg was not installed and it silently fell back to
the threshold.** The receipt lies. Fix the cause, never the knob:

```powershell
uv pip install --python C:\AI\HY3D2\python_standalone\python.exe `
  --break-system-packages rembg onnxruntime scipy trimesh
```

Do not tune around it. `--force backdrop` and shrinking `--max-hole` were both
tried and both made it worse.

---

## 4. Per-item pipeline

Stage the image → `matte_router.py` → hash-verified frozen
`Run-SingleViewProduction.ps1` → `render_asset_views12.py`.

The twelve-view sheet is **not optional**; an item without one is not done.

---

## 5. Where state lives

`out\QUEUE_STATUS.json` — queue-level state: `total`, `index`, and an `items`
array with `PENDING` / `RUNNING` / `DONE` / `FAILED(...)`.

`out\RUN_STATUS.json` â€” the current item's stage: `MATTE`, `GENERATING`,
`RENDER12`, `DONE`, plus its exact local `proofRun` and `visualReview` state.

After a valid 12-view render, the runner publishes a write-once bundle under `C:\LowVRAMProofs\<run-id>`. The queue records `PENDING_REVIEW` and continues to the next asset; it never waits for review. Reviewers inspect that exact run and write only `reviewed.json`. Do not use a global latest pointer.

> **One writer.** Both files are rewritten wholesale by whichever queue is
> running. Asset single-flight prevents duplicate heavy execution, but it does not make these
> queue-status files multi-writer. A second queue can still destroy the first queue's bookkeeping;
> use the canonical detached queue path and inspect `QUEUE_STATUS.json` rather than starting a
> second queue shell.

The per-run `.stdout.log` beside the GLB reports progress as `[flow] N/12`.

---

## 6. Reading a failure

**A failure on every item indicts the gate, not the assets.** On 2026-08-25 the
render-proof gate rebuilt `<glb-stem>__views12_raw_FULL.png` while the renderer
writes `<subject>__views12_FULL.png`, so 26 sound assets were marked
`FAILED(render-proof-missing)` with valid sheets sitting in `ALL_VIEWS12`.

**Stop early.** The queue halts on an `out\QUEUE_STOP` marker between items, and
on its own after `-MaxFailures` (default 2). One failure is an asset; two is a
pattern, and a pattern reproduced across the rest of the batch is hours spent
confirming something already known. Change a *running* queue's behaviour only
through the marker file — never by editing the script it is executing.

**Retry errored items first:**

```powershell
pwsh -NoProfile -File tools\requeue_failed.ps1            # show the plan
pwsh -NoProfile -File tools\requeue_failed.ps1 -Launch    # stop current, relaunch
```

Errored first, then never-ran; `DONE` items are never repeated. Rerunning in
the original order means sitting through the assets that already worked before
learning whether the fix took.

**Silent death right after the sparse flow is a missing `out\` directory.**
The runtime writes `--voxply` output to a **cwd-relative** `out\` path with an
unchecked `fopen`, so if that directory is absent next to `trellis-cli.exe` the
process dies without a message.

The signature is specific — learn it, because it looks exactly like a hardware
fault and has been misdiagnosed as one repeatedly:

- stderr is about **199 bytes**: the banner and nothing else
- the log **never reaches `active voxels @res32`**
- no CUDA error, no OOM, no stack

It is never memory, never drivers, never the model. Create the directory and
rerun:

```powershell
New-Item -ItemType Directory -Force "C:\AI	rellis-cppuild-tu116-126-mmq\Release\out"
```

**A quiet log is not a stall.** Stdout is block-buffered (~4 KB) when
redirected. Use stage-boundary artifacts as ground truth: `*.slat.bin` (end of
`[4/7]`), `*.decmesh.bin` (end of `[5/7]`), `*.post.bin` (start of `[7/7]`).

**Climbing step times mean two jobs, not a denser mesh.** 232 → 496 → 766 →
1087 s once meant two producers on one card.

---

## 7. Billboards

TRELLIS can return a flat sheet that exits 0, has UVs and a texture, weighs
100+ MB, and looks convincing head-on while Left/Right collapse to a line.

`check_asset_sane.py` gates it from the glTF POSITION bounds, keyed on
**thinnest / median** axis — thinnest/longest would reject a plank, and planks
are real work.

```
billboard  1.004 x 1.003 x 0.004   thin/med 0.0040   FAIL
solid      0.997 x 0.562 x 0.544   thin/med 0.9669   ok
```

**It is visible in the log before any render.** Compare `decoded voxels
@res1024` across a batch — the billboard read `1050625`, exactly 1025², one
plane of voxels one voxel thick, against 1.83M and 1.76M for its neighbours. It
dropped **0** floater components; the solid ones dropped 25 and 29, because a
plane has none.

Always check Top and Bottom before accepting geometry.

---

## 8. Outputs

A GLB and a PLY under `out\<name>_<date>\`, plus the twelve-view sheet in
`C:\Users\Lauri\Desktop\ALL_VIEWS12\`.

**The `.ply` is the undecimated master** and is routinely far larger than the
GLB. Report it alongside the GLB; a run described only by its GLB understates
what was produced.

---

## 9. Before a batch — four checks

```powershell
# 1. matte dependencies (has silently broken twice)
& C:\AI\HY3D2\python_standalone\python.exe -c "import trimesh,numpy,PIL,scipy,rembg,onnxruntime;print('deps OK')"

# 2. nothing else owns the GPU
Get-Process trellis-cli,UnrealEditor,'UnrealEditor-Cmd',blender -EA SilentlyContinue

# 3. the out\ directory exists next to the runtime exe (see section 6)
$exe = 'C:\AI	rellis-cppuild-tu116-126-mmq\Release'
if (-not (Test-Path "$exe\out")) { New-Item -ItemType Directory -Force "$exe\out" }

# 4. the card is not in its factory overclock
nvidia-smi --query-gpu=clocks.mem,clocks.max.mem --format=csv
```

On (4): current memory clock must be **at or below** `clocks.max.mem` (7001
MHz). ~7248 means the OC is live and the run faults within seconds with
`illegal memory access` at `ggml-cuda.cu:103`. Fix is the MSI Afterburner stock
profile, and **it dies on every reboot, reset and driver install**.

On (2): Unreal running during production is the documented cause of stalls — it
pushes the card past its ~5.6 GB usable ceiling and Windows spills silently
into shared memory: 100% utilisation, near-zero progress, never an OOM.

5. Reconcile against existing outputs — section 2.
