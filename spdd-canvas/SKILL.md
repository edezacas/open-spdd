---
name: spdd-canvas
description: Generate a REASONS canvas for a new feature before any code is written, saved to spdd/changes/. Delegated by spdd-agent or invoked manually via /spdd-canvas — does not auto-trigger on its own.
license: Apache-2.0
compatibility: Works with any agent. Step 9 (SPDD hook and subagent cache TTL setup) requires Claude Code.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "2.9"
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

### Step 3 — Read the base template

Read [template-reasons.md](assets/template-reasons.md) — its header note fixes English as the language of all document content.

### Step 4 — Understand the project

If the stack and conventions are not clear from the project context, inspect the project structure before generating the canvas.

### Step 5 — Context: freshness, spec, norms, and risk

Before filling the canvas:

1. Infer the domain from folder conventions (e.g. `src/billing/` → `billing`).
2. **Freshness check.** If `spdd/specs/<domain>.md` exists, check whether it has fallen behind code changes made outside the SPDD flow (e.g. a manual refactor that skipped `spdd-sync`) — get its last commit date and any domain commits since then:
   ```bash
   spec_date=$(git log -1 --format=%cI -- spdd/specs/<domain>.md)
   git log --format='%h %cI %s' --since="$spec_date" -- <domain-folder>/
   ```
   If either command fails (not a git repo, no matching folder), skip this check silently. If the second returns commits: in the foreground, stop and ask via `AskUserQuestion` — "Run spdd-sync first" (invoke `spdd-sync` for this domain, then continue) or "Continue anyway" (proceed at their own risk — note the staleness in the final report); do not generate the canvas until the human has decided. In the background (no `AskUserQuestion`), do not stop: continue and add `⚠️ Confirm: spec stale — last sync <date>, <n> commits since` for the orchestrator's checkpoint to resolve.
3. **Read the living spec.** Read `spdd/specs/<domain>.md` if it exists. If the domain can't be inferred with confidence, use `spdd/specs/general.md` as a fallback and say so in the final report. Use whatever is found to avoid contradicting current system behavior, and to mark explicitly which parts of the canvas are new requirements versus changes to something already spec'd.
4. **Read global norms.** Read `spdd/norms.md` (project root) if it exists — see [template-norms.md](assets/template-norms.md) for its expected shape. Carry its content over as starting Norms/Safeguards in the new canvas, in addition to the feature-specific ones, clearly marked as coming from `spdd/norms.md`. Never create or edit this file — it's team-maintained, read-only for this skill.
5. **Identify risk and ambiguity.** Actively look for ambiguous domain concepts, unclear boundaries, and risky assumptions in the feature description — don't wait for them to surface incidentally while filling the template. Feed what you find into the `⚠️ Confirm:` lines and the Safeguards section.

### Step 6 — Determine layers

Only ask about layers if the feature description explicitly mentions two separate concerns (e.g. "backend + frontend", "API + CLI"). If so, ask: one canvas per layer or a single unified canvas? In the background (no `AskUserQuestion`), take the default — a single unified canvas — and add `⚠️ Confirm: layers — the description mentions separate concerns; confirm whether one canvas per layer is wanted`.

### Step 7 — Generate a filled canvas

Fill the template with real, project-specific content. Use actual file paths, the project's real model layer, and concrete operations — no generic placeholders.

Write Acceptance Criteria and Safeguards edge cases as `WHEN/THEN` scenarios (see the template), not freeform checkboxes — each scenario should be concrete enough to become a test.

Mark any decision that requires user input with `⚠️ Confirm:` and propose a sensible default.

### Step 8 — Save the file

Save to `spdd/changes/SPDD-YYYY-MM-DD-HHMM-slug/canvas.md` (kebab-case slug, today's date and time). Create the directory if needed.

### Step 9 — Ensure the SPDD hook and subagent cache TTL are present *(Claude Code only)*

> Skip this step if you are not running as Claude Code.

Check whether `.claude/settings.local.json` already contains the SPDD guard hook and the subagent cache TTL setting:

```bash
grep -q 'SPDD' .claude/settings.local.json 2>/dev/null && echo "hook: exists" || echo "hook: missing"
grep -q '"subagentPromptCacheTtl"' .claude/settings.local.json 2>/dev/null && echo "ttl: exists" || echo "ttl: missing"
```

For whichever is **missing**, ask the user whether to add it (one combined `AskUserQuestion` if both are missing). If confirmed, read [hook-setup.md](assets/hook-setup.md) for the exact JSON and merge it into `.claude/settings.local.json`.

### Step 10 — Report back

Show the saved file path, a 3-bullet summary, and all `⚠️ Confirm:` lines the user must resolve before implementing.

Suggest running `/spdd-design` as the next step — `spdd-implement` requires a plan to exist and never implements directly from the canvas.
