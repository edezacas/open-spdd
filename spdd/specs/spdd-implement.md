# Spec: spdd-implement

> Living spec for the `spdd-implement` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, we want every document `spdd-implement` writes or updates
during implementation (divergence notes, canvas/plan annotations) to be written in English,
instead of detecting and using the user's conversation language, so that downstream tasks
reading these documents as context spend fewer reasoning tokens.

**Scenario: `spdd-implement` implements a plan**
- WHEN `spdd-implement` reaches its output-language step (Step 0, "Output language")
- THEN any document content it generates or updates during implementation (divergence notes on
  canvas/plan, business-intent comments in prose if the stack calls for them) is written in
  English; the code itself already follows the English-only convention from the user's global
  `CLAUDE.md` ("code in English") and is unaffected by this change

**Scenario: conversational replies to the user do not change language**
- WHEN `spdd-implement` reports back to the user in the chat turn — not a persisted file
- THEN that conversational reply still follows the conversation's language settings; the
  English-only rule applies only to persisted document content (canvas/plan notes), not to chat

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| Step "Output language" | `spdd-implement/SKILL.md` (Step 0) | Replaced the former "Detect output language" step — no longer detects or asks for the user's language; fixes "English" as the language of all document content generated or modified during implementation |
| Step "Ensure the SPDD hook and subagent cache TTL" (Step 5) | `spdd-implement/SKILL.md` + `assets/hook-setup.md` | Claude Code only; lazy-loaded since v2.4 — inline grep check against `.claude/settings.local.json`, asset read only when the hook or TTL is missing |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Output language" (Step 0, replaces "Detect output language") in `spdd-implement/SKILL.md` | Uses English for all document content generated or modified during implementation (canvas or plan notes, discrepancy/divergence annotations), regardless of the user's conversation language |
| Boundary | Document content vs. code | The English-only rule for this step covers canvas/plan document content; code has always been written in English per the user's global `CLAUDE.md` convention and is not a new behavior introduced by this change |

---

## Norms

- Simplicity First: the language rule is a fixed, unconditional instruction — no conditional logic or per-project configuration.
- Increment `metadata.version` of `spdd-implement/SKILL.md` whenever its instructions are edited (currently at 2.5, cumulative across changes).
- Do not translate historical content already written in another language (e.g. divergence notes written before this change) — the rule is forward-only.
- This plan is implemented after `plan-01-spdd-canvas.md`; the eval ID range it uses is computed as the repo-wide max at implementation time, so it necessarily comes after `spdd-canvas`'s IDs.
- Test coverage: `spdd-implement/evals/evals.json` gained new cases 54–55, verifying that divergence notes written with Spanish conversational context still land in English.
