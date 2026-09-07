# Contributing to Tiny3D

Tiny3D is tested without an online reasoning service, an Unreal installation,
or a GitHub Actions credit budget. The local matrix below is the canonical PR
gate. The GitHub workflow is manual and non-gating; run it only when Actions
capacity is intentionally available.

## Local test matrix

On Windows, run:

```powershell
.\scripts\test-matrix.ps1
```

This is the clean-checkout command: it verifies dependency/provenance/toolchain
metadata, creates locked environments, and runs the full unittest suite on
Python 3.11, 3.12, and 3.13. It does not require `PYTHONPATH` or a pre-existing
virtual environment. It stops at the first failed environment and returns a
non-zero exit code.

Do not wait for a GitHub status check to validate a change. Record the local
matrix result in the PR description instead.

To run one environment directly:

```powershell
uv sync --locked --python 3.11
uv run --locked --with-editable . --python 3.11 python -m unittest discover -s tests -v
```

This is also the clean-checkout setup and test path: it installs the locked
dependencies and the current checkout as an editable package, so supported
tests do not require a manually configured `PYTHONPATH`.

The avian compiler's production path additionally requires Blender 5.x. The
supported production minor versions are declared in
`data/toolchain-versions-v1.json` and are currently Blender 5.0, 5.1, and 5.2.
The deterministic validation and packaging tests do not require Blender.
