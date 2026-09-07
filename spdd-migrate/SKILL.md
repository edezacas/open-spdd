---
name: spdd-migrate
description: Migrate canvases from the old flat docs/prompts/SPDD-*.md layout to the new spdd/changes/ or spdd/archive/ folder layout (reformatting Acceptance Criteria and Safeguards into WHEN/THEN scenarios), and fold docs/features/*.md legacy feature docs into spdd/specs/<domain>.md. Use once, in a project that still has canvases in the old location, when moving to the current version of these skills.
license: Apache-2.0
compatibility: Works with any agent. Step 5 (hook rewrite) requires Claude Code.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "2.2"
---

## Instructions

> **Language note:** All new content (reformatted Acceptance Criteria/Safeguards, spec sections, `⚠️ Confirm:` lines) is written in English, regardless of the conversation's language.

### Step 1 — Detect the old layout

Look for `docs/prompts/SPDD-*.md` and `docs/features/*.md`. Neither exists → stop, tell the user there's nothing to migrate.

### Step 2 — Migrate each old canvas

For each `docs/prompts/SPDD-*.md` file:

1. Read its `Status` header (`Draft`, `Confirmed`, or `Implemented`).
2. Look for a paired `docs/features/<slug>.md` (same slug, no date prefix).
3. **Idempotency check.** `spdd/changes/SPDD-<same-slug>/canvas.md` or `spdd/archive/SPDD-<same-slug>/canvas.md` already exists → skip, note as already migrated.
4. Reformat Acceptance Criteria and Safeguards from freeform checkboxes/bullets into `WHEN/THEN` scenarios, preserving the original meaning as closely as possible. Ambiguous rewrite → add `⚠️ Confirm:` asking the user to double-check intent wasn't changed — never guess silently.
5. **Route the migrated canvas:**
   - Closed (`Status: Implemented`, or a paired `docs/features/<slug>.md` exists) → write to `spdd/archive/SPDD-<same-date-slug>/canvas.md` with `Status: Verified`, preserving the original `> Implemented: YYYY-MM-DD` line if present. Mirrors `spdd-verify`'s invariant: only `Verified` material lives in `spdd/archive/`.
   - Still active (`Draft` or `Confirmed`, no paired feature doc) → write to `spdd/changes/SPDD-<same-date-slug>/canvas.md`, keeping the original `Status` exactly. Don't fold into `spdd/specs/` — that happens when the user later runs `spdd-verify`, same as any other feature.

### Step 3 — Fold closed feature docs into the living spec

For every `docs/features/<slug>.md` paired with a canvas archived in Step 2, or orphaned (no matching `docs/prompts/SPDD-*-<slug>.md` at all) — skip a paired doc whose canvas stayed in `spdd/changes/`, unfinished work has nothing to fold yet:

1. **Idempotency check.** `spdd/specs/<domain>.md` already contains `<!-- spdd-migrate source: docs/features/<slug>.md -->` → skip, note as already migrated. (Folded content isn't byte-for-byte deterministic across runs, so the name/identifier dedupe used elsewhere isn't enough — this explicit marker is.)
2. **Infer the domain** — same folder-convention heuristic `spdd-canvas` uses (e.g. `src/billing/` → `billing`):
   - Prefer the paired canvas's Structure section, if there is one.
   - Otherwise use file paths in the feature doc's "Technical notes" section.
   - Neither gives a confident answer → fall back to `spdd/specs/general.md`, say so in the report.
3. **Convert the feature doc's prose into spec sections** — never invent detail the prose doesn't support; add `⚠️ Confirm:` wherever the mapping is ambiguous or lossy:
   - **Requirements**: synthesize a user story plus at least one `WHEN/THEN` scenario from "What it does" + "Business rules" + "Flows".
   - **Entities**: models/interfaces named in "Business rules" or "Technical notes".
   - **Operations**: concrete endpoints/commands/actions named in "Flows" or "Technical notes".
   - **Norms**: business rules that read as fixed constraints or conventions.
   - Before appending to Entities, Operations, or Norms: check for an existing row with the same name/identifier in `spdd/specs/<domain>.md`; update in place instead of duplicating.
4. Create `spdd/specs/<domain>.md` if it doesn't exist, add the `<!-- spdd-migrate source: docs/features/<slug>.md -->` marker next to what was folded in.

### Step 4 — Leave the originals in place

Never delete `docs/prompts/*.md` or `docs/features/*.md` — migration is non-destructive by default. Files not matched by Step 2/3 stay as-is; list them in the final report as legacy docs no longer auto-maintained.

### Step 5 — Update the hook *(Claude Code only)*

> Skip this step if not running as Claude Code.

`.claude/settings.local.json`'s SPDD guard hook still points at `docs/prompts/SPDD-*.md` → rewrite the `command` to the current pattern:

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

No hook installed at all → leave it; the other SPDD skills already offer to install it on first use.

### Step 6 — Report

Show:
- Canvases migrated to `spdd/changes/` (active) vs. `spdd/archive/` (closed), and how many skipped (already migrated).
- `spdd/specs/<domain>.md` files created or updated, and their `docs/features/<slug>.md` source.
- Any canvas archived as `Implemented` with no paired feature doc — note no spec was folded for it, suggest `spdd-sync` if the code already reflects that behavior.
- Any `⚠️ Confirm:` lines added during reformatting or spec conversion.
- A reminder that `docs/prompts/` and `docs/features/` were left untouched.

### Step 7 — Optional cleanup

Ask whether to delete the `docs/prompts/SPDD-*.md` and `docs/features/*.md` files successfully migrated. Only after explicit confirmation — never by default.
