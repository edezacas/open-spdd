---
name: spdd-design
description: Split an existing SPDD canvas into one or more implementation plans (one or several is this skill's call), between spdd-canvas and spdd-implement. Delegated by spdd-agent or invoked manually via /spdd-design — does not auto-trigger on its own.
license: Apache-2.0
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "1.7"
---

## Instructions

### Step 1 — Locate the canvas

Use the given change folder or canvas path if provided. Otherwise list `spdd/changes/SPDD-*`, sorted by name, most recent first.

- None found → stop, tell the user to run `spdd-canvas` first.
- Multiple found, no argument given → ask which one.

### Step 2 — Check for existing plans

If `plans/` already exists for this change:

- Every plan `Status: Draft` → ask whether to regenerate or leave as-is.
- Any plan `Confirmed`, `Implemented`, or `Verified` → warn explicitly that regenerating discards progress. Proceed only on explicit confirmation, and only overwrite the plans named — never a blanket overwrite.

### Step 3 — Read the canvas

Read `canvas.md` in full.

### Step 4 — Find partition boundaries

Cross-reference Entities, Structure, and Operations: which Operations touch which Entities, which Structure paths belong to which module. A safe partition has non-overlapping Structure paths per group, except explicitly shared files.

### Step 5 — One plan or many

Default to one plan. Split only when groups are genuinely separable — not intrinsically sequential, not funneled through one shared module — **and** differ in Operation type or are meant for different agents/people.

Same Operation type applied homogeneously across files → one plan, one row per file, even without Structure overlap.

### Step 6 — Read the base template

Read [template-plan.md](assets/template-plan.md).

### Step 7 — Generate the plan(s)

> **Language note:** Write all new plan content (names, headings, prose) in English, regardless of the conversation's language.

For each group (or the single plan), fill the template and write to `spdd/changes/SPDD-slug/plans/plan-NN-<name>.md`. Keep `../canvas.md` as-is. Fill in:

- The Operations subset this plan owns.
- The Entities and Structure paths this plan owns.
- `Depends on:` and `Shared touchpoints:` per the template.

Do not duplicate Requirements, Norms, or Safeguards — they stay in `canvas.md`; `spdd-implement` reads both.

### Step 8 — Report

Show the plan breakdown (or why it stayed one plan), the dependency graph, and any `⚠️ Confirm:` lines — before implementation starts.
