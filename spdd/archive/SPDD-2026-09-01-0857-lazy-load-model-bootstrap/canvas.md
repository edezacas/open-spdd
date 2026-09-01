# REASONS: Lazy-load spdd-agent's model-bootstrap instructions

> Generated on 2026-09-01 08:57. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.

**Status:** Confirmed

---

## Requirements

**User story:**
As a maintainer running `spdd-agent` repeatedly on an already-configured machine, I want Step 1 ("Load or bootstrap the model configuration") to skip loading the full bootstrap-instructions prose into context when `~/.config/spdd/config.json` already has all six phase values filled in, so that every ordinary invocation of the complete route doesn't pay the token cost of a block it will never act on.

**Acceptance criteria:**

- **[NEW]** Scenario: config already complete for the applicable section
  - WHEN `~/.config/spdd/config.json` exists and the section that applies to the detected host (`claude.models` under Claude Code, flat top-level `models` otherwise) has all six keys (`canvas`, `design`, `implement`, `verify`, `sync`, `migrate`) present as non-empty strings
  - THEN Step 1 reads those six values directly from the config file and proceeds to Step 2 without reading `spdd-agent/assets/model-bootstrap.md` at all — no `AskUserQuestion` call for model selection occurs

- **[NEW]** Scenario: config file doesn't exist yet (first-run bootstrap)
  - WHEN `~/.config/spdd/config.json` doesn't exist
  - THEN Step 1 reads `spdd-agent/assets/model-bootstrap.md` and follows its first-run bootstrap flow (default-tier table, `AskUserQuestion` grouped into 1–2 calls, writing the flat or `claude`-namespaced shape per host detection) exactly as documented today

- **[NEW]** Scenario: one or more of the six keys is missing or empty (repair case)
  - WHEN the applicable section exists but at least one of the six keys is missing, empty, or not a string
  - THEN Step 1 reads `spdd-agent/assets/model-bootstrap.md` and follows its repair flow, re-asking via `AskUserQuestion` only for the affected phase(s), leaving the other values untouched

- **[NEW]** Scenario: migration case still forces the asset open even if the flat section is complete
  - WHEN Claude Code is detected, a flat top-level `models` key is present with all six values non-empty, and no `claude` namespace exists yet
  - THEN Step 1 does **not** take the fast path (completeness alone is not enough — the section that actually applies under Claude Code is `claude.models`, which is absent) — it reads `spdd-agent/assets/model-bootstrap.md` and follows the migration flow (propose the copy via a real foreground `AskUserQuestion`, write only once confirmed, leave the flat key untouched)

- **[MODIFIED]** Scenario: config file matches neither valid shape (malformed) — CONFIRMED: this generalizes `spdd/specs/spdd-agent.md`'s existing scenario with no behavior change, only where the instructions live
  - WHEN the JSON parses but matches neither the flat nor the `claude`-namespaced schema for the six phase values
  - THEN Step 1 cannot confirm completeness from the lightweight check alone, so it reads `spdd-agent/assets/model-bootstrap.md` and follows the same repair path documented there today — re-asking only for what's unresolvable via `AskUserQuestion`, without overwriting unrelated valid top-level keys

- **[NEW]** Scenario: config file is not valid JSON at all (parse failure) — CONFIRMED: treat as repair-path, per proposed default
  - WHEN `~/.config/spdd/config.json` exists but fails to parse as JSON
  - THEN Step 1 treats this the same as the malformed-shape case (opens `spdd-agent/assets/model-bootstrap.md`, follows its repair flow) rather than silently overwriting the file or treating it as "file doesn't exist" — asks for all six values since nothing can be trusted from an unparseable file, and warns the user the existing file couldn't be parsed before writing over it

- **[MODIFIED]** Scenario: explicit config request, read-only, config already complete
  - WHEN the user asks to view (not change) the current per-phase models and the applicable section is already complete
  - THEN Step 1 reports the six values from the lightweight check directly — `spdd-agent/assets/model-bootstrap.md` is not opened for a pure read of an already-complete config
- **[MODIFIED]** Scenario: explicit config request, user wants to change a value
  - WHEN the user asks to change one or more phase values (regardless of whether the config was already complete)
  - THEN Step 1 reads `spdd-agent/assets/model-bootstrap.md` for the `AskUserQuestion` mechanics (host-capability-based options) needed to ask only for the phases being changed, then writes back to the applicable section

