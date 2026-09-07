# Rapid Basebuilding Follow-on

STATUS=SOURCE_ONLY
BUILD=NOT_PROVEN
RUNTIME=NOT_PROVEN

Base: `agent/chatgpt-basebuilding-materials-terrain-20260816 @ c2686ef80182b87050a076f2d72927daf85d14f6`

This follow-on deliberately leaves the frozen materials/earthworks compile target untouched.

## New controls

While in RTS build mode with a valid build preview:

- **Shift + hold LMB — paint build**
  - as the preview moves into a different valid grid/snap transform, it requests another placement
  - placement still goes through `Ap3PlayerController::TryPlaceSelectedBuild()`
  - existing affordability, collision validation, recipe application, spawn-failure refund and preview refresh remain authoritative
  - releasing Shift or LMB resets the paint stroke

- **Hold Alt with a Foundation preview — auto-grade**
  - only operates when the foundation preview is already valid
  - only operates when the surface under the preview is `Ap3DeformableGround`
  - applies one volume-conserving flatten pass per preview XY position
  - after grading, placement waits a frame so normal preview/collision logic can re-query the changed surface
  - release/re-hold Alt if you intentionally want to grade the same position again

No shared Enhanced Input asset is modified by this follow-on.

## Fast acceptance

After the frozen materials/earthworks branch builds green, integrate this follow-on and do only a short smoke:

1. Enter RTS mode and select a cheap piece.
2. Hold Shift + LMB and drag across several valid grid cells; confirm multiple pieces place and inventory decreases normally.
3. Confirm paint stops when material affordability fails.
4. Create a deformable worksite, select Foundation, hold Alt over an uneven position, and confirm the patch grades once under the preview.
5. Place the foundation normally and hand the build to the user for feel/tuning.

Do not tune paint spacing or grading strength autonomously unless a concrete failure blocks playtesting.
