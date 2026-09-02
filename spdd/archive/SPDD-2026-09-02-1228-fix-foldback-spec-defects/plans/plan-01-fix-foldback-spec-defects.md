# Plan: Fix fold-back defects in the living specs (audit remediation)

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-02
**Depends on:** none
**Shared touchpoints:** none

> ⚠️ Confirm (background divergence note, 2026-09-02): the canvas Safeguard check `grep -n '⚠️ Confirm:' spdd/specs/spdd-migrate.md` returns nothing is unsatisfiable as literally written — the file legitimately retains three behavior-description mentions of `⚠️ Confirm:` (two pre-dating this change: the language-note Operations row and the "never invent detail" Norm; one necessarily introduced by the mandated hook-rewrite Requirements scenario, since the hook factually scans for unresolved `⚠️ Confirm:` lines). The check's intent — the stale Requirements Confirm (line 24) resolved — is met: `grep -n '^> ⚠️ Confirm:'` returns nothing. Resolve at the foreground checkpoint by refining the check wording (e.g. to `^> ⚠️ Confirm:` or "no unresolved Confirm items"). — **Resolved 2026-09-02 (foreground checkpoint, user decision): canvas check refined to `grep -n '^> ⚠️ Confirm:'`.**

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Merge | `spdd/specs/spdd-design.md` — `## Operations` | Fuse the two `## Operations` sections (lines 47, 59) into one: keep the richer 5-row table, collapse the second table's homogeneity row into the existing "Homogeneity criterion" row, delete the second heading. Row-set diff before/after must show union minus exact duplicates only |
| Resolve | `spdd/specs/spdd-migrate.md:24` — stale `⚠️ Confirm:` | Author Requirements `WHEN/THEN` scenarios for: closed-canvas routing → `spdd/archive/` as `Status: Verified`; active-canvas routing → `spdd/changes/` status-preserved; feature-doc fold with source marker; idempotency checks; hook rewrite (Claude Code only) — each citing `spdd-migrate/SKILL.md` (v2.1) Steps 2–5; then delete the Confirm line, keep the historical fold note |
| Correct | `spdd/specs/spdd-verify.md:54` — obsolete out-of-scope bullet | Replace with the accurate statement (global-norms validation exists since Mejora 4, `spdd-verify/SKILL.md` Step 7 point 4); extend the Step 7 Operations row (line 81) to mention the `spdd/norms.md` validation pass; leave the other two bullets intact |
| Remove | `spdd/specs/spdd-implement.md:58` — leaked plan prose | Delete the "This plan is implemented after `plan-01-spdd-canvas.md`…" line from Norms; keep line 59 (test-coverage norm) |
| Replace | 7 × version-counter Norms | Replace each "Increment `metadata.version` … (currently at X, cumulative across changes)" line with: "The authoritative version of a skill is the `metadata.version` in its own `SKILL.md` frontmatter — spec Norms never restate a version counter (removed 2026-09-02 after the counter drifted: spdd-agent said 1.13, skill was 1.14)" |
| Author | `spdd/specs/spdd-sync.md` — Requirements | Add the Step 4 behavior-guardrail scenario (observable-behavior suspicion → stop, never touch Requirements, redirect to `spdd-canvas`), citing `spdd-sync/SKILL.md` Step 4 |
| Author | `spdd/specs/spdd-implement.md` — Requirements | Add the three foundational scenarios (dependency check, `⚠️ Confirm:` gate + `Status: Confirmed`, divergence stop-and-confirm protocol), citing `spdd-implement/SKILL.md` Steps 3, 4, 6 |

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):

- `spdd-design` spec — `spdd/specs/spdd-design.md` (Existing) — merge duplicate `## Operations` sections (lines 47 + 59); drop counter line 70
- `spdd-migrate` spec — `spdd/specs/spdd-migrate.md` (Existing) — resolve `⚠️ Confirm:` (line 24) by authoring 4 v2.0-behavior scenarios; drop counter line 56
- `spdd-verify` spec — `spdd/specs/spdd-verify.md` (Existing) — replace obsolete out-of-scope bullet (line 54); extend Operations row (line 81); drop counter line 97
- `spdd-implement` spec — `spdd/specs/spdd-implement.md` (Existing) — delete leaked plan prose (line 58); author 3 foundational scenarios; drop counter line 56
- `spdd-sync` spec — `spdd/specs/spdd-sync.md` (Existing) — author Step 4 guardrail scenario; drop counter line 53
- `spdd-agent` spec — `spdd/specs/spdd-agent.md` (Existing) — drop counter line 157 (currently misstated "1.13"; skill is at 1.14)
- `spdd-canvas` spec — `spdd/specs/spdd-canvas.md` (Existing) — drop counter line 102

**Structure — files to create or modify:**

```
spdd/specs/spdd-design.md        # merge Operations sections; remove version counter
spdd/specs/spdd-migrate.md       # resolve Confirm; author v2.0 scenarios; remove version counter
spdd/specs/spdd-verify.md        # fix out-of-scope bullet + Operations row; remove version counter
spdd/specs/spdd-implement.md     # remove leaked prose; author 3 foundational scenarios; remove counter
spdd/specs/spdd-sync.md          # author guardrail scenario; remove version counter
spdd/specs/spdd-agent.md         # remove version counter (misstated 1.13 vs actual 1.14)
spdd/specs/spdd-canvas.md        # remove version counter
```

No other files are touched. `spdd/norms.md` does not exist in this repo and is not created.
