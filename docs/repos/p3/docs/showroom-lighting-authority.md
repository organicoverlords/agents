# Showroom lighting authority

This is a source-level ownership contract; it does not edit or save a map.

`Content/Python/TuneShowroomLighting.py` is the only script that owns the
baseline values for the named showroom Sun, SkyLight, and FillLight. It has a
world-path guard for `/Game/Showroom/Maps/ALL_ASSETS_Lineup`.

`Content/Python/RepairShowroomVisuals.py` owns floor/material/grass repair only
and must leave lights untouched. `Content/Python/TuneShowroomSkylight.py` is a
deprecated no-op compatibility entry point and must not save a level.

Mountain time-of-day is opt-in. `P3TimeOfDay::Apply()` routes to an existing
survival environment director when one owns the world; otherwise it updates only
directional and sky lights tagged `MountainTimeOfDay`. The named showroom Sun,
SkyLight, and FillLight remain exclusively under `TuneShowroomLighting.py`, so an
H/X keypress cannot overwrite the showroom baseline. The H cycle still advances
Morning → Bright Day → Rain → Evening → Night and still triggers the Mountain
rain burst.
