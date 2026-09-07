# Atlas density, and which renderer to believe — 2026-08-11

Two findings, one of which corrects the other. Read both before acting on the
first.

> **This is a measurement record, not the current configuration.** Every number
> below was taken at `--faces 450000`. The production budget is now `1000000`
> (`docs/CURRENT_STATE.md`), so the texel-density figures here are an upper
> bound on what the current setting delivers at the same atlas.

## 1. Every textured asset is atlas-starved

Median texels per triangle, measured as UV triangle area times atlas pixels:

| asset | tris | atlas | texels/tri | edge |
|---|---|---|---|---|
| 00_dragon_feathered_azure | 141,174 | 1024 | 1.92 | 2.11 px |
| icemountain | 149,470 | 1024 | 3.96 | 3.02 px |
| brutalistinen_temppeli | 131,430 | 1024 | 2.95 | 2.61 px |
| radio_tower_res512_prod (Aug 8, earliest) | 149,616 | 1024 | 2.55 | 2.43 px |
| architecture_hovel_079_textured (scene-smoke) | 150,000 | 339 | 0.53 | 1.10 px |

Across 171 textured GLBs the median is **2.42** and only **7** exceed 20. It is
not a regression and nothing caused it: the same numbers appear in the earliest
assets, in the other checkout, and under the other pipeline. The cause is a
ratio — the vendor finalizer QEMs to 150k triangles and `trellis-cli --atlas`
defaults to 1024 at res512, which is ~4 texels per triangle arithmetically.
`--xatlas` is already the default; the unwrapper is not at fault.

`workers/production_queue.sh` now sets `--atlas 4096`. Measured on icemountain,
same seed, texture path the only variable:

| atlas | texels/tri | atlas gradient | time | GLB |
|---|---|---|---|---|
| 1024 | 3.96 | 3.80 | 227 s | 7.8 MB |
| 4096 | 65.9 | 1.09 | 273 s | 29 MB |
| 8192 | 259.8 | 0.39 | 321 s | 60 MB |

`--tex-res` is deliberately left on auto. It sets the PBR volume, not the
packing (62.3 vs 65.9 texels/tri), and auto exists to drop a dense res-1024
decode to a clean res-512 volume — it is the guard against stage-6 OOM on 6 GB.

## 2. …and it mostly does not matter, which the numbers do not tell you

`mossy_outcrop` measures **2.87** texels/tri — *lower* than icemountain's 3.96 —
and looks excellent from all nine angles. The number does not predict quality.

What predicts it is **triangle size on screen**. On a dense organic subject at
150k triangles the triangles are tiny, so one colour per face reads as natural
fine-grained detail. On large flat facets — icemountain's cone, a greenhouse's
panels — the same thing reads as camouflage blotching. So the atlas raise is a
real improvement for a narrow class of flat-faceted subjects and not a repair of
the library. 70 assets shipped on the old default and hold up in the Unreal ring.

There is a second, separate defect the atlas cannot touch: where one part of a
subject occludes another, the bake puts the front thing's colour on the surface
behind it. Confirmed independently by two vision models on icemountain, where
the front view — fully observed — has cloud white on the mountain and mountain
blue on the clouds.

### Paint is deprioritised, 2026-08-11

`workers/hunyuan_paint_texture.py` was the designed fix for that defect. It is
**not being pursued**, on Lauri's call, and it was never on the production path
to begin with — `production_queue.sh`, `publish_asset.sh` and
`asset_supervisor.sh` do not reference it.

Why it is a reasonable drop. Across seven subjects generated at
`--faces 450000 --atlas 4096`, several with heavy self-occlusion — agave leaves
overlapping in a dense rosette, heliconia bracts layered over foliage, griffin
and hummingbird wings crossing their bodies — none showed cross-contamination.
That is evidence, not proof, but it is the right kind: the pathological case was
a **flat vector illustration with a distinct foreground element over a distinct
background element**, which is not what the queue mostly generates.

What it costs to drop: nothing operational. What to watch for: the icemountain
class specifically. If a flat illustrated plate with strong foreground/background
overlap comes back wrong, this is the first thing to reconsider.

The file stays on disk with the `--no-delight` work intact rather than being
deleted — an unreferenced file costs nothing, and re-deriving that flag would
cost an evening. Paint needs ~9.8 GB of host commit if it is ever revived.

## 3. Which renderer to believe

Three renderers disagree, in a consistent direction:

* `workers/render_textured_views.py` — flat, unlit, grey background. Exaggerates
  texture noise badly. An asset that looks broken here is often fine. **Do not
  form a verdict from this alone.**
