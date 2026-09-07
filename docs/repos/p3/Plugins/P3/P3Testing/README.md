# P3Testing

This is the V2 test-only Unreal module boundary. V2-00B establishes the plugin without forcing a project-level enablement change, because `p3.uproject` is outside this packet's ownership.

The canonical cross-process receipt is `docs/v2/schemas/P3VerificationReceipt.schema.json`, emitted by `scripts/v2/verification/Invoke-P3Verification.ps1`. Future L1/L2/L3 Unreal helpers belong here rather than in feature plugins or one-off workflow scripts.

Proof rules remain strict:

- Functional/Automation tests may prove their declared runtime scope but do not automatically prove a real user input path.
- Gauntlet/session scenarios own multi-process orchestration evidence.
- User-path/visual scenarios must record real PIE/editor ownership and release only sessions they actually acquired.
- Static results cannot be promoted to runtime or visual PASS by changing labels in the receipt.
