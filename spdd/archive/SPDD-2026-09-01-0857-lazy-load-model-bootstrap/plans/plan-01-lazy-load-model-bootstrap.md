# Plan: Lazy-load spdd-agent's model-bootstrap instructions

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-01
> Verified: 2026-09-01
**Depends on:** none
**Shared touchpoints:** none — this plan is the only one for this change; all files below belong to it exclusively.

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — all of them, this is a single-plan change):

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Detect Claude Code host" (Step 1, unchanged) | `Bash` check of `CLAUDECODE`; determines which section (`claude.models` vs flat `models`) the completeness check inspects |
| Step | "Completeness check" (Step 1, new inline logic) | Reads `~/.config/spdd/config.json` (if present), inspects the applicable section, and classifies the run as: fast-path (complete, no migration pending) / first-run bootstrap / repair / migration / malformed-or-unparseable |
| Step | "Fast path" (Step 1, new) | On classification "complete": reads the six values, proceeds directly to Step 2 — `spdd-agent/assets/model-bootstrap.md` is never opened |
| Step | "Open model-bootstrap.md" (Step 1, new) | On any other classification: reads `spdd-agent/assets/model-bootstrap.md` and follows the flow documented there for that specific case |
| Asset | `spdd-agent/assets/model-bootstrap.md` — First-run bootstrap section | Default-tier table, tier rationale, `AskUserQuestion` mechanics grouped into 1–2 calls, writes flat or `claude`-namespaced shape per host detection |
| Asset | `spdd-agent/assets/model-bootstrap.md` — Repair section | Re-asks only for missing/empty/malformed phase values via `AskUserQuestion`, writes back to the applicable section only |
| Asset | `spdd-agent/assets/model-bootstrap.md` — Migration section | Proposes copying the flat `models` six values into a new `claude.models` namespace via a real foreground `AskUserQuestion`; writes only once confirmed; never touches the original flat key |
| Asset | `spdd-agent/assets/model-bootstrap.md` — JSON shape examples | Both the flat `{"models": {...}}` and `claude`-namespaced `{"claude": {"models": {...}}}` examples, verbatim from the current Step 1 |

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Model-bootstrap asset — `spdd-agent/assets/model-bootstrap.md` (New)
- Step 1 lightweight check — `spdd-agent/SKILL.md` "Load or bootstrap the model configuration" (Existing, modified)
- Config bootstrap/repair/migration evals — `spdd-agent/evals/evals.json` ids 31–38, 48 (Existing, modified)
- Fast-path eval — `spdd-agent/evals/evals.json` new id, proposed 67 (New)
- Parse-failure eval — `spdd-agent/evals/evals.json` new id, 68 (New)
- `CLAUDE.md` Gotchas (Existing, modified)
- `AGENTS.md` Gotchas + Structure (Existing, modified)
- `spdd/specs/spdd-agent.md` (Existing, read-only for this plan — `spdd-verify` folds into it later, not touched here)

**Structure — files to create or modify:**

```
spdd-agent/assets/model-bootstrap.md      # NEW — extracted bootstrap/repair/migration instructions + JSON shape examples
spdd-agent/SKILL.md                       # MODIFIED — Step 1 replaced with host detection (unchanged) + lightweight completeness check + conditional read of assets/model-bootstrap.md; metadata.version bumped
spdd-agent/evals/evals.json               # MODIFIED — evals 31–38, 48 assertions extended with asset-read/not-read checks; new eval(s) added for the fast path (id 67) and parse-failure (id 68)
CLAUDE.md                                 # MODIFIED — Gotchas: new bullet for the model-bootstrap.md lazy-load convention
AGENTS.md                                 # MODIFIED — mirrors the CLAUDE.md Gotchas bullet + Structure line for the new asset
```