* `workers/render_asset_views.py` with `--native --size 1400` and the nine-view
  set — Blender EEVEE. This is what `evidence/compare/*/views9.png` holds and it
  is the sheet to judge from.
* The Unreal ring (`unreal/place_assets_in_ring.py`) — final word on whether an
  asset is usable, since it is lit and at working distance.

An evening was spent concluding the whole library was defective from the first
renderer while the ring and the nine-view sheets — which show the assets are
fine — were already on disk.

## 4. Nine-view sheets are now generated by the queue

They never existed for queue output. `asset_supervisor.sh` owns that step and
was not running; starting it alongside would not have helped, because it
arbitrates on `gpu.lock` while `production_queue.sh` only takes `queue.lock`, so
both would have used the card at once. The queue now renders inline after each
successful generation, with the supervisor's exact views and size. A render
failure is reported and does not fail the asset.

## 5. Face budget raised to 450k, and what it actually cost

`trellis-cli` gained `--faces` on 2026-08-11; before that the QEM target was a
constant in `trellis_cli.cpp` (`cascade ? 300000 : 150000`) with `--decim`
selecting a different algorithm and `--decim 0` turning simplification off, so
there was nothing in between. `production_queue.sh` now passes
`--faces 450000`.

What the old constant discarded, from the production logs:

| asset | remesh output | kept at 150k |
|---|---|---|
| griffin_macaw_leopard | 1,741,188 F | 140,856 (8.1%) |
| foxfire_magma_winged | 3,353,076 F | 146,664 (4.4%) |

Measured on `02_lone_hoodoo`, same seed, atlas 4096:

| | 150k | 450k |
|---|---|---|
| faces | 140,856 | 436,648 |
| wall clock | ~217–294 s | 218.8 s |
| GLB | ~36 MB | 39.9 MB |
| texels/tri | 35.00 | 17.53 |
| texel edge | 8.99 px | 6.36 px |

**Neither worry materialised.** xatlas did not blow up — its chart compute is
superlinear, but 450k sits below the knee. Texel density halves exactly as the
face ratio predicts, and 6.36 px per triangle edge is still triple the ~2 px
point where bilinear starts bleeding neighbours.

Time tracks **decode density, not the face target**. A subject whose remesh
produces 8.1M faces takes ~766 s at either target, because QEM's work scales
with its input; assets at the old 150k target with 7–14M-face remeshes took
586–1368 s. Do not read a slow 450k asset as a cost of the face budget.

What it buys, visible in the nine-view sheets: thin features that used to be
smoothed away survive. Comms-tower railings stay open rails instead of
collapsing into a solid band; agave marginal teeth remain individual bumps;
foliage tufts at a pylon base persist. That is the whole point of the change.

## 6. Do not rebuild `build-mmq`

`trellis_run.py` defaulted to `C:\AI\trellis-cpp\build-mmq`, whose CMakeCache
records `CMAKE_CUDA_ARCHITECTURES=75-real;75-virtual`. A binary built from that
configuration returns an **all-NaN DINOv3 conditioning tensor** on this GTX 1660
SUPER (`nan/inf=1053696` of 1053696) and dies with an illegal memory access.
48 assets failed that way in seven minutes.

The `.exe` that had been sitting in `build-mmq` was demonstrably not built from
that cache — it worked, and rebuilding the directory from its own recorded
settings broke it. The default is now `build-tu116-126-mmq`
(`61-virtual;80-virtual`), which is what ggml prints as the recommended
workaround in our own failure log, and tu116 is this card's chip. A known-good
copy sits beside it as `trellis-cli.exe.known-good`.

**After any rebuild, run one asset and grep the log for `nan/inf=0` before
letting the queue near it.** The failure is silent at the binary level.

## 7. Commit charge, not free RAM, is the constraint

2026-08-11: a ComfyUI server (`main.py --port 8199`) had been idle 16 hours
holding **10,582 MB of commit with 2 MB resident**, and UnrealEditor held
11,196 MB with 388 MB resident — 21.8 GB held by two processes doing nothing,
against a hard 47.3 GB ceiling (15.3 GB RAM + a fixed 32 GB pagefile,
`AutomaticManagedPagefile = False`).

Symptoms it produced, none of which looked like memory: `matte_router.py`
failing with `NO_RECEIPT` on five consecutive plates, and shape decodes failing
at stage 5. All five mattes passed unchanged after the kill.

Two verdicts formed under that pressure are therefore suspect and should be
re-tested before being trusted: `imagegen_6` "capacity-blocked at this
resolution", and the `kulunut_sci_fi_kenttäradio` decode failure.

Check `FreeVirtualMemory`, and check per-process `PrivateMemorySize64` rather
than working set — working set understates a paged-out hog by three orders of
magnitude.
