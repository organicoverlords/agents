# LowVRAM production queue extraction

This repository contains only the proven single-view drag/drop queue and its transitive source dependencies. It does not contain TRELLIS model weights, the frozen executable, CUDA DLLs, or the rembg model cache.

The compatibility entrypoint is `GENERATE_ASSET.cmd`. One or many dropped images run sequentially, one `trellis-cli.exe` GPU job at a time. Production defaults remain resolution 1024, seed 12345, atlas 8192, target faces 1000000. Outputs remain under `out\<name>_<date>\`; the mandatory 12-view `_FULL.png` remains under `%USERPROFILE%\Desktop\ALL_VIEWS12\`.

Run `SETUP.cmd` only when `.venv` must be recreated. Run `CHECK_ENV.cmd` for a non-GPU verification of Python, Blender, frozen TRELLIS runtime, co-located ggml DLL hashes, CUDA/VC runtime DLLs, model sizes, rembg weights, and the queue source closure.

`production\FREEZE_20260815.json` is the copied frozen runtime authority. `config\runtime_contract.json` documents the additional host/runtime dependencies discovered from the live executable and queue code.

A production 12-view sheet must carry the queue asset name in its title band. UNNAMED, an empty title, or a title that disagrees with the queue item is a hard failure; the item must not reach DONE.

## Visual review

Finished 12-view runs publish to `C:\LowVRAMProofs\<run-id>` with `manifest.json` and `12views.png`. The queue continues with review marked `PENDING_REVIEW`; an independent reviewer writes the run's one `reviewed.json`. The GLB/PLY remain in the normal output location and are hash-bound by the manifest.
