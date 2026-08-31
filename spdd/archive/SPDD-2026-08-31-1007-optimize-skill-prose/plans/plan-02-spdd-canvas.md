# Plan: Trim spdd-canvas/SKILL.md hook/TTL rationale sentence

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-08-31
> Verified: 2026-08-31
**Depends on:** none
**Shared touchpoints:** none — this plan, `plan-04-spdd-implement.md`, and `plan-05-spdd-verify.md` each independently apply the same consolidation decision to their own file; none of them read or write another plan's file, so there is no runtime coupling despite the shared wording below.

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase; this row also appears in `plan-04-spdd-implement.md` and `plan-05-spdd-verify.md` since it spans all three files, each plan applies it only to its own file):

| Type | Identifier | Description |
|------|-----------|-------------|
| Consolidate | Hook/TTL setup block (3× full duplicate) | `spdd-canvas` Step 11, `spdd-implement` Step 5, `spdd-verify` Step 9 each carry the identical ~25-line bash-check + JSON-hook + JSON-TTL block, differing only in one rationale sentence about *why* that phase benefits from the cache TTL. **Confirmed:** keep the operative snippet duplicated in all three (portability), replace each phase-specific TTL rationale sentence with a single shared short form ("this phase can run several turns inside one subagent call; without the TTL setting, Claude Code caps its prompt cache at 5 minutes regardless of plan") |

## Implementation notes

- Scope for this plan: only the rationale sentence inside Step 11 ("Ensure the SPDD hook and subagent cache TTL are present") of `spdd-canvas/SKILL.md`. The bash check block and the JSON hook/TTL snippets are operative and must stay byte-for-byte identical to the current file — do not touch them.
- Current sentence to replace (verbatim, current file, in the bullet starting "**Subagent cache TTL**"):
  > `spdd-implement` and `spdd-verify` run internal edit/test/verify loops inside one subagent call; without this, Claude Code caps that subagent's own prompt cache at a 5-minute TTL regardless of plan, so a slow test run between turns forces a full, uncached re-read of that phase's growing conversation.
- Replacement: use the canvas's shared short form, adapted grammatically since this file's Step 11 describes a benefit to *other* phases (`spdd-implement`/`spdd-verify`), not itself — unlike the same sentence in those two files' own Step, which describes their own phase. Suggested wording: "so that `spdd-implement` and `spdd-verify` — which can run several turns inside one subagent call — keep their prompt cache alive; without the TTL setting, Claude Code caps it at 5 minutes regardless of plan."
  - **Confirmed** (foreground checkpoint, 2026-08-31): wording approved as-is.
- Do not touch anything outside Step 11 — the rest of `spdd-canvas/SKILL.md` is out of scope for this plan.

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-canvas SKILL.md` — 115 lines, contains one full copy of the hook/TTL setup block

**Structure — files to create or modify:**

```
spdd-canvas/SKILL.md
```

## Norm compliance for this plan

- Bump `metadata.version` in `spdd-canvas/SKILL.md` frontmatter (currently `"2.6"`) once the trim is applied — instructions changed.
- Re-run `spdd-canvas/evals/evals.json` after the edit; no assertion is expected to reference the removed rationale sentence's exact wording, but verify (evals.json covers the hook step per repo Structure notes — evals 1–3, 9–10, 48–50).
- Verify `allowed-tools:` frontmatter still matches actual tool usage after the edit (expected: no change needed).
