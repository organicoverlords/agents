# Nexus

Nexus is the operator workspace for the development stack. Its primary experience is an infinite canvas with a synchronized Trello delivery board, topology inspectors, source-backed activity, evidence and collaboration.

The [North Star](NORTH_STAR.md) is the canonical product direction. [Nexus #16](https://github.com/organicoverlords/nexus/issues/16) owns the current implementation plan, linked WIP and acceptance handoffs. [The agent contract](AGENT_CONTRACT.md) explains the operating boundary.

## Names and implementation state

The canonical repository is [organicoverlords/nexus](https://github.com/organicoverlords/nexus). Dev Progress Board, DevProgressBoard and devboard remain compatibility/search aliases. This directory remains stable for existing documentation links.

The legacy Python board is a read-only reporting implementation. Its historical local entrypoint is `OPEN DEV PROGRESS BOARD.cmd` through `Start-Board.ps1`, using `http://127.0.0.1:8765/` and generated `state/snapshot.json`. Its documented reconciliation/cache intervals are 15/120 seconds. These are legacy implementation details, not claims about current service liveness or the Rust state store.

Rust Nexus is the shared Canvas/Board target. It deliberately supports bounded native layout, comments and annotations while projecting delivery, runtime and acceptance from their owners. Inspect the current executable/configuration and #16/#23 before making a deployment claim. This documentation does not authorize a production cutover.

GitHub owns delivery; current runtime observations own activity; Busy owns exact mutation collisions. Nexus-native writes cannot promote themselves into external status or acceptance.