**Out of scope:**
- Any change to *what* gets bootstrapped, asked, or written — the six-phase table, tier defaults, JSON shapes, and migration semantics are unchanged; only *when the instructional prose is loaded into context* changes.
- Fixing the pre-existing eval-ID collision discovered while drafting this canvas: `spdd-agent/evals/evals.json` reuses ids 31–36 that are also used by unrelated cases in `spdd-verify/evals/evals.json` (confirmed by inspecting both files — genuinely different prompts under the same numbers, not a duplicate). CONFIRMED: leave this pre-existing collision alone, out of scope for this canvas — this feature's new eval cases use fresh ids ≥ 67 (the highest id in use project-wide is currently 66 in `spdd-migrate/evals/evals.json`).
- Extending `scripts/check-hook-sync.sh` (or an equivalent) to cover `model-bootstrap.md` — that script diffs three *duplicated* copies of `hook-setup.md` across skills; `model-bootstrap.md` has no duplicate copies (it's `spdd-agent`-only), so there is nothing to diff.

---

## Entities

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| Model-bootstrap asset | `spdd-agent/assets/model-bootstrap.md` | New | Holds the default-model-per-phase table, tier rationale, first-run/repair/migration `AskUserQuestion` flows, and both JSON shape examples (flat + `claude`-namespaced). First asset file `spdd-agent` has ever needed — no `assets/` folder exists there yet. |
| Step 1 lightweight check | `spdd-agent/SKILL.md` ("Load or bootstrap the model configuration") | Existing (modified) | Keeps host detection (`CLAUDECODE` check) inline; replaces the always-loaded bootstrap block with a short completeness check plus a conditional read of the asset |
| Config bootstrap/repair/migration evals | `spdd-agent/evals/evals.json` (ids 31–38, 48) | Existing (modified) | Assertions extended to check whether `spdd-agent/assets/model-bootstrap.md` was or wasn't read during each scenario |
| Fast-path eval | `spdd-agent/evals/evals.json` (new id, proposed 67) | New | Asserts the asset is *not* read when the applicable section is already complete |
| Parse-failure eval | `spdd-agent/evals/evals.json` (new id, 68) | New | CONFIRMED — covers the "config exists but isn't valid JSON" edge case |
| `CLAUDE.md` Gotchas | `CLAUDE.md` | Existing (modified) | New bullet documenting the `model-bootstrap.md` lazy-load convention, alongside the existing `hook-setup.md` bullet |
| `AGENTS.md` Gotchas + Structure | `AGENTS.md` | Existing (modified) | Mirrors the `CLAUDE.md` bullet verbatim (per this repo's own "AGENTS.md mirrors CLAUDE.md" convention) plus a new Structure line for `spdd-agent/assets/model-bootstrap.md` |
| `spdd/specs/spdd-agent.md` | `spdd/specs/spdd-agent.md` | Existing (read-only for this canvas) | Not edited here — `spdd-verify` folds this feature's confirmed behavior into it once implemented and verified |

---

## Approach

- [x] Service/internal logic only (no presentation layer) — this is a prose/context-loading refactor inside a single `SKILL.md`'s instructions, following the precedent already set for the hook/TTL setup block.

**Rationale:**
Same pattern as commit `abccab7` ("refactor: lazy-load hook/TTL setup block from per-skill assets"): extract a block of instructions that's only actionable in a minority of runs (bootstrap/repair/migration) into its own asset file, and leave a cheap inline check in `SKILL.md` that decides whether to open it. No new runtime behavior is introduced — the six-phase config contract, the JSON shapes, and the `AskUserQuestion` mechanics are unchanged; only *where* the instructions live and *when* they're read changes.

---

## Structure

Files to create or modify:

```
spdd-agent/assets/model-bootstrap.md      # NEW — extracted bootstrap/repair/migration instructions + JSON shape examples
spdd-agent/SKILL.md                       # MODIFIED — Step 1 replaced with host detection (unchanged) + lightweight completeness check + conditional read of assets/model-bootstrap.md; metadata.version bumped
spdd-agent/evals/evals.json               # MODIFIED — evals 31–38, 48 assertions extended with asset-read/not-read checks; new eval(s) added for the fast path (and parse-failure, if confirmed)
CLAUDE.md                                 # MODIFIED — Gotchas: new bullet for the model-bootstrap.md lazy-load convention
AGENTS.md                                 # MODIFIED — mirrors the CLAUDE.md Gotchas bullet + Structure line for the new asset
```

---

## Operations

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

## Norms

Mandatory project conventions for this feature:

- [ ] Increment `metadata.version` in `spdd-agent/SKILL.md` on this edit (currently `1.9` on disk, uncommitted — this feature bumps it again on top of that). *(from `spdd/specs/spdd-agent.md` Norms, and the user's global memory note "Bump SKILL.md version")*
- [ ] Mirror any Structure/Conventions/Gotchas edit into both `CLAUDE.md` and `AGENTS.md`. *(from `spdd/specs/spdd-agent.md` Norms, and the user's global memory note "AGENTS.md mirrors CLAUDE.md")*
- [ ] When in doubt between direct and complete route, always choose complete. *(from `spdd/specs/spdd-agent.md` Norms — not directly applicable here since this canvas was requested explicitly via `/spdd-canvas`, not routed by `spdd-agent` itself, but noted for consistency)*
- [ ] Do not add automatic verification that a routing choice was "the correct one". *(from `spdd/specs/spdd-agent.md` Norms — unrelated to this feature but carried over as a standing project norm)*
- [ ] No `spdd/norms.md` exists in this project yet — nothing to carry over from team-wide norms.
- [ ] Follow the exact precedent structure of the three existing `hook-setup.md` assets and their owning `SKILL.md` grep-check-then-conditional-read pattern (see `spdd-canvas/SKILL.md` lines ~90–95, `spdd-implement/SKILL.md` lines ~50–55) — same "lightweight inline check → conditional read" shape, adapted from a `grep` check to a JSON completeness check since this asset gates on structured config content, not a flat text marker.

---

## Safeguards

**Tests to write:**
- [ ] Fast path: config complete → asset not read, no `AskUserQuestion`, proceeds straight to Step 2
- [ ] First-run bootstrap: config missing → asset read, full flow followed, correct shape written (flat vs. `claude`-namespaced per host)
- [ ] Repair: one key missing/empty → asset read, only that phase re-asked, other five untouched
- [ ] Migration: flat complete but no `claude` namespace, Claude Code detected → asset read, migration `AskUserQuestion` shown, write only after confirmation, flat key untouched
- [ ] Malformed shape (valid JSON, wrong schema) → asset read, only unresolvable phases re-asked, unrelated keys untouched
- [ ] Explicit config request, read-only, already complete → values reported without opening the asset
- [ ] Explicit config request, wants to change a value → asset read for the `AskUserQuestion` mechanics, only requested phase(s) changed

**Edge cases to consider (as WHEN/THEN scenarios — `spdd-verify` writes a targeted test for each one not already covered):**

- Scenario: config exists, applicable section complete, but the *other* (inapplicable) section is incomplete or malformed
  - WHEN e.g. Claude Code is detected, `claude.models` is complete, but a stray top-level `models` key is malformed
  - THEN Step 1 still takes the fast path — only the applicable section's completeness matters; the other section is never inspected or touched
- Scenario: config file exists but is completely empty (zero bytes)
  - WHEN `~/.config/spdd/config.json` exists as an empty file
  - THEN Step 1 treats this the same as the parse-failure case above (opens the asset, repair flow, warns before overwriting) — CONFIRMED together with the parse-failure scenario
- Scenario: six keys present but one value is not a string (e.g. a number or object)
  - WHEN a phase value in the applicable section is present but not a string type
  - THEN Step 1 treats it as "not a valid non-empty string" — same as missing/empty — and routes to the repair path via the asset, per the existing "non-empty string" requirement already stated in `spdd-agent/SKILL.md`'s Step 1
- Scenario: config directory `~/.config/spdd/` doesn't exist at all (not just the file)
  - WHEN neither the directory nor the file exists
  - THEN Step 1 treats this identically to "file doesn't exist" (first-run bootstrap) — the asset's bootstrap flow already creates the directory if needed, per the current Step 1 text

**Production rollback:**
Revert `spdd-agent/SKILL.md`'s Step 1 to inline the full bootstrap block (delete `spdd-agent/assets/model-bootstrap.md`, restore the prior Step 1 text from git history, decrement `metadata.version`); revert the `evals/evals.json`, `CLAUDE.md`, and `AGENTS.md` edits in the same commit. No runtime state or `~/.config/spdd/config.json` schema is touched by this feature, so rollback has no data-migration concerns.
