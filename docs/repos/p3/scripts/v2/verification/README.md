# p3 V2 verification runner

`Invoke-P3Verification.ps1` is the stable repo-local integration seam for V2 verification. CI/control-plane code should call this entrypoint rather than duplicating scenario, tooling-provenance, or receipt logic in YAML.

## Interface

Run form:

```powershell
pwsh -File scripts/v2/verification/Invoke-P3Verification.ps1 `
  -Scenario noop/static `
  -Profile gate `
  -Repository organicoverlords/p3 `
  -Ref main `
  -Head 0123456789abcdef0123456789abcdef01234567 `
  -Topology none `
  -TimeoutSeconds 60 `
  -OutputDirectory Saved/Verification `
  -EvidenceLevel static
```

The source tuple (`Repository`, `Ref`, `Head`) may be omitted only when the runner can resolve it from GitHub Actions environment variables or the local Git checkout. The receipt always records repository, ref, derived branch and exact SHA.

Validation-only form:

```powershell
pwsh -File scripts/v2/verification/Invoke-P3Verification.ps1 `
  -ValidateReceipt Saved/Verification/P3VerificationReceipt.json
```

Scenario discovery:

```powershell
pwsh -File scripts/v2/verification/Invoke-P3Verification.ps1 -DescribeScenarios
```

## Unattended tooling contract

The PowerShell entrypoint does not treat `python`/`py` command-name resolution as proof. It resolves only executable applications, rejects Windows App Execution Alias paths, performs one bounded `--version` probe per candidate without shell execution, and records every attempted route.

Candidate order is:

1. exact path in `P3_VERIFICATION_PYTHON`, if supplied;
2. installed `python.exe`;
3. installed `py.exe -3`.

An executable listed in `-RejectedExecutable` or `P3_VERIFICATION_REJECTED_EXECUTABLES` is recorded as a prior prompt/rejection and is **not executed again**. If no candidate passes the bounded probe, the wrapper exits nonzero and writes `P3VerificationTooling.json` with `ROUTE_REJECTED=UNATTENDED_TOOLING_NOT_PROVEN`; only that verification route is unavailable, other work continues, and routine permission-click responsibility is never assigned to the user.

A successful `P3VerificationReceipt` contains structured `tooling` evidence:

- selected executable, Python version, argument prefix and provenance (`REPOSITORY_PROVIDED`, `PREINSTALLED_KNOWN`, or `BOUNDED_NEW_NONINTERACTIVE`);
- probe status;
- listener/bind/exposure state;
- prompt/fallback/route-rejection state;
- the complete bounded attempt list.

The Python core requires this tooling evidence for every run scenario. Missing or invalid tooling evidence fails closed before a PASS receipt can be emitted.

## Scenario levels

- `noop/static` — **implemented** — L0 no-Unreal receipt/validator proof.
- `l0/automation` — **implemented** — native UE 5.8 MCP `AutomationTestToolset` runtime proof against an exact caller-owned editor PID.
- `l1/functional` — **extension point** — in-level Functional Tests.
- `l1/runtime-navigation` — **implemented** — headless packaged-game runtime navigation acceptance.
- `l2/gauntlet` — **extension point** — dedicated/listen server and multi-client sessions.
- `l3/visual` — **implemented** — canonical owned PIE visual proof through `tools/proof/capture.py` and `Invoke-P3VisualProofCapture.ps1`.
- `l3/animation` — **extension point** — animation trace plus mid-action visual proof.
- `l3/user-path` — **implemented** — owned PIE and real gameplay-input user-path proof.

Known but unimplemented scenarios return a non-success proof result and a nonzero exit code. That means only that proof is unavailable; it is never implementation permission. Unknown scenarios are rejected before dispatch.

`l0/automation` is deliberately narrow. The verifier does not launch or stop an editor: the caller supplies `--expected-editor-pid <pid>` from the canonical worker-owned editor launcher and one exact `--automation-test P3....` name. The native MCP client rechecks that `127.0.0.1:8000` is owned by that PID before every request, requires Tool Search's three meta-tools, runs only the exact discovered P3 test, records editor ownership as borrowed, and closes only its native MCP session. Globs and non-P3 test names are rejected.

`l3/visual` also borrows rather than owns runtime lifecycle. The caller supplies an exact worker-owned `--expected-editor-pid` and `--map`; the verifier requires live PIE and delegates screenshot acquisition to the existing canonical proof owner. It records the editor and PIE as borrowed, never launches or stops them, and maps the owner-produced SHA-256 and pixel evidence into the canonical verification receipt.

### Prebuilt Gauntlet stage provider

