# p3 V2 control and verification support

This directory provides scope, safety, provenance, and verification tooling. It does **not** decide whether product implementation is allowed to proceed.

## Nonblocking rule

Lane/packet dependencies, issue state, receipts, HISTORY evidence, activation conditions, branch protection, CI status, acceptance text, and old handoffs are planning/provenance data. They never create an implementation or merge prerequisite by themselves.

Before treating anything as blocking, prove a current causal dependency for the exact change from code/runtime ownership, mutation collision, safety, or unavoidable external authority. If that dependency is absent, repair the stale metadata and continue.

`v2_control.py` therefore enforces structural registry validity, changed-path ownership boundaries, and truthful supplied evidence. Legacy path-condition tokens, dependency/activation/HISTORY data, and merge-barrier metadata are nonblocking/advisory. `v2_finalize.py` enforces canonical agent-rule pointer consistency and the trusted workflow boundary.

## `v2-verify`

`.github/workflows/v2-verify.yml` publishes a reusable `v2-verify` status as evidence. It is not a required permission gate.

The workflow keeps a strict trust boundary because it may execute on the self-hosted Windows machine:

- owner-authored bounded issue-comment request;
- trusted control code comes from default-branch `main`;
- candidate ref/SHA is data only;
- candidate-owned control scripts are never executed;
- exact candidate SHA/ref and issue identity are checked;
- the candidate receives a truthful success/failure status.

Branch protection may consume this evidence if desired, but source text or a receipt never proves that branch protection is active, and branch-protection state never authorizes workers to stop unrelated product work.

## Unattended execution

Routine workers run unattended. Prefer repository-provided tools, then known/preinstalled tools, then bounded noninteractive tools. Python is allowed when noninteractive.

If an executable route produces UAC, Firewall, SmartScreen, credential, installer, or first-run UI, reject **that exact route**, record the evidence, switch to another safe route, and continue other work. The user is not the routine permission-click or technical-failure interpreter.

## Candidate-safe entrypoint

`Invoke-V2Gate.ps1` may validate a candidate tree while executing trusted control code from its own checkout. The entrypoint validates changed paths, runs the trusted control tests and reusable verification seam, and records exact provenance. Missing optional HISTORY evidence does not prevent execution.

A failed validation is evidence about that candidate or route. Fix the actual defect or use a safe alternative; do not convert it into a project-wide stop.
