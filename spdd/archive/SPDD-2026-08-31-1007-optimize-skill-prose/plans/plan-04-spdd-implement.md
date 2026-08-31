# Plan: Trim spdd-implement/SKILL.md hook/TTL rationale sentence and language note

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-08-31

**Depends on:** none
**Shared touchpoints:** none — the hook/TTL row also appears in `plan-02-spdd-canvas.md` and `plan-05-spdd-verify.md`; the language-note row also appears in `plan-03-spdd-design.md`, `plan-05-spdd-verify.md`, and `plan-06-spdd-sync.md`. Each plan applies both rows only to its own file — no cross-file read/write.

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Consolidate | Hook/TTL setup block (3× full duplicate) | `spdd-canvas` Step 11, `spdd-implement` Step 5, `spdd-verify` Step 9 each carry the identical ~25-line bash-check + JSON-hook + JSON-TTL block, differing only in one rationale sentence about *why* that phase benefits from the cache TTL. **Confirmed:** keep the operative snippet duplicated in all three (portability), replace each phase-specific TTL rationale sentence with a single shared short form ("this phase can run several turns inside one subagent call; without the TTL setting, Claude Code caps its prompt cache at 5 minutes regardless of plan") |
| Trim | Language-note paragraphs (`spdd-design` Step 7, `spdd-implement` Step 0, `spdd-verify` Step 7, `spdd-sync` Step 5) | Each restates "write new content in English" with a different rationale clause. The one-line operative instruction ("write all new content in English") must stay in each — a background subagent's prompt (per `spdd-agent` Step 3) carries only the skill call + never-block rule, not the full project `CLAUDE.md`, so the rule can't be assumed inherited. **Confirmed:** drop the varying rationale clause everywhere, keep one uniform short instruction line per file |

## Implementation notes

### Hook/TTL rationale (this file's occurrence, Step 5)

Current sentence to replace (verbatim, current file, in the bullet starting "**Subagent cache TTL**"):
> This phase's own edit/test/fix loop can run inside one subagent call for several turns; without this, Claude Code caps that subagent's own prompt cache at a 5-minute TTL regardless of plan, so a slow test run between turns forces a full, uncached re-read of the growing conversation.

Replacement — this file's own Step is naturally "this phase" (it describes its own loop), so the canvas's shared short form applies with minimal adaptation:
> This phase can run several turns inside one subagent call; without the TTL setting, Claude Code caps its prompt cache at 5 minutes regardless of plan.

The bash check block and the JSON hook/TTL snippets above/around this sentence are operative and must stay byte-for-byte identical to the current file — do not touch them.

### Language note (this file's occurrence, Step 0)

Current text (verbatim):
> ### Step 0 — Output language
>
> Use English for all document content generated or modified during implementation (canvas or plan notes, discrepancy annotations, etc.), regardless of the user's conversation language. This reduces reasoning tokens when other skills read these documents as context later. Code itself already follows the English-only convention in the user's global `CLAUDE.md`.

**Confirmed** (foreground checkpoint, 2026-08-31): wording approved as-is.

> ### Step 0 — Output language
>
> Write all document content generated or modified during implementation (canvas or plan notes, discrepancy annotations, etc.) in English, regardless of the user's conversation language.

Drop the "This reduces reasoning tokens..." and "Code itself already follows..." sentences — both are rationale/scope commentary, not instruction; the one-line rule already implies documents-not-code by naming "document content."

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-implement SKILL.md` — 85 lines, second full copy of the hook/TTL setup block

**Structure — files to create or modify:**

```
spdd-implement/SKILL.md
```

## Norm compliance for this plan

- Bump `metadata.version` in `spdd-implement/SKILL.md` frontmatter (currently `"2.2"`) once the trim is applied — instructions changed.
- Re-run `spdd-implement/evals/evals.json` after the edit (evals 4–8); no assertion is expected to reference the removed rationale wording, but verify.
- Verify `allowed-tools:` frontmatter still matches actual tool usage after the edit (expected: no change needed).
