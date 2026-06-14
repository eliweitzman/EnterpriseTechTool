## Enterprise Tech Tool — Copilot / AI Agent Guidance

This repository is a single Windows PowerShell application with a small set of supporting modules and GUI helpers. The notes below capture the essential patterns, workflows, and examples an AI coding agent should know to be productive.

### Big picture
- Primary entrypoint: `ETT.ps1` — loads `ETTConfig.json`, sets runtime flags, and dot-sources the helper scripts listed in `$Dependencies` (see the `$Dependencies` array in `ETT.ps1`).
- UI and features are defined by functions in `PSAssets/*.ps1` and `MiniClients/*.ps1` and then composed inside `ETT.ps1` (toolbox, tabs, and buttons).
- Packaging: authors use PS2EXE (see `Compiler/ps2exe.ps1`) to compile a portable EXE; runtime behavior differs when compiled vs running the raw PS1.

### Developer / runtime workflows (explicit)
- Dev run (recommended for iterative edits): open PowerShell and dot-source `.\ETT.ps1` (or run it). Note: dot-sourcing in a compiled build behaves differently; many UI helpers and dot-sourced modules are intended for script execution.
- Build / compile: `Compiler/ps2exe.ps1` (project uses PS2EXE). Ensure PS2EXE is available in the environment. If it is not installed, write an error message that includes the `Install-Module -Name ps2exe -Scope CurrentUser -Force` command and stop; do not attempt to install it automatically. The README also documents winget packaging and the `EliWeitzman.ETT` package id.
- Auto-update and releases: `ETT.ps1` checks GitHub tags (API) for release tags; offline devices will skip update checks.

### Project-specific conventions and patterns
- Custom functions intended for the GUI toolbox must be named with the `custom_` prefix to be auto-discovered (ETT loads functions and `Get-Command` filters for `custom_*`).
- Custom tools can also come from `ETTConfig.json` under `CustomFunctions`; each entry expects: `displayName`, `description`, `tab`, `requireAdmin`, and `codeBlock` (string containing the code to run). For config-driven custom functions, `requireAdmin` is handled by the framework/UI before `codeBlock` runs; do not duplicate the admin check in `codeBlock` unless the action intentionally executes in the current shell and must guard itself with `$adminmode`. For multiline scripts in `codeBlock`, replace newlines with semicolons and escape embedded double quotes as needed so the JSON string remains valid.
- GUI construction uses a small set of composable helpers. Common helpers to reuse/patch:
  - `Create-ETTButton` (ETT.ps1) — returns a WinForms Button wired to a ScriptBlock.
  - `Create-ToolboxListItem` — returns PSCustomObject used in toolbox lists.
  - `Create-ToolboxTabPage` — builds tabs and listboxes for toolbox items.
  - `Create-GenericToolWindow` (PSAssets/GenericToolWindow.ps1) — standard pattern for AD/BitLocker windows.
- Admin-aware flow: many actions check `$adminmode`. When adding a new admin action, choose exactly one pattern: (1) if the action can run in a separate elevated child process, use `Start-Process -Verb RunAs` and return; or (2) if the action must execute in the current shell, verify `$adminmode` as a boolean and fail fast with `if (-not $adminmode) { throw 'Admin elevation required.' }`. Do not combine both behaviors in one action. Assume privileged actions must be guarded and tested on Windows with UAC prompts.

### Integration points / external dependencies to be aware of
- RSAT / ActiveDirectory PowerShell module: many AD functions check `Get-Command -Name Get-ADComputer` and will disable GUI features if absent. When adding new AD or vendor features, wrap execution in a `Get-Command` or `Test-Path` check. If the feature is triggered by a GUI button, disable that UI action; if the feature runs in the background or during update logic, log a warning instead of assuming the dependency exists. Tests or CI must run on Windows with RSAT to exercise AD flows.
- Microsoft Graph (Get-MGContext / Connect-MgGraph) — used by Entra ID / BitLocker key retrieval in `MiniClients`. Guard Graph calls with `if ($null -eq (Get-MgContext)) { return }`, and if the session is not available, tell the user to run `Connect-MgGraph` instead of attempting automatic interactive sign-in.
- winget (Windows Package Manager) — used for app updates and referenced in README for install flow.
- Vendor CLIs (Dell/Lenovo command-line updaters) — code contains explicit checks for vendor-specific paths when invoking driver update logic. If the required vendor CLI is missing or its path does not exist, log a warning and disable the corresponding UI action instead of failing silently.

