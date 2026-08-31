# Plan: Add homogeneity criterion to spdd-design's splitting logic

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
| Modify | `spdd-design` Step 5 ("Decide: one plan or many") | Add: "If every group found in Step 4 applies the same Operation type homogeneously to files of the same kind, emit a single plan with one row per file instead of splitting — even if their Structure paths don't overlap. Reserve real splitting for groups that differ in Operation type, or that are meant to be handed to different agents/people." |

## Implementation notes

- Insert the new sentence(s) directly into Step 5's existing paragraph, after "Only split when the groups found in Step 4 are genuinely separable." — do not renumber any step.
- Bump `metadata.version` in `spdd-design/SKILL.md` frontmatter (currently `"1.2"`).
- Add a case to `spdd-design/evals/evals.json`: same Operation type (e.g. a trim) repeated across N same-kind files with non-overlapping Structure paths → expect a single plan with N rows, not N plans. Keep the existing split-plan cases (11–14, 29) passing unchanged — this criterion narrows when splitting applies, it doesn't remove the ability to split genuinely separable work.
- Do not touch Steps 1–4 or 6–8 — out of scope for this plan.

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-design SKILL.md` — `spdd-design/SKILL.md`

**Structure — files to create or modify:**

```
spdd-design/SKILL.md
spdd-design/evals/evals.json
```
