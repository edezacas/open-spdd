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

**Scenario: hook-presence check in one sentence (v2.6 trim)**
- WHEN `spdd-implement` Step 5 runs on Claude Code
- THEN the step checks `.claude/settings.local.json` for `SPDD` and `"subagentPromptCacheTtl"` in
  one sentence and reads `assets/hook-setup.md` only when something is missing

**Scenario: dependency check blocks silent out-of-order implementation** *(hand-authored 2026-09-02 from `spdd-implement/SKILL.md` Step 3 — audit-driven exception, not a fold-back)*
- WHEN the plan being implemented declares `Depends on:` other than `none` and any dependency is
  not at least `Status: Implemented`
- THEN `spdd-implement` warns the user explicitly and asks for confirmation before continuing —
  implementing out of order may be a deliberate choice, but it must never happen silently

**Scenario: unresolved `⚠️ Confirm:` lines gate implementation** *(hand-authored 2026-09-02 from `spdd-implement/SKILL.md` Step 4 — audit-driven exception, not a fold-back)*
- WHEN any `⚠️ Confirm:` lines exist in the canvas or the chosen plan
- THEN `spdd-implement` stops, lists them, and asks the user to confirm each one, replaces each
  with the confirmed value, and sets `**Status:** Confirmed` in the canvas (and plan, if any)
  header before proceeding

**Scenario: divergence from the canvas or plan stops implementation** *(hand-authored 2026-09-02 from `spdd-implement/SKILL.md` Step 6 — audit-driven exception, not a fold-back)*
- WHEN the canvas or plan is discovered to be wrong or incomplete during implementation
- THEN `spdd-implement` stops, explains the divergence, proposes the update, and resumes once
  the user confirms — it never silently edits around an incorrect document

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| Step "Output language" | `spdd-implement/SKILL.md` (Step 0) | Replaced the former "Detect output language" step — no longer detects or asks for the user's language; fixes "English" as the language of all document content generated or modified during implementation |
| Step "Ensure the SPDD hook and subagent cache TTL" (Step 5) | `spdd-implement/SKILL.md` + `assets/hook-setup.md` | Claude Code only; lazy-loaded since v2.4 — one-sentence presence check against `.claude/settings.local.json` (v2.6 trim), asset read only when the hook or TTL is missing |
| Dedicated-agent wrapper templates | `assets/agent-claude-code.md`, `assets/agent-opencode.md` | New (per-host phase subagents feature): thin bodies (load-and-follow + byte-identical never-block rule + report-back) installed by `spdd-install` to `~/.claude/agents/spdd-implement.md` / `~/.config/opencode/agents/spdd-implement.md`; Claude Code tools `Read, Glob, Grep, Write, Edit, Bash`, opencode `permission: {edit: allow, bash: allow}` — full implementation access |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Output language" (Step 0, replaces "Detect output language") in `spdd-implement/SKILL.md` | Uses English for all document content generated or modified during implementation (canvas or plan notes, discrepancy/divergence annotations), regardless of the user's conversation language |
| Boundary | Document content vs. code | The English-only rule for this step covers canvas/plan document content; code has always been written in English per the user's global `CLAUDE.md` convention and is not a new behavior introduced by this change |

---

## Norms

- Simplicity First: the language rule is a fixed, unconditional instruction — no conditional logic or per-project configuration.
- The authoritative version of a skill is the `metadata.version` in its own `SKILL.md` frontmatter — spec Norms never restate a version counter (removed 2026-09-02 after the counter drifted: spdd-agent said 1.13, skill was 1.14).
- Do not translate historical content already written in another language (e.g. divergence notes written before this change) — the rule is forward-only.
- Test coverage: `spdd-implement/evals/evals.json` gained new cases 54–55, verifying that divergence notes written with Spanish conversational context still land in English.
