# Plan: Trim spdd-sync/SKILL.md language note

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-08-31
> Verified: 2026-08-31
**Depends on:** none
**Shared touchpoints:** none — the language-note row below also appears in `plan-03-spdd-design.md`, `plan-04-spdd-implement.md`, and `plan-05-spdd-verify.md`; each plan applies it only to its own file, no cross-file read/write.

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Trim | Language-note paragraphs (`spdd-design` Step 7, `spdd-implement` Step 0, `spdd-verify` Step 7, `spdd-sync` Step 5) | Each restates "write new content in English" with a different rationale clause. The one-line operative instruction ("write all new content in English") must stay in each — a background subagent's prompt (per `spdd-agent` Step 3) carries only the skill call + never-block rule, not the full project `CLAUDE.md`, so the rule can't be assumed inherited. **Confirmed:** drop the varying rationale clause everywhere, keep one uniform short instruction line per file |

## Implementation notes

### Language note (this file's occurrence, Step 5)

Current text (verbatim, blockquote):
> **Language note:** Any new text written when updating the spec in Step 5 (modified Entities descriptions, Structure notes, Operations changes, or Norms updates) must be in English, consistent with the rest of the spec document. This applies even if the user's conversation is in another language. The spec documents are the authoritative source in English; conversational responses to the user follow the conversation's language settings (e.g., the user's CLAUDE.md global instructions).

**Confirmed** (foreground checkpoint, 2026-08-31): wording approved as-is, including dropping the "conversational responses follow the conversation's language" clause per user decision.

> **Language note:** Write all new spec text added in Step 5 (Entities, Structure, Operations, Norms updates) in English, regardless of the conversation's language.

Drop the "This applies even if..." and "The spec documents are the authoritative source..." sentences — both restate/expand the same rule or add rationale, not new instruction.

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-sync SKILL.md` — 41 lines, has its own shorter language-note restatement

**Structure — files to create or modify:**

```
spdd-sync/SKILL.md
```

## Norm compliance for this plan

- Bump `metadata.version` in `spdd-sync/SKILL.md` frontmatter (currently `"1.1"`) once the trim is applied — instructions changed.
- Re-run `spdd-sync/evals/evals.json` after the edit (evals 20–23); no assertion is expected to reference the removed rationale wording, but verify.
- Verify `allowed-tools:` frontmatter still matches actual tool usage after the edit (expected: no change needed).
