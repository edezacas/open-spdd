---
name: spdd-implement
description: Implement a feature from a plan produced by spdd-design. Never implements directly from the canvas's Operations. Reads the canvas and the chosen plan, checks for unresolved items and unmet dependencies, implements step by step, and updates the canvas or plan if anything diverges during development. Invoked manually via /spdd-implement, or delegated by spdd-agent — does not auto-trigger on its own.
license: Apache-2.0
compatibility: Works with any agent. Step 5 (SPDD hook and subagent cache TTL setup) requires Claude Code.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "2.4"
---

## Instructions

### Step 0 — Output language

Write all document content generated or modified during implementation (canvas or plan notes, discrepancy annotations, etc.) in English, regardless of the user's conversation language.

### Step 1 — Locate the change and plan

If a change folder or plan path was provided, use that. Otherwise, list recent changes:

List the directories in `spdd/changes/` matching `SPDD-*`, sorted by name (most recent first).

If empty, stop and tell the user to run the `spdd-canvas` skill first. If multiple exist and no argument was given, ask which one to use.

Then check for a `plans/` folder inside the chosen change:
- If it exists, ask (or accept as an argument) which plan to implement.
- If it doesn't exist, stop and tell the user to run the `spdd-design` skill first — `spdd-implement` always implements from a plan, never directly from the canvas's Operations.

### Step 2 — Read the canvas and plan

Read `canvas.md` in full (Requirements, Norms, and Safeguards apply regardless of which plan is being implemented) and read the chosen plan in full — it scopes which Operations, Entities, and Structure paths to touch.

### Step 3 — Check dependencies

If the plan being implemented declares `Depends on:` other than `none`, check the status of those plans. If any of them is not at least `Status: Implemented`, warn the user explicitly and ask for confirmation before continuing — implementing out of order may be a deliberate choice, but it must never happen silently.

### Step 4 — Check for unresolved items

If any `⚠️ Confirm:` lines exist in the canvas or the chosen plan: stop, list them, and ask the user to confirm each one. Replace each with the confirmed value.

Then set `**Status:** Confirmed` in the canvas (and plan, if any) header before proceeding.

### Step 5 — Ensure the SPDD hook and subagent cache TTL are present *(Claude Code only)*

> Skip this step if you are not running as Claude Code.

Check whether `.claude/settings.local.json` already contains the SPDD guard hook and the subagent cache TTL setting:

```bash
grep -q 'SPDD' .claude/settings.local.json 2>/dev/null && echo "hook: exists" || echo "hook: missing"
grep -q '"subagentPromptCacheTtl"' .claude/settings.local.json 2>/dev/null && echo "ttl: exists" || echo "ttl: missing"
```

For whichever is **missing**, ask the user whether to add it (one combined `AskUserQuestion` if both are missing). If confirmed, read [hook-setup.md](assets/hook-setup.md) for the exact JSON and merge it into `.claude/settings.local.json`.

### Step 6 — Implement

Follow the Operations in scope (from the plan) in order, respecting Norms. If you discover the canvas or plan is wrong or incomplete: stop, explain the divergence, propose the update, and resume once the user confirms.

### Step 7 — Run tests

Detect and run the project's test suite. If tests fail, fix the issues before continuing.

### Step 8 — Mark as implemented

Set `**Status:** Implemented` in the header of the plan just implemented and add `> Implemented: YYYY-MM-DD` below it. This is the status other plans' dependency checks (Step 3) look for.

### Step 9 — Report

List all files created or modified, any canvas/plan sections updated, and the test results summary. Suggest running `/spdd-verify` on this same plan as the closing step.
