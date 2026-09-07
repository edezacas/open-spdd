---
name: spdd-implement
description: Implement a feature from an spdd-design plan — never directly from the canvas's Operations; checks unresolved items and dependencies, and updates the canvas or plan on divergence. Delegated by spdd-agent or invoked manually via /spdd-implement — does not auto-trigger on its own.
license: Apache-2.0
compatibility: Works with any agent. Step 5 (SPDD hook and subagent cache TTL setup) requires Claude Code.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "2.8"
---

## Instructions

### Step 0 — Output language

Write all generated/modified document content (canvas or plan notes, discrepancy annotations) in English, regardless of the conversation's language.

### Step 1 — Locate the change and plan

Use the given change folder or plan path if provided. Otherwise list `spdd/changes/SPDD-*`, sorted by name, most recent first.

- None found → stop, tell the user to run `spdd-canvas` first.
- Multiple found, no argument given → ask which one.

Then check for a `plans/` folder in the chosen change:

- Exists → ask (or accept as an argument) which plan to implement.
- Doesn't exist → stop, tell the user to run `spdd-design` first. `spdd-implement` always implements from a plan, never directly from the canvas's Operations.

### Step 2 — Read the canvas and plan

Read `canvas.md` in full (Requirements, Norms, and Safeguards apply to every plan) and the chosen plan in full — it scopes which Operations, Entities, and Structure paths to touch.

### Step 3 — Check dependencies

Plan declares `Depends on:` other than `none` → check those plans' status. Any not at least `Status: Implemented` → warn explicitly and ask for confirmation before continuing. Implementing out of order can be deliberate, but never silent.

### Step 4 — Check for unresolved items

Any `⚠️ Confirm:` lines in the canvas or plan → stop, list them, ask the user to confirm each, replace with the confirmed value.

Then set `**Status:** Confirmed` in the canvas (and plan, if any) header.

### Step 5 — Ensure the SPDD hook and subagent cache TTL are present *(Claude Code only)*

> Skip this step if not running as Claude Code.

Grep `.claude/settings.local.json` for `SPDD` and for `"subagentPromptCacheTtl"`. For whichever is missing:

- Ask the user whether to add it (one combined `AskUserQuestion` if both are missing).
- If confirmed, read [hook-setup.md](assets/hook-setup.md) for the exact JSON and merge it in.

### Step 6 — Implement

Follow the plan's Operations in order, respecting Norms. Canvas or plan wrong or incomplete → stop, explain the divergence, propose the update, resume once confirmed.

### Step 7 — Run tests

Detect and run the project's test suite. Fix failures before continuing.

### Step 8 — Mark as implemented

Set `**Status:** Implemented` in the plan's header, add `> Implemented: YYYY-MM-DD` below it — the status Step 3's dependency check looks for.

### Step 9 — Report

List files created or modified, canvas/plan sections updated, and the test results summary. Suggest `/spdd-verify` on this same plan next.
