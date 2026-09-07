---
name: spdd-canvas
description: Generate a REASONS canvas for a new feature before any code is written, saved to spdd/changes/. Delegated by spdd-agent or invoked manually via /spdd-canvas — does not auto-trigger on its own.
license: Apache-2.0
compatibility: Works with any agent. Step 9 (SPDD hook and subagent cache TTL setup) requires Claude Code.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "2.12"
---

## Today's date and time

Run `date +%Y-%m-%d-%H%M`. If you can't run commands, use today's date and time from context.

## Instructions

Generate a REASONS canvas for the feature described. Follow these steps in order.

### Step 1 — Require a feature description

No description given → ask the user for a brief one before continuing.

### Step 2 — Applicability guard

Description reads as a trivial change (typo, config tweak, single obvious line) or an open-ended spike with no fixed shape yet → ask in one line: full canvas, or skip straight to editing? Skip chosen → stop, no canvas.

### Step 3 — Read the base template

Read [template-reasons.md](assets/template-reasons.md) — its header fixes English as the language of all document content.

### Step 4 — Understand the project

Stack and conventions unclear from project context → inspect the project structure before generating the canvas.

### Step 5 — Context: freshness, spec, norms, and risk

Before filling the canvas:

1. Infer the domain from folder conventions (e.g. `src/billing/` → `billing`).
2. **Freshness check.** `spdd/specs/<domain>.md` exists → check it hasn't fallen behind code changes made outside the SPDD flow:
   ```bash
   spec_date=$(git log -1 --format=%cI -- spdd/specs/<domain>.md)
   git log --format='%h %cI %s' --since="$spec_date" -- <domain-folder>/
   ```
   - Either command fails (not a git repo, no matching folder) → skip this check silently.
   - Second command returns commits, foreground → stop, ask via `AskUserQuestion`: "Run spdd-sync first" (invoke it, then continue) or "Continue anyway" (proceed at risk, note staleness in the final report). Don't generate the canvas until decided.
   - Second command returns commits, background (no `AskUserQuestion`) → don't stop: continue, add `⚠️ Confirm: spec stale — last sync <date>, <n> commits since` for the orchestrator's checkpoint.
3. **Read the living spec.** `spdd/specs/<domain>.md` if it exists; fall back to `spdd/specs/general.md` when the domain can't be inferred with confidence, and say so in the final report. Use it to avoid contradicting current behavior, and to mark which parts of the canvas are new versus changes to something already spec'd.
4. **Read global norms.** `spdd/norms.md` (project root) if it exists — see [template-norms.md](assets/template-norms.md) for its shape. Carry it over as starting Norms/Safeguards, marked as coming from `spdd/norms.md`. Never create or edit this file — team-maintained, read-only here.
5. **Identify risk and ambiguity.** Actively look for ambiguous domain concepts, unclear boundaries, and risky assumptions — don't wait for them to surface while filling the template. Feed what's found into `⚠️ Confirm:` lines and Safeguards.

### Step 6 — Determine layers

Only ask about layers if the description explicitly names two separate concerns (e.g. "backend + frontend", "API + CLI"): one canvas per layer, or a single unified canvas? Background (no `AskUserQuestion`) → default to a single unified canvas, add `⚠️ Confirm: layers — the description mentions separate concerns; confirm whether one canvas per layer is wanted`.

### Step 7 — Generate a filled canvas

Fill the template with real, project-specific content — actual file paths, the project's real model layer, concrete operations, no generic placeholders.

Write Acceptance Criteria and Safeguards edge cases as `WHEN/THEN` scenarios (see the template), not freeform checkboxes — each scenario concrete enough to become a test.

Mark any decision needing user input with `⚠️ Confirm:` and propose a sensible default.

### Step 8 — Save the file

Save to `spdd/changes/SPDD-YYYY-MM-DD-HHMM-slug/canvas.md` (kebab-case slug, today's date and time). Create the directory if needed.

### Step 9 — Ensure the SPDD hook and subagent cache TTL are present *(Claude Code only)*

> Skip this step if not running as Claude Code.

Grep `.claude/settings.local.json` for `SPDD` and for `"subagentPromptCacheTtl"`. For whichever is missing:

- Ask the user whether to add it (one combined `AskUserQuestion` if both are missing).
- If confirmed, read [hook-setup.md](assets/hook-setup.md) for the exact JSON and merge it in.

### Step 10 — Report back

Show the saved file path, a 3-bullet summary, and all `⚠️ Confirm:` lines to resolve before implementing.

Suggest `/spdd-design` as the next step.
