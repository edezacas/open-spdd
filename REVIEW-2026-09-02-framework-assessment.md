# Framework assessment — 2026-09-02

The durable form of the 2026-09-02 review of `open-spdd`'s own hygiene mechanisms. The review ran as a conversation and was at risk of living only there — persisting it is itself one of its recommendations (5.1 below).

**Provenance and re-verification.** Per the implementing plan's resolution (plan-03 of SPDD-2026-09-02-1324), every cited finding was re-verified against the repo at implementation time (2026-09-02, after plan-01 and plan-02 were implemented) and only findings that still hold are recorded as open; the rest are recorded with the state that superseded them. Citations marked **(pre-change)** refer to the last commit before the change (`5f0725d`); citations marked **(observed 2026-09-02)** refer to the working tree at implementation time. The four goals below are reconstructed from the review summary captured in the change's canvas — the review itself was not yet persisted (that is finding 5.1).

---

## Goal 1 — Mirror docs stay accurate and in sync

**Finding 1.1 — Eval id enumerations in the mirror docs were stale (pre-change, fixed by plan-01).**
The Structure sections of `CLAUDE.md` and `AGENTS.md` hardcoded eval id ranges that had drifted from the actual `*/evals/evals.json` files:

- `CLAUDE.md:21` (pre-change) claimed the agent suite covered "evals 31–38, 48, 67–68"; the file actually contains ids 31–48 and 67–72 (24 evals). `AGENTS.md:25` (pre-change) had the correct "31–48, 67–72" — the two mirror docs disagreed with each other on the same row.
- `CLAUDE.md:26` (pre-change) claimed canvas evals "1–3, 9–10, 48–50"; the file also contains ids 52–54.
- `CLAUDE.md:35` (pre-change) claimed verify evals "15–19, 30–36, 51"; the file also contained ids 56 and 60–62.

*Re-verification (observed 2026-09-02):* `grep -rn "evals [0-9]" CLAUDE.md AGENTS.md` returns nothing — the enumerations were deleted outright and `*/evals/evals.json` is the single source of truth, per the canvas acceptance criterion.

**Finding 1.2 — The mirror Norm was a blanket rule both files already violated (pre-change, fixed by plan-01).**
`spdd/specs/spdd-agent.md:164` (pre-change) read "Mirror any Structure/Conventions/Gotchas edit into both `CLAUDE.md` and `AGENTS.md`." — yet `CLAUDE.md` had no `## Conventions` heading at all (its content was merged into `## Gotchas`) and was missing at least four shared bullets present in `AGENTS.md`. A norm the codebase violates on every read is worse than no norm.

*Re-verification (observed 2026-09-02):* the Norm at `spdd/specs/spdd-agent.md:164` now states the real policy — shared sections (Structure, Conventions, Gotchas) byte-identical across both files; audience-specific sections (Overview and Evaluating skills / Claude Code Integration in `CLAUDE.md`, Overview and Auto-triggers in `AGENTS.md`) may differ by design (Overview added to the exception 2026-09-02, foreground checkpoint). Plan-01 re-synced the shared sections byte-identical, adopting the verified `AGENTS.md` side as target; `CLAUDE.md` gained a `## Conventions` heading in the process.

## Goal 2 — Fold-backs keep the living specs integral

**Finding 2.1 — Nothing checked a spec's integrity after a fold-back (pre-change, fixed by plan-02).**
`spdd-verify`'s fold-back (Step 8) could complete and archive with a damaged spec. This was the root cause of the audit defects repaired the same day in commit `5f0725d` (SPDD-2026-09-02-1228): a duplicated `## Operations` heading in `spdd/specs/spdd-design.md` and an orphan unresolved `> ⚠️ Confirm:` blockquote in `spdd/specs/spdd-migrate.md`. The repair fixed the instances; nothing prevented recurrence. `spdd-verify/SKILL.md` (pre-change) was at `version: "2.0"` with no integrity check in Step 8.

