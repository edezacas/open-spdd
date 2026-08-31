# Plan: Add missing language note to spdd-migrate

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
| Modify | `spdd-migrate` — near Step 2, point 3 (WHEN/THEN reformatting) | Add `> **Language note:** Write the reformatted Acceptance Criteria/Safeguards content in English, regardless of the conversation's language.` — same blockquote style already used by `spdd-design`/`spdd-verify`/`spdd-sync` |

## Implementation notes

- Place the blockquote directly above or below point 3 in Step 2's numbered list ("Reformat Acceptance Criteria and Safeguards edge cases from freeform checkboxes/bullets into `WHEN/THEN` scenarios..."), matching the placement pattern already used in `spdd-sync/SKILL.md` Step 5 (blockquote right after the operative instruction it governs).
- Do not touch Steps 1, 3, 4, 5, 6 — out of scope for this plan.
- Bump `metadata.version` in `spdd-migrate/SKILL.md` frontmatter (currently `"1.0"`).
- `spdd-migrate/evals/` — check whether `evals.json` exists; if it does, add a case confirming reformatted `WHEN/THEN` content stays in English even when the source `docs/prompts/SPDD-*.md` and the conversation are in Spanish. If no eval file exists yet for this skill, note that in the report rather than creating a new eval harness (out of scope for this plan).

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-migrate SKILL.md` — `spdd-migrate/SKILL.md`

**Structure — files to create or modify:**

```
spdd-migrate/SKILL.md
```
