# Spec: spdd-design

> Living spec for the `spdd-design` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, we want every plan document `spdd-design` generates to be
written in English, instead of detecting and using the user's conversation language, so that
downstream tasks reading these documents as context spend fewer reasoning tokens.

**Scenario: `spdd-design` generates a plan from an already-English canvas**
- WHEN `spdd-design` reads a canvas (already in English) and generates one or more `plan-*.md` files
- THEN the new content it authors (not just what is copied from the canvas) stays in English — it does not reintroduce Spanish or any other language even if the conversation with the user is in a different language

**User story:**
As a team maintaining `open-spdd`, we want `spdd-design` to avoid splitting genuinely homogeneous
work into one plan per file, so that mechanical, same-shaped changes across many files aren't
handed to `spdd-implement` as artificial separate plans.

**Scenario: `spdd-design` merges homogeneous same-type edits into one plan**
- WHEN every group found in Step 4 applies the same Operation type to files of the same kind (e.g. the same prose trim repeated across N `SKILL.md` files), even though their Structure paths don't overlap
- THEN Step 5 emits a single plan with one row per file instead of one plan per file — splitting stays reserved for work that is genuinely separable (different Operation types, or work meant for different people/agents)

**Scenario: Step 7 delegates field guidance to the template (v1.5 trim)**
- WHEN `spdd-design` generates plan(s) after reading `template-plan.md` in Step 6
- THEN `Depends on:`/`Shared touchpoints:` guidance comes from the template; generated plans still carry both fields with the same semantics

**Scenario: change lookup is self-contained (v1.5 trim)**
- WHEN `spdd-design` Step 1 locates a change without an argument
- THEN it lists `spdd/changes/` entries matching `SPDD-*` (most recent first) inline, without referencing `spdd-implement` Step 1

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| `> Language: ...` note | `spdd-design/assets/template-plan.md` (line 4) | States the document is written in English, with no translation instruction |
| Language defensive note | `spdd-design/SKILL.md` (Step 7 — "Generate the plan(s)") | Reminds the skill, at the point where it authors new prose of its own (not copied from the canvas), that this prose must also stay in English |
| Dedicated-agent wrapper templates | `assets/agent-claude-code.md`, `assets/agent-opencode.md` | New (per-host phase subagents feature): thin bodies (load-and-follow + byte-identical never-block rule + report-back) installed by `spdd-install` to `~/.claude/agents/spdd-design.md` / `~/.config/opencode/agents/spdd-design.md`; Claude Code tools `Read, Glob, Grep, Write`, opencode `permission: {edit: allow, bash: deny}` — plan-file `Write` only, no shell |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Template note | `> Language: ...` in `template-plan.md` | Explicitly declares the document is written in English, with no translate-to-detected-language instruction |
| Note | Language defensive note in `spdd-design/SKILL.md` Step 7 | Placed right before the plan-generation instructions; states plan content (names, headings, all prose in Operations/Entities/Structure, and any notes added) must be in English regardless of the canvas's or the user's conversation language |
| Boundary | Persisted document vs. conversational reply | The English-only rule applies only to `plan-*.md` content; conversational replies to the user in chat still follow the conversation's language rules (e.g. the user's global `CLAUDE.md` instructions) |
| Homogeneity criterion | `spdd-design/SKILL.md` (Step 5 — "Decide: one plan or many") | Sentence(s) reserving real splitting for groups that differ in Operation type or are meant for different agents/people; merges same-type/same-kind groups into a single plan with one row per file, even if their Structure paths don't overlap |
| Step 7 field guidance | `spdd-design/SKILL.md` (Step 7) | Delegated to `template-plan.md` since v1.5 — the `Depends on:`/`Shared touchpoints:` bullets were a duplicate of the template's own guidance |

---

## Norms

- Simplicity First: the language rule is a fixed, unconditional instruction — no conditional logic or per-project configuration.
- The authoritative version of a skill is the `metadata.version` in its own `SKILL.md` frontmatter — spec Norms never restate a version counter (removed 2026-09-02 after the counter drifted: spdd-agent said 1.13, skill was 1.14).
- Do not translate historical content already written in another language (e.g. plans generated before this change) — the rule is forward-only.
- New prose `spdd-verify` adds while folding a change into this spec, or during its Diff-to-canvas check, must also be in English (see `spdd-verify/SKILL.md`'s own language note near Steps 7–8).
- The homogeneity criterion requires both the same Operation type AND the same file kind — groups that are small but differ in Operation type must still be split.
