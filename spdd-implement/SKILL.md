---
name: spdd-implement
description: Implement a feature from its SPDD canvas. Reads the canvas, checks for unresolved items, implements step by step, and updates the canvas if anything diverges during development. Use when the user wants to start coding a feature that has a SPDD canvas.
license: Apache-2.0
compatibility: Works with any agent. Step 4 (SPDD hook installation) requires Claude Code.
metadata:
  author: edezacas
  version: "1.0"
---

## Instructions

### Step 0 — Detect output language

Use the language detected from the user for all document content.

### Step 1 — Locate the canvas

If a canvas filename was provided, use that file. Otherwise, list recent canvases:

List the files in `docs/prompts/` matching `SPDD-*.md`, sorted by date (most recent first).

If empty, stop and tell the user to run the `spdd-canvas` skill first. If multiple exist and no argument was given, ask which one to use.

### Step 2 — Read the canvas

Read the canvas file in full.

### Step 3 — Check for unresolved items

If any `⚠️ Confirm:` lines exist: stop, list them, and ask the user to confirm each one. Replace each with the confirmed value.

Then set `**Status:** Confirmed` in the canvas header before proceeding.

### Step 4 — Ensure the SPDD hook is present *(Claude Code only)*

> Skip this step if you are not running as Claude Code.

Check whether `.claude/settings.local.json` already contains the SPDD guard hook:

```bash
grep -q 'SPDD' .claude/settings.local.json 2>/dev/null && echo "exists" || echo "missing"
```

If **missing**, ask the user whether to add it. If confirmed, merge the following into `hooks.PreToolUse` (create the key if absent) and write back to `.claude/settings.local.json`:

```json
{
  "matcher": "Edit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "unresolved=$(grep -rl '⚠️ Confirm:' docs/prompts/SPDD-*.md 2>/dev/null); if [ -n \"$unresolved\" ]; then echo \"SPDD WARNING: unresolved canvas items in: $unresolved — review before editing code.\"; fi"
    }
  ]
}
```

### Step 5 — Implement

Follow the canvas sections in order. If you discover the canvas is wrong or incomplete: stop, explain the divergence, propose the canvas update, and resume once the user confirms.

### Step 6 — Run tests

Detect and run the project's test suite. If tests fail, fix the issues before continuing.

### Step 7 — Generate feature documentation

Save a feature doc to `docs/features/SLUG.md` (same slug as the canvas, no date prefix). Create the directory if needed.

Write it so anyone on the team can use it — developer, product owner, technical writer, or someone preparing a demo or user manual. Structure it in this order:

- **What it does** — one paragraph, plain language, no technical jargon
- **Business rules** — the logic and constraints that govern this feature
- **Flows** — step-by-step description of how the feature works: user interactions if it's UI-facing, or system behavior if it's a background job, webhook, integration, etc.
- **How it connects** — which other features, entities, or services it interacts with
- **Technical notes** — key files with a one-line description each, and implementation decisions worth preserving

The first three sections should be readable by anyone. The last two are for developers.

### Step 8 — Mark the canvas as implemented

Set `**Status:** Implemented` in the header and add `> Implemented: YYYY-MM-DD` below it.

### Step 9 — Report

List all files created or modified, any canvas sections updated, the test results summary, and the path to the generated feature doc.
