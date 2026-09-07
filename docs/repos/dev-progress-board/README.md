# Dev Progress Board

A local operator cockpit for the development stack. It is built for the user to read and steer from one screen; workers do not coordinate through it:

`LowVRAM 3D Pipeline -> Asset Library + TinyLab -> P3`

## What updates automatically

The local board service reconciles every 15 seconds. GitHub probes are cached for 120 seconds so local activity stays near-live without hammering the API. It reads:

- local Git branch, HEAD, recent commits, and dirty-file count for configured repos;
- file activity for the non-Git asset library workspace;
- open GitHub PRs and workflow runs for configured repos;
- recent shared MCP process receipts mapped to configured project paths;

The browser is one deliberately simple control surface: four large project rows with prominent progress bars, finish lines, current/next milestones, current direction, worker/lane aim, and real milestone evidence. Recent wins/goals are compact; worker-direction and technical activity detail stays folded away until opened.

## Source of truth

GitHub/repository state owns delivery work, BusyCoordinator owns exact live mutation collision control, and this board is a read-only operator view over them. Coordinator backlog/ready records are never promoted into product goals or workload pressure. AI summaries are optional and never replace live evidence.

MCP activity ingest is metadata-only: the board keeps the project, process class, short workspace label, action count, and timestamp. Network addresses, authentication fields, request payloads, and command bodies are never copied into the board snapshot.

`/api/health` separates service liveness from data freshness. It exposes reconciliation duration, consecutive failures, and stale-snapshot age. The board service owns reconciliation retries while it is running. It is intentionally on-demand: `OPEN DEV PROGRESS BOARD.cmd` starts it through `Start-Board.ps1`, and the UI exposes degraded or stale data instead of hiding it behind a second supervisor.

Milestone completion is conservative: a milestone contributes 100% when marked `done`; partial completion is counted only when a worker explicitly supplies `progress=0..100`. Merely saying `active` does not invent a percentage.

`state/snapshot.json` is the single live generated board state and is intentionally Git-ignored. Retired status/event snapshots are not current repository surfaces; historical versions remain available through Git history.

## Open locally

Run `OPEN DEV PROGRESS BOARD.cmd` on the Desktop. The service is not started automatically at Windows login.

Local URL: `http://127.0.0.1:8765/`
