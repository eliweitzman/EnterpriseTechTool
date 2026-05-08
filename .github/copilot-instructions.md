## Enterprise Tech Tool — Copilot / AI Agent Guidance

This repository is a single Windows PowerShell application with a small set of supporting modules and GUI helpers. The notes below capture the essential patterns, workflows, and examples an AI coding agent should know to be productive.

### Big picture
- Primary entrypoint: `ETT.ps1` — loads `ETTConfig.json`, sets runtime flags, and dot-sources the helper scripts listed in `$Dependencies` (see the `$Dependencies` array in `ETT.ps1`).
- UI and features are defined by functions in `PSAssets/*.ps1` and `MiniClients/*.ps1` and then composed inside `ETT.ps1` (toolbox, tabs, and buttons).
- Packaging: authors use PS2EXE (see `Compiler/ps2exe.ps1`) to compile a portable EXE; runtime behavior differs when compiled vs running the raw PS1.

### Developer / runtime workflows (explicit)
- Dev run (recommended for iterative edits): open PowerShell and dot-source `.\ETT.ps1` (or run it). Note: dot-sourcing in a compiled build behaves differently; many UI helpers and dot-sourced modules are intended for script execution.
- Build / compile: `Compiler/ps2exe.ps1` (project uses PS2EXE). Ensure PS2EXE is available in the environment. The README also documents winget packaging and the `EliWeitzman.ETT` package id.
- Auto-update and releases: `ETT.ps1` checks GitHub tags (API) for release tags; offline devices will skip update checks.

### Project-specific conventions and patterns
- Custom functions intended for the GUI toolbox must be named with the `custom_` prefix to be auto-discovered (ETT loads functions and `Get-Command` filters for `custom_*`).
- Custom tools can also come from `ETTConfig.json` under `CustomFunctions`; each entry expects: `displayName`, `description`, `tab`, `requireAdmin`, and `codeBlock` (string containing the code to run).
- GUI construction uses a small set of composable helpers. Common helpers to reuse/patch:
  - `Create-ETTButton` (ETT.ps1) — returns a WinForms Button wired to a ScriptBlock.
  - `Create-ToolboxListItem` — returns PSCustomObject used in toolbox lists.
  - `Create-ToolboxTabPage` — builds tabs and listboxes for toolbox items.
  - `Create-GenericToolWindow` (PSAssets/GenericToolWindow.ps1) — standard pattern for AD/BitLocker windows.
- Admin-aware flow: many actions check `$adminmode` and either run logic inline or call `Start-Process -Verb RunAs` to elevate. Assume privileged actions must be guarded and tested on Windows with UAC prompts.

### Integration points / external dependencies to be aware of
- RSAT / ActiveDirectory PowerShell module: many AD functions check `Get-Command -Name Get-ADComputer` and will disable GUI features if absent. Tests or CI must run on Windows with RSAT to exercise AD flows.
- Microsoft Graph (Get-MGContext / Connect-MgGraph) — used by Entra ID / BitLocker key retrieval in `MiniClients`.
- winget (Windows Package Manager) — used for app updates and referenced in README for install flow.
- Vendor CLIs (Dell/Lenovo command-line updaters) — code contains explicit checks for vendor-specific paths when invoking driver update logic.

### Concrete editing examples (copy / paste friendly)
- Add a new toolbox action (place near other toolbox arrays in `ETT.ps1`):

  `# Example: add a quick diagnostic action`
  `[void]$ActionsTabArray.Add((Create-ToolboxListItem -DisplayName "Quick Disk Health" -RequireAdmin $true -ScriptBlock { Start-Process powershell.exe -Verb RunAs -ArgumentList '-Command', 'chkdsk C:' }))`

- Add a simple custom function (script scope) and let UI pick it up:

  `function custom_ShowHello { $wshell = New-Object -ComObject Wscript.Shell; $wshell.Popup('Hello from custom_ShowHello',0,'ETT',64) }`