### Concrete editing examples (copy / paste friendly)
- Add a new toolbox action (place near other toolbox arrays in `ETT.ps1`):

  `# Example: add a quick diagnostic action`
  `[void]$ActionsTabArray.Add((Create-ToolboxListItem -DisplayName "Quick Disk Health" -RequireAdmin $true -ScriptBlock { Start-Process powershell.exe -Verb RunAs -ArgumentList '-Command', 'chkdsk C:' }))`

- Add a simple custom function (script scope) and let UI pick it up:

  `function custom_ShowHello { $wshell = New-Object -ComObject Wscript.Shell; $wshell.Popup('Hello from custom_ShowHello',0,'ETT',64) }`

- Add a config-driven custom function to `ETTConfig.json` (example entry):

  `{ "displayName": "Show Random", "description": "Show random number", "tab":"Custom", "requireAdmin": false, "codeBlock": "$rand=(Get-Random -Minimum 1 -Maximum 100); $wshell=New-Object -ComObject Wscript.Shell; $wshell.Popup($rand,0,'Random',64)" }`

  For multiline `codeBlock` scripts, replace newlines with semicolons and escape embedded double quotes so the JSON string stays valid.

### Observed gotchas / edge cases (experimentally verified)
- Dot-sourcing vs compiled EXE: dot-sourcing helper scripts (`. $psFile`) works for development but compiled EXE builds will often hit the `catch` and skip dot-sourced loads — verify behavior after compilation.
- Platform: Windows-only. Tests or automation must run on Windows with PowerShell and required modules installed.
- Admin flows: when an action must run in the current shell, guard it with `if (-not $adminmode) { throw 'Admin elevation required.' }`. Do not add a separate `Start-Process -Verb RunAs` path in the same function.
- Winget and GitHub API calls can fail on offline devices, due to network issues, or from rate limits. When changing update logic, wrap these calls in `try/catch`, log a warning, and return `$null` or `$false` without halting the app.

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
- `ETT.ps1` dot-sources `MiniClients/*.ps1` and `PSAssets/*.ps1` at runtime via `$Dependencies`. During compilation these dot-sources are wrapped in a try/catch, and the compiled EXE intentionally swallows those load errors so the GUI remains usable. After compiling:
  - Verify that the compiled EXE behaves as expected and that all UI modules are available.
  - Do not inline helper scripts into `ETT.ps1` unless the user explicitly asks for that structural change.
  - If dependencies fail to load in the compiled EXE, temporarily add logging to the existing `catch` block for diagnosis only, such as `catch { $_.Exception.Message | Out-File .\compile-debug.log -Append; return }`, and keep the fix limited to diagnostics without re-throwing the error.

Quick verification checklist after building
- Tell the user to run the compiled EXE on a Windows test machine.
- Tell the user to confirm that the app window appears and that basic buttons (Clear Last Login, Get LAPS Password) open their windows.
- Tell the user to test one admin and one non-admin flow (for example, Start-WingetAppUpdates and Get-WindowsActivationKey) to confirm elevation behavior and UAC prompts.
- Tell the user to check BitLocker and AD windows on a machine with RSAT / Microsoft Graph available to ensure those paths work.

If anything fails, the two fastest remedies are:
- Re-run as a script (`.\ETT.ps1`) to get full error output (dot-sourcing provides easier debugging).
- Temporarily add verbose/logging output around the `$Dependencies` dot-source loop to confirm whether each helper file is loaded inside the EXE.

Use these notes as the default operational guidance. When the user prompt specifically asks for examples, output only the requested examples (for example, a new toolbox item, a `CustomFunction` entry, or a smoke-test script) and keep the implementation focused on that task.

