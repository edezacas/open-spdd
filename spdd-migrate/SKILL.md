---
name: spdd-migrate
description: Migrate canvases from the old flat docs/prompts/SPDD-*.md layout to the new spdd/changes/SPDD-.../canvas.md folder layout, reformatting Acceptance Criteria and Safeguards into WHEN/THEN scenarios. Use once, in a project that still has canvases in the old location, when moving to the current version of these skills.
license: Apache-2.0
compatibility: Works with any agent. Step 4 (hook rewrite) requires Claude Code.
metadata:
  author: edezacas
  version: "1.0"
---

## Instructions

### Step 1 — Detect the old layout

Look for `docs/prompts/SPDD-*.md`. If none exist, stop and tell the user there's nothing to migrate.

### Step 2 — Migrate each old canvas

For each `docs/prompts/SPDD-*.md` file found:

1. Read its `Status` header (`Draft`, `Confirmed`, or `Implemented`).
2. **Idempotency check**: if `spdd/changes/SPDD-<same-slug>/canvas.md` or `spdd/archive/SPDD-<same-slug>/canvas.md` already exists, skip this file and note it as already migrated.
3. Reformat Acceptance Criteria and Safeguards edge cases from freeform checkboxes/bullets into `WHEN/THEN` scenarios, preserving the original meaning as closely as possible. If a rewrite is ambiguous, add `⚠️ Confirm:` asking the user to double-check the rewrite didn't change the intent — never guess silently.
4. Write the result to `spdd/changes/SPDD-<same-date-slug>/canvas.md`, **keeping the original `Status` exactly as it was** — including `Implemented`. Do not promote it to `Verified` and do not fold it into `spdd/specs/` or move it to `spdd/archive/`; that only happens when the user later runs `spdd-verify` on it, same as any other feature.
5. Do not delete the original file in this step — migration is non-destructive by default.

### Step 3 — Leave docs/features/ alone

Don't touch any `docs/features/*.md` files. List them in the final report as legacy docs that are no longer auto-maintained, and note they'll become redundant once their domain gets folded into `spdd/specs/` via `spdd-verify`.

### Step 4 — Update the hook *(Claude Code only)*

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

### Step 5 — Report

Show: how many canvases were migrated, how many were skipped (already migrated), any `⚠️ Confirm:` lines added during reformatting, and a reminder that `docs/prompts/` and `docs/features/` were left untouched.

### Step 6 — Optional cleanup

Ask whether the user wants to delete the `docs/prompts/SPDD-*.md` files that were successfully migrated. Only delete after explicit confirmation — never by default.
