# Plan: Trim spdd-verify/SKILL.md hook/TTL rationale sentence and language note

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-08-31
> Verified: 2026-08-31

**Depends on:** none
**Shared touchpoints:** none — the hook/TTL row also appears in `plan-02-spdd-canvas.md` and `plan-04-spdd-implement.md`; the language-note row also appears in `plan-03-spdd-design.md`, `plan-04-spdd-implement.md`, and `plan-06-spdd-sync.md`. Each plan applies both rows only to its own file — no cross-file read/write.

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Consolidate | Hook/TTL setup block (3× full duplicate) | `spdd-canvas` Step 11, `spdd-implement` Step 5, `spdd-verify` Step 9 each carry the identical ~25-line bash-check + JSON-hook + JSON-TTL block, differing only in one rationale sentence about *why* that phase benefits from the cache TTL. **Confirmed:** keep the operative snippet duplicated in all three (portability), replace each phase-specific TTL rationale sentence with a single shared short form ("this phase can run several turns inside one subagent call; without the TTL setting, Claude Code caps its prompt cache at 5 minutes regardless of plan") |
| Trim | Language-note paragraphs (`spdd-design` Step 7, `spdd-implement` Step 0, `spdd-verify` Step 7, `spdd-sync` Step 5) | Each restates "write new content in English" with a different rationale clause. The one-line operative instruction ("write all new content in English") must stay in each — a background subagent's prompt (per `spdd-agent` Step 3) carries only the skill call + never-block rule, not the full project `CLAUDE.md`, so the rule can't be assumed inherited. **Confirmed:** drop the varying rationale clause everywhere, keep one uniform short instruction line per file |

## Implementation notes

### Hook/TTL rationale (this file's occurrence, Step 9)

Current sentence to replace (verbatim, current file, in the bullet starting "**Subagent cache TTL**"):
> This phase's own test-writing, test-running, and diff-to-canvas checks can run inside one subagent call for several turns; without this, Claude Code caps that subagent's own prompt cache at a 5-minute TTL regardless of plan, so a slow test run between turns forces a full, uncached re-read of the growing conversation.

Replacement — this file's own Step is naturally "this phase" (it describes its own loop), so the canvas's shared short form applies with minimal adaptation:
> This phase can run several turns inside one subagent call; without the TTL setting, Claude Code caps its prompt cache at 5 minutes regardless of plan.

The bash check block and the JSON hook/TTL snippets above/around this sentence are operative and must stay byte-for-byte identical to the current file — do not touch them.

### Language note (this file's occurrence, Step 7)

Current text (verbatim, blockquote):
> **Language note:** Any new prose written during Diff-to-canvas check (discrepancy notes, `⚠️ Confirm:` lines added directly to canvas/plan) or during Fold back and archive (new scenarios or Norms added to spec, fold annotations) must be written in English, regardless of the user's conversation language. The canvas/plan/spec documents are always generated in English; conversational responses to the user follow the conversation's language settings (e.g., the user's CLAUDE.md global instructions).

**Confirmed** (foreground checkpoint, 2026-08-31): wording approved as-is, including dropping the "conversational responses follow the conversation's language" clause per user decision.

> **Language note:** Write all new prose added during this skill's steps (discrepancy notes, `⚠️ Confirm:` lines, fold-back annotations) in English, regardless of the conversation's language.

Drop the "The canvas/plan/spec documents are always generated in English; conversational responses..." sentence — it's rationale/scope commentary, not instruction. (The "conversational responses follow the conversation's language" clarification is useful context but is already the general default behavior established elsewhere; it's not a rule specific to this step's operative action.)

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-verify SKILL.md` — 113 lines, third full copy of the hook/TTL setup block; longest language-note paragraph

**Structure — files to create or modify:**

```
spdd-verify/SKILL.md
```

## Norm compliance for this plan

- Bump `metadata.version` in `spdd-verify/SKILL.md` frontmatter (currently `"1.5"`) once the trim is applied — instructions changed.
- Re-run `spdd-verify/evals/evals.json` after the edit (evals 15–19, 30–36, 51); no assertion is expected to reference the removed rationale wording, but verify.
- Verify `allowed-tools:` frontmatter still matches actual tool usage after the edit (expected: no change needed).
