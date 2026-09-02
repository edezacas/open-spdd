# Plan: spdd-verify fold-back integrity guard

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-02
> Verified: 2026-09-02 (plan-02 only — fold-back and archiving held until every plan in this change is verified)
**Depends on:** none — independent of plan-01 and plan-03; no file overlap (runtime relations only: this plan's guard will later run when `spdd-verify` folds plan-01's mirror-norm reword into the spec, and plan-03's CI workflow only validates this plan's `evals.json` without editing it)
**Shared touchpoints:** none

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Extend | `spdd-verify/SKILL.md` Step 8 | Add the pre-completion integrity check (orphan `> ⚠️ Confirm:` blockquotes; duplicate `##` headings in the folded spec); bump `metadata.version` to 2.1 |
| Add | `spdd-verify/evals/evals.json` cases | Cover: guard passes on a clean fold; guard flags a duplicate heading; guard flags an orphan Confirm |

Notes (implementation guidance, not new requirements):
- Confirm 2 on the canvas is resolved — the guard lives in `spdd-verify` Step 8 (hook extension declined), so the version bump `metadata.version` `"2.0"` → `"2.1"` is unconditional in this plan.
- New eval ids: 63, 64, 65 — continuing the existing sequence (current ids 15–19, 30–36, 51, 56, 60–62; max = 62, verified against the file). Ids must be unique across the whole file.
- The three cases: (1) guard passes on a clean fold, (2) guard flags a duplicate `##` heading, (3) guard flags an orphan unresolved `> ⚠️ Confirm:` blockquote.
- The guard is host-agnostic (root cause of the 2026-09-02 audit defects: duplicate `## Operations` in the design spec, orphan Confirm in the migrate spec).
- Per project Norm, no `SKILL.md` may reference repo tooling (`scripts/`) at execution time — the check is defined inline in the Step 8 prose.

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Verify skill — `spdd-verify/SKILL.md` — Existing — Step 8 fold-back integrity guard; version bump v2.0 → v2.1 (Confirm 2 resolved: kept)
- Verify evals — `spdd-verify/evals/evals.json` — Existing — New evals for the integrity guard (unique ids, continuing the existing sequence)

**Structure — files to create or modify:**

```
spdd-verify/SKILL.md          # Step 8 integrity guard + version bump v2.0 → v2.1
spdd-verify/evals/evals.json  # new evals ids 63–65 for the guard
```

---

⚠️ Confirm: spdd-verify's own eval suite (21 cases) was not re-run during this verification — the harness procedure (CLAUDE.md "Evaluating skills") requires executing every prompt against the project with and without the skill, which is infeasible in this background session. Static Safeguards checks (JSON validity, id uniqueness/sequence, non-empty fields, version bump) and targeted guard-logic tests for all three new scenarios (clean fold / duplicate heading / orphan Confirm) passed. Re-run or explicitly waive the suite at the next foreground checkpoint.
  - *Resolved 2026-09-02 (foreground checkpoint):* waived by the user — the guard already passed 21 targeted tests (real specs + synthetic fixtures), and agent-run eval suites stay manual per repo convention. Recorded here; no re-run required for archiving.
