# Spec: general (repo-level conventions)

> Living spec for repo-level conventions and tooling that don't belong to a single skill
> domain (fallback home per `spdd-canvas` Step 2's domain-inference rule). Folded from
> verified SPDD changes — kept in sync by `spdd-verify` (fold-back after each change) and
> `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a maintainer of `open-spdd`, I want the framework's own hygiene mechanisms (eval assets,
CI checks, README conventions, persisted reviews) to be cheap to run and impossible to
silently regress, so that the whole team keeps the framework healthy without manual attention.

**Scenario: eval assets get a lightweight CI guard**
- WHEN a push or PR touches any `*/evals/evals.json` or `**/assets/hook-setup.md`
- THEN the GitHub Actions workflow `.github/workflows/evals.yml` validates every `spdd-*/evals/evals.json` (parses as JSON, ids unique across the file, `prompt`/`assertions` non-empty) and runs `bash scripts/check-hook-sync.sh`, failing on any violation — agent-run eval suites stay manual (expensive, need API keys), and the workflow is static-only: no `secrets:` usage, passes on a fresh fork

**Scenario: the spec compaction policy is documented**
- WHEN a team wonders how large a domain spec may grow
- THEN `README.md` documents a soft budget (~150 lines per domain spec) and the consolidation convention (merge superseded scenarios, drop volatile state, split at a `##` section boundary) — doc-only, no enforcement in code

**Scenario: framework reviews fold into the living specs, not a standalone doc**
- WHEN a framework review or assessment is produced
- THEN its findings and implemented-vs-deferred outcomes are folded directly into the affected `spdd/specs/<domain>.md` files (via `spdd-verify`'s normal fold-back, same as any other change) rather than persisted as a separate root-level review document — a 2026-09-02 assessment was persisted standalone at `REVIEW-2026-09-02-framework-assessment.md` and later removed (2026-09-07) once its findings were confirmed already duplicated in `general.md` and `spdd-verify.md`, in favor of this convention

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| CI workflow | `.github/workflows/evals.yml` | Static eval-asset validation only: JSON validity, id uniqueness, required fields, hook-asset sync, and (since the per-host phase subagents feature) never-block-rule sync across the 8 wrapper templates; no secrets, no agent-run suites |
| README "Framework maintenance" section | `README.md` | "Eval results registry" convention + "Spec size budget" section |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Create | `.github/workflows/evals.yml` | on: push/PR touching `**/evals/evals.json` or `**/assets/hook-setup.md`; steps: JSON validity + id uniqueness + required fields per eval; `bash scripts/check-hook-sync.sh` |
| Document | `README.md` | "Eval results registry" convention (agent-run results committed as dated summaries) and "Spec size budget" section |
| Remove | `REVIEW-2026-09-02-framework-assessment.md` | Deleted 2026-09-07 — its findings were already folded into `general.md`/`spdd-verify.md`; superseded by the fold-into-specs convention above |

---

## Norms

- `.github/` and `scripts/` are repo tooling: no `SKILL.md` may reference them at execution time.
- `*/evals/evals.json` files are the single source of truth for eval coverage — eval id ranges are never restated anywhere else; agent-run eval results are committed as dated summaries under `evals/`, and raw output stays in the gitignored `evals/workspace/`.
- `docs/` stays deleted and gitignored; nothing recreates it.
- A domain spec has a soft budget of ~150 lines; when outgrown, consolidate (merge superseded scenarios, drop volatile state) and split at a `##` section boundary if it genuinely covers two areas.
- Framework reviews/assessments are folded into the affected `spdd/specs/<domain>.md` files, not persisted as standalone root-level review docs — a second such doc duplicates what the specs already own and risks the same enumeration drift the mirror-doc eval id ranges once had.
