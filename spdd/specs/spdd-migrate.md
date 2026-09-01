# Spec: spdd-migrate

> Living spec for the `spdd-migrate` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, we want `spdd-migrate` to state each rule exactly once, so that
every agent run loads fewer tokens without changing any observable behavior.

**Scenario: single top-level language note (replaces the two per-step blockquotes)**
- WHEN `spdd-migrate/SKILL.md` instructs about output language
- THEN a single top-level language note (top of Instructions) covers both the `WHEN/THEN` reformatting prose (Step 2) and the newly authored spec prose (Step 3) — reformatting and spec-fold outputs remain English in all cases (v2.1 trim)

**Scenario: non-destructive default stated once**
- WHEN the migration flow runs
- THEN Step 4 keeps forbidding deletion of `docs/prompts/*.md` and `docs/features/*.md` outside the explicit Step 7 cleanup — the former Step 2 point 6 restatement is gone (v2.1 trim)

> Fold note (2026-09-01): the `spdd/specs/spdd-migrate.md` sync edit present in the same working tree was a user-accepted diff-scope discrepancy — `spdd-sync` ran before the v2.1 trim per the canvas freshness gate.
>
> ⚠️ Confirm: The v2.0 behavior (closed/active routing, feature-doc folding, idempotency checks, hook rewrite) has no Requirements scenarios in this spec — `spdd-sync` never authors Requirements. Fold them from the next verified change touching this skill, or author them manually.

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| Language note (×1) | `spdd-migrate/SKILL.md` (top of Instructions) | Single note covering reformat and spec-fold prose; replaced the two per-step blockquotes (v2.1 trim) |
| Route decision (closed vs. active) | `spdd-migrate/SKILL.md` (Step 2, point 5) | Closed (`Status: Implemented` or paired `docs/features/<slug>.md`) → `spdd/archive/` as `Status: Verified`; active (`Draft`/`Confirmed`) → `spdd/changes/` with the original status preserved |
| Idempotency markers | `spdd-migrate/SKILL.md` (Step 2, point 3; Step 3, point 1) | Existence check of `spdd/changes\|archive/SPDD-<same-slug>/canvas.md` for canvases; `<!-- spdd-migrate source: docs/features/<slug>.md -->` HTML comment for folded feature docs |
| Domain inference | `spdd-migrate/SKILL.md` (Step 3, point 2) | Same folder-convention heuristic as `spdd-canvas`; prefers the paired canvas's Structure, then the doc's "Technical notes" paths, else falls back to `spdd/specs/general.md` |
| Hook rewrite | `spdd-migrate/SKILL.md` (Step 5, Claude Code only) | Rewrites the guard hook's `command` from the old `docs/prompts/SPDD-*.md` pattern to the current `spdd/changes/` pattern; a missing hook is left uninstalled |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Note | Language note at the top of Instructions | All newly authored content (reformatted Acceptance Criteria/Safeguards, spec sections, `⚠️ Confirm:` lines) is written in English, regardless of the conversation's language |
| Route | Closed canvas → `spdd/archive/SPDD-<same-date-slug>/canvas.md` with `Status: Verified` | Preserves an existing `> Implemented:` line; mirrors `spdd-verify`'s invariant that only `Verified` material lives in `spdd/archive/` |
| Route | Active canvas → `spdd/changes/SPDD-<same-date-slug>/canvas.md` with the original `Status` unchanged | Never folded into `spdd/specs/` at migrate time — folding happens later via `spdd-verify` |
| Check | Idempotency (canvases and feature docs) | Skips any file whose target already exists or whose source marker is already present, noting it as already migrated |
| Fold | `docs/features/<slug>.md` → `spdd/specs/<domain>.md` (Requirements, Entities, Operations, Norms) | Synthesizes only from the doc's own prose; name/identifier dedupe before appending; source marker added next to folded content |
| Guard | Non-destructive default (Step 4) | Originals are never deleted during migration; unmatched leftovers are listed in the report; deletion only via Step 7 with explicit confirmation |

---

## Norms

- Simplicity First: the language rule is a fixed, unconditional instruction — no conditional logic or per-project configuration.
- Increment `metadata.version` in `spdd-migrate/SKILL.md` on any edit to its instructions (currently at 2.1, cumulative across changes).
- Content copied verbatim from the source file (not reformatted) is not translated as a side effect — the rule applies only to newly authored prose.
- Migration is non-destructive by default — originals are never deleted during Steps 2–4; deletion happens only in Step 7 after explicit confirmation.
- Never invent detail the source prose doesn't support — ambiguous rewrites and lossy mappings become `⚠️ Confirm:` lines instead of guesses.
