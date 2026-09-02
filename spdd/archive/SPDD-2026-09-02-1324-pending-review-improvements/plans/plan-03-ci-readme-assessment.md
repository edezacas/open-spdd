# Plan: CI eval guard + README conventions + persisted assessment

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-02
**Depends on:** plan-01, plan-02 — the assessment document's postscript must record exactly what this change implemented vs. deferred, so both other plans must be implemented first; a stale implementation-state claim in the postscript fails the canvas's Safeguard check
**Shared touchpoints:** none — no file in this plan is touched by any other plan

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Create | `.github/workflows/evals.yml` | on: push/PR touching `**/evals/evals.json` or `**/assets/hook-setup.md`; steps: JSON validity + id uniqueness + required fields per eval; `bash scripts/check-hook-sync.sh` |
| Document | `README.md` | Add "Eval results registry" convention (agent-run results committed as summaries) and "Spec size budget" section; link the assessment doc |
| Create | `REVIEW-2026-09-02-framework-assessment.md` | Persist the 2026-09-02 review (four-goal assessment, drift evidence, prioritized recommendations, implemented-vs-deferred postscript) |

**Resolved 2026-09-02 (foreground checkpoint):** the assessment document re-verifies each of the review's cited findings against the repo at implementation time and records only findings that still hold, each with the file/line it observed (canvas Norm: "evidence, not aspiration"); recommendation priorities default to the canvas's item order (doc hygiene, fold-back guard, eval CI, compaction policy, persisted assessment).

Notes (implementation guidance, not new requirements):
- `.github/` does not exist yet — creating the workflow file implies creating the directory; the workflow is static-only: no secrets, no agent-run eval suites (out of scope per canvas), must pass on a fresh fork.
- `scripts/check-hook-sync.sh` exists (verified) — the workflow calls it as-is.
- README additions: "Eval results registry" convention, "Spec size budget" (soft ~150 lines per domain spec, consolidation convention: merge superseded scenarios, drop volatile state, split at section boundaries — doc-only, no enforcement), and a link to `REVIEW-2026-09-02-framework-assessment.md`.
- The assessment postscript is authored after plan-01 and plan-02 are implemented (see Depends on), listing exactly what this change implemented vs. deferred.

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- CI workflow — `.github/workflows/evals.yml` — New — Static validation only, no secrets
- Project README — `README.md` — Existing — Eval-results registry convention + spec compaction policy + assessment link
- Assessment doc — `REVIEW-2026-09-02-framework-assessment.md` — New — The persisted review (English)

**Structure — files to create or modify:**

```
.github/workflows/evals.yml                # new — static eval-asset validation
README.md                                  # registry convention, compaction policy, assessment link
REVIEW-2026-09-02-framework-assessment.md  # new — persisted review
```

---

## Implementation notes (2026-09-02)

- `.github/workflows/evals.yml` created: static-only (no `secrets:`), triggers on push/PR touching `**/evals/evals.json` or `**/assets/hook-setup.md`, validates every `spdd-*/evals/evals.json` (JSON validity, ids unique per file, non-empty `prompt`/`assertions`) via inline Python, then runs `bash scripts/check-hook-sync.sh`. The embedded validator was extracted and run against the repo (passes) and against a synthetic bad file (correctly flags duplicate id + empty prompt/assertions).
- `README.md` gained a `## Framework maintenance` section (before `## Other agents`) with the "Eval results registry" and "Spec size budget" subsections and a link to the assessment doc.
- `REVIEW-2026-09-02-framework-assessment.md` created at the repo root: four-goal assessment, drift evidence with file/line citations (pre-change state from `5f0725d`, current state re-verified at implementation time per the plan's resolution note), prioritized recommendations (canvas item order), and the implemented-vs-deferred postscript recording plan-01 (doc hygiene + mirror norm), plan-02 (Step 8 integrity guard, evals 63–65, v2.0 → v2.1), and this plan.
- Canvas Safeguards run and passing: YAML parses; no `secrets:` usage; validator passes on all 7 eval files; `check-hook-sync.sh` OK; assessment file exists and is README-linked; `grep -rn "evals [0-9]" CLAUDE.md AGENTS.md` → nothing.
- ⚠️ Confirm: the committed eval-summary destination — README documents the default "a dated note under `evals/`" (raw output stays in the gitignored `evals/workspace/`); no registry file was created. Resolve if the team prefers a different location or format (e.g. a single `evals/RESULTS.md`).
  - *Resolved 2026-09-02 (foreground checkpoint):* confirmed the README default — each agent-run eval suite commits a dated note under `evals/`; raw output stays in gitignored `evals/workspace/`. No README change needed.
