---
name: unrealmcp
description: Unreal Engine 5 MCP integration via UnrealMCP C++ plugin (TCP 55557) + stdio MCP server. Use when the user needs to control Unreal Editor from an AI agent — spawn actors, modify properties, read/write Blueprints, take viewport screenshots, run PIE sessions, edit C++ classes, query assets, build the project, navigate the viewport camera, or any other live editor automation. Triggers include "spawn an actor", "set a property", "take a screenshot", "compile the project", "open the editor", "look at this actor", "what's in the level", "make a light", or any UE5 editor task. The C++ plugin (UnrealMCPBridge) lives inside the editor on localhost:55557; the stdio MCP server is the `unrealmcp` Python package (pip install unrealmcp, ~280 commands).
allowed-tools: Bash(unrealmcp.exe:*), Bash(pip:*), Bash(ue-cli:*)
---

# Policy boundary

Global operating policy is defined by the active project `AGENTS.md`. This
skill is Unreal/MCP domain procedure only; `AGENTS.md` wins if anything
conflicts. Do not infer provider routing or add workflow gates here.

# unrealmcp (Unreal Engine 5 MCP)

Control the live UE5 editor through 280+ MCP commands exposed by the
**UnrealMCPBridge** C++ plugin (port 55557). The stdio MCP server is the
Python `unrealmcp` package (FastMCP-based).

## Architecture

```
AI agent (Claude / Cursor / OpenCode)
   │  stdio JSON-RPC
   ▼
unrealmcp  (Python, pip install unrealmcp)
   │  TCP 127.0.0.1:55557  (JSON-newline)
   ▼
UnrealMCPBridge C++ plugin  (inside UE Editor)
   │  UE Editor APIs
   ▼
Unreal Editor (UE 5.7 / 5.8)
```

A CLI variant (`ue-cli`, npm `unrealcli`) talks to the same plugin if MCP
isn't available — same commands, just `ue-cli spawn_actor ...` instead of
the MCP tool.

## Project setup (already done in this workspace)

- `C:\Users\Lauri\AppData\Local\Temp\opencode\JungleScene2\` is the UE project
- `Plugins\UnrealMCP\` installed (UnrealMCPBridge C++ plugin, compiled successfully on UE 5.8)
- `JungleScene2.uproject` enables `UnrealMCP` (TargetAllowList=Editor)
- OpenCode `opencode.json` registers `mcp.unreal` pointing to `unrealmcp.exe`
- `unrealmcp.exe` installed via pip at `C:\Users\Lauri\AppData\Local\Programs\Python\Python312\Scripts\unrealmcp.exe`

## Startup

The user starts the editor manually. Do NOT launch UnrealEditor.exe without
explicit permission.

1. User opens the project (`JungleScene2.uproject`) in UE 5.8.
2. UnrealMCPBridge plugin is enabled; starts TCP listener on `127.0.0.1:55557`.
3. OpenCode auto-launches the stdio MCP server (`unrealmcp.exe`) when the agent connects.
4. MCP server connects to plugin on port 55557.

## Verify the connection

```bash
# Plugin listening?
Test-NetConnection -ComputerName 127.0.0.1 -Port 55557

# Plugin responsive?
ue-cli health_check
```

## Tools (~280 across 13 categories)

- **Core**: `health_check`, `execute_python`
- **Asset Management** (16): `find_assets`, `list_assets`, `get_asset_info`, `get_asset_properties`, `set_asset_property`, `find_references`, `import_asset`, `import_assets_batch`, `duplicate_asset`, `rename_asset`, `delete_asset`, `save_asset`, `save_all`, `open_asset`, `sync_browser`, `get_selected_assets`
- **Blueprints** (22): `create_blueprint`, `compile_blueprint`, `read_blueprint_content`, `analyze_blueprint_graph`, `add_component_to_blueprint`, `add_event_node`, `connect_blueprint_nodes`, `delete_blueprint_node`, `set_blueprint_node_property`, variable/function CRUD, etc.
- **Materials** (35): `create_material`, `create_material_instance`, `build_material_graph` (atomic), `get_material_info`, `add/delete/move/duplicate_material_expression`, `connect_material_expressions`, `set_material_expression_property`, MI parameter get/set, validation/diagnostics
- **Data Tables** (8): full CRUD + schema introspection
- **Data Assets** (12): Mass Config trait editing (`get_mass_config_traits`, `add_mass_config_trait`, `set_mass_config_trait_property`, `remove_mass_config_trait`)
- **Actors & Level** (19): `spawn_actor`, `spawn_blueprint_actor`, `spawn_actor_from_class`, `get_actors_in_level`, `find_actors_by_name`, `get_actor_properties`, `set_actor_transform`, `delete_actor`, `get_selected_actors`, `get_world_info`, `take_screenshot`
- **Enhanced Input** (21): full UInputAction / UInputMappingContext CRUD
- **Widgets — UMG** (11): widget tree, add/move/rename, slot props
- **Niagara VFX** (96): systems, emitters, stack bindings (nested), scratch pad authoring, graph CRUD, DI member functions, source-menu discovery
- **StateTree** (33): states, tasks, evaluators, transitions, conditions, bindings
- **Performance Profiling** (3): record `.utrace` + smart analysis (`diagnose`, `spikes`, `flame`)
- **Debug** (2): token tracking, debug toggle

## Headless vs live

Most tools require the editor running (live plugin). The MCP server returns
`plugin_not_connected` errors gracefully when the editor is down.

## Reference

- Repo: <https://github.com/aadeshrao123/Unreal-MCP>
- pip: `unrealmcp` (v1.3.0)
- npm: `unrealcli` (CLI alternative)
- Installed plugin: `C:\Users\Lauri\AppData\Local\Temp\opencode\JungleScene2\Plugins\UnrealMCP\`
- MCP server: `C:\Users\Lauri\AppData\Local\Programs\Python\Python312\Scripts\unrealmcp.exe`
