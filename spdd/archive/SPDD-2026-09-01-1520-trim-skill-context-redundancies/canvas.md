# REASONS: Trim redundant context across SPDD skills

> Generated on 2026-09-01. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.

**Status:** Verified

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, we want the skill files and assets stripped of duplicated or
self-repeating prose found in the redundancy review, so that every agent run loads fewer tokens
without changing any observable behavior of the framework.

**Acceptance criteria:**

*(Each scenario below is a [MODIFIED] prose-economy change: observable outputs stay identical; only the amount of instruction text loaded per run shrinks.)*

- **[MODIFIED]** Scenario: `spdd-migrate` states the English rule once
  - WHEN `spdd-migrate/SKILL.md` instructs about output language
  - THEN a single top-level language note covers both the `WHEN/THEN` reformatting prose (Step 2) and the newly authored spec prose (Step 3), replacing the two per-step blockquotes — reformatting and spec-fold outputs remain English in all cases

- **[MODIFIED]** Scenario: `spdd-migrate` states the non-destructive default once
  - WHEN the migration flow runs
  - THEN Step 2's point 6 ("Do not delete the original file in this step") is removed as subsumed by Step 4, which keeps forbidding deletion of `docs/prompts/*.md` and `docs/features/*.md` outside the explicit Step 7 cleanup — behavior unchanged

- **[MODIFIED]** Scenario: `spdd-design` Step 7 delegates field guidance to the template
  - WHEN `spdd-design` generates plan(s) after reading `template-plan.md` in Step 6
  - THEN the `Depends on:` and `Shared touchpoints:` bullets are not restated in Step 7 (the template already owns that guidance); generated plans still carry both fields with the same semantics

- **[MODIFIED]** Scenario: change lookup is self-contained in each skill
  - WHEN `spdd-design` Step 1 or `spdd-verify` Step 1 must locate a change without an argument
  - THEN each skill states the lookup inline ("list `spdd/changes/` entries matching `SPDD-*`, most recent first") instead of referencing `spdd-implement` Step 1 — a subagent running one skill no longer depends on another skill's text

- **[MODIFIED]** Scenario: `model-bootstrap.md` opens lean and states flat-key immutability once
  - WHEN `spdd-agent/assets/model-bootstrap.md` is read
  - THEN it opens with a ≤2-sentence scope note (down from a 6-line paragraph), the "never merge or delete the flat key" rule appears only once (in the migration section), and the line-22 parenthetical is gone — both JSON shape examples and every `AskUserQuestion` mechanic stay intact

- **[MODIFIED]** Scenario: hook-presence check keeps its semantics with less text
  - WHEN `spdd-canvas` Step 9, `spdd-implement` Step 5, or `spdd-verify` Step 9 runs on Claude Code
  - THEN the step checks `.claude/settings.local.json` for the SPDD guard hook and `"subagentPromptCacheTtl"` (grep intent preserved in one sentence instead of a literal bash block) and still reads `assets/hook-setup.md` only when something is missing

- **[MODIFIED]** Scenario: `spdd-canvas` Step 10 stops explaining another skill's internals
  - WHEN `spdd-canvas` reports back
  - THEN it suggests `/spdd-design` as the next step without restating `spdd-implement`'s "never implements from the canvas" rule (already owned by `spdd-implement`'s frontmatter and Step 1)

**Out of scope (deliberate):**
- Defensive duplications kept as-is: "Status: Confirmed" in both `spdd-agent` Step 5 and `spdd-implement` Step 4 (manual-flow safety), the 5-case completeness enumeration in `spdd-agent` Step 1 (it *is* the fast-path router), per-step foreground/background outcome patterns.
- `scripts/check-hook-sync.sh` scope (it intentionally compares only the JSON block and the TTL value).
- Any edit to evals content or to the never-block rule string.

---

## Entities

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| `spdd-migrate/SKILL.md` | `spdd-migrate/SKILL.md` | Existing | v2.0 → 2.1; language note ×2 → ×1 (top), drop Step 2.6 |
| `spdd-design/SKILL.md` | `spdd-design/SKILL.md` | Existing | v1.4 → 1.5; Step 7 bullets → template delegation; Step 1 self-contained lookup |
| `spdd-agent/assets/model-bootstrap.md` | `spdd-agent/assets/model-bootstrap.md` | Existing | Compress intro; dedup flat-key rule; drop line-22 parenthetical; JSON examples intact |
| `spdd-canvas/SKILL.md` | `spdd-canvas/SKILL.md` | Existing | v2.9 → 2.10; Step 9 bash → one sentence; Step 10 trimmed |
| `spdd-implement/SKILL.md` | `spdd-implement/SKILL.md` | Existing | v2.5 → 2.6; Step 5 bash → one sentence |
| `spdd-verify/SKILL.md` | `spdd-verify/SKILL.md` | Existing | v1.9 → 2.0; Step 1 self-contained lookup; Step 9 bash → one sentence |
| `spdd-canvas/assets/hook-setup.md` | `spdd-canvas/assets/hook-setup.md` | Existing | Line 17 aligned to per-copy phrasing (confirmed at checkpoint; attribution corrected at implement time — implement/verify copies already used it) |
| `AGENTS.md` / `CLAUDE.md` gotcha | repo root, "Gotchas" section | Existing | Mirrored touch-up of the "inlines the grep check" sentence (confirmed at checkpoint) |

---

## Approach

Select the main pattern and briefly justify why:

- [ ] Full CRUD (model + repository + service + controller/handler)
- [ ] Endpoint/handler only (on an existing entity)
- [x] Service/internal logic only (no presentation layer)
- [ ] Async worker / job
- [ ] External service integration — specify: ___
- [ ] UI component / page

