# gh-buffer North Star

Status: **COMPONENT PRODUCT DIRECTION; REFINES THE ASSISTANT STACK NORTH STAR**
Owning stack: Assistant Stack / `organicoverlords/regression-research`
Local implementation: `C:\Users\Lauri\Desktop\gh-buffer`
Canonical human-facing authority: `organicoverlords/agents@main` at `docs/repos/regression-research/`.

## Product identity

gh-buffer is the **local-first GitHub read accelerator for the swarm**. GitHub remains authoritative; gh-buffer removes repeated network/API/process work when workers ask the same safe read questions.

It is not a GitHub replacement, repository authority, issue database, write queue, offline source of truth, scheduler or ownership system. It may cache and coalesce provably read-only GitHub CLI/API traffic and may route safe reads from other execution nodes, but writes continue to use the real GitHub authority.

## Finished-product outcome

A finished gh-buffer makes ordinary GitHub lookup latency mostly disappear from swarm coordination:

- repeated safe reads are served from a persistent localhost Rust sidecar with an in-memory L1 and durable SQLite L2;
- simultaneous identical misses collapse into one upstream GitHub request;
- operation-aware TTL and bounded stale-while-revalidate keep hot reads local without pretending cached data is permanently current;
- recent successful data may be served on transient refresh failure only under explicit stale bounds and visible semantics;
- successful writes invalidate affected reads conservatively, with repo-scoped invalidation where identity is explicit and full invalidation when it is not;
- REST and GraphQL are cached only when the command/document is provably read-only; ambiguous operations bypass the cache;
- request context preserves host/repo identity so a persistent sidecar never leaks one caller's repository into another caller;
- existing tools can adopt the cache without source rewrites through a scoped `exec` lane, while human/interactive or mutating commands retain normal GitHub CLI behavior;
- remote workers can consume the Windows-hosted cache through an authenticated loopback tunnel using a fail-closed read-only lane; they do not gain a GitHub write path or create another cache authority;
- local bare Git mirrors answer refs/commits/object questions that do not need GitHub API state at all;
- cache/proxy failure degrades to the supported real GitHub route where safe rather than becoming a task permission gate.

## Hard boundaries

1. **GitHub stays authoritative.** Cached values are acceleration data, never issue/PR/repository truth independent of GitHub.
2. **Read safety is proven, not guessed.** Unknown commands, mutation/subscription GraphQL, field-bearing API writes, watch/interactive modes and other ambiguous traffic bypass or fail closed.
3. **No blind write buffer.** Do not queue arbitrary GitHub mutations for later replay. Any future deferred write mechanism requires explicit idempotency, durable receipts, conflict detection and a narrower product decision.
4. **Writes preserve semantics.** Non-cacheable commands use the real GitHub CLI with normal stdio/exit behavior; successful writes invalidate cache state before stale pre-write data can repopulate it.
5. **Remote means read-only by default.** A worker without authenticated GitHub credentials may consume the shared cache/upstream read route only through the explicit fail-closed lane; it must not receive transparent mutation capability.
6. **Cache metrics are not work state.** Hits, misses, freshness, inflight leases and latency are performance evidence only—not backlog, liveness, ownership or completion authority.
7. **Local Git beats remote API.** When a question can be answered correctly from an up-to-date local mirror/object database, do not spend a GitHub API call merely because an API exists.

## Rust-first implementation direction

The maintained runtime is Rust.

- Sidecar, client/proxy, classifier, cache engine, single-flight, invalidation and remote-readonly behavior remain native Rust.
- Do not reintroduce Python on the maintained hot/runtime path for convenience.
- Prefer a small native dependency surface, explicit protocol and measurable behavior over framework-heavy infrastructure.
- Optimize only where measurement shows meaningful swarm cost; once local hit latency reaches process/IPC floor, prioritize adoption, Git mirrors and cross-machine sharing over micro-optimizing SQLite or counters.

## Durable milestones

1. **Local hot-path elimination.** Repeated GitHub reads become localhost memory/IPC, not repeated `gh` processes plus network requests.
2. **Correct freshness under concurrency.** Single-flight, SWR, stale-on-error and generation-guarded writes remain race-safe under real parallel worker load.
3. **Safe transparent adoption.** Existing swarm helpers can enter a scoped proxy lane without semantic changes, while writes/interactive commands remain direct and cache-invalidating.
4. **Authenticated cross-machine reads.** OMEN/VPS workers share the Windows cache/upstream authentication through a bounded encrypted read-only route rather than duplicating GitHub lookups or credentials.
5. **Git object locality.** Bare mirrors/local object stores absorb refs, commits, ancestry and object-content questions that do not require live GitHub service state.
6. **Finished GitHub access layer.** GitHub latency/rate limit/process startup stop being a swarm bottleneck, while GitHub remains the unambiguous source of remote truth and mutation authority.

## Current priority

Finish and prove the Rust remote-readonly lane, route high-frequency swarm helpers through scoped cache access without source collisions, then add local Git mirrors for object/ref queries. Keep correctness/invalidation ahead of hit rate, and prefer broader adoption over further hot-path micro-optimization once local cache hits are near IPC cost.