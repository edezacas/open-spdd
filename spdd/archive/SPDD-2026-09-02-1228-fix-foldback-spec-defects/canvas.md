# REASONS: Fix fold-back defects in the living specs (audit remediation)

> Generated on 2026-09-02. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.

**Status:** Verified

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, I want the living specs under `spdd/specs/*.md` to faithfully
document the skills' current behavior — without duplicate sections, stale `⚠️ Confirm:` lines,
obsolete out-of-scope notes, leaked plan prose, or drifting version counters — so that the specs
remain the trustworthy source of truth that `spdd-verify` folds into and every later SPDD run reads.

**Acceptance criteria:**

*(Every item below edits spec documents only — no `SKILL.md` or code behavior changes. Each defect was verified against the repo before writing this canvas.)*

- **[MODIFIED]** Scenario: `spdd-design.md` has exactly one `## Operations` section
  - WHEN the two `## Operations` sections (currently at lines 47 and 59) are merged
  - THEN the file contains exactly one `## Operations` heading; the surviving table is the union of both tables' rows with the duplicated homogeneity rule collapsed into the single richer "Homogeneity criterion" row — no row content is lost, no near-duplicate row survives
- **[MODIFIED]** Scenario: `spdd-migrate.md` carries no unresolved `⚠️ Confirm:`
  - WHEN the `⚠️ Confirm:` at line 24 (asking for Requirements scenarios for the v2.0 behavior: closed/active routing, feature-doc folding, idempotency, hook rewrite) is resolved
  - THEN the Requirements section gains hand-authored `WHEN/THEN` scenarios for those four behaviors, each citing the `spdd-migrate/SKILL.md` step it documents (current skill version 2.1 — behavior unchanged since v2.0); the stale `⚠️ Confirm:` line is deleted; the historical fold note above it (2026-09-01) is left untouched (forward-only rule) — *Resolved 2026-09-02: hand-author the scenarios from the current v2.1 SKILL.md*
- **[MODIFIED]** Scenario: `spdd-verify.md` no longer contradicts `spdd-verify/SKILL.md` about global-norms validation
  - WHEN the obsolete "Out of scope (deliberate)" bullet at line 54 (claiming the Diff-to-canvas check validates only against the source canvas/plan, never against `spdd/norms.md`) is updated
  - THEN the bullet is replaced with the accurate statement that since Mejora 4, Step 7 point 4 (`spdd-verify/SKILL.md:65-67`) validates the diff against every rule in `spdd/norms.md` when that file exists, treating violations like canvas discrepancies; the Operations row for the Diff-to-canvas check (line 81) is extended to mention the global-norms validation pass; the other two out-of-scope bullets (static analysis, Step 3 complement) are untouched
- **[MODIFIED]** Scenario: `spdd-implement.md` Norms contain only norms
  - WHEN the plan prose leaked into the Norms section at line 58 ("This plan is implemented after `plan-01-spdd-canvas.md`; the eval ID range…") is cleaned up
  - THEN that line is deleted and the neighboring line 59 ("Test coverage: … cases 54–55") is preserved — it is a legitimate coverage norm, matching the pattern other specs use
- **[MODIFIED]** Scenario: no spec tracks a volatile version counter — *Resolved 2026-09-02: replace with the source-of-truth norm*
  - WHEN the "Increment `metadata.version` … (currently at X)" lines in the Norms of all 7 specs (`spdd-agent.md:157`, `spdd-canvas.md:102`, `spdd-design.md:70`, `spdd-implement.md:56`, `spdd-verify.md:97`, `spdd-sync.md:53`, `spdd-migrate.md:56`) are removed
  - THEN each is replaced by a single source-of-truth norm — the authoritative version of a skill is the `metadata.version` in its own `SKILL.md` frontmatter; spec Norms never restate a counter — and the concrete drift driving this defect (`spdd-agent.md:157` says "1.13" while `spdd-agent/SKILL.md` frontmatter is "1.14") disappears by construction
