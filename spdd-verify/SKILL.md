---
name: spdd-verify
description: Verify an implemented SPDD plan (or canvas) against its Operations, Norms, and Safeguards, write targeted tests for uncovered edge cases, and — once everything for a change is verified — fold it into the living spec and archive it. Invoked manually via /spdd-verify, or delegated by spdd-agent — does not auto-trigger on its own.
license: Apache-2.0
compatibility: Works with any agent. Step 9 (SPDD hook installation) requires Claude Code.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "1.2"
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

### Step 7 — Diff-to-canvas check

Before folding any result back to `spdd/specs/<domain>.md`, verify that the actual code changes align with the canvas and plan:

1. **Obtain the real diff:**
   - If the scope is not yet committed: run `git diff <files in scope>` to get the working tree changes.
   - If already committed: use `git log -p --stat <files in scope>` to retrieve the commit changes.

2. **Compare the diff against Operations:**
   - For each Operation listed in the scope (canvas and plan), confirm there is corresponding code in the diff.
   - If an Operation has no corresponding implementation: **stop and report** the gap (e.g., "Canvas declares Operation: `X` → Code real: no changes in diff").

3. **Validate the diff's scope:**
   - No file or module touched in the diff may exist outside Structure, Shared touchpoints, or Operations of the canvas/plan.
   - **Exception:** Test files created by Step 4 (Put the implementation to the test) during *this same* verification are exempt — they are a verification byproduct, not part of the original implementation diff.
   - If a file falls outside declared scope: **stop and report** (e.g., "Canvas declares: [list of paths] → Code real: also includes `<file>`, undeclared").

4. **Validate against global norms:**
   - If `spdd/norms.md` (project root) exists, check the diff against every rule it states (Architecture, Security, Code conventions, Non-negotiable decisions) — not just the canvas's own Norms.
   - If the diff violates a stated norm, treat it exactly like a canvas discrepancy: **stop and report** (e.g., "spdd/norms.md states: `<rule>` → Code real: `<file>` violates it").

5. **Handle discrepancies:**
   - **In foreground (interactive session with user turn):** Use `AskUserQuestion` to ask whether the discrepancy is intentional. If confirmed, continue to Step 8 and note the accepted discrepancy in the fold. If not confirmed or unclear, stop without folding.
   - **In background (subagent under spdd-agent, no AskUserQuestion available):** Treat the discrepancy as a Step 6 failure — stop the process (never block waiting for a response), leave the plan/canvas unchanged, do not fold or archive, report the concrete gap, and append a line `⚠️ Confirm: <discrepancy detected during Diff-to-canvas check — review and confirm whether intentional>` to the plan/canvas for the foreground checkpoint in `spdd-agent` to resolve afterward.

If everything passes (diff is coherent or user confirms discrepancies), continue to Step 8.

### Step 8 — Fold back and archive (canvas level, not plan level)

Only when *every* plan under this change is `Status: Verified` (or immediately, if the change never had a `plans/` split):

1. Fold the canvas's Requirements, Entities, Operations, and Norms into `spdd/specs/<domain>.md` — create the file if it doesn't exist. Use the NEW/MODIFIED markers already present in the canvas's Requirements to decide whether to add new scenarios or replace existing ones; remove anything the canvas marked as replaced. Entities, Operations, and Norms don't carry NEW/MODIFIED markers — before appending a row, check whether one with the same name/identifier already exists in that section; if it does, update it in place instead of adding a duplicate. Only append when the name/identifier is genuinely new to the domain.
2. Move the entire change folder from `spdd/changes/` to `spdd/archive/`.

While any plan is still pending, do not fold or archive anything — a partially implemented feature should never be described as done in the living spec.

### Step 9 — Ensure the SPDD hook is present *(Claude Code only)*

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

### Step 10 — Report back

Summarize what was verified, tests added, and — if the change was fully verified — the spec files updated and the new path under `spdd/archive/`.
