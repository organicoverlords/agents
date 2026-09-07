# Personal-view earthworks preview — 2026-08-16

Branch: `agent/chatgpt-earthworks-personal-preview-20260816`

Parent: `agent/chatgpt-earthworks-fieldcraft-20260816 @ 702449a912f7feba819eafcef700724d9ce2dae8`

Status: SOURCE COMPLETE / UE5.8 BUILD + USER PLAYTEST PENDING.

## Goal

Make the same deformable-earth system usable from ordinary first- and third-person character play, with a visible preview before terrain is changed. RTS behavior remains unchanged.

## Personal-view controls

The personal adapter only runs while the PlayerController possesses an `ACharacter`-derived pawn and RTS mode is off. This intentionally excludes Owl/Hummingbird flight pawns, because their existing flight contract uses X for landing.

- `N` — create the one allowed deformable worksite at the camera aim point if none exists.
- `B` — cycle the same precision / standard / large brush used by RTS.
- Hold `Z` — preview dig footprint and depth; release `Z` to commit exactly the last visible preview.
- Hold `X` — preview fill footprint and height; release `X` to commit.
- Hold `C` — preview grade/flatten radius; release `C` to commit.
- Hold `H` — preview trench length/radius/direction; release `H` to cut it.
- Hold `J` — preview berm length/radius/direction; release `J` to build it.
- `Backspace` — use the existing shared terrain undo path.

The preview follows `APlayerController::GetPlayerViewPoint`, so whichever first- or third-person camera is active drives the trace.

## Preview contract

The playtest preview is asset-free debug geometry:

- brown = excavation
- green = fill / berm
- yellow = grading
- red marker = the current view hit is not deformable soil
- a vertical arrow shows raise/lower direction
- trench/berm previews show the full elongated centreline plus brush-radius volumes
- text shows Soil cost/yield and the release key

The release frame does not retrace. The operation commits the last valid preview position and direction shown while the key was held.

## Shared economy / undo

This is not a parallel terrain economy.

`Up3PersonalEarthworksSubsystem` retrieves the existing `Up3EarthworksSubsystem` from the same world and reuses its:

- brush size
- Soil scale
- worksite cost
- trench / berm dimensions
- Stone dig-progress accounting
- terrain undo record stack

Dig/trench yields and fill/berm costs therefore remain compatible with RTS switching and cannot silently duplicate a second inventory model.

## Integration constraints

This child branch adds only:

- shared accounting accessors in `p3EarthworksSubsystem.h`
- `p3PersonalEarthworksSubsystem.h/.cpp`
- this document

It does not edit:

- `p3PlayerController`
- character movement / AnimBP code
- bird flight code
- Enhanced Input assets
- maps
- Claude's showroom-playtest bootstrap

## Fast gate

After integration onto the current playtest branch:

1. Build UE5.8 once with the machine's known `UE_SDKS_ROOT=C:\Users\Lauri\UE_AutoSDK` requirement.
2. Start the copied showroom gameplay map.
3. Possess one normal humanoid Character pawn.
4. `N` create a worksite if needed.
5. Hold Z while aiming at the worksite: confirm a brown footprint follows the crosshair/camera and no terrain changes while held.
6. Release Z: confirm only the last previewed footprint deforms.
7. Repeat one fill or grade operation.
8. Confirm Backspace reverses the operation and shared inventory accounting.
9. Switch to Owl/Hummingbird and confirm X still belongs to bird landing, with no personal earthworks preview.

Stop there and hand feel/visibility acceptance to the user.
