# Emergency recovery override

This contract is dormant. Do not load, consult, or apply it during normal operation. It becomes active only when the trigger in C:\Users\Lauri\.agents\RULES.md is satisfied. Once service/control is restored, stop using this contract and return to the normal shared rules.

## Purpose

Prevent local safety, coordination, evidence, or change-control machinery from creating a recovery deadlock in which the rules intended to protect production make restoration impossible or materially slower.

## Emergency trigger

Emergency recovery is active only when at least one of these is true:

1. The user explicitly invokes emergency or break-glass recovery for the affected production/control-plane path; or
2. Current authoritative evidence establishes an active outage, severe degradation, loss of control, or recovery deadlock, and a normal local operational/change-control/coordination prerequisite is directly preventing or materially delaying restoration.

Ordinary bugs, tuning, convenience, planned migrations, speculative cleanup, or desired configuration changes are not emergencies.

## Recovery priority

During a qualifying emergency, restoring service or regaining control takes precedence over conflicting local procedural safeguards. This is standing user authorization for the minimum live production/control-plane change necessary to recover the affected path when the conditions below are met.

The operator may bypass a conflicting local production-change gate, evidence-completeness requirement, coordination prerequisite, or similar shared-contract restriction when satisfying that prerequisite is impossible because of the incident itself or would materially prolong the incident.

A local gate returning BLOCK solely because global observation is incomplete, the degraded path cannot certify itself, a recovery dependency is unavailable, or another circular prerequisite cannot be satisfied is not by itself a stop condition during emergency recovery.

## Anti-deadlock rule

No recovery prerequisite may require evidence, approval, telemetry, coordination, or control exclusively from the same subsystem whose degradation is the reason recovery is required. Use the smallest independent supported evidence route available. If no independent route exists, lack of that route does not create a permanent deadlock: proceed only with the smallest reversible action that has a credible path to restore control.

## Minimum evidence before acting

Before an emergency mutation, establish as much as the degraded system allows, with current authoritative evidence where available:

- the specific failing or blocking component/path;
- evidence connecting it to the outage/degradation/deadlock;
- the exact intended mutation and bounded blast radius;
- the safest available rollback or recovery state, if one exists; and
- known active dependents or ownership collisions that can still be observed independently.

Unknown unrelated global state is not a reason to block a narrowly evidenced emergency repair. Do not broaden the mutation to compensate for missing telemetry.

## Coordination and locks

Busy claims and other coordination locks continue to prevent concurrent conflicting mutation when their current ownership is positively observable and active. A stale, orphaned, unreachable, or incident-causing local coordination state may be recovered or bypassed using the narrowest evidence-backed mechanism available. If the coordination service itself is degraded and cannot provide a claim, record the intended exact scope in the recovery evidence and do not let the unavailable coordinator prevent the minimum repair.

Never use emergency recovery as permission for broad process, port, service, task, or filesystem cleanup.

## Control-plane recovery

Prefer, in order: reversible reroute/failover; disabling the specific failing restriction; restoring a verified known-good serving configuration; replacing the failing component off-path and cutting over; then narrowly targeted destructive recovery only when the safer options cannot restore control.

For MCP/Commander or equivalent protected control-plane infrastructure, positively identify the target and likely process/service/task blast radius before destructive action whenever the available evidence permits. Preserve unrelated control paths and user/foreign processes. Do not turn incomplete incident telemetry into permission for indiscriminate termination.

A machine reboot/restart remains explicit-only unless the user explicitly invokes emergency recovery and the reboot/restart is the narrowly established recovery action for that named machine. Prefer subsystem recovery over whole-machine restart.

## Boundaries that are not suspended

This local contract does not override platform security or safety controls, authorization enforced outside these shared local contracts, protections for unrelated credentials/secrets/user data, or legal/security boundaries. It does not authorize destructive action against unrelated systems or data.

## Exit and reconciliation

Emergency mode ends immediately when the affected service/control path is restored to a usable state or when evidence shows the emergency trigger no longer holds. Then:

- normal RULES.md and AGENTS.md requirements resume;
- remove or reconcile temporary bypasses unless they are intentionally adopted through normal change control;
- preserve enough evidence to explain the trigger, overridden local gate, action taken, result, and rollback state; and
- fix the local rule/tool that caused the recovery deadlock when that repair is cheap, bounded, and safe, so the same incident cannot recur for the same reason.

## Priority

When this contract is active and conflicts with another local shared operational rule, this emergency recovery contract wins only for the minimum scope and duration required to restore service or regain control. Outside an active emergency, it has no effect.
