# Jungle Scene C++ Builder - opencode Skill

## Description
Build photorealistic jungle scenes in Unreal Engine 5.8 using a comprehensive C++ generation system. Implements 25+ UE5-specific procedural generation techniques.

## When to Use
- User wants to build a jungle scene in UE 5.8
- Need trees, rocks, river, grass, shrubs, logs, animals
- Want fast C++ generation (10-50x faster than Python)
- Need PCG, Mass Entity, Nanite-ready output
- Want a one-click build via commandlet

## Triggers
- "build the jungle"
- "generate jungle scene"
- "add trees/rocks/etc to jungle"
- "create jungle with C++"
- "run the orchestrator"

## Files
- `C:\Users\Lauri\AppData\Local\Temp\opencode\JungleScene2\` - project root
- `Scripts/run_orchestrator.py` - Python entry point
- `Scripts/build_jungle.bat` - Batch entry point
- `Source/JungleScene2/` - C++ module
- `Docs/UsageGuide.md` - Complete usage guide

## Commands

### Full Build (recommended)
```
ue-cli execute_python --timeout 600 --code "exec(open('C:\\Users\\Lauri\\AppData\\Local\\Temp\\opencode\\JungleScene2\\Scripts\\run_orchestrator.py').read())"
```

### Quick Preview
```
ue-cli execute_python --timeout 120 --code "exec(open('C:\\Users\\Lauri\\AppData\\Local\\Temp\\opencode\\JungleScene2\\Scripts\\run_orchestrator.py').read())" 
# Then edit to call run('preview')
```

### High Quality (with animals)
```
# In Python, call run('high')
```

### Cinematic
```
# In Python, call run('cinematic')
```

### Section Builds
```python
# Vegetation only
o.build_only_vegetation()

# Water only  
o.build_only_water()

# Terrain (rocks) only
o.build_only_terrain()

# Atmosphere only
o.build_only_atmosphere()
```

### Custom Counts
```python
o.set_tree_count(20)
o.set_rock_count(150)
o.set_grass_count(800)
o.generate_full_jungle()
```

### Clear All
```python
o.clear_everything()
```

### Screenshot
```python
screenshot = unreal.JungleScreenshot()
screenshot.initialize(unreal.EditorLevelLibrary.get_editor_world())
screenshot.take_screenshot("C:/Users/Lauri/Desktop/jungle.png")
```

## Automation launch boundary

This skill does not own a direct Unreal process launcher. Never copy a bare
`UnrealEditor-Cmd.exe` command into an agent run. Automation-owned p3 startup
and recovery must go through the tracked repository launcher:
`scripts/windows/start-p3-agent-editor.ps1`.

The JungleScene2 example is not a p3 project and has no approved launcher in
this skill. Keep it manual/user-owned or add a separately reviewed,
ownership-aware project launcher before automating it.

## From Batch File
```batch
cd /d "C:\Users\Lauri\AppData\Local\Temp\opencode\JungleScene2"
Scripts\build_jungle.bat standard
```

## Available C++ Classes

### UJungleSceneOrchestrator
Main entry point. Use this for all builds.
- BuildFullScene(Quality)
- BuildQuickPreview / BuildHighQuality / BuildCinematic
- BuildOnlyVegetation / Water / Terrain / Atmosphere
- ClearEverything / LogBuildStats

### UJungleGenerator
Direct generator with finer control.
- GenerateTrees/Rocks/River/Grass/Shrubs/Logs
- CreateMaterials / CreateSpeciesMaterials
- SetupLighting / SetupPCGVolume
- SetXCount setters for all categories

### UJungleAtmosphereController
Time of day and weather.
- SetTimeOfDay(Dawn/Morning/Noon/Afternoon/Dusk/Night)
- SetWeather(Clear/Hazy/Rainy/Misty/Stormy)

### UJungleAnimalSpawner
8 animal types.
- GenerateButterflies/Birds/Fish/Frogs/Dragonflies/Spiders/Snakes/Crabs
- GenerateAllAnimals

### UJungleMaterialFactory
Materials.
- CreateBasicMaterial / CreateGroundMaterial / CreateTrunkMaterial / CreateLeavesMaterial
- CreateSubstrateMaterial

### UJungleSplineSystem
Splines.
- CreateRiverSpline / MakeSineSpline / MakeCircleSpline
- PlaceAlongSpline / PlaceVinesAlongSpline / PlaceIvyAlongSpline

### UJungleWaterFlow
Animated water.
- CreateAnimatedWaterMaterial / ApplyAnimatedMaterialToRiverActors / TickFlow

### UJungleScreenshot
Screenshots.
- TakeScreenshot / TakeViewportScreenshot / TakeCameraScreenshot
- TakeOrbitScreenshots

### UJunglePCGGenerator
PCG (UE 5.5+).
- CreatePCGVolume / CreateTreeScatterGraph / CreateGrassScatterGraph / CreateRockScatterGraph
- GeneratePCGFoliage / GeneratePCGGrass / GeneratePCGRocks

## Best Practices

1. **Use the Orchestrator** - It handles subsystem creation and ordering
2. **Start with Standard** quality and iterate
3. **Save level after build** - orchestrator does this automatically
4. **Take screenshot before/after** to compare
5. **Use section builds** to recover from crashes

## Important Notes

- The C++ module compiles automatically on UE launch
- First launch takes 1-2 minutes for compilation
- Subsequent launches are fast
- Bridge timeout is avoided by using C++ directly
- Memory-efficient for large scenes

## UE5 Features Used (25+ techniques)

### Vegetation (8)
1. Nanite Foliage (5.7+)
2. PCG Production-Ready (5.5+)
3. PCG GPU Processing (5.5+)
4. Foliage + World Partition (5.0+)
5. Nanite Tessellation (5.4+)
6. Landscape Grass + Nanite (5.0+)
7. Procedural Foliage Volume (5.0+)
8. Virtual Shadow Maps (5.0+)

### Stones (8)
9. Nanite Static Displacement (5.4+)
10. Nanite Tessellation Runtime (5.4+)
11. Nanite Landscape (5.3+)
12. Geometry Scripting (5.0+)
13. Substrate Materials (5.0+ beta)
14. Chaos Destruction (5.0+)
15. Chaos Fields (5.0+)
16. Lumen GI (5.0+)

### Animals (9)
17. Mass Spawner (5.0+)
18. Mass ISM (5.1+)
19. Mass LOD (5.1+)
20. Mass Avoidance (5.1+)
21. StateTree (5.2+ production)
22. Animation Sharing (5.0+)
23. Mass SmartObject (5.1+)
24. Mass Replication (5.1+)
25. Nanite Skeletal Mesh (5.2+)
