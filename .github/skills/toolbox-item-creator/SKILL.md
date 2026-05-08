---
name: toolbox-item-creator
description: 'Guided prompt to generate a custom_ function or a Create-ToolboxListItem block for EnterpriseTechTool. Use when adding toolbox actions with admin gating, tooltip, and a matching entry in ETTConfig.json.'
argument-hint: 'Provide the tool name, description, tab, requires admin (yes/no), and the action script block.'
user-invocable: true
---

# Toolbox Item Creator

Create a new toolbox action for EnterpriseTechTool either as a `custom_` function or a `Create-ToolboxListItem` block, with admin gating, a tooltip, and a matching entry in `ETTConfig.json`.

## When to Use
- Adding a new toolbox button or list item
- Creating a `custom_` function for auto-discovery
- Keeping `ETTConfig.json` in sync with UI actions

## Inputs to Collect
- Display name
- Short description (tooltip)
- Tab name (existing or new)
- Requires admin (yes/no)
- Action logic (script block)
- Preferred approach: `custom_` function or `Create-ToolboxListItem`

## Procedure
1. **Clarify the approach**
   - If the action should be auto-discovered, choose a `custom_` function.
   - If it belongs in a specific toolbox list, use `Create-ToolboxListItem`.

2. **Draft the PowerShell implementation**
   - For a `custom_` function, name it with the `custom_` prefix.
   - For `Create-ToolboxListItem`, create the list item and add it to the correct tab array.
   - Add admin gating with `$adminmode` or elevation via `Start-Process -Verb RunAs`.

3. **Add a matching `ETTConfig.json` entry**
   - Create or update a `CustomFunctions` entry with:
     - `displayName`, `description`, `tab`, `requireAdmin`, `codeBlock`
   - Ensure the `codeBlock` matches the intended action logic.

4. **Add or verify tooltip text**
   - Ensure the description is concise and user-facing.

5. **Validate consistency**
   - Names match between UI label and `ETTConfig.json`.
   - Admin requirement is consistent across UI and config.
   - Script block is safe to run in non-admin mode when `requireAdmin` is false.

## Completion Checks
- The new action appears in the intended tab or auto-discovery list.
- Admin-only actions show the shield indicator and elevate correctly.
- `ETTConfig.json` contains the matching entry with required fields.
