# Agent capabilities registry

Registry of proven machine methods, not policy prose.

- Global operating contract: `AGENTS.md`
- Live production work: `docs/production-lanes.yaml`

## Capability discovery rule

```
proven registry
→ quick general web/Google search for FREE + FAST existing solution
→ official/current open-source/built-in solution
→ existing local/native APIs/tools
→ introspect API instead of guessing
→ minimal custom implementation only as last resort
→ prove on real task
→ record capability once
```

Search is brief and action-oriented, not a research essay.

## Capabilities

### WINDOW_CAPTURE=PROVEN

- helper: `scripts/windows/capture-window.ps1`
- Windows PowerShell 5.1
- exact HWND/project targeting
- multi-monitor
- produced PNG must be model-inspectable
- read-only capture allowed for unknown/user-owned editors

### UE_GUI_OBSERVABILITY=PROVEN

- capture + inspect before GUI mutation
- capture again whenever GUI state matters
- final capture + inspect for visual acceptance

### UE_PROJECT_LAUNCH

- canonical launcher: `scripts/windows/start-p3-agent-editor.ps1`
- preserve the exact `.uproject` argument boundary
- prefer `.NET ProcessStartInfo.ArgumentList`; do NOT use unsafe
  `Start-Process -ArgumentList` joining for paths containing spaces
- Project Browser / Select Project = failed project launch, never a loading state
- Restore Packages prompt = immediate automation failure, not a user prompt

### UE_COMMANDLET=PROVEN

- tracked commandlet wrapper: `scripts/windows/run-p3-commandlet.ps1`
- per-process MCP autostart disabled

### ENHANCED_INPUT_INJECTION=PROVEN

- current PIE PlayerController → LocalPlayer → subsystem

### TRELLIS_PRODUCTION_RUNTIME=PROVEN

- exe: `C:\AI\trellis-cpp\build-tu116-126-mmq\Release\trellis-cli.exe`
- SHA-256: `3b61e8767ec96f202ef257768e36e2db26305d5e9428c4f0511a0b10e109ca4a`
- with co-located `ggml-cuda.dll`
- SHA-256: `7674e79da47afba961f5b611d9506d5d928bb3e36ec1430199d307e862661b0e`
- EXE + co-located DLLs are one runtime package; never swap halves

New entries are added only after being proven on a real task.