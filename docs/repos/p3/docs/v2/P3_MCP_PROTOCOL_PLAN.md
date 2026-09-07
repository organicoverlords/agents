# P3 MCP and custom bridge protocol plan

This plan is part of regression-research #580. It distinguishes **source inventory** from **live protocol conformance** so an `initialize` response, an advertised version string, or an MCP-like method name cannot be promoted into a conformance claim.

The bounded executable inventory is:

```powershell
python scripts/v2/verification/p3_mcp_protocol_inventory.py --repo-root .
```

It reads exactly three known owners and makes no network calls.

## Surface classification

### UE 5.8 native MCP — Inspector/conformance target

`scripts/v2/verification/p3_native_mcp_client.py` currently targets the protocol version advertised by the installed native Unreal integration and uses sessionful HTTP with `Mcp-Session-Id`. This is the only current P3 Unreal surface that should be treated as MCP Inspector-eligible.

A source version string is not proof that the endpoint is current or conformant. Live proof must use the exact worker-owned UnrealEditor PID and its live native MCP endpoint. At that point, run the **current MCP Inspector/conformance suite available at proof time**, record the negotiated protocol version and deviations, and bind the evidence to that editor/process generation. #1634 owns the current native-L0 editor proof, so this document does not launch a second editor or compete for that endpoint.

### UE_MCP_Bridge — MCP-like subset on custom transport

`UE_MCP_Bridge` implements MCP-shaped JSON-RPC methods such as `initialize`, `tools/list`, and `tools/call`, and advertises a protocol version, but it also supports project-specific legacy/custom framing: length-prefixed TCP and newline-delimited JSON, plus the retained WebSocket transport. The repo-owned verifier client uses the length-prefixed legacy `{method, params}` envelope for current project features.

Therefore it must not be described as MCP-spec conformant merely because method names or a version string overlap MCP. Keep bounded repo contract tests for its framing and supported method subset. MCP Inspector becomes meaningful only if a standards-supported transport is deliberately provided. Until current runtime/user-path/visual consumers migrate, this bridge remains a compatibility surface rather than the primary typed-tool path.

### UnrealMCPBridge — custom command protocol, not MCP-spec transport

`UnrealMCPBridge` exposes a custom loopback newline-JSON command protocol and reports its own numeric protocol version. Treat that value as a plugin protocol revision, not an MCP specification version. MCP Inspector is not applicable to this transport.

#1621 owns the remaining project-index uniqueness benchmark. If that benchmark shows no unique product/runtime value, disable the bridge by default rather than extending its transport. If unique value remains, port that capability to the primary typed surface or document the narrow retained role.

## Closure rules

- Never infer conformance from source strings, `initialize` success, listener presence, or old receipts.
- Bind live native Inspector evidence to the exact owned editor PID/process generation and current project.
- Do not install or invoke Inspector merely to create a source-only proof when no owned native endpoint exists.
- Keep custom transport contract tests separate from MCP specification conformance claims.
- Re-run source inventory when any of the three exact protocol owners change.
- Record the protocol/spec version actually negotiated at live proof time rather than copying a remembered notion of “current MCP”.
