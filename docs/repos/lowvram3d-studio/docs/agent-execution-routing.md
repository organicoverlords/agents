# LowVRAM execution surfaces

General tool, provider, client, and failover routing comes from the canonical agent rules and the LowVRAM context. This repository does not select AI coding providers or maintain a second routing policy.

## Frozen production path

TRELLIS generation, diagnosis, retry, and cleanup use the current frozen production package named by the LowVRAM context and its current `production/README.md`, freeze manifest, and canonical launch scripts. Do not reconstruct production commands from old branches, build folders, or remembered flags.

## Unreal MCP vs commandlet

- **MCP = live Unreal truth/control:** current editor/world/actor state, PIE, gameplay/runtime behavior, viewport proof, or mutation of an owned live editor.
- **Commandlet = headless deterministic Unreal batch work:** import, validation, package/asset processing, or scripted publish work that does not require live PIE/viewport truth.
- A successful commandlet does not prove gameplay or live visual behavior.
- TRELLIS/Blender production is neither MCP nor an Unreal commandlet unless the stage actually enters Unreal.
- Current repo production/bridge files override stale memory, remembered ports, old commandlets, and old launcher recipes.

## KONE and proof boundary

Never execute fork or untrusted-PR code on KONE. Never use privileged self-hosted execution for untrusted code. Preserve the frozen production/runtime contracts and require direct runtime or visual evidence for runtime/visual claims.

UnrealOpenCode is not a LowVRAM execution surface. Do not connect to or control Unreal through remembered plugin ports or user-global OpenCode configuration.
