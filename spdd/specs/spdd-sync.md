# Spec: spdd-sync

> Living spec for the `spdd-sync` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, we want any new text `spdd-sync` writes while updating a
living spec after a behavior-preserving refactor to be in English, instead of detecting and
using the user's conversation language, so that downstream tasks reading these documents as
context spend fewer reasoning tokens.

**Scenario: `spdd-sync` updates a living spec after a refactor**
- WHEN `spdd-sync` updates Entities/Structure/Operations/Norms of `spdd/specs/<domain>.md`
  following a behavior-preserving refactor made outside the SPDD flow (Step 5, "Update the
  spec")
- THEN the text it writes or modifies is in English, consistent with the rest of the spec
  already in English

**Scenario: a pre-existing spec already written in another language gets a partial update**
- WHEN `spdd-sync` updates a living spec that already existed in a non-English language before
  this rule was introduced (e.g. `spdd/specs/spdd-agent.md` in this repo)
- THEN `spdd-sync` does not automatically retranslate the spec's existing content as a side
  effect of a partial update — only the new text it writes is in English, leaving an accepted
  temporary language mix until the team decides to migrate the rest manually. **Confirmed:**
  this is the default behavior; the mix is not flagged as something to review

**Scenario: observable-behavior suspicion stops the sync** *(hand-authored 2026-09-02 from `spdd-sync/SKILL.md` Step 4 — audit-driven exception, not a fold-back)*
- WHEN Step 3 finds anything suggesting a change in observable behavior, not just shape
- THEN `spdd-sync` does not touch the Requirements section: it stops and tells the user
  explicitly this isn't a sync case — behavior changes need a new canvas via `spdd-canvas`,
  not a sync. This is the core safeguard of the skill: it must never rewrite behavior silently

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| Language note | `spdd-sync/SKILL.md` | Placed right after Step 5 ("Update the spec") |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Note | Language note in `spdd-sync/SKILL.md` (after Step 5) | States that any new text written while updating the spec (modified Entities descriptions, Structure notes, Operations changes, Norms updates) must be in English, regardless of the user's conversation language; the spec documents are the authoritative source in English, and conversational replies to the user follow the conversation's language settings |
| Boundary | Requirements vs. Entities/Structure/Operations/Norms | `spdd-sync` never touches Requirements (the behavior contract) — the English-only rule for this domain applies only to the sections `spdd-sync` is allowed to write: Entities, Structure, Operations, Norms |

---

## Norms

- Simplicity First: the language rule is a fixed, unconditional instruction — no conditional logic or per-project configuration.
- The authoritative version of a skill is the `metadata.version` in its own `SKILL.md` frontmatter — spec Norms never restate a version counter (removed 2026-09-02 after the counter drifted: spdd-agent said 1.13, skill was 1.14).
- Do not retranslate a spec's pre-existing content as a side effect of an unrelated partial update — only newly written text follows the English-only rule; a manual full-spec migration is a separate, deliberate decision left to the team.
- This norm does not change Step 4's behavior guardrail (never rewrite the Requirements/behavior contract silently) — it only governs the language of the text `spdd-sync` is already allowed to write in Step 5.
