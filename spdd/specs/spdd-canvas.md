# Spec: spdd-canvas

> Living spec for the `spdd-canvas` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, we want every `canvas.md` `spdd-canvas` generates to be
written in English, instead of detecting and using the user's conversation language, so that
downstream tasks reading these documents as context spend fewer reasoning tokens.

**Scenario: `spdd-canvas` generates a new canvas**
- WHEN `spdd-canvas` reaches the output-language step (Step 3, "Output language")
- THEN it generates all `canvas.md` content — section headings, User story, Acceptance Criteria
  (WHEN/THEN scenarios), Entities, Norms, Safeguards, and any domain notes — in English,
  regardless of the language the user used to describe the feature

**Scenario: user describes the feature entirely in Spanish (or any non-English language)**
- WHEN the user invokes `/spdd-canvas` with a feature description in Spanish
- THEN the generated `canvas.md` has all headings, scenarios, and notes in English; the
  conversational report back to the user may still follow the conversation's language (e.g. the
  user's global `CLAUDE.md` instructions)

**Scenario: `template-reasons.md` no longer asks for a translated language**
- WHEN a `canvas.md` is generated from `spdd-canvas/assets/template-reasons.md`
- THEN the template's `> Language: ...` note no longer says "translate ... to the language
  detected from the user" — it states explicitly that the document is written in English

**Scenario: conversational replies to the user do not change language**
- WHEN `spdd-canvas` reports back to the user in the chat turn (Step 12's final summary) — not a
  persisted file
- THEN that conversational reply still follows the conversation's language settings; the
  English-only rule applies only to the persisted document content (`canvas.md`), not to chat

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| Step "Output language" | `spdd-canvas/SKILL.md` (Step 3) | Replaced the former "Detect output language" step — no longer detects or asks for the user's language; fixes "English" as the language of all document content generated from this point on |
| `> Language: ...` note | `spdd-canvas/assets/template-reasons.md` (line 5) | States the document is written in English, with no translation instruction |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Output language" (Step 3, replaces "Detect output language") in `spdd-canvas/SKILL.md` | No longer detects or asks the user's language; fixes "English" as the language of all document content generated from this step onward (headings, labels, User story, Acceptance Criteria, Entities, Norms, Safeguards, inline notes) |
| Template note | `> Language: ...` in `template-reasons.md` | Explicitly declares the document is written in English, with no translate-to-detected-language instruction |
| Boundary | Persisted document vs. conversational reply | The English-only rule applies only to `canvas.md` content; conversational replies to the user in chat still follow the conversation's language rules (e.g. the user's global `CLAUDE.md` instructions) |

---

## Norms

- Simplicity First: the language rule is a fixed, unconditional instruction — no conditional logic or per-project configuration, no opt-out via `spdd/norms.md`.
- Increment `metadata.version` of `spdd-canvas/SKILL.md` whenever its instructions are edited (bumped to 2.3 for this change).
- Do not translate historical content already written in another language (e.g. archived canvases generated before this change) — the rule is forward-only.
- Test coverage: `spdd-canvas/evals/evals.json` gained new cases 52–53, verifying that a Spanish-language feature description still produces an English-language `canvas.md`.
