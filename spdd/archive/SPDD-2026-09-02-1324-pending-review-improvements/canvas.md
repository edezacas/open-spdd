# REASONS: Implement the pending framework-review improvements

> Generated on 2026-09-02. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.

**Status:** Confirmed

---

## Requirements

**User story:**
As the maintainer of `open-spdd`, I want the five pending improvements identified by the
2026-09-02 framework review (doc hygiene, a fold-back integrity guard, eval CI, a spec
compaction policy, and the persisted assessment) implemented, so that the framework's own
hygiene mechanisms stop regressing and stay cheap to run for the whole team.

**Acceptance criteria:**

*(Context: the living specs were freshly repaired in SPDD-2026-09-02-1228 (commit 5f0725d) — no stale-spec risk. Items marked ⚠️ depend on Confirm decisions below; the canvas proposes a default for each.)*

- **[MODIFIED]** Scenario: eval enumerations are gone from the mirror docs
  - WHEN the per-skill eval id ranges are removed from `CLAUDE.md` and `AGENTS.md` Structure sections (stale today: canvas ids 52–54 and verify ids 56, 60–62 undocumented; `CLAUDE.md` lists agent evals as "31–38, 48, 67–68" while the file has 31–48, 67–72)
  - THEN neither file states eval id ranges — `*/evals/evals.json` stays the single source of truth — and the surrounding Structure entries keep their path + purpose description

- **[MODIFIED]** Scenario: the mirror norm reflects the real sync policy
  - WHEN the mirror Norm in `spdd/specs/spdd-agent.md` is updated alongside the doc cleanup
  - THEN it states: shared sections (Structure, Conventions, Gotchas) must stay identical across `CLAUDE.md` and `AGENTS.md`; audience-specific sections (Claude Code Integration / Evaluating skills in `CLAUDE.md` vs. host-agnostic Auto-triggers in `AGENTS.md`) may differ by design — replacing the blanket "mirror any edit" rule both files already violate — *Resolved 2026-09-02: shared-sections-identical + documented audience exception*
- **[MODIFIED]** Scenario: shared sections are byte-identical after the cleanup
  - WHEN the Structure/Conventions/Gotchas sections of both files are re-synced
  - THEN extracting those sections from each file and diffing them yields zero differences; the only remaining inter-file differences are the documented audience-specific sections

- **[MODIFIED]** Scenario: `spdd-verify` folds only into integral specs — *Resolved 2026-09-02: extend spdd-verify Step 8*
  - WHEN `spdd-verify` completes the fold-back of a verified change into `spdd/specs/<domain>.md` (SKILL.md Step 8)
  - THEN before reporting success it checks the resulting spec for (a) orphan unresolved `> ⚠️ Confirm:` blockquotes and (b) duplicated `##` section headings; any finding is reported and blocks the "folded" claim until fixed — root cause of the 2026-09-02 audit defects (duplicate `## Operations` in design, orphan Confirm in migrate), host-agnostic — *Resolved 2026-09-02: extend spdd-verify Step 8*

- **[NEW]** Scenario: eval assets get a lightweight CI guard
  - WHEN a push or PR touches any `*/evals/evals.json` or `assets/hook-setup.md`
  - THEN a GitHub Actions workflow validates every `evals.json` (parses as JSON, ids unique across the file, `prompt`/`assertions` non-empty), runs `scripts/check-hook-sync.sh`, and fails on any violation — agent-run eval suites stay manual — *Resolved 2026-09-02: lightweight static workflow + registry convention*

- **[NEW]** Scenario: the spec compaction policy is documented
  - WHEN a team wonders how large a domain spec may grow
  - THEN `README.md` documents a soft budget (~150 lines per domain spec) and the consolidation convention (merge superseded scenarios, drop volatile state, split at section boundaries) — doc-only in this change, no enforcement — *Resolved 2026-09-02: doc-only*

- **[NEW]** Scenario: the 2026-09-02 assessment is persisted in-repo
  - WHEN the review document is saved
  - THEN it lives at `REVIEW-2026-09-02-framework-assessment.md` (repo root, English — findings against the four goals, concrete drift evidence, prioritized recommendations, with a postscript noting what this change implemented vs. deferred), linked from `README.md` — *Resolved 2026-09-02: root file + README link*

