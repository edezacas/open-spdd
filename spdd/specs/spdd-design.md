# Spec: spdd-design

> Living spec for the `spdd-design` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, we want every plan document `spdd-design` generates to be
written in English, instead of detecting and using the user's conversation language, so that
downstream tasks reading these documents as context spend fewer reasoning tokens.

**Scenario: `spdd-design` generates a plan from an already-English canvas**
- WHEN `spdd-design` reads a canvas (already in English) and generates one or more `plan-*.md` files
- THEN the new content it authors (not just what is copied from the canvas) stays in English — it does not reintroduce Spanish or any other language even if the conversation with the user is in a different language

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| `> Language: ...` note | `spdd-design/assets/template-plan.md` (line 4) | States the document is written in English, with no translation instruction |
| Language defensive note | `spdd-design/SKILL.md` (Step 7 — "Generate the plan(s)") | Reminds the skill, at the point where it authors new prose of its own (not copied from the canvas), that this prose must also stay in English |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Template note | `> Language: ...` in `template-plan.md` | Explicitly declares the document is written in English, with no translate-to-detected-language instruction |
| Note | Language defensive note in `spdd-design/SKILL.md` Step 7 | Placed right before the plan-generation instructions; states plan content (names, headings, all prose in Operations/Entities/Structure, and any notes added) must be in English regardless of the canvas's or the user's conversation language |
| Boundary | Persisted document vs. conversational reply | The English-only rule applies only to `plan-*.md` content; conversational replies to the user in chat still follow the conversation's language rules (e.g. the user's global `CLAUDE.md` instructions) |

---

## Norms

- Simplicity First: the language rule is a fixed, unconditional instruction — no conditional logic or per-project configuration.
- Increment `metadata.version` of `spdd-design/SKILL.md` whenever its instructions are edited (currently bumped 1.0 → 1.1 for this change).
- Do not translate historical content already written in another language (e.g. plans generated before this change) — the rule is forward-only.
- New prose `spdd-verify` adds while folding a change into this spec, or during its Diff-to-canvas check, must also be in English (see `spdd-verify/SKILL.md`'s own language note near Steps 7–8).
