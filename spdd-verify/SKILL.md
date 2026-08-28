---
name: spdd-verify
description: Verify an implemented SPDD plan (or canvas) against its Operations, Norms, and Safeguards, write targeted tests for uncovered edge cases, and — once everything for a change is verified — fold it into the living spec and archive it. Use after spdd-implement, or whenever the user wants to review/test a feature against its canvas.
license: Apache-2.0
compatibility: Works with any agent. Step 8 (SPDD hook installation) requires Claude Code.
metadata:
  author: edezacas
  version: "1.0"
---

## Instructions

### Step 1 — Locate the change and plan

If a change folder or plan path was provided, use that. Otherwise, list recent changes in `spdd/changes/` matching `SPDD-*`, sorted by name (most recent first), same lookup pattern as `spdd-implement` Step 1.

If the change has a `plans/` folder and no specific plan was named, ask which plan to verify.

### Step 2 — Read the scope

Read the plan (or `canvas.md` in full if there is no `plans/` folder) plus the current code for every path it touches.

### Step 3 — Structural check

Confirm, for the scope being verified:

- Every Operation is implemented.
- Every Norm is followed (grep for the project's stated conventions).
- Every file under Structure/Shared touchpoints is accounted for — nothing missing, nothing extra without explanation.

### Step 4 — Put the implementation to the test

For every Safeguards edge case (`WHEN/THEN` scenario) in scope that isn't already covered by an existing test, write a test targeting exactly that scenario, then run it. Run the full test suite for the affected area.

### Step 5 — Report

Report pass/fail per section with concrete gaps — file, expected behavior, what's actually there. Never a generic "looks fine."

### Step 6 — Mark status

If everything in Step 3–4 passes: set `Status: Verified` on the plan just checked (or on `canvas.md` directly if there is no `plans/` folder).

If something fails: report the gaps, leave the plan/canvas as-is in `spdd/changes/`, do not archive anything, stop here.

### Step 7 — Fold back and archive (canvas level, not plan level)

Only when *every* plan under this change is `Status: Verified` (or immediately, if the change never had a `plans/` split):

1. Fold the canvas's Requirements, Entities, Operations, and Norms into `spdd/specs/<domain>.md` — create the file if it doesn't exist. Use the NEW/MODIFIED markers already present in the canvas's Requirements to decide whether to add new scenarios or replace existing ones; remove anything the canvas marked as replaced. Entities, Operations, and Norms don't carry NEW/MODIFIED markers — before appending a row, check whether one with the same name/identifier already exists in that section; if it does, update it in place instead of adding a duplicate. Only append when the name/identifier is genuinely new to the domain.
2. Move the entire change folder from `spdd/changes/` to `spdd/archive/`.

While any plan is still pending, do not fold or archive anything — a partially implemented feature should never be described as done in the living spec.

### Step 8 — Ensure the SPDD hook is present *(Claude Code only)*

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

### Step 9 — Report back

Summarize what was verified, tests added, and — if the change was fully verified — the spec files updated and the new path under `spdd/archive/`.
