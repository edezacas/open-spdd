# Plan: Doc hygiene + mirror norm

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-02
> Verified: 2026-09-02
**Depends on:** none
**Shared touchpoints:** none — no file in this plan is touched by any other plan in this change (the CI workflow in plan-03 only *validates* `evals.json` files; it does not edit them, and this plan does not touch them either)

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Remove | `CLAUDE.md` + `AGENTS.md` eval id ranges | Delete every "evals <ids>:" enumeration from the Structure sections; keep path + purpose text |
| Update | `spdd/specs/spdd-agent.md` mirror Norm | Replace the blanket mirror rule with the shared-sections-identical / audience-sections-may-differ policy |
| Sync | Shared sections of `CLAUDE.md` / `AGENTS.md` | Make Structure, Conventions, and Gotchas sections byte-identical across both files |

**Resolved 2026-09-02 (foreground checkpoint):** when the shared-section sync finds a divergence that is *not* an eval-range enumeration, reconcile toward the state verified against the repo's actual files at implementation time — never copy one mirror doc over the other blindly.

**Scope correction 2026-09-02 (review of this change folder, pre-implementation):** the divergence is *not* limited to eval-range enumerations — verified directly against the repo:
- `CLAUDE.md` has **no `## Conventions` heading at all**; its equivalent content is merged into a single `## Gotchas` section (10 bullets). `AGENTS.md` splits this into `## Conventions` (6 bullets) and `## Gotchas` (8 bullets). Making the two files' Structure/Conventions/Gotchas byte-identical therefore requires **adding a new `## Conventions` heading to `CLAUDE.md`**, not just editing existing text in place.
- `CLAUDE.md` is missing at least 4 bullets present in `AGENTS.md`: "`SKILL.md` files are pure Markdown — no agent-specific syntax", "Acceptance criteria and Safeguards edge cases are written as `WHEN/THEN` scenarios", "`spdd/changes/` canvases/plans with `Status: Draft`, `Confirmed`, or `Implemented` (but not yet `Verified`) are works in progress", and "No backward-compat shim for the old `docs/prompts/` layout — projects on the previous version should run `/spdd-migrate` once...". Each needs a judgment call: copy verbatim into `CLAUDE.md` as shared content, or confirm it's legitimately audience-specific and leave it AGENTS.md-only (document the reasoning either way).
- The `Structure` section also has trivial capitalization diffs in Structure entry descriptions across several rows (e.g. `spdd-design/SKILL.md`'s description starts lowercase in `CLAUDE.md`, uppercase in `AGENTS.md`) — reconcile to one consistent casing.
- Treat this list as a starting point, not exhaustive — still diff the full sections at implementation time rather than only fixing the items named here.

Notes (implementation guidance, not new requirements):
- Eval id ranges are deleted outright — `*/evals/evals.json` stays the single source of truth; the surrounding Structure entries keep their path + purpose text.
- The audience-specific sections are out of scope: Claude Code Integration / Evaluating skills in `CLAUDE.md`, host-agnostic Auto-triggers in `AGENTS.md` — they may keep differing by design.
- The mirror-norm reword must state the policy confirmed on the canvas: shared sections (Structure, Conventions, Gotchas) identical across both files; audience-specific sections may differ by design — replacing the blanket "mirror any edit" rule.

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Mirror doc (Claude Code view) — `CLAUDE.md` — Existing — Remove eval ranges; re-sync shared sections
- Mirror doc (host-agnostic view) — `AGENTS.md` — Existing — Same treatment; audience sections stay
- Mirror norm — `spdd/specs/spdd-agent.md` (Norms) — Existing — Reword the blanket mirror rule

**Structure — files to create or modify:**

```
CLAUDE.md                  # remove eval ranges; re-sync shared sections
AGENTS.md                  # same
spdd/specs/spdd-agent.md   # reword the mirror Norm
```

---

## Implementation notes (2026-09-02)

- **Sync direction:** `AGENTS.md`'s shared-section bytes were adopted as the target and synced into `CLAUDE.md`. Verified row-by-row against the repo's actual files first: every divergence was either the canvas-documented stale eval ranges in `CLAUDE.md`, casing/trailing-punctuation trivia, or bullets present in `AGENTS.md` but missing from `CLAUDE.md`. No audience-specific fact lives in any shared-section row on either side, so nothing was copied blindly.
- **Missing bullets — judgment calls (documented per the scope correction):** all four bullets named by the plan, plus one additional found by the full-section diff (the Gotcha "When `spdd-verify` verifies one of this repo's own skills…" — the harness pointer relocated to `CLAUDE.md`'s "Evaluating skills" section), were copied verbatim into `CLAUDE.md` as shared content. Reasoning: every one is a host-agnostic SPDD convention; none carries a Claude-Code-only fact, so none qualifies as legitimately audience-specific.
- `CLAUDE.md` gained a new `## Conventions` heading (6 bullets) between Structure and Gotchas, per the scope correction; its former merged-Gotchas bullets all map into the target Conventions/Gotchas set — nothing was dropped.
- Eval id ranges were deleted outright from all seven `evals.json` Structure rows in both files; the fuller topic text from `AGENTS.md` (e.g. `routing, …, isolated-without-model-override, …, fast path, parse failure`) was kept for the `spdd-agent` row, matching the canvas's finding that `CLAUDE.md`'s ranges were the stale side.
- **Judgment call on Overview:** the `## Overview` sections of the two mirror docs also differ (Claude-Code-flavored in `CLAUDE.md` vs. host-agnostic in `AGENTS.md`). Neither the canvas nor the plan lists Overview among the shared sections, so it was left untouched as an audience difference — raised as a pending confirm for the foreground rather than silently expanded scope.
  - *Resolved 2026-09-02 (foreground checkpoint):* Overview confirmed as an audience-specific exception — the mirror Norm in `spdd/specs/spdd-agent.md` now lists Overview on both sides of the exception (edited by the orchestrator after user confirmation). Both files' Overview sections stay as-is.
