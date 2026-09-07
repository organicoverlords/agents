# Repository contract

This is a compatibility-preserving extraction of the LowVRAM single-view production queue. Do not redesign generation behavior while fixing packaging or sanitation defects.

The external TRELLIS executable, its four co-located ggml DLLs, CUDA runtime, model GGUFs, and rembg ONNX weights are runtime dependencies and are never vendored or modified here. `production/FREEZE_20260815.json` owns the frozen executable/DLL/model identity.

`GENERATE_ASSET.cmd` is the human entrypoint. Preserve sequential one-GPU-job execution, 1024 / 8192 / 1000000 defaults, matte preflight, frozen-wrapper hash verification, early PLY preservation, and mandatory 12-view `_FULL.png` proof.

Before any GPU generation, verify that no unrelated `trellis-cli.exe` is already running. Never replace or rebuild the frozen runtime as a queue repair.

The 12-view renderer MUST receive the queue asset name explicitly. Empty/UNNAMED titles and title/name mismatches are production failures, never acceptable review output.

Each completed 12-view result publishes a write-once `C:\LowVRAMProofs\<run-id>` bundle and records `PENDING_REVIEW` without blocking the next queue item. Only an independent `reviewed.json` may establish visual acceptance; sheet existence or dimensions alone are not acceptance.
