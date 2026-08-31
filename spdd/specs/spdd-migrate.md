# Spec: spdd-migrate

> Living spec for the `spdd-migrate` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, we want the new prose `spdd-migrate` authors while reformatting
Acceptance Criteria/Safeguards into `WHEN/THEN` scenarios to be written in English, matching the
same rule already enforced in `spdd-design`, `spdd-verify`, and `spdd-sync`, so migrated canvases
are consistent with every other SPDD document.

**Scenario: `spdd-migrate` reformats Acceptance Criteria/Safeguards from a non-English source**
- WHEN `spdd-migrate` Step 2, point 3 reformats freeform checkboxes/bullets into `WHEN/THEN` scenarios (new prose, not copied verbatim from the source file)
- THEN that reformatted content is written in English, regardless of the conversation's language or the language of the original `docs/prompts/SPDD-*.md` file

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| Language note | `spdd-migrate/SKILL.md` (Step 2, point 3) | Blockquote placed directly after the `WHEN/THEN` reformatting instruction, matching the placement style already used in `spdd-sync/SKILL.md` Step 5 |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Note | Language note in `spdd-migrate/SKILL.md` Step 2, point 3 | States that the reformatted Acceptance Criteria/Safeguards content must be in English, regardless of the conversation's language |

---

## Norms

- Simplicity First: the language rule is a fixed, unconditional instruction — no conditional logic or per-project configuration.
- Increment `metadata.version` in `spdd-migrate/SKILL.md` on any edit to its instructions (currently at 1.1, cumulative across changes).
- Content copied verbatim from the source file (not reformatted) is not translated as a side effect — the rule applies only to newly authored `WHEN/THEN` prose.
