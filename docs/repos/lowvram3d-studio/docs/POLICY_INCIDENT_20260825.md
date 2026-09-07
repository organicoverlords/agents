# Policy note — asset queue, 2026-08-25

Short version for whoever maintains policy. Six things went wrong. Five were
policy, not code.

## What happened

A 26-item queue was asked to run at resolution 512. It ran at 1024 — roughly
four times the work per item on a 6 GB card. It then died at item 3 when the
session that launched it ended, and every item that had completed was reported
as failed. On inspection two of those three were finished, correct assets: a
stone watchtower and a mossy runestone. Only one had genuinely failed.

## The four causes

**1. A default was read as a veto.** `production/production.json` describes
itself as "the ONLY PLACE GENERATION SETTINGS EXIST". That sentence was written
to stop four hardcoded copies drifting apart, which was a real problem it
really solved. It was then read as authority to ignore what the caller asked
for. Nothing in the file said which wins.

*Policy:* "default" means the value used when the caller did not specify one.
An explicit request always wins. If a request cannot be honoured, stop and say
why — never silently substitute. Now stated in `production.json` and
`docs/PIPELINE_CONTRACT.md`.

**2. A proof gate verified a filename instead of an artifact.** The queue
confirmed each render by rebuilding the expected sheet name from the GLB path.
The renderer changed its naming convention in `279ffb9e`. Every asset rendered
perfectly; every asset was marked `FAILED(render-proof-missing)`. Two good
assets were condemned by a string mismatch and would have been regenerated.

*Policy:* a proof gate must check the artifact — find it, open it, measure it.
A gate that reconstructs an artifact's name is a gate on the naming
convention, and it fails the whole batch the day someone renames anything.

**3. Long work was launched as a child process.** Agent harnesses put their
shell in a job object, so every child dies with the session. The queue had no
way to outlive the thing that started it.

*Policy:* any batch longer than a few minutes launches detached — owned by the
scheduler, not by the caller. `tools/launch_queue_detached.ps1`.

**4. Agent housekeeping was escalated to the user.** The user was asked whether
to commit, which branch to use, whether to requeue a rejected asset, and was
told that an MCP coordination server needed authorization and that the working
tree was dirty. None of that is a user decision. It is the cost of doing the
work, and surfacing it means the user is doing the agent's job.

*Policy:* branch naming, committing, retry-after-rejection, and coordination
availability are the agent's to resolve. Pick the documented default and
proceed. Escalate only a genuine product decision — what to build, what to
accept — never the mechanics of building it. If a coordination service is
unavailable, record it locally and continue; do not make it the user's problem
and do not let it block mutation of idle scope.

**5. A fixed batch was rerun in its original order.** After the fix, the queue
restarted from the top — meaning the assets that already worked would run
again before anyone learned whether the fix took. That is the same "wait for
the whole batch to find out" failure as (2), one level up.

*Policy:* a queue stops itself on a failure pattern and requeues **errored
items first**. One failure is an asset; two is a pattern, and a pattern
reproduced across the rest of the batch is hours of GPU time spent confirming
something already known. Behaviour of a running queue changes through a marker
file it checks between items — never by editing the script it is currently
executing. `run_queue.ps1` (`out\QUEUE_STOP`, `-MaxFailures`) and
`tools/requeue_failed.ps1`. Completed items are never repeated.

**6. Preserving the work was offered to the user as a choice.** Whether to
push, branch, or merge is not a product decision. Asking it is the same error
as (4): it moves the cost of the work onto the person who asked for the work.

*Policy:* the agent pushes its own branch and opens the PR, unprompted. What it
must **not** do is unilaterally resolve conflicts in other lanes' files to get
there. Merging `origin/main` into this work produced six conflicts, several in
files owned by other agents (`AGENTS.md`, `workers/render_asset_views.py`).
The right scope was: fold in the one change that would otherwise be lost
(`origin/main` 71abe6e5's GLB container check, which touches the same gate),
push the branch, and let integration happen where those lanes can see it.
Durability is the agent's job; arbitrating between lanes is not.

## One real bug, for completeness

TRELLIS can return a flat sheet instead of a volume — full size, fully
textured, a million faces, exits 0, and only visibly wrong from the side. It
passed every check the pipeline had. It is now gated in
`workers/check_asset_sane.py` from the glTF bounds, keyed on thinnest/median
axis so that genuinely long thin assets still pass.

It was also visible in the generator log an hour before any render:
`decoded voxels @res1024 = 1050625`, which is exactly 1025², a single plane of
voxels one voxel thick — against 1.83M and 1.76M for the two solid assets in
the same queue. It dropped 0 floater components; the solid ones dropped 25 and
29, because a plane has none.

Related: the matte router chooses from the *plate* and was correct about the
plate, but never asked whether the *subject* was mostly internal negative
space, which is what a global threshold fills in. On a bonsai canopy it kept
5.96% of the subject as backdrop colour; segmentation kept 0.00%. Now measured
and escalated automatically.

## Standing rule this incident argues for

**Prove the pipeline on the item that broke, first.** Every policy failure
above was visible in the first completed item and was instead discovered after
26. The batch should stop itself at the second failure, put the errored assets
at the front of the retry, and prove the fix in minutes rather than hours.

## The shape of all six

Five of the six are the same mistake wearing different clothes: **something
checked a proxy instead of the thing itself.** A filename instead of a render.
A default instead of the request. A batch's original order instead of its
failures. And twice, the user instead of the agent's own judgement.