**Out of scope:**
- Running the agent-based eval suites in CI (expensive, needs API keys) — the workflow only does static checks.
- Enforcing the spec budget in code (no `spdd-verify` behavior change for compaction) unless Confirm 4 says otherwise.
- Recreating a `docs/` folder (deleted and gitignored by decision 2026-09-02) or `spdd/norms.md` (team-maintained, doesn't exist here).
- Editing any `SKILL.md` other than `spdd-verify/SKILL.md` (and only if Confirm 2 keeps the fold-back guard).

---

## Entities

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| Mirror doc (Claude Code view) | `CLAUDE.md` | Existing | Remove eval ranges; re-sync shared sections |
| Mirror doc (host-agnostic view) | `AGENTS.md` | Existing | Same treatment; audience sections stay |
| Mirror norm | `spdd/specs/spdd-agent.md` (Norms) | Existing | Reword the blanket mirror rule |
| Verify skill | `spdd-verify/SKILL.md` | Existing | Step 8 fold-back integrity guard; version bump v2.0 → v2.1 (only if Confirm 2 keeps it) |
| Verify evals | `spdd-verify/evals/evals.json` | Existing | New evals for the integrity guard (unique ids, continuing the existing sequence) |
| CI workflow | `.github/workflows/evals.yml` | New | Static validation only, no secrets |
| Project README | `README.md` | Existing | Eval-results registry convention + spec compaction policy + assessment link |
| Assessment doc | `REVIEW-2026-09-02-framework-assessment.md` | New | The persisted review (English) |

---

## Approach

- [ ] Full CRUD (model + repository + service + controller/handler)
- [ ] Endpoint/handler only (on an existing entity)
- [x] Service/internal logic only (no presentation layer) — documentation hygiene + one skill-behavior guard + repo tooling (CI workflow); no runtime code
- [ ] Async worker / job
- [ ] External service integration — specify: ___
- [ ] UI component / page

**Rationale:**
One canvas for the batch: all five items share the same root (the 2026-09-02 review), one review pass, and overlapping files (`README.md`, the mirror norm, `spdd-verify`). `spdd-design` decides the plan split — the natural seam is docs+mirror-norm vs. verify-guard vs. CI+README+assessment.

---

## Structure

```
CLAUDE.md                                     # remove eval ranges; re-sync shared sections
AGENTS.md                                     # same
spdd/specs/spdd-agent.md                      # reword the mirror Norm
spdd-verify/SKILL.md                          # Step 8 integrity guard + version bump (if confirmed)
spdd-verify/evals/evals.json                  # new evals for the guard (if confirmed)
.github/workflows/evals.yml                   # new — static eval-asset validation
README.md                                     # registry convention, compaction policy, assessment link
REVIEW-2026-09-02-framework-assessment.md     # new — persisted review
```

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Remove | `CLAUDE.md` + `AGENTS.md` eval id ranges | Delete every "evals <ids>:" enumeration from the Structure sections; keep path + purpose text |
| Update | `spdd/specs/spdd-agent.md` mirror Norm | Replace the blanket mirror rule with the shared-sections-identical / audience-sections-may-differ policy |
| Sync | Shared sections of `CLAUDE.md` / `AGENTS.md` | Make Structure, Conventions, and Gotchas sections byte-identical across both files |
| Extend | `spdd-verify/SKILL.md` Step 8 | Add the pre-completion integrity check (orphan `> ⚠️ Confirm:` blockquotes; duplicate `##` headings in the folded spec); bump `metadata.version` to 2.1 |
| Add | `spdd-verify/evals/evals.json` cases | Cover: guard passes on a clean fold; guard flags a duplicate heading; guard flags an orphan Confirm |
| Create | `.github/workflows/evals.yml` | on: push/PR touching `**/evals/evals.json` or `**/assets/hook-setup.md`; steps: JSON validity + id uniqueness + required fields per eval; `bash scripts/check-hook-sync.sh` |
| Document | `README.md` | Add "Eval results registry" convention (agent-run results committed as summaries) and "Spec size budget" section; link the assessment doc |
| Create | `REVIEW-2026-09-02-framework-assessment.md` | Persist the 2026-09-02 review (four-goal assessment, drift evidence, prioritized recommendations, implemented-vs-deferred postscript) |

---

## Norms

Feature-specific:

- Every document authored in this change is in English (mirror docs, README, workflow comments, assessment, spec norm reword).
- Any edited `SKILL.md` increments its `metadata.version` (only `spdd-verify` is expected to change: v2.0 → v2.1, gated on Confirm 2).
- New eval ids continue each file's existing sequence without collisions.
- `.github/` and `scripts/` are repo tooling: no `SKILL.md` may reference them at execution time (existing convention).
- `docs/` stays deleted and gitignored; nothing recreates it.
- The assessment document records evidence, not aspiration — every finding cites the file/line it observed.

From `AGENTS.md` / project conventions:

- SPDD document content is always written in English; conversational replies follow the conversation's language.
- Unresolved `⚠️ Confirm:` items must be resolved before implementation.
- `spdd/specs/<domain>.md` is the living source of truth — the mirror-norm reword is itself a spec Norm edit, folded and archived like any other change.

---

## Safeguards

**Tests to write (content/tooling checks, run after implementation):**
- [ ] `grep -rn "evals [0-9]" CLAUDE.md AGENTS.md` → nothing
- [ ] Extracted Structure/Conventions/Gotchas sections of both mirror docs diff → empty
- [ ] All 7 `evals.json` parse as JSON; ids unique per file; every eval has non-empty `prompt` and `assertions`
- [ ] `bash scripts/check-hook-sync.sh` → OK
- [ ] `spdd-verify/SKILL.md` frontmatter version bumped (if Confirm 2 keeps the guard)
- [ ] `.github/workflows/evals.yml` parses as YAML and contains no `secrets:` usage
- [ ] `test -f REVIEW-2026-09-02-framework-assessment.md` and README links it

**Edge cases to consider (as WHEN/THEN scenarios — `spdd-verify` writes a targeted check for each one not already covered):**

- Scenario: shared-section sync accidentally moves an audience-specific fact
  - WHEN the shared sections are made byte-identical
  - THEN the section diff shows zero differences and a spot-check confirms no Claude-Code-only fact landed in `AGENTS.md` (or vice versa); anything beyond the documented audience sections differing is a failure
- Scenario: new eval ids collide with existing ones
  - WHEN the new verify evals are appended
  - THEN an id-uniqueness check over the whole file passes; a collision fails the change
- Scenario: the new fold guard fires on this very change's fold
  - WHEN `spdd-verify` folds this verified change into `spdd/specs/spdd-agent.md` (mirror-norm reword)
  - THEN the integrity check finds nothing (specs were just repaired) — a finding here is a real regression, not noise
- Scenario: CI workflow would need secrets
  - WHEN the workflow is authored
  - THEN it contains no `secrets:` and would pass on a fresh fork — otherwise the static-only scope was violated
- Scenario: the assessment doc contradicts the implemented state
  - WHEN the assessment is written after implementation
  - THEN its postscript lists exactly what this change implemented vs. deferred; a stale claim about implementation state fails the check

**Production rollback:**
All edits are git-tracked text; a single `git revert` restores everything. The new workflow file only activates on future pushes — reverting the commit removes it cleanly.

---

## ⚠️ Confirm lines — resolved 2026-09-02 (foreground checkpoint)

- `1 — mirror policy` → **Confirmed: shared-sections-identical + documented audience exception** (the recommended default).
- `2 — fold-back integrity guard owner` → **Confirmed: extend spdd-verify Step 8** (the recommended default; hook extension declined for now).
- `3 — CI scope` → **Confirmed: lightweight static workflow** + manual-evals registry convention (the recommended default).
- `4 — compaction enforcement` → **Confirmed: doc-only policy in README** (the recommended default).
- `5 — assessment home` → **Confirmed: repo-root `REVIEW-2026-09-02-framework-assessment.md` + README link** (the recommended default).
