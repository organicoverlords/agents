# CI runner capacity

The P3 Actions fleet has explicit runner roles. Workflow labels are part of the
capacity contract, not descriptive metadata.

## Roles

- `p3-build` is the scarce Unreal C++ lane. Full `p3Editor` builds and other
  work that consumes the warm Unreal build cache use this role.
- `p3-secondary` is the short-check lane. Contract and architecture checks use
  this role.
- `p3-checks` may remain on a provisioned machine for compatibility, but it is
  not a substitute for the `p3-secondary` pool used by the short-check
  workflows.

Keeping these roles separate prevents a five-minute policy or documentation
check from occupying the only runner that can execute a full Unreal build.

## Live audit

Runner transport state is not proof of task progress. Inspect the required
labels and the job's exact step before diagnosing a queue:

```powershell
gh api repos/organicoverlords/p3/actions/runners?per_page=100 |
  ConvertFrom-Json |
  Select-Object -ExpandProperty runners |
  Select-Object name,status,busy,labels
```

Use concrete process/runtime/output evidence for active work; runner `busy` is
transport metadata only. The `scripts/ci/remote/ensure-*-core-workers.ps1`
scripts own the provisioned runner pool. Do not register duplicate runners
merely because an existing role-labeled runner is busy.
