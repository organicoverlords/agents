# Flight Profile Proposal — Shared, Reusable (CPU/source only)

Status: **implemented 2026-08-16 (Lane B)**. `Source/p3/p3FlightTypes.h/.cpp` now defines `FFlightProfile` and `FlightProfiles::MakeEagleDefault()/MakeOwlDefault()/MakeHummingbirdDefault()/MakeMacawDefault()` exactly as sketched below (field names below are the proposal's original sketch names; the committed struct uses the equivalent shape with a couple of naming/precision differences documented in the header itself — e.g. `PitchLimit`/`PitchLimitUp`/`PitchLimitDown` all present, not just the split pair). `AEagleFlightPawn` (`EagleFlightPawn.h/.cpp`) consumes it directly, replacing the hardcoded literals below. `Ap3Character`'s Macaw flight (`p3Character.h/.cpp`) also consumes a `MacawFlightProfile` instance at runtime for its bank/pitch attitude. Owl and Hummingbird have profile *data* only (`MakeOwlDefault`/`MakeHummingbirdDefault`) — no playable pawn exists yet in `p3` for either, so there is nothing to wire the data into beyond the struct itself; see the Lane B final report for exactly which fields are measured vs. placeholder for those two. No editor/compile step was available to this lane; see the report for how correctness was validated instead.

Original proposal text follows, unedited, as the design record:

## 1) Evidence read

- `C:\Users\Lauri\Desktop\lowvram3d-master-unif-20260816\eagle\EAGLE_ANIMATION_GATE.md` — Phase 7: 3 actions on 13-bone rig (`Eagle_WingSpread` 24f, `Eagle_Flap` 24f loop +28/-28°, `Eagle_Glide` 48f loop +8/-8°), body/tail identity, 0.0 loop closure.
- `C:\Users\Lauri\Desktop\p3-building15-20260816\Source\p3\EagleFlightPawn.h` / `.cpp` — current airborne pawn (`ACharacter`, `MOVE_Flying`, capsule NoCollision airborne, velocity commanded directly, mesh-only roll/pitch, fixed literals listed below).
- `C:\Users\Lauri\Desktop\lowvram3d-master-unif-20260816\eagle\eagle_animation.py` — `clip_specs()`: `WingSpread 16*smoothstep`, `Flap 28*sin(2πt)`, `Glide 8*sin(2πt)` on bone-local hinge fractions `0.50/0.30/0.15/0.05`.
- `C:\Users\Lauri\Desktop\lowvram3d-master-unif-20260816\flight\flight_profiles.json` — species-agnostic template: adding a species = adding a profile, not editing the controller (owl 1.5 Hz/85°, hummingbird 11 Hz/70° + hover, etc.). `flight/species.json` / `flight/README.md` confirm the pattern.

Search scope covered `flap_speed|hover|glide|pitch_limit|roll_limit` in `Source/p3` and `eagle/*.py` — only the files above matched with flight relevance; no hidden flight tunables found elsewhere.

## 2) Current Eagle hardcoded tunables (the contract to preserve)

From `Source/p3/EagleFlightPawn.h` + `EagleFlightPawn.cpp`:

| Field in code | Value | Meaning |
|---|---|---|
| `CruiseSpeed` | `720.0f` | horizontal target when idle (glide) |
| `MaximumSpeed` | `1500.0f` | horizontal target when `W` held |
| `Acceleration` | `1150.0f` | `FInterpConstantTo` rate toward target |
| `BrakeDeceleration` | `1900.0f` | rate when `LeftShift` held |
| `ClimbSpeed` | `520.0f` | `TargetVerticalSpeed` when `Space` held |
| `DiveSpeed` | `980.0f` | `TargetVerticalSpeed` when `Ctrl` held |
| `BankTurnRate` | `80.0f` | `AddActorLocalRotation(Yaw)` rate — yaw response |
| `MaximumBankDegrees` | `28.0f` | roll target, mesh-relative only |
| `TargetPitchDegrees` | `+18.0f` climb / `-24.0f` dive | mesh-relative pitch, `FInterpTo 4.5` (hardcoded literals in `Tick()`) |
| `bHoverCapable` (implicit) | `false` | gravity resumes on `Grounded`, no hover hold; `flight/flight_profiles.json` owl `hover_capable:false`, hummingbird `true` confirms the flag exists outside Eagle |
| `Flap amplitude` | `28.0°` (`Eagle_Flap`) | from `eagle_animation.py` |
| `Glide amplitude` | `8.0°` (`Eagle_Glide`) | from `eagle_animation.py` |
| `Flap frequency` | implicit via clip length | `Eagle_Flap` 24f loop, `Eagle_Glide` 48f loop (playback rate 1.0 in `EagleFlightPawn::UpdatePrimaryAnimation`) |

`TickFlightMovement()` notes: braking/host: `BrakingDecelerationFlying/BrakingFriction/FrictionFactor = 0`, `AddTickPrerequisiteActor(this)` — both required and orthogonal to tuning.

## 3) Smallest reusable profile

Mapped to the 10 task fields. No per-species controller — just data.

```cpp
// Proposed: Source/p3/FlightProfile.h  (not committed in this patch — header sketch only)
// Keep it a plain USTRUCT so Eagle defaults live as a single constexpr, and future
// species override by data. No virtual dispatch, no Owl/Hummingbird/Macaw subclasses.

USTRUCT(BlueprintType)
struct FFlightProfile
{
    GENERATED_BODY()

    // Wingbeat
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Wing") float FlapFrequency = 1.25f; // Hz at playback 1.0 (Eagle_Flap 24f @30fps); drives AnimSequence play rate scalar
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Wing") float FlapAmplitude = 28.0f; // degrees, matches Eagle_Flap ±28
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Wing") float GlideStrength = 8.0f;  // degrees/glide amplitude, matches Eagle_Glide ±8; also maps to glide_efficiency in flight_profiles.json

    // Translation
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Motion") float MaxSpeed = 1500.0f;   // == MaximumSpeed
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Motion") float Acceleration = 1150.0f;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Motion") float Braking = 1900.0f;     // == BrakeDeceleration

    // Attitude limits (mesh-relative; actor yaw is separate)
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Attitude") float PitchLimitUp = 18.0f;   // +18 climb
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Attitude") float PitchLimitDown = 24.0f; // -24 dive (single pitch_limit in task maps to max(|up|,|down|)=24; split kept to reproduce asymmetry)
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Attitude") float RollLimit = 28.0f;      // == MaximumBankDegrees
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Attitude") float YawResponse = 80.0f;    // == BankTurnRate (deg/s per unit BankCommand)

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Flight|Capability") bool bHoverCapable = false;
};

inline constexpr FFlightProfile EagleDefaultProfile{
    /*FlapFrequency*/ 1.25f,
    /*FlapAmplitude*/ 28.0f,
    /*GlideStrength*/ 8.0f,
    /*MaxSpeed*/      1500.0f,
    /*Acceleration*/  1150.0f,
    /*Braking*/       1900.0f,
    /*PitchLimitUp*/  18.0f,
    /*PitchLimitDown*/24.0f,
    /*RollLimit*/     28.0f,
    /*YawResponse*/   80.0f,
    /*bHoverCapable*/ false
};
// Single scalar pitch_limit for callers that need one: pitch_limit = max(PitchLimitUp, PitchLimitDown) = 24.0f
```

Parametric differences vs `flight/flight_profiles.json` (reference, not normative for p3):

| Task field | json analogue | Owl | Hummingbird | Eagle (this proposal) |
|---|---|---|---|---|
| `flap_frequency` | `flap_frequency` | 1.5 | 11.0 | 1.25 |
| `flap_amplitude` | `flap_amplitude` | 85 | 70 | 28 |
| `glide_strength` | `glide_efficiency` / `glide_spread` | 0.96 / 1.0 | 0.72 / 0.85 | 8.0 (deg) |
| `max_speed` | `max_speed` (m/s) vs cm/s in p3 | 17.0 | 26.0 | 1500 (cm/s) |
| `acceleration` | `acceleration` | 6.5 | 16.0 | 1150 |
| `braking` | `brake_drag` (factor) vs `Braking` (rate) | 0.95 | 0.55 | 1900 |
| `pitch_limit` | `max_pitch_degrees` / `pitch_strength` | 32 / 52 | 45 / 120 | 18 up / 24 down (max 24) |
| `roll_limit` | `max_bank_degrees` | 60 | 75 | 28 |
| `yaw_response` | `yaw_strength` / `bank_strength` | 38 / 72 | 130 / 165 | 80 (`BankTurnRate`) |
| `hover_capability` | `hover_capable` | false | true | false |

Derived/omitted pawn fields for completeness (not in task's 10, keep as-is until profile v2): `CruiseSpeed 720`, `ClimbSpeed 520`, `DiveSpeed 980` — proposed to fold into `MaxSpeed`/`Acceleration`/`Braking` + vertical-speed fields later, but excluded here to keep "smallest" strictly to 10.

## 4) Eagle-default reproduction proof

Setting `FFlightProfile = EagleDefaultProfile` and replacing literals in `EagleFlightPawn.cpp` with `Profile.*` must yield identical traces:

- `HorizontalSpeed -> MaxSpeed` with `Acceleration`/`Braking` unchanged → same `TickFlightMovement` velocity command.
- `BankTurnRate` → `YawResponse`, `MaximumBankDegrees` → `RollLimit` → same `AddActorLocalRotation` + mesh roll `FInterpTo 5.0`.
- `Pitch 18/-24` → `PitchLimitUp/Down` with `FInterpTo 4.5` unchanged → same mesh pitch.
- `FlapAmplitude 28 / GlideStrength 8` selects `Eagle_Flap` vs `Eagle_Glide` AnimSequences already; `FlapFrequency 1.25` is the measured playback for 24f @30fps — assert no change at rate 1.0.
- `bHoverCapable false` retains `Grounded` gravity/landing logic.

## 5) Adoption (deferred, source-only)

1. Add `Source/p3/FlightProfile.h` with the struct above (no controller subclass).
2. In `AEagleFlightPawn`, add `UPROPERTY(EditAnywhere) FFlightProfile FlightProfile = EagleDefaultProfile;` and replace 10 literals with `FlightProfile.*` — single-site edit, no new classes.
3. Future species (Owl/Hummingbird/Macaw) add a second `FFlightProfile` instance or `DataAsset`, not a new pawn class. Migration is data-only.

No editor launch, no `Source/p3/FlightProfile.h` creation, no controller implementations performed in this proposal turn (per instruction: CPU/source/git only, no bespoke controllers).

## 6) Files

- This file: `C:\Users\Lauri\Desktop\p3-building15-20260816\docs\FLIGHT_PROFILE_PROPOSAL.md` (new).
- Reference impl sketch lives inside this markdown; actual `Source/p3/FlightProfile.h` creation deferred until approved to avoid premature compile coupling.
