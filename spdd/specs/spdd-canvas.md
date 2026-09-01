# Spec: spdd-canvas

> Living spec for the `spdd-canvas` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, we want every `canvas.md` `spdd-canvas` generates to be
written in English, instead of detecting and using the user's conversation language, so that
downstream tasks reading these documents as context spend fewer reasoning tokens.

**Scenario: `spdd-canvas` generates a new canvas**
- WHEN `spdd-canvas` generates a canvas from `assets/template-reasons.md`
- THEN all `canvas.md` content — section headings, User story, Acceptance Criteria
  (WHEN/THEN scenarios), Entities, Norms, Safeguards, and any domain notes — is in English:
  the template's own `> Language:` note (template-reasons.md line 5) is the single authoritative
  instruction. Since v2.9 the former dedicated "Output language" step (Step 3) is deleted as a
  redundant duplicate — observable output (English canvas) is unchanged

**Scenario: user describes the feature entirely in Spanish (or any non-English language)**
- WHEN the user invokes `/spdd-canvas` with a feature description in Spanish
- THEN the generated `canvas.md` has all headings, scenarios, and notes in English; the
  conversational report back to the user may still follow the conversation's language (e.g. the
  user's global `CLAUDE.md` instructions)

**Scenario: `template-reasons.md` no longer asks for a translated language**
- WHEN a `canvas.md` is generated from `spdd-canvas/assets/template-reasons.md`
- THEN the template's `> Language: ...` note no longer says "translate ... to the language
  detected from the user" — it states explicitly that the document is written in English

**Scenario: conversational replies to the user do not change language**
- WHEN `spdd-canvas` reports back to the user in the chat turn (Step 12's final summary) — not a
  persisted file
- THEN that conversational reply still follows the conversation's language settings; the
  English-only rule applies only to the persisted document content (`canvas.md`), not to chat

**Scenario: freshness check, foreground**
- WHEN the domain's `spdd/specs/<domain>.md` predates commits touching that domain's source folder
- THEN `spdd-canvas` stops before generating and asks via `AskUserQuestion`: "Run spdd-sync first"
  (invoke `spdd-sync` for this domain, then continue) or "Continue anyway" (staleness noted in the
  final report); no canvas is written until the human decides

**Scenario: freshness check, background (never-block default)**
- WHEN the same staleness is found in a background run (no `AskUserQuestion` available)
- THEN the run does not stop: it continues, generates and saves the canvas, and adds
  `⚠️ Confirm: spec stale — last sync <date>, <n> commits since` for the orchestrator's foreground
  checkpoint to resolve (v2.9)

**Scenario: global norms carry-over**
- WHEN `spdd/norms.md` exists at the project root
- THEN its rules are carried into the new canvas as starting Norms/Safeguards, clearly attributed
  to `spdd/norms.md` and distinct from feature-specific ones; `spdd/norms.md` itself is never
  created or edited by this skill

**Scenario: layers question, background (never-block default)**
- WHEN the feature description mentions two separate concerns (e.g. "backend + frontend") and the
  run is in background (no `AskUserQuestion`)
- THEN the default is a single unified canvas, with a `⚠️ Confirm: layers` line for the
  orchestrator's checkpoint (v2.9)

**Scenario: hook-presence check in one sentence (v2.10 trim)**
- WHEN `spdd-canvas` Step 9 runs on Claude Code
- THEN the step checks `.claude/settings.local.json` for `SPDD` and `"subagentPromptCacheTtl"` in
  one sentence and reads `assets/hook-setup.md` only when something is missing

**Scenario: Step 10 suggests the next step without explaining other skills (v2.10 trim)**
- WHEN `spdd-canvas` reports back
- THEN it suggests `/spdd-design` without restating `spdd-implement`'s
  never-implements-from-canvas rule (owned by `spdd-implement`'s frontmatter and Step 1)

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| `> Language: ...` note | `spdd-canvas/assets/template-reasons.md` (line 5) | Single authoritative English-language instruction since v2.9 — the former "Output language" step (Step 3) was a redundant duplicate and was deleted |
| Step "Context: freshness, spec, norms, and risk" (Step 5) | `spdd-canvas/SKILL.md` | Merged in v2.9 from the former freshness + context steps: infers the domain, runs the freshness check (foreground ask / background default), reads the living spec (`general.md` fallback), reads `spdd/norms.md`, identifies risk |
| Step "Determine layers" (Step 6) | `spdd-canvas/SKILL.md` | Asks one-canvas-vs-per-layer only for two-concern descriptions; background default since v2.9: single unified canvas + `⚠️ Confirm` |
| Step "Ensure the SPDD hook and subagent cache TTL" (Step 9) | `spdd-canvas/SKILL.md` + `assets/hook-setup.md` | Claude Code only; lazy-loaded since v2.8 — one-sentence presence check (v2.10 trim), asset read only when the hook or TTL is missing (renumbered from Step 11 in v2.9) |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Context: freshness, spec, norms, and risk" (Step 5, merges former Steps 6+7) | Infer domain from folder conventions → freshness check (foreground: stop and ask spdd-sync-vs-continue; background: continue + `⚠️ Confirm: spec stale`) → read living spec (`general.md` fallback) → read `spdd/norms.md` (carry-over, attributed) → identify risk and ambiguity |
| Step | "Determine layers" (Step 6) | One-canvas-vs-per-layer question only for two-concern descriptions; background default: single unified canvas + `⚠️ Confirm` |
| Template note | `> Language: ...` in `template-reasons.md` | Explicitly declares the document is written in English — single authoritative language instruction since v2.9 |
| Step | "Ensure the SPDD hook and subagent cache TTL" (Step 9, Claude Code only) | One-sentence presence check (grep `SPDD` and `"subagentPromptCacheTtl"`) against `.claude/settings.local.json`; asks before any write; merges from `assets/hook-setup.md` only when something is missing |
| Boundary | Persisted document vs. conversational reply | The English-only rule applies only to `canvas.md` content; conversational replies to the user in chat still follow the conversation's language rules (e.g. the user's global `CLAUDE.md` instructions) |

---

## Norms

- Simplicity First: the language rule is a fixed, unconditional instruction — no conditional logic or per-project configuration, no opt-out via `spdd/norms.md`.
- Increment `metadata.version` of `spdd-canvas/SKILL.md` whenever its instructions are edited (currently at 2.10, cumulative across changes).
- Do not translate historical content already written in another language (e.g. archived canvases generated before this change) — the rule is forward-only.
- Test coverage: `spdd-canvas/evals/evals.json` cases 52–53 (English output from a Spanish description) and 54 (background freshness default) verify this spec's scenarios.
- Every foreground ask in this skill names a never-block default for background runs (freshness: continue + `⚠️ Confirm: spec stale`; layers: single unified canvas + `⚠️ Confirm`) — a background subagent must never block on a step that only names an ask (v2.9).