`scripts/v2/verification/Invoke-P3GauntletStage.ps1` owns the build/cook/stage step that produces a prebuilt game for Gauntlet. It is deliberately separate from `p3_gauntlet_adapter.py`: the adapter remains a consumer and never gains build permission. The stage provider requires an `editor` workspace, binds reuse to the exact source HEAD, map, configuration, and UE `Build.version`, delegates compilation to `scripts/Invoke-P3Build.ps1 -Target Game`, and then runs bounded `BuildCookRun -skipbuild -cook -stage -pak` into `Saved/StagedBuilds/Gauntlet/<stage-key>`. A PASS receipt is reusable only while the staged `p3.exe` still matches its recorded SHA-256. Missing map content is hydrated only through the existing narrow-LFS helper for that exact map.

Use `-PlanOnly` to print the exact stage identity and destination without building. A successful run prints a `p3.gauntlet-stage.v1` receipt whose `build_path` is the directory to pass to the canonical Gauntlet verification route.

## `SUPERSEDED_BY` contract

`SUPERSEDED_BY` is no longer a free-form PR/branch reference.

The dependency identity is `replacement.packet_id`, using the canonical V2 packet ID grammar (`V2-00B`, `V2-04C1`, etc.). The runner resolves that packet against `docs/v2/P3_V2_EXECUTION_PACKETS.json`; an unknown packet fails closed. `replacement.issue` is optional redundancy and, when supplied, must match the packet registry.

PR/branch/commit information is **provenance only** and lives under `replacement.provenance`:

```json
{
  "DISPOSITION": "SUPERSEDED_BY",
  "replacement": {
    "packet_id": "V2-01",
    "issue": 19,
    "provenance": {
      "pr": 99,
      "branch": "lane/replacement",
      "sha": "abcdef0123456789abcdef0123456789abcdef01"
    }
  }
}
```

Only `replacement.packet_id` drives dependency-DAG resolution. Optional PR/branch/SHA provenance must never be interpreted as a replacement identity. Non-`SUPERSEDED_BY` receipts require `replacement=null`.

## Predecessor disposition / no-reinvention record

Shared verification infrastructure has one directly relevant pre-V2 predecessor:

- `infra/p3-proof-harness-v2-20260818` — **`ABSORB_BEHIND_CURRENT_INTERFACE`**.

The branch is historical implementation/provenance input, not current authority and not a second public verification framework. Do **not** merge that branch wholesale and do not recreate its `.github/scripts/**` surface as a competing API.

Mechanics selected for absorption behind the scenario handlers are:

- environmental/test-harness failures classified separately from feature failures (`TEST_INVALID` semantics);
- exact editor/map identity plus the actual possessed pawn as runtime evidence;
- normal gameplay input through the project bridge rather than desktop input or editor-Python gameplay driving;
- bounded pawn safety-envelope monitoring during user-path/motion proof;
- fresh/stable evidence files with size, timestamp and SHA-256 checks so stale output cannot become a new PASS;
- stale same-case evidence cleanup before rerun and compact evidence manifests afterward;
- temporal MP4/GIF proof for motion/animation, with still frames explicitly insufficient as motion proof;
- bounded capture duration/disk retention and deletion of ordinary failed-test video artifacts;
- exact Unreal-window/process targeting for temporal capture;
- imported-asset proof based on loaded Unreal objects, dimensions, import provenance and referencer/material binding rather than source-file existence alone.

Mechanics explicitly **rejected as-is** during absorption are:

- stopping any active PIE session merely because it is running; current p3 ownership rules permit cleanup only for a session the verifier actually acquired and still owns;
- commandeering user-owned or ownership-unknown editor/PIE state;
- treating editor Python or OS/desktop input as L3 gameplay proof;
- generic executable discovery (Python, ffmpeg, or other helpers) without the current structured unattended-tooling provenance/probe contract;
- using stale historical receipt formats as current acceptance authority.

The standalone core starts with fail-closed extension defaults, while the public `p3_verification.py` entrypoint composes the implemented adapters behind the same interface. Current public implementations are `noop/static`, `l0/automation`, `l1/runtime-navigation`, `l3/visual`, and `l3/user-path`. Functional, Gauntlet, and animation remain explicit unimplemented extension points until their mechanics are adapted and receive fresh proof. Their proof status cannot stop implementation elsewhere.

## Proof invariants

- Static/noop PASS is only valid for `EvidenceLevel=static`; it cannot satisfy runtime/visual/full proof.
- Commandlets or editor Python may support deterministic setup/inspection but do not satisfy user-path gameplay proof.
- Editor and PIE ownership are recorded separately. Cleanup is explicit and must never stop an editor/PIE session the scenario did not acquire.
- `ACCEPTANCE` and `DISPOSITION` are independent vocabularies. `PASS` is not a disposition, and `MERGED` is not an acceptance result.
- A tooling route rejection cannot coexist with `ACCEPTANCE=PASS`.
- Failed verification returns nonzero. A written receipt is re-read and validated after serialization.

Schema: `docs/v2/schemas/P3VerificationReceipt.schema.json`.