- **[NEW]** Scenario: `spdd-sync.md` documents its core behavior guardrail in Requirements — *Resolved 2026-09-02: author now*
  - WHEN the foundational scenario is hand-authored from `spdd-sync/SKILL.md` Step 4
  - THEN the Requirements section states: WHEN Step 3 finds anything suggesting a change in observable behavior (not just shape) THEN `spdd-sync` does not touch Requirements, stops, and tells the user this is not a sync case — behavior changes need a new canvas via `spdd-canvas` — never rewriting behavior silently; the scenario cites `spdd-sync/SKILL.md` Step 4 as its source
- **[NEW]** Scenario: `spdd-implement.md` documents its three foundational gates in Requirements — *Resolved 2026-09-02: author now*
  - WHEN the foundational scenarios are hand-authored from `spdd-implement/SKILL.md` Steps 3, 4, and 6
  - THEN the Requirements section gains: (a) the dependency check — WHEN the plan declares `Depends on:` other than `none` and any dependency is not yet `Status: Implemented` THEN `spdd-implement` warns explicitly and asks for confirmation before continuing, never proceeding silently (Step 3); (b) the `⚠️ Confirm:` gate — WHEN unresolved `⚠️ Confirm:` lines exist in the canvas or plan THEN `spdd-implement` stops, lists them, asks for confirmation of each, replaces each with the confirmed value, and sets `Status: Confirmed` before proceeding (Step 4); (c) the divergence protocol — WHEN the canvas or plan is discovered to be wrong or incomplete during implementation THEN `spdd-implement` stops, explains the divergence, proposes the update, and resumes only once the user confirms (Step 6); each scenario cites its source step

**Out of scope:**
- Any edit to `SKILL.md` files, `evals/evals.json`, templates, or `assets/` — all six defects are spec-document drift, not skill behavior drift (verified: the skills already do what the specs fail to say, except where the spec says something the skill no longer does).
- Creating `spdd/norms.md` for this repo — it does not exist here and is team-maintained; no skill creates or edits it.
- A full `spdd-sync` pass over the `spdd-agent` domain — **executed 2026-09-02, pre-implementation** (per the staleness checkpoint decision): the spec's Entities/Operations now cover Step 2's three isolation modes and Step 3-alt (inline), the Step 3 row notes the phase-chaining fix, and the counter was corrected 1.13 → 1.14. The only gap left is the v1.14 *behavior* Requirements scenarios, which arrive via the next verified change's fold-back, not by hand-authoring here.
- Retranslating or rewriting historical notes/fold annotations in the specs — forward-only rule.
- The meta fold-back of *this very change* into the specs is expected to be a near-no-op dedupe: the implemented edits ARE the spec edits. See Safeguards.

---

## Entities

All entities are existing Markdown documents being repaired. No new entities, no schema changes.

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| `spdd-design` spec | `spdd/specs/spdd-design.md` | Existing | Merge duplicate `## Operations` sections (lines 47 + 59); drop counter line 70 |
| `spdd-migrate` spec | `spdd/specs/spdd-migrate.md` | Existing | Resolve `⚠️ Confirm:` (line 24) by authoring 4 v2.0-behavior scenarios; drop counter line 56 |
| `spdd-verify` spec | `spdd/specs/spdd-verify.md` | Existing | Replace obsolete out-of-scope bullet (line 54); extend Operations row (line 81); drop counter line 97 |
| `spdd-implement` spec | `spdd/specs/spdd-implement.md` | Existing | Delete leaked plan prose (line 58); author 3 foundational scenarios; drop counter line 56 |
| `spdd-sync` spec | `spdd/specs/spdd-sync.md` | Existing | Author Step 4 guardrail scenario; drop counter line 53 |
| `spdd-agent` spec | `spdd/specs/spdd-agent.md` | Existing | Drop counter line 157 (currently misstated "1.13"; skill is at 1.14) |
| `spdd-canvas` spec | `spdd/specs/spdd-canvas.md` | Existing | Drop counter line 102 |

---

## Approach

- [ ] Full CRUD (model + repository + service + controller/handler)
- [ ] Endpoint/handler only (on an existing entity)
- [x] Service/internal logic only (no presentation layer) — closest fit: content-only edits to existing spec documents, no executable code touched
- [ ] Async worker / job
- [ ] External service integration — specify: ___
- [ ] UI component / page

