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
- THEN the GitHub Actions workflow `.github/workflows/evals.yml` validates every `spdd-*/evals/evals.json` (parses as JSON, ids unique across the file, `prompt`/`assertions` non-empty), runs `bash scripts/check-hook-sync.sh`, and fails on any violation — agent-run eval suites stay manual (expensive, need API keys), and the workflow is static-only: no `secrets:` usage, passes on a fresh fork

**Scenario: the spec compaction policy is documented**
- WHEN a team wonders how large a domain spec may grow
- THEN `README.md` documents a soft budget (~150 lines per domain spec) and the consolidation convention (merge superseded scenarios, drop volatile state, split at a `##` section boundary) — doc-only, no enforcement in code

**Scenario: framework reviews are persisted in-repo**
- WHEN a framework review or assessment is produced
- THEN it is saved as an English Markdown file at the repo root (e.g. `REVIEW-YYYY-MM-DD-<topic>.md`), linked from `README.md`, citing the file/line it observed for every finding (evidence, not aspiration) and closing with an implemented-vs-deferred postscript

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| CI workflow | `.github/workflows/evals.yml` | Static eval-asset validation only: JSON validity, id uniqueness, required fields, hook-asset sync; no secrets, no agent-run suites |
| README "Framework maintenance" section | `README.md` | "Eval results registry" convention + "Spec size budget" section + links the latest framework assessment |
| Framework assessment doc | `REVIEW-2026-09-02-framework-assessment.md` | The 2026-09-02 four-goal review: findings with file/line evidence, prioritized recommendations, implemented-vs-deferred postscript |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Create | `.github/workflows/evals.yml` | on: push/PR touching `**/evals/evals.json` or `**/assets/hook-setup.md`; steps: JSON validity + id uniqueness + required fields per eval; `bash scripts/check-hook-sync.sh` |
| Document | `README.md` | "Eval results registry" convention (agent-run results committed as dated summaries) and "Spec size budget" section; links the assessment doc |
| Create | `REVIEW-2026-09-02-framework-assessment.md` | Persisted 2026-09-02 review (four-goal assessment, drift evidence, prioritized recommendations, implemented-vs-deferred postscript) |

---

## Norms

- `.github/` and `scripts/` are repo tooling: no `SKILL.md` may reference them at execution time.
- `*/evals/evals.json` files are the single source of truth for eval coverage — eval id ranges are never restated anywhere else; agent-run eval results are committed as dated summaries under `evals/`, and raw output stays in the gitignored `evals/workspace/`.
- `docs/` stays deleted and gitignored; nothing recreates it.
- A domain spec has a soft budget of ~150 lines; when outgrown, consolidate (merge superseded scenarios, drop volatile state) and split at a `##` section boundary if it genuinely covers two areas.
