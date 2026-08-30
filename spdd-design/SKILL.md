---
name: spdd-design
description: Split an existing SPDD canvas into one or more independent implementation plans, run after spdd-canvas and before spdd-implement, which requires a plan to exist. Deciding whether the work needs one plan or several is part of this skill. Invoked manually via /spdd-design, or delegated by spdd-agent — does not auto-trigger on its own.
license: Apache-2.0
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "1.1"
---

## Instructions

### Step 1 — Locate the canvas

If a change folder or canvas path was provided, use that. Otherwise, list recent changes:

List the directories in `spdd/changes/` matching `SPDD-*`, sorted by name (most recent first).

If empty, stop and tell the user to run `spdd-canvas` first. If multiple exist and no argument was given, ask which one to use.

### Step 2 — Check for existing plans

If a `plans/` folder already exists for this change, do not regenerate it silently:

- If every existing plan is still `Status: Draft`, it's safe to ask the user whether to regenerate (overwrite) or leave them as-is.
- If any existing plan is `Confirmed`, `Implemented`, or `Verified`, stop and warn explicitly — regenerating now would discard that progress. Only proceed if the user explicitly confirms, and even then only overwrite the specific plans they name, never a blanket overwrite of plans with real progress.

### Step 3 — Read the canvas

Read `canvas.md` in the change folder in full.

### Step 4 — Analyze for partition boundaries

Look at Entities, Structure, and Operations together to find natural boundaries: which Operations depend on which Entities, and which Structure paths belong to which module. A safe partition is one where each group's Structure paths don't overlap with another group's, except for explicitly shared files.

### Step 5 — Decide: one plan or many

**Do not force a split.** If the work is intrinsically sequential (later steps depend on earlier ones touching the same core files) or everything funnels through one shared module, emit a single plan covering the whole canvas. Only split when the groups found in Step 4 are genuinely separable.

### Step 6 — Read the base template

Read [template-plan.md](assets/template-plan.md).

### Step 7 — Generate the plan(s)

> **Language note:** The plan content you generate (plan names, section headings, all prose in Operations/Entities/Structure descriptions, and any notes you add) must be in English, regardless of the language of the canvas you read or the user's conversation language. The canvas is already in English as of this version; maintain that English-only rule in any new content you write.

For each group (or the single plan), fill the template read in Step 6 and write it to `spdd/changes/SPDD-slug/plans/plan-NN-<name>.md`. Keep the template's `../canvas.md` link as-is — it's a valid relative path from any `plans/` folder — and fill in:

- The subset of Operations that belong to this plan.
- The Entities and Structure paths this plan owns.
- `Depends on:` — the ids of other plans this one requires to be done first, or `none`. Never assume independence without checking; if a dependency is genuinely uncertain, write `⚠️ Confirm:` next to it instead of guessing.
- `Shared touchpoints:` — any file that this plan and at least one other plan both need to touch (e.g. a central router, a providers registry). List it even if the rest of the plan is fully independent, so whoever implements it knows a conflict is possible there.

Do not duplicate Requirements, Norms, or Safeguards in each plan — those stay in the parent `canvas.md` and `spdd-implement` reads both.

### Step 8 — Report

Show the plan breakdown (or the decision to keep it as one plan and why), the dependency graph between plans, and any `⚠️ Confirm:` lines, before any implementation starts.