**Rationale:**
This is an audit-remediation change over Markdown documents that happen to live in `spdd/specs/`. There is no code, no runtime, no API — the "implementation" is a set of precise document edits whose correctness is checkable by grep and by reading. A single unified canvas covers all 7 spec files because the defects share one root cause (fold-back imperfections across the same audit) and one review pass; splitting per-domain would create 7 trivial plans with heavy shared context duplication.

---

## Structure

```
spdd/specs/spdd-design.md        # merge Operations sections; remove version counter
spdd/specs/spdd-migrate.md       # resolve Confirm; author v2.0 scenarios; remove version counter
spdd/specs/spdd-verify.md        # fix out-of-scope bullet + Operations row; remove version counter
spdd/specs/spdd-implement.md     # remove leaked prose; author 3 foundational scenarios; remove counter
spdd/specs/spdd-sync.md          # author guardrail scenario; remove version counter
spdd/specs/spdd-agent.md         # remove version counter (misstated 1.13 vs actual 1.14)
spdd/specs/spdd-canvas.md        # remove version counter
```

No other files are touched. `spdd/norms.md` does not exist in this repo and is not created.

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Merge | `spdd/specs/spdd-design.md` — `## Operations` | Fuse the two `## Operations` sections (lines 47, 59) into one: keep the richer 5-row table, collapse the second table's homogeneity row into the existing "Homogeneity criterion" row, delete the second heading. Row-set diff before/after must show union minus exact duplicates only |
| Resolve | `spdd/specs/spdd-migrate.md:24` — stale `⚠️ Confirm:` | Author Requirements `WHEN/THEN` scenarios for: closed-canvas routing → `spdd/archive/` as `Status: Verified`; active-canvas routing → `spdd/changes/` status-preserved; feature-doc fold with source marker; idempotency checks; hook rewrite (Claude Code only) — each citing `spdd-migrate/SKILL.md` (v2.1) Steps 2–5; then delete the Confirm line, keep the historical fold note |
| Correct | `spdd/specs/spdd-verify.md:54` — obsolete out-of-scope bullet | Replace with the accurate statement (global-norms validation exists since Mejora 4, `spdd-verify/SKILL.md` Step 7 point 4); extend the Step 7 Operations row (line 81) to mention the `spdd/norms.md` validation pass; leave the other two bullets intact |
| Remove | `spdd/specs/spdd-implement.md:58` — leaked plan prose | Delete the "This plan is implemented after `plan-01-spdd-canvas.md`…" line from Norms; keep line 59 (test-coverage norm) |
| Replace | 7 × version-counter Norms | Replace each "Increment `metadata.version` … (currently at X, cumulative across changes)" line with: "The authoritative version of a skill is the `metadata.version` in its own `SKILL.md` frontmatter — spec Norms never restate a version counter (removed 2026-09-02 after the counter drifted: spdd-agent said 1.13, skill was 1.14)" |
| Author | `spdd/specs/spdd-sync.md` — Requirements | Add the Step 4 behavior-guardrail scenario (observable-behavior suspicion → stop, never touch Requirements, redirect to `spdd-canvas`), citing `spdd-sync/SKILL.md` Step 4 |
| Author | `spdd/specs/spdd-implement.md` — Requirements | Add the three foundational scenarios (dependency check, `⚠️ Confirm:` gate + `Status: Confirmed`, divergence stop-and-confirm protocol), citing `spdd-implement/SKILL.md` Steps 3, 4, 6 |

---

## Norms

Feature-specific:

- Spec edits are content-only: no `SKILL.md`, eval, template, or asset file is modified in this change — the skills' behavior is already correct; only the documentation of it drifted.
- Every hand-authored Requirements scenario must cite the exact `SKILL.md` step it documents, so the next `spdd-sync`/fold-back can re-verify it against the source.
- Hand-authoring Requirements into a living spec is a deliberate, audit-driven exception to the normal fold-back-only flow — it must be recorded as such in each spec's edit (short parenthetical or note), never silently mixed with folded content.
- The merge in `spdd-design.md` is a dedupe, not a rewrite: content present before the merge and absent after, without being an exact near-duplicate, is a failure.
- `spdd/norms.md` does not exist in this repo — nothing to carry over; the Norms above come from this canvas and the repo's `AGENTS.md` conventions.