**Rationale:**
Documentation-only refactor of skill prose — the closest available pattern; there is no runtime
surface, no new endpoints, and no data model. All changes are instruction-text reductions whose
observable outputs are pinned identical by the Acceptance Criteria above.

---

## Structure

Files to create or modify, with real project paths:

```
spdd-migrate/SKILL.md
spdd-design/SKILL.md
spdd-agent/assets/model-bootstrap.md
spdd-canvas/SKILL.md
spdd-implement/SKILL.md
spdd-verify/SKILL.md
spdd-canvas/assets/hook-setup.md
AGENTS.md   (gotcha sentence, mirrored)
CLAUDE.md   (gotcha sentence, mirrored)
```

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Edit | `spdd-migrate/SKILL.md` | Consolidate the two Language notes into one top-level note; delete Step 2 point 6; bump version to 2.1 |
| Edit | `spdd-design/SKILL.md` | Replace Step 7's `Depends on:`/`Shared touchpoints:` bullets with a pointer to the template's guidance; inline the change-lookup sentence in Step 1 (drop the `spdd-implement` cross-reference); bump version to 1.5 |
| Edit | `spdd-agent/assets/model-bootstrap.md` | Compress lines 3–8 to a ≤2-sentence scope note; remove the line-36 flat-key sentence (keep line 75's); remove the line-22 parenthetical |
| Edit | `spdd-canvas/SKILL.md` | Replace Step 9's bash block with a one-sentence check (same grep targets); trim Step 10's trailing rationale sentence; bump version to 2.10 |
| Edit | `spdd-implement/SKILL.md` | Replace Step 5's bash block with a one-sentence check; bump version to 2.6 |
| Edit | `spdd-verify/SKILL.md` | Inline the change-lookup sentence in Step 1 (drop the cross-reference); replace Step 9's bash block with a one-sentence check; bump version to 2.0 |
| Edit | `spdd-canvas/assets/hook-setup.md` | Align line 17 with the per-copy phrasing decided at the checkpoint |
| Edit | `AGENTS.md` + `CLAUDE.md` | Update the "inlines the grep check" gotcha sentence to match the new one-sentence check, mirrored in both files |
| Version bumps | all edited `SKILL.md` files | `metadata.version` increments per each domain spec's Norm (agent bumps for the asset edit: 1.12 → 1.13) |

---

## Norms

- [x] SPDD documents (canvas, plans, fold-back notes) are written in English (template-reasons.md line 5)
- [x] Increment `metadata.version` of every edited `SKILL.md` (per-domain spec Norms: canvas 2.9→2.10, design 1.4→1.5, implement 2.5→2.6, verify 1.9→2.0, migrate 2.0→2.1, agent 1.12→1.13)
- [x] The never-block rule quoted verbatim in `spdd-agent` Step 3 is an exact string — untouched by this change (agent spec Norm)
- [x] Mirror any Gotchas edit into both `AGENTS.md` and `CLAUDE.md` (agent spec Norm)
- [x] From `spdd/norms.md`: nothing — the file does not exist in this project

---

## Safeguards

**Tests to write:**
- [x] `scripts/check-hook-sync.sh` exits 0 after the `hook-setup.md` edit
- [x] Grep sweep: the removed duplicate strings no longer appear in their files (e.g. second "Language note" in migrate, "same lookup pattern as" in design/verify, the duplicated "never merge or delete" in model-bootstrap)
- [x] The never-block rule string in `spdd-agent/SKILL.md` Step 3 is byte-identical to before (git diff shows no change on those lines)

**Edge cases to consider (as WHEN/THEN scenarios — `spdd-verify` writes a targeted test for each one not already covered):**

- Scenario: an eval references a trimmed string
  - WHEN any `evals.json` of an affected skill pins a string targeted for removal
  - THEN the trim for that string is dropped or the eval is updated in the same change (grep pre-check showed none do, but verify re-checks)
- Scenario: the hook-presence phrase loses operational precision
  - WHEN a reader of the one-sentence check cannot tell what to grep
  - THEN the sentence must name both targets verbatim (`SPDD`, `"subagentPromptCacheTtl"`) and the file (`.claude/settings.local.json`)
- Scenario: spec Entity rows go stale after the trim
  - WHEN the fold-back updates the six domain specs
  - THEN rows documenting moved/removed prose (migrate Language notes ×2→×1, "inline grep check" wording, design Step 7 bullets) are updated in place, not duplicated
- Scenario: v2.0 migrate Requirements gap flagged by the sync run
  - WHEN the fold-back reaches `spdd/specs/spdd-migrate.md`
  - THEN the existing `⚠️ Confirm:` about missing v2.0 Requirements scenarios stays visible until a change authoring those scenarios is verified

**Production rollback:**
Single-commit documentation change; `git revert <commit>` restores all files. No runtime state,
no config writes, no hook changes.

---

**Confirmed at checkpoint (2026-09-01):**
1. Finding 9 applied **with** the mirrored gotcha touch-up: the inline bash check becomes a one-sentence check in `spdd-canvas`/`spdd-implement`/`spdd-verify`, and the "inlines the grep check" sentence in `AGENTS.md` + `CLAUDE.md` is updated in both files.
2. `hook-setup.md` line 17: all three copies aligned to the per-copy phrasing ("This phase can run several turns inside one subagent call…") — each copy is read standalone by its own skill, so "This phase" is always accurate; `check-hook-sync.sh` keeps passing (it does not diff prose).
