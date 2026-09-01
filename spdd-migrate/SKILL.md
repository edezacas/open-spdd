---
name: spdd-migrate
description: Migrate canvases from the old flat docs/prompts/SPDD-*.md layout to the new spdd/changes/ or spdd/archive/ folder layout (reformatting Acceptance Criteria and Safeguards into WHEN/THEN scenarios), and fold docs/features/*.md legacy feature docs into spdd/specs/<domain>.md. Use once, in a project that still has canvases in the old location, when moving to the current version of these skills.
license: Apache-2.0
compatibility: Works with any agent. Step 5 (hook rewrite) requires Claude Code.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "2.1"
---

## Instructions

> **Language note:** All newly authored content in this skill (reformatted Acceptance Criteria/Safeguards, spec sections, `⚠️ Confirm:` lines) is written in English, regardless of the conversation's language.

### Step 1 — Detect the old layout

Look for `docs/prompts/SPDD-*.md` and `docs/features/*.md`. If neither exists, stop and tell the user there's nothing to migrate.

### Step 2 — Migrate each old canvas

For each `docs/prompts/SPDD-*.md` file found:

1. Read its `Status` header (`Draft`, `Confirmed`, or `Implemented`).
2. Look for a paired `docs/features/<slug>.md` (same slug as the canvas, without the date prefix).
3. **Idempotency check**: if `spdd/changes/SPDD-<same-slug>/canvas.md` or `spdd/archive/SPDD-<same-slug>/canvas.md` already exists, skip this file and note it as already migrated.
4. Reformat Acceptance Criteria and Safeguards edge cases from freeform checkboxes/bullets into `WHEN/THEN` scenarios, preserving the original meaning as closely as possible. If a rewrite is ambiguous, add `⚠️ Confirm:` asking the user to double-check the rewrite didn't change the intent — never guess silently.

5. **Route the migrated canvas:**
   - **Closed** (`Status: Implemented`, or a paired `docs/features/<slug>.md` exists): write to `spdd/archive/SPDD-<same-date-slug>/canvas.md` with `Status: Verified` — preserve the original `> Implemented: YYYY-MM-DD` line if the source canvas already had one. This mirrors `spdd-verify`'s own invariant: only `Verified` material lives in `spdd/archive/`.
   - **Still active** (`Draft` or `Confirmed`, no paired feature doc): write to `spdd/changes/SPDD-<same-date-slug>/canvas.md`, **keeping the original `Status` exactly as it was**. Do not fold it into `spdd/specs/` — that happens when the user later runs `spdd-verify` on it, same as any other feature.
### Step 3 — Fold closed feature docs into the living spec

For every `docs/features/<slug>.md`:

- **Paired** with a canvas that was archived in Step 2 (closed), **or**
- **Orphaned** (no matching `docs/prompts/SPDD-*-<slug>.md` at all)

...do the following (skip a paired doc whose canvas stayed in `spdd/changes/` — unfinished work has nothing to fold yet):

1. **Idempotency check**: if `spdd/specs/<domain>.md` already contains an HTML comment `<!-- spdd-migrate source: docs/features/<slug>.md -->`, skip this file and note it as already migrated. (Content generated while folding isn't byte-for-byte deterministic across runs, so the name/identifier dedupe used elsewhere isn't enough here — this explicit marker is.)
2. **Infer the domain**, same folder-convention heuristic `spdd-canvas` already uses (e.g. `src/billing/` → `billing`):
   - Prefer the paired canvas's Structure section, if there is a paired canvas.
   - Otherwise use file paths mentioned in the feature doc's own "Technical notes" section.
   - If neither gives a confident answer, fall back to `spdd/specs/general.md` and say so in the report.
3. **Convert the feature doc's prose into spec sections** — never invent detail the prose doesn't support; add `⚠️ Confirm:` wherever the mapping is ambiguous or lossy:
   - **Requirements**: synthesize a user story plus at least one `WHEN/THEN` scenario from "What it does" + "Business rules" + "Flows".
   - **Entities**: models/interfaces named in "Business rules" or "Technical notes".
   - **Operations**: concrete endpoints/commands/actions named in "Flows" or "Technical notes".
   - **Norms**: business rules that read as fixed constraints or conventions.
   - Before appending to Entities, Operations, or Norms, check whether a row with the same name/identifier already exists in that section of `spdd/specs/<domain>.md`; update in place instead of duplicating.
4. Create `spdd/specs/<domain>.md` if it doesn't exist yet, and add the `<!-- spdd-migrate source: docs/features/<slug>.md -->` marker next to what was folded in.

### Step 4 — Leave the originals in place

Never delete `docs/prompts/*.md` or `docs/features/*.md` in this step — migration is non-destructive by default. `docs/prompts/` files not matched by Step 2 and `docs/features/` files not matched by Step 3 stay as-is; list them in the final report as legacy docs no longer auto-maintained.

### Step 5 — Update the hook *(Claude Code only)*

> Skip this step if you are not running as Claude Code.

If `.claude/settings.local.json` has the SPDD guard hook still pointing at `docs/prompts/SPDD-*.md`, rewrite the `command` to the current pattern:

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

If there's no hook installed at all, leave it — the other SPDD skills already offer to install it on first use.

### Step 6 — Report

Show:
- How many canvases were migrated to `spdd/changes/` (still active) vs. `spdd/archive/` (closed), and how many were skipped (already migrated).
- Which `spdd/specs/<domain>.md` files were created or updated, and from which `docs/features/<slug>.md` source each came from.
- Any canvas archived as `Implemented` with no paired `docs/features/<slug>.md` — note that no spec was folded for it, and suggest running `spdd-sync` if the code already reflects that behavior.
- Any `⚠️ Confirm:` lines added during reformatting or spec conversion.
- A reminder that `docs/prompts/` and `docs/features/` were left untouched.

### Step 7 — Optional cleanup

Ask whether the user wants to delete the `docs/prompts/SPDD-*.md` and `docs/features/*.md` files that were successfully migrated. Only delete after explicit confirmation — never by default.