*Re-verification (observed 2026-09-02):* `spdd-verify/SKILL.md:82` now requires, before reporting a fold as successful, an inspection of the resulting spec for (a) orphan unresolved `> ⚠️ Confirm:` blockquotes and (b) duplicated `##` section headings; findings block the "folded" claim and the archive. `metadata.version` is `"2.1"` (`spdd-verify/SKILL.md:9`), and evals 63–65 were added to `spdd-verify/evals/evals.json` covering the clean fold, the duplicate-heading case, and the orphan-Confirm case. The guard is host-agnostic (defined in the skill's prose, no hook extension — Confirm 2 declined that "for now").

## Goal 3 — Eval assets stay valid without manual attention

**Finding 3.1 — No automated validation of eval assets (held at implementation time; implemented by plan-03).**
The seven `spdd-*/evals/evals.json` files had no automated check for JSON validity, id uniqueness, or required fields — exactly the class of drift documented in finding 1.1. `scripts/check-hook-sync.sh` existed but was manual-only, and there was no `.github/` directory at all (observed 2026-09-02).

*Status:* implemented by plan-03 — `.github/workflows/evals.yml` runs on push/PR touching any `**/evals/evals.json` or `**/assets/hook-setup.md`, validates every eval file (parses as JSON, ids unique across the file, non-empty `prompt`/`assertions`), runs `scripts/check-hook-sync.sh`, and fails on any violation. It contains no `secrets:` usage and passes on a fresh fork; the agent-run eval suites stay out of CI (expensive, API keys) — see the deferred list in the postscript.

## Goal 4 — Specs stay cheap to read and maintain as they grow

**Finding 4.1 — No documented size policy for living specs (held at implementation time; implemented by plan-03).**
`README.md` said nothing about how large a domain spec may grow or how to compact one (grep for registry/budget/assessment/compaction topics over `README.md`: no matches, observed 2026-09-02). With every verified change folding into `spdd/specs/<domain>.md`, unbounded growth was the default trajectory.

*Status:* implemented by plan-03 — `README.md` now documents the soft budget (~150 lines per domain spec) and the consolidation convention (merge superseded scenarios, drop volatile state, split at a `##` section boundary). Doc-only, per Confirm 4; no `spdd-verify` behavior change enforces it.

## Meta — the review itself

**Finding 5.1 — The review was not persisted (held at implementation time; implemented by plan-03).**
The 2026-09-02 review lived only in conversation; its actionable summary survived solely through the canvas of SPDD-2026-09-02-1324. *Status:* implemented by plan-03 — this document, at the repo root (`REVIEW-2026-09-02-framework-assessment.md`), linked from `README.md`.

---

## Prioritized recommendations

Priorities follow the canvas's item order (the recommended default). Status is as of 2026-09-02, after SPDD-2026-09-02-1324.

| # | Recommendation | Addresses | Status |
|---|----------------|-----------|--------|
| 1 | Remove eval id enumerations from the mirror docs; re-sync shared sections; reword the mirror Norm to the real sync policy | 1.1, 1.2 | Implemented (plan-01) |
| 2 | Add a fold-back integrity guard to `spdd-verify` Step 8 (orphan Confirms, duplicate `##` headings); bump to v2.1 with evals 63–65 | 2.1 | Implemented (plan-02) |
| 3 | Lightweight static CI workflow for eval assets + hook-asset sync; keep agent-run suites manual, registry convention for results | 3.1 | Implemented (plan-03) |
| 4 | Document the spec size budget and consolidation convention in `README.md` (doc-only) | 4.1 | Implemented (plan-03) |
| 5 | Persist this assessment in-repo, linked from `README.md` | 5.1 | Implemented (plan-03) |

## Postscript — implemented vs. deferred (2026-09-02)

**Implemented by SPDD-2026-09-02-1324:**

- **plan-01 (doc hygiene + mirror norm):** eval id ranges deleted from all seven `evals.json` Structure rows in `CLAUDE.md` and `AGENTS.md`; the shared Structure/Conventions/Gotchas sections re-synced byte-identical across both files (verified `AGENTS.md` side adopted as target; `CLAUDE.md` gained a `## Conventions` heading and the four-plus-one missing shared bullets); the mirror Norm in `spdd/specs/spdd-agent.md` reworded from the blanket mirror rule to shared-sections-identical + documented audience exception (Overview added to the exception at the foreground checkpoint).
- **plan-02 (fold-back integrity guard):** `spdd-verify/SKILL.md` Step 8 extended with the pre-completion integrity check (orphan `> ⚠️ Confirm:` blockquotes; duplicated `##` headings in the folded spec — findings block the "folded" claim and the archive); `metadata.version` bumped 2.0 → 2.1; evals 63–65 added (clean fold, duplicate heading, orphan Confirm).
- **plan-03 (this plan):** `.github/workflows/evals.yml` (static-only, no secrets); `README.md` "Eval results registry" and "Spec size budget" sections plus the link to this document; this assessment persisted at the repo root.

**Deferred, with reason:**

- **Agent-run eval suites in CI** — expensive and API-key-dependent; out of scope by canvas decision. The registry convention (commit summaries, raw output stays in the gitignored `evals/workspace/`) covers visibility instead.
- **Spec-budget enforcement in code** — Confirm 4 kept the policy doc-only; no `spdd-verify` behavior change enforces the ~150-line budget.
- **Hook-level extension of the fold guard** — Confirm 2 declined it "for now"; the integrity check lives in `spdd-verify` Step 8 prose and is host-agnostic.
- **`spdd/norms.md`** — team-maintained by convention; no skill (and no plan in this change) creates it, and it doesn't exist in this repo.
- **Old `docs/` layout** — stays deleted and gitignored; nothing recreates it.
