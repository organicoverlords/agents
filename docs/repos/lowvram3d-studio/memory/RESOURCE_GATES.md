# Active resource-gate memory

`AUTHORITATIVE_POLICY=organicoverlords/agents:AGENTS.md`

Global operating contract: [`AGENTS.md`](../../../../AGENTS.md)
Proven machine capabilities: [`docs/agent-capabilities.md`](../docs/agent-capabilities.md)
Current production work: [`docs/production-lanes.yaml`](https://github.com/organicoverlords/lowvram3d-studio/blob/main/docs/production-lanes.yaml)

This file is durable technical memory describing the resource-gate evidence;
it is not a competing workflow policy. Operational sequencing and whether to
wait are governed by the Agents repository [`AGENTS.md`](../../../../AGENTS.md).

```text
RESOURCE_GATE_POLICY=COMMIT_PRESSURE_FIRST
AVAILABLE_PHYSICAL_RAM_IS_NOT_A_HARD_BLOCK=true
PAGEFILE_USAGE_ALONE_IS_NOT_A_HARD_BLOCK=true
ENGINE_MEMORY_ESTIMATE_IS_NOT_ACTUAL_REQUIRED_RESIDENT_MEMORY=true
COMMIT_LIMIT=PRIMARY_CAPACITY_SIGNAL
COMMIT_CHARGE=REQUIRED_TELEMETRY
COMMITTED_BYTES=REQUIRED_TELEMETRY
COMMIT_REMAINING=REQUIRED_TELEMETRY
PROCESS_PRIVATE_BYTES=REQUIRED_TELEMETRY
PROCESS_WORKING_SET=REQUIRED_TELEMETRY
PAGING_ALLOWED_WHEN_COMMIT_HEALTHY=true
UNKNOWN_ESTIMATE_ACTION=PROCEED_WITH_MONITORING
GLOBAL_HEAVY_UE_MUTEX=false
```

Hard block only with concrete evidence:

- `COMMIT_REMAINING < measured_or_predicted_peak + modest_safety_margin`;
- exhausted commit/pagefile capacity;
- an actual allocation/OOM failure; or
- sustained severe paging with no measurable progress.

Low physical RAM with healthy commit is `RAM_PRESSURE=ELEVATED`,
`PAGING_ALLOWED=true`, `ACTION=PROCEED`. Every wait must report the resource,
current value, hard limit, required estimate, estimate source, measured prior
peak, and why waiting is required. Repeated “wait for RAM to free” loops are
forbidden.

Measured operation history is preferred over engine estimates. The seeded
record `ASYLUM_435K_SKELETAL_IMPORT` is approximately 2325 MiB process peak,
despite UE reporting `RequiredMemory=4096 MiB`.