- Add a config-driven custom function to `ETTConfig.json` (example entry):

  `{ "displayName": "Show Random", "description": "Show random number", "tab":"Custom", "requireAdmin": false, "codeBlock": "$rand=(Get-Random -Minimum 1 -Maximum 100); $wshell=New-Object -ComObject Wscript.Shell; $wshell.Popup($rand,0,'Random',64)" }

### Observed gotchas / edge cases (experimentally verified)
- Dot-sourcing vs compiled EXE: dot-sourcing helper scripts (`. $psFile`) works for development but compiled EXE builds will often hit the `catch` and skip dot-sourced loads — verify behavior after compilation.
- Platform: Windows-only. Tests or automation must run on Windows with PowerShell and required modules installed.
- Admin flows: UI shows a shield emoji for tools that require admin; ensure scripts that perform registry or BitLocker changes always verify `$adminmode`.
- Winget and GitHub API calls can fail on offline devices — code already catches and degrades, but changes to update logic should keep that in mind.

### Files and locations you will reference most
- `ETT.ps1` — main app orchestration (load order, flags, `$Dependencies`).
- `ETTConfig.json` — runtime customization (brand color, AutoUpdateCheckerEnabled, CustomFunctions, Azure IDs).
- `PSAssets/ToolboxFunctions.ps1` — primary toolbox helper functions and many action implementations.
- `PSAssets/GenericToolWindow.ps1` — reusable GUI window builder (used by BitLocker and AD tools).
- `MiniClients/*.ps1` — small utilities (ADLookup, BitLocker, LAPS, etc.) used by toolbox tabs.
- `Compiler/ps2exe.ps1` — compile helper and intended packaging flow.

### How to compile (PS2EXE) — quick recipe

Summary: this project is typically distributed as a compiled EXE (PS2EXE). Development is easiest by dot-sourcing `ETT.ps1`. Use PS2EXE to build an EXE for portable or installer-based distribution.

1) Install PS2EXE (optional if you already have `Compiler/ps2exe.ps1`):

```powershell
# Install the community PS2EXE module (if needed)
Install-Module -Name ps2exe -Scope CurrentUser -Force
```

2) Basic compile (recommended starting command):

```powershell
# From the repository root
# Uses the community ps2exe wrapper if installed; otherwise run the repo's Compiler/ps2exe.ps1 script similarly
Invoke-ps2exe -inputFile .\ETT.ps1 -outputFile .\dist\ETT.exe -iconFile .\ImageAssets\EnterpriseTechTool.ico -noConsole -x64
```

If you prefer to call the included script directly (it may wrap options differently):

```powershell
& '.\Compiler\ps2exe.ps1' -InputFile '.\ETT.ps1' -OutputFile '.\dist\ETT.exe' -x64
```

Notes and recommended options
- Use `-x64` for 64-bit builds (recommended). The GUI and some MiniClients note "MUST COMPILE WITH x64".
- `-noConsole` removes the console window and produces a GUI-only EXE.
- Provide an `-iconFile` to brand the EXE; put an .ico in `ImageAssets/` and reference it.

Dot-sourcing and embedding caveat
- `ETT.ps1` dot-sources `MiniClients/*.ps1` and `PSAssets/*.ps1` at runtime via `$Dependencies`. During compilation these dot-sources are wrapped in a try/catch (the code intentionally swallows errors for compiled mode). After compiling:
  - Verify that the compiled EXE behaves as expected and that all UI modules are available.
  - If a helper script is not embedding or running, either: embed its contents into `ETT.ps1` before compiling, or adjust the compile wrapper to include additional files (some ps2exe versions support an `-include` parameter).

Quick verification checklist after building
- Run the compiled EXE on a Windows test machine.
- Confirm the app window appears and basic buttons (Clear Last Login, Get LAPS Password) open their windows.
- Test one admin and one non-admin flow (e.g., Start-WingetAppUpdates and Get-WindowsActivationKey) to confirm elevation behavior and UAC prompts.
- Check BitLocker and AD windows on a machine with RSAT / Microsoft Graph available to ensure those paths work.

If anything fails, the two fastest remedies are:
- Re-run as a script (`.\ETT.ps1`) to get full error output (dot-sourcing provides easier debugging).
- Temporarily add verbose/logging output around the `$Dependencies` dot-source loop to confirm whether each helper file is loaded inside the EXE.

If any of these sections are unclear or you'd like the file to be extended with examples for a specific task (e.g., add a new toolbox item, wire a new CustomFunction from JSON, or create a test harness), tell me which area to expand and I will iterate.

---
Please review these notes and tell me if you want additional examples (unit/test harness, or a short script to run local smoke-tests for common flows like: load UI, call a non-admin action, and call an admin action with elevation). 
