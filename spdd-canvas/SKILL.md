---
name: spdd-canvas
description: Generate a REASONS canvas for a new feature and save it to spdd/changes/. Use BEFORE writing code. Invoked manually via /spdd-canvas, or delegated by spdd-agent as the first phase of its automated flow — does not auto-trigger on its own.
license: Apache-2.0
compatibility: Works with any agent. Step 10 (SPDD hook installation) requires Claude Code.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "2.0"
---

## Today's date and time

Run `date +%Y-%m-%d-%H%M` to get today's date and time. If you cannot run commands, use today's date and time from your context.

## Instructions

Generate a REASONS canvas for the feature the user described.

Follow these steps in order:

### Step 1 — Guard: require a feature description

If no feature description was provided, ask the user for a brief description before continuing.

### Step 2 — Applicability guard

If the description reads as a trivial change (typo, config tweak, single obvious line) or as an open-ended exploratory spike with no fixed shape yet, ask in one line whether the user wants the full canvas or would rather skip it and go straight to editing. If they skip it, stop here — do not generate a canvas.

### Step 3 — Detect output language

Use the language detected from the user for all document content.

### Step 4 — Read the base template

Read [template-reasons.md](assets/template-reasons.md).

### Step 5 — Understand the project

If the stack and conventions are not clear from the project context, inspect the project structure before generating the canvas.

### Step 6 — Context and risk

Do both of the following before filling the canvas:

- **Read the living spec.** Infer the domain from the project's folder conventions (e.g. `src/billing/` → `billing`) and read `spdd/specs/<domain>.md` if it exists. If the domain can't be inferred with confidence, use `spdd/specs/general.md` as a fallback and say so in the final report. Use whatever is found to avoid contradicting current system behavior, and to mark explicitly which parts of the canvas are new requirements versus changes to something already spec'd.
- **Identify risk and ambiguity.** Actively look for ambiguous domain concepts, unclear boundaries, and risky assumptions in the feature description — don't wait for them to surface incidentally while filling the template. Feed what you find into the `⚠️ Confirm:` lines and the Safeguards section.

### Step 7 — Determine layers

Only ask about layers if the feature description explicitly mentions two separate concerns (e.g. "backend + frontend", "API + CLI"). If so, ask: one canvas per layer or a single unified canvas?

### Step 8 — Generate a filled canvas

Fill the template with real, project-specific content. Use actual file paths, the project's real model layer, and concrete operations — no generic placeholders.

Write Acceptance Criteria and Safeguards edge cases as `WHEN/THEN` scenarios (see the template), not freeform checkboxes — each scenario should be concrete enough to become a test.

Mark any decision that requires user input with `⚠️ Confirm:` and propose a sensible default.

### Step 9 — Save the file

Save to `spdd/changes/SPDD-YYYY-MM-DD-HHMM-slug/canvas.md` (kebab-case slug, today's date and time). Create the directory if needed.

### Step 10 — Ensure the SPDD hook is present *(Claude Code only)*

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
      "command": "unresolved=$(grep -rl '⚠️ Confirm:' spdd/changes/*/canvas.md spdd/changes/*/plans/*.md 2>/dev/null); if [ -n \"$unresolved\" ]; then echo \"SPDD WARNING: unresolved canvas/plan items in: $unresolved — review before editing code.\"; fi"
    }
  ]
}
```

### Step 11 — Report back

Show the saved file path, a 3-bullet summary, and all `⚠️ Confirm:` lines the user must resolve before implementing.

Suggest running `/spdd-design` as the next step — `spdd-implement` requires a plan to exist and never implements directly from the canvas.
