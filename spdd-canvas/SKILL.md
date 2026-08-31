---
name: spdd-canvas
description: Generate a REASONS canvas for a new feature and save it to spdd/changes/. Use BEFORE writing code. Invoked manually via /spdd-canvas, or delegated by spdd-agent as the first phase of its automated flow — does not auto-trigger on its own.
license: Apache-2.0
compatibility: Works with any agent. Step 11 (SPDD hook and subagent cache TTL setup) requires Claude Code.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "2.6"
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

### Step 3 — Output language

Generate all document content in English, regardless of the language used in the feature description or conversation. This includes section headings, labels, User story, Acceptance Criteria, Entities, Norms, Safeguards, and any inline notes.

### Step 4 — Read the base template

Read [template-reasons.md](assets/template-reasons.md).

### Step 5 — Understand the project

If the stack and conventions are not clear from the project context, inspect the project structure before generating the canvas.

### Step 6 — Freshness check

Before reading the spec, check whether it has fallen behind code changes made outside the SPDD flow (e.g. a manual refactor that skipped `spdd-sync`).

1. Infer the domain the same way as the next step (folder conventions, e.g. `src/billing/` → `billing`).
2. If `spdd/specs/<domain>.md` doesn't exist yet, skip this check — there's nothing to compare against.
3. Otherwise, get the spec's last commit date and any domain commits since then:
   ```bash
   spec_date=$(git log -1 --format=%cI -- spdd/specs/<domain>.md)
   git log --format='%h %cI %s' --since="$spec_date" -- <domain-folder>/
   ```
   If either command fails (not a git repo, no matching folder), skip this check silently.
4. If that second command returns any commits, stop and tell the user:
   `Domain <domain> has code changes not reflected in the spec (last commit: <date/hash>, last spec sync: <date>). Run spdd-sync before continuing?`
   This is a conversational message, not persisted document content — phrase it in whatever language the current conversation is in, same as every other conversational reply from this skill.
   Ask via `AskUserQuestion` with options: "Run spdd-sync first" (invoke `spdd-sync` for this domain, then continue) or "Continue anyway" (proceed at their own risk — note the staleness in the final report).
5. Do not generate the canvas until the human has decided.

### Step 7 — Context and risk

Do both of the following before filling the canvas:

- **Read the living spec.** Read `spdd/specs/<domain>.md` for the domain identified in Step 6 if it exists. If the domain can't be inferred with confidence, use `spdd/specs/general.md` as a fallback and say so in the final report. Use whatever is found to avoid contradicting current system behavior, and to mark explicitly which parts of the canvas are new requirements versus changes to something already spec'd.
- **Read global norms.** Read `spdd/norms.md` (project root) if it exists — see [template-norms.md](assets/template-norms.md) for its expected shape. Carry its content over as starting Norms/Safeguards in the new canvas, in addition to the feature-specific ones, clearly marked as coming from `spdd/norms.md`. Never create or edit this file — it's team-maintained, read-only for this skill.
- **Identify risk and ambiguity.** Actively look for ambiguous domain concepts, unclear boundaries, and risky assumptions in the feature description — don't wait for them to surface incidentally while filling the template. Feed what you find into the `⚠️ Confirm:` lines and the Safeguards section.

### Step 8 — Determine layers

Only ask about layers if the feature description explicitly mentions two separate concerns (e.g. "backend + frontend", "API + CLI"). If so, ask: one canvas per layer or a single unified canvas?

### Step 9 — Generate a filled canvas

Fill the template with real, project-specific content. Use actual file paths, the project's real model layer, and concrete operations — no generic placeholders.

Write Acceptance Criteria and Safeguards edge cases as `WHEN/THEN` scenarios (see the template), not freeform checkboxes — each scenario should be concrete enough to become a test.

Mark any decision that requires user input with `⚠️ Confirm:` and propose a sensible default.

### Step 10 — Save the file

Save to `spdd/changes/SPDD-YYYY-MM-DD-HHMM-slug/canvas.md` (kebab-case slug, today's date and time). Create the directory if needed.

### Step 11 — Ensure the SPDD hook and subagent cache TTL are present *(Claude Code only)*

> Skip this step if you are not running as Claude Code.

Check whether `.claude/settings.local.json` already contains the SPDD guard hook and the subagent cache TTL setting:

```bash
grep -q 'SPDD' .claude/settings.local.json 2>/dev/null && echo "hook: exists" || echo "hook: missing"
grep -q '"subagentPromptCacheTtl"' .claude/settings.local.json 2>/dev/null && echo "ttl: exists" || echo "ttl: missing"
```

For whichever is **missing**, ask the user whether to add it (one combined `AskUserQuestion` if both are missing). If confirmed, merge the applicable piece(s) into `.claude/settings.local.json` and write it back:

- **Guard hook** — into `hooks.PreToolUse` (create the key if absent):
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
- **Subagent cache TTL** — top-level (not under `hooks`): `"subagentPromptCacheTtl": "1h"`. `spdd-implement` and `spdd-verify` run internal edit/test/verify loops inside one subagent call; without this, Claude Code caps that subagent's own prompt cache at a 5-minute TTL regardless of plan, so a slow test run between turns forces a full, uncached re-read of that phase's growing conversation.

### Step 12 — Report back

Show the saved file path, a 3-bullet summary, and all `⚠️ Confirm:` lines the user must resolve before implementing.

Suggest running `/spdd-design` as the next step — `spdd-implement` requires a plan to exist and never implements directly from the canvas.
