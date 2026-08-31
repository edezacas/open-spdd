# Plan: Add eval-harness branch and background-note clarification to spdd-verify

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-08-31
**Depends on:** none
**Shared touchpoints:** none

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Modify | `spdd-verify` Step 4 ("Put the implementation to the test") | Add a conditional sub-step: "If the scope includes a `SKILL.md` file with its own `evals/evals.json`, either run that eval harness (see this repo's own `CLAUDE.md` 'Evaluating skills' section for the procedure) or, in a foreground session, ask via `AskUserQuestion` whether a lighter diff-based check is acceptable instead. In background (no `AskUserQuestion`), default to running the harness if the scope is non-trivial, or leave a `⚠️ Confirm:` note if running it isn't feasible in that context — never silently treat a diff read as equivalent to re-running the evals." |
| Modify | `spdd-verify` — near Step 7 ("Diff-to-canvas check") / Step 7.5 | Add one short line clarifying that the foreground/background branch there is intentional — needed to choose between a real `AskUserQuestion` and a `⚠️ Confirm:` fallback specifically for diff discrepancies — not an inconsistency versus other skills, which rely entirely on `spdd-agent`'s injected never-block rule |

## Implementation notes

- Per the canvas's resolved confirmation: "non-trivial" = anything beyond a single-sentence/single-line prose edit with no new decision logic, branch, or exact string added/removed. A single-sentence/single-line prose-only edit counts as trivial and defaults to leaving a `⚠️ Confirm:` in background instead of running the harness.
- Insert the new sub-step at the end of Step 4, after the existing "Run the full test suite for the affected area" sentence — do not renumber Step 4 or any step after it.
- The Step 7.5 clarification is a single short sentence placed right before or after the existing background-handling paragraph in Step 7.5 — do not change that paragraph's actual logic, only add the one clarifying sentence.
- Bump `metadata.version` in `spdd-verify/SKILL.md` frontmatter (currently `"1.6"`).
- Add a case to `spdd-verify/evals/evals.json`: verification scope includes a `SKILL.md` with its own `evals/evals.json`, change is non-trivial → harness runs (or foreground asks); scope has no `SKILL.md` → new branch never triggers, Step 4 behaves exactly as before. Keep existing cases (15–19, 30–36, 51) passing unchanged.
- Do not touch Steps 1–3, 5, 6, 8, 9, 10 — out of scope for this plan.

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-verify SKILL.md` — `spdd-verify/SKILL.md`

**Structure — files to create or modify:**

```
spdd-verify/SKILL.md
spdd-verify/evals/evals.json
```
