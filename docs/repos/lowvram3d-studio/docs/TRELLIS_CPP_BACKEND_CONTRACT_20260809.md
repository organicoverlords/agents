# trellis.cpp backend contract

**Updated: 2026-08-12. Production runtime selection in this file supersedes older build-mmq notes.**

This is a technical reference for the native TRELLIS backend. For queue operations, read `docs/RUNBOOK-trellis-pipeline.md` first.

## Production runtime

The proven production runtime is:

`C:\AI\trellis-cpp\build-tu116-126-mmq\Release\trellis-cli.exe`

SHA-256:

`3b61e8767ec96f202ef257768e36e2db26305d5e9428c4f0511a0b10e109ca4a`

with the co-located CUDA backend:

`C:\AI\trellis-cpp\build-tu116-126-mmq\Release\ggml-cuda.dll`

SHA-256:

`7674e79da47afba961f5b611d9506d5d928bb3e36ec1430199d307e862661b0e`

The EXE alone is not a complete runtime backup. `ggml-cuda.dll` contains compiled CUDA kernels and must be preserved with the executable and the rest of its DLL package.

## TU116 build rule

This GTX 1660 SUPER reports compute capability 7.5 but is TU116. The working build family uses:

- `CMAKE_CUDA_ARCHITECTURES=61-virtual;80-virtual`
- `GGML_CUDA_FORCE_MMQ=ON`

Do not use or rebuild production from:

`C:\AI\trellis-cpp\build-mmq`

Its recorded cache uses `75-real;75-virtual`. Rebuilding from that cache previously produced all-NaN DINO conditioning and immediate CUDA failures across the queue.

A directory name is not provenance. Hash the runtime files.

## Production configuration

The live recovery proved:

- resolution 512
- seed 12345
- atlas 4096
- face target 450000
- one producer

Do not infer a different production configuration from historical backend experiments.

## Sparse/shape flow interpretation

A broad immediate failure across unrelated subjects at sparse flow `0/12` is not normal seed variation. Stop the queue and verify runtime package and launcher state.

A subject-specific later failure after the same runtime has already progressed normally is a different failure class and may be handled by the queue's ledger/backoff logic.

## Grid semantics

The native backend's shape support semantics remain:

```text
ss_decode                 -> occupancy logits on a 64 grid
ss_coords(logits, 64, 32) -> ANY-hit 2x2x2 pool -> 32 grid
shape_flow                -> consumes those 32-grid coordinates
world position            -> (c + 0.5) / 32 - 0.5
```

`--res 512` controls the downstream FlexiDualGrid decode resolution; it does not mean the shape support grid is 512.

## Shape-SLAT dump

`--dump-slat` writes the Shape-SLAT before geometry decode. The replay file contains:

- `N` int32 voxel count;
- `res` int32 decode resolution;
- `N x 3` int32 coordinates;
- `32 x N` float32 features.

Coordinates are embedded in the replay file. The serialized features are denormalized using the shape mean/std expected by the decoder.

The SLAT is useful recovery evidence but does not contain texture.

## Post dump / replay

A post dump contains decoded mesh plus PBR voxel data and exists only on the textured path. It is substantially larger than a Shape-SLAT dump.

Use post replay for finalizer experiments only. It is not part of ordinary queue recovery.

## Provenance rule

Any backend comparison intended to say two outputs differ only by one finalizer/runtime variable must record at minimum:

- source image hash;
- exact CLI path and SHA-256;
- exact `ggml-cuda.dll` path and SHA-256;
- model directory and model hashes;
- seed;
- resolution;
- full argv;
- resulting artifact hash.

Without that evidence, a build-directory name or CMakeCache is not sufficient proof of what runtime actually produced an asset.