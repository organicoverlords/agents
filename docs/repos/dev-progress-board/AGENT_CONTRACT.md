# Nexus agent contract

Follow the canonical [North Star](NORTH_STAR.md), shared RULES.md/AGENTS.md and the current [Nexus #16 plan](https://github.com/organicoverlords/nexus/issues/16). Reconcile linked WIP before starting an uncovered contribution. The existing issues own work; Nexus is not worker assignment, scheduling or admission.

## Native interactions and external facts

HTTP and MCP share one durable Nexus-native store for layout, append-only comments/questions, attachments and explicit annotations. Native interaction writes are intentional. The old Python board's read-only implementation is not a prohibition on these Nexus features.

Delivery state, authoritative acceptance, runtime activity and topology retain their owning sources and provenance. Card movement, local status/evidence labels, decisions and focus reports cannot silently update those authorities. Apply the North Star's revision/conflict, retry, acceptance-source, reviewer-lineage, transitive-readiness, freshness and privacy requirements to the actual write/read paths.

An acceptance_ledger binding reads the owning issue/protocol and identified revision. The legacy P3 configuration referenced issue #611 and `p3-acceptance-row:v1`; verify the current binding and owning protocol before use. A local evidence-set operation is not an alternative acceptance ledger.

## Proof and deployment

Use existing issue #23 for integrated candidate proof. Preserve accepted implementation and exact PR/commit/artifact checkpoints. New acceptance gaps do not erase previously delivered work, and prior test success does not prove new acceptance. No deployment follows automatically from this contract, issue closure or merge; the existing specific production-change authorization remains required.
