---
name: spdd-verify
description: Verify an implemented SPDD plan (or canvas) against its Operations, Norms, and Safeguards, test uncovered edge cases, then fold into the living spec and archive. Delegated by spdd-agent or invoked manually via /spdd-verify — does not auto-trigger on its own.
license: Apache-2.0
compatibility: Works with any agent. Step 9 (SPDD hook and subagent cache TTL setup) requires Claude Code.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "2.3"
---

## Instructions

### Step 1 — Locate the change and plan

Use the given change folder or plan path if provided. Otherwise list `spdd/changes/SPDD-*`, sorted by name, most recent first.

Change has a `plans/` folder, no plan named → ask which plan to verify.

### Step 2 — Read the scope

Read the chosen plan and `canvas.md` in full — Requirements, Norms, and Safeguards live in the canvas and apply to every plan (no `plans/` folder → the canvas alone is the scope) — plus the current code for every path they touch.

### Step 3 — Structural check

Confirm, for the scope being verified:

- Every Operation is implemented.
- Every Norm is followed (grep for the project's stated conventions).
- Every file under Structure/Shared touchpoints is accounted for — nothing missing, nothing extra without explanation.

### Step 4 — Put the implementation to the test

For every in-scope Safeguards edge case (`WHEN/THEN` scenario) not already covered by an existing test: write a test targeting exactly that scenario, run it. Run the full test suite for the affected area.

Scope includes its own eval suite (e.g. a `SKILL.md` with `evals/evals.json`):

- Foreground → run it, or ask via `AskUserQuestion` whether a lighter diff-based check is acceptable.
- Background (no `AskUserQuestion`) → default to running the suite if the scope is non-trivial, else leave a `⚠️ Confirm:` note if running it isn't feasible. Never treat a diff read as equivalent to re-running the evals.

### Step 5 — Report

Report pass/fail per section with concrete gaps — file, expected behavior, what's actually there. Never a generic "looks fine."

### Step 6 — Mark status

- Step 3–4 all pass → set `Status: Verified` on the plan just checked (or `canvas.md` directly, no `plans/` folder).
- Something fails → report the gaps, leave the plan/canvas as-is in `spdd/changes/`, don't archive anything, stop here.

### Step 7 — Diff-to-canvas check

Before folding back to `spdd/specs/<domain>.md`, verify the actual code changes align with the canvas and plan:

1. **Obtain the real diff.** Not yet committed → `git diff <files in scope>`. Already committed → `git log -p --stat <files in scope>`.

2. **Compare the diff against Operations.** Each Operation in scope needs corresponding code in the diff. Missing → **stop and report** (e.g., "Canvas declares Operation: `X` → Code real: no changes in diff").

3. **Validate the diff's scope.** No file/module in the diff may exist outside Structure, Shared touchpoints, or Operations of the canvas/plan. Exception: test files this same verification created in Step 4 — a verification byproduct, not original implementation. A file outside declared scope → **stop and report** (e.g., "Canvas declares: [paths] → Code real: also includes `<file>`, undeclared").

4. **Validate against global norms.** `spdd/norms.md` (project root) exists → check the diff against every rule it states (Architecture, Security, Code conventions, Non-negotiable decisions), not just the canvas's own Norms. Violation → **stop and report** like a canvas discrepancy (e.g., "spdd/norms.md states: `<rule>` → Code real: `<file>` violates it").

5. **Handle discrepancies.**
   - Foreground → `AskUserQuestion` whether it's intentional. Confirmed → continue to Step 8, note the accepted discrepancy in the fold. Not confirmed or unclear → revert the `Status: Verified` set in Step 6, stop without folding, report the concrete gap.
   - Background (subagent under `spdd-agent`, no `AskUserQuestion`) → treat as a Step 6 failure: stop (never block waiting for a response), revert the `Status: Verified` set in Step 6, don't fold or archive, report the concrete gap, append `⚠️ Confirm: <discrepancy detected during Diff-to-canvas check — review and confirm whether intentional>` to the plan/canvas for `spdd-agent`'s foreground checkpoint to resolve.

Everything passes (diff coherent, or discrepancies confirmed) → continue to Step 8.

> **Language note:** Write all new prose added by this skill (discrepancy notes, `⚠️ Confirm:` lines, fold-back annotations) in English, regardless of the conversation's language.

### Step 8 — Fold back and archive (canvas level, not plan level)

Only when every plan under this change is `Status: Verified` (or immediately, no `plans/` split):

1. Fold the canvas's Requirements, Entities, Operations, and Norms into `spdd/specs/<domain>.md` — create it if absent. Requirements: use the canvas's NEW/MODIFIED markers to add or replace scenarios; remove anything marked replaced. Entities/Operations/Norms carry no such markers — check for an existing row with the same name/identifier first and update it in place; only append when genuinely new to the domain.
2. **Integrity check, before reporting success.** Inspect the resulting `spdd/specs/<domain>.md` for: (a) orphan unresolved `> ⚠️ Confirm:` blockquotes left by the fold, (b) duplicated `##` section headings (e.g. two `## Operations` sections). Either found → report it concretely (file, heading/line), fix the spec, re-run the check. "Folded" is blocked until both checks pass; don't archive the change folder in the meantime.
3. Move the change folder from `spdd/changes/` to `spdd/archive/`.

Any plan still pending → fold or archive nothing. A partially implemented feature is never described as done in the living spec.

### Step 9 — Ensure the SPDD hook and subagent cache TTL are present *(Claude Code only)*

> Skip this step if not running as Claude Code.

Grep `.claude/settings.local.json` for `SPDD` and for `"subagentPromptCacheTtl"`. For whichever is missing:

- Ask the user whether to add it (one combined `AskUserQuestion` if both are missing).
- If confirmed, read [hook-setup.md](assets/hook-setup.md) for the exact JSON and merge it in.

### Step 10 — Report back

Summarize what was verified, tests added, and — if fully verified — the spec files updated and the new path under `spdd/archive/`.