From `AGENTS.md` / project conventions:

- SPDD document content (specs, canvases, plans) is always written in English; conversational replies follow the conversation's language.
- Unresolved `⚠️ Confirm:` items must be resolved before implementation (`spdd-implement` Step 4 enforces this gate).
- Acceptance criteria and Safeguards edge cases are written as `WHEN/THEN` scenarios, not freeform checkboxes.
- `spdd/specs/<domain>.md` is the living, cumulative source of truth per domain — treat every edit here as an edit to the contract downstream runs read.

---

## Safeguards

**Tests to write:**
- [ ] No executable code exists in this change — "tests" are content checks, run after implementation:
  - `grep -c '^## Operations' spdd/specs/spdd-design.md` returns exactly `1`
  - `grep -rn 'currently at' spdd/specs/` returns nothing
  - `grep -n '^> ⚠️ Confirm:' spdd/specs/spdd-migrate.md` returns nothing — no unresolved Confirm blockquote (the file legitimately keeps 3 descriptive mentions of the marker; check wording refined at the 2026-09-02 foreground checkpoint)
  - `grep -n 'plan-01' spdd/specs/spdd-implement.md` returns nothing
  - `grep -n 'not against project-wide norms' spdd/specs/spdd-verify.md` returns nothing
  - `grep -c 'metadata.version' spdd/specs/*.md` — each file mentions the frontmatter as source of truth, none states a counter value

**Edge cases to consider (as WHEN/THEN scenarios — `spdd-verify` writes a targeted check for each one not already covered):**

- Scenario: the Operations merge drops a row
  - WHEN the two tables in `spdd-design.md` are fused
  - THEN a before/after row-set diff shows the union of rows minus exact/near-duplicates only; any silently missing row fails the check
- Scenario: an authored scenario contradicts the skill it documents
  - WHEN a foundational scenario is written into `spdd-sync.md` or `spdd-implement.md`
  - THEN the cited `SKILL.md` step is read side-by-side and the scenario's WHEN/THEN matches its actual behavior — a mismatch fails the check and is not resolved by editing the `SKILL.md`
- Scenario: counter removal damages neighboring norms
  - WHEN the version-counter lines are replaced in the 7 specs
  - THEN only those single lines change; adjacent norm lines (e.g. `spdd-implement.md` line 59, `spdd-agent.md` never-block and mirror norms) survive byte-identical
- Scenario: `spdd-migrate` Confirm resolution invents behavior
  - WHEN the v2.0-behavior scenarios are authored
  - THEN each scenario is backed by the current `spdd-migrate/SKILL.md` (v2.1) prose and the spec's own Entities/Operations tables; anything the prose doesn't support becomes a new `⚠️ Confirm:` instead of a guess (mirrors the spec's own "never invent detail" norm)
- Scenario: fold-back of this change duplicates the authored Requirements
  - WHEN `spdd-verify` later folds this verified change back into the same specs it edited
  - THEN the name/identifier dedupe recognizes the already-present scenarios and notes — the fold is a no-op annotation, not a duplication
- Scenario: a Confirm line in this canvas is unresolved when implementation starts
  - WHEN `spdd-implement` reaches Step 4 with any `⚠️ Confirm:` still open in this canvas
  - THEN it stops and lists them before any edit — the built-in gate, not a new safeguard

**Production rollback:**
All edits are to git-tracked Markdown; a single `git revert` of the implementation commit restores every spec. No caches, no hooks, no config, no state outside the repo.

---

## ⚠️ Confirm lines — resolved 2026-09-02 (foreground checkpoint)

- `spec stale — 1 commits since (ddb9254)` → **User chose: run `spdd-sync` first.** Executed inline on the `spdd-agent` domain before implementation (see Out of scope for scope notes).
- `version-counter policy` → **Confirmed: replace-with-norm** (the recommended default; outright deletion was declined).
- `foundational-scenarios policy` → **Confirmed: author now** (the recommended default).
- `spdd-migrate Confirm resolution method` → **Confirmed: author manually** (the recommended default).
