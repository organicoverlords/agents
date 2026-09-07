# Central repository documentation

Human-facing documentation for product repositories is authoritative here, on `organicoverlords/agents@main`.

## Layout

- `docs/repos/p3/` — P3 product direction, architecture, operating documentation, README/start-here material, and changelog.
- `docs/repos/tiny3d/` — Tiny3D product direction and human-facing repository documentation.
- `docs/repos/lowvram3d-studio/` — LowVRAM3D Studio product direction and human-facing repository documentation.

Paths below each repository directory preserve their former product-repository layout so documentation-to-documentation relative links remain stable where possible.

## Authority rule

Edit human-facing repository prose only here. Product repositories retain minimal pointer files at legacy documentation paths for discoverability and backwards-compatible links; those pointers are not product authority and must not accumulate copied prose.

The following remain in their owning product repositories because they are executable or evidence state rather than synchronized documentation:

- machine-consumed JSON/YAML schemas, registries, manifests, fixtures, allowlists, and execution contracts;
- source code, scripts, tests, configuration, and generated help owned by those executables;
- artifact-bound evidence, proof bundles, vendor snapshots, and provenance notes that must travel with the artifact.

When a central document references one of those owners, link to the product repository rather than copying the contract into prose.
