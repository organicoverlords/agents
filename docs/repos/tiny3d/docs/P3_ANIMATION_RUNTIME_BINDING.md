# P3 animation runtime binding

`qualify_p3_skeletal_animation_set.py` produces the hash-bound Tiny3D animation
mission. The mission now declares the exact consumer assets and runtime graph
requirements for issue #132:

- a loaded `SkeletalMesh`, `Skeleton`, and `AnimBlueprint`, with the mesh and
  blueprint bound to the mission skeleton;
- an explicit exercised-character binding that names the runtime character object
  and binds it to those exact `SkeletalMesh`, `Skeleton`, and `AnimBlueprint` paths;
- the exact materialized `AnimSequence` package identity for every required
  role and each action’s `AnimSequence`/`AnimMontage` package identity. An
  `AnimMontage` must also declare one or more source roles from this qualified
  animation set, so an unrelated same-skeleton montage cannot satisfy binding;
- `Idle`, `Locomotion`, `Airborne`, `Landing`, and `GameplayAction` states;
- gameplay-driven `movement_state`, `speed`, `airborne_state`,
  `attack_request`, `cast_request`, `interact_request`, `defeat_request`, and
  `action_complete` inputs; and
- idle, moving, airborne/landing, and gameplay-action runtime captures. The
  gameplay-action capture must also carry the #55 visual evidence bundle: a
  timestamped reviewed screenshot, a distinct timestamped motion sequence with
  at least two frames, matching capture/reviewed hashes, and stable-base and
  visible-motion verdicts.

P3 returns a `tiny3d.p3-animation-runtime-binding-receipt.v2` only after the
intended character has been exercised. Tiny3D validates it with:

```bash
python scripts/validate_p3_animation_runtime_binding.py \
  --receipt p3-runtime-binding-receipt.json \
  --animation-contract p3-animation-contract.json \
  --content-root P3/Content \
  --p3-revision <exact-p3-commit> \
  --output p3-runtime-binding-contract.json
```

Validation is fail-closed. The receipt must bind the exact animation contract
and mission IDs, current package hashes, exact P3 commit/build/executor, and a
complete set of `PASS` captures sourced from `P3_GAMEPLAY`. Timer/showcase
drivers, stale packages, wrong skeletons, unrelated or undeclared montage source
roles, missing state-machine transitions, incomplete captures, and
gameplay-action captures without the reviewed screenshot plus motion sequence
are rejected. Tiny3D validates the evidence
identity and declared frame count; it does not inspect pixels or promote
offline metadata to runtime proof.

The resulting contract can prove exact binding and returned P3 gameplay
evidence. `rendered_deformation` remains `NOT_PROVEN`: capture hashes preserve
evidence identity but Tiny3D does not inspect pixels or infer deformation from
metadata.
