# REASONS: Optimize SKILL.md prose for AI consumption

> Generated on 2026-08-31 10:07. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.

**Status:** Confirmed

---

## Requirements

**User story:**
As the maintainer of the open-spdd skills framework, I want each `SKILL.md` instruction file audited and trimmed of prose that exists only to help a human reader understand the design — plus cross-file duplication reduced where safe — so that an AI executing these skills spends fewer reasoning/context tokens on non-operative text, without losing any instruction it actually needs to follow correctly.

**Acceptance criteria:**

- **[NEW]** Scenario: A trim removes only human-facing content
  - WHEN a line, sentence, or block is removed or shortened from any `SKILL.md`
  - THEN it must be prose whose sole function is explaining rationale, background, or examples to a human reader — never an instruction, decision rule, branching condition, or exact string/snippet (the never-block-rule quoted block, the JSON hook snippet, the bash `grep` checks, template placeholders) that the executing LLM needs verbatim to behave correctly
- **[NEW]** Scenario: Cross-skill duplication is reduced only where it doesn't break portability
  - WHEN the same operative block appears verbatim or near-verbatim in two or more `SKILL.md` files (e.g. the "Ensure the SPDD hook and subagent cache TTL are present" step, duplicated in full in `spdd-canvas` Step 11, `spdd-implement` Step 5, `spdd-verify` Step 9)
  - THEN duplication is reduced only if the fix doesn't require one skill's folder to read a file outside itself at runtime — because each `spdd-*/` directory is symlinked into `~/.claude/skills/` and distributed independently (see `⚠️ Confirm` below); trimming repeated *rationale sentences* down to one shared short form is safe, extracting the *operative* bash/JSON snippet into a shared file is not, by default
- **[NEW]** Scenario: Skill files stay independently loadable
  - WHEN any single `SKILL.md` is loaded on its own, with no other `spdd-*` skill present in the same install
  - THEN it must remain fully self-contained and executable exactly as before — no new implicit dependency on another skill's file or wording
- **[NEW]** Scenario: No behavioral regression in evals
  - WHEN each modified skill's `evals/evals.json` is re-run after trimming
  - THEN every existing assertion still passes; trimming changes how many tokens the instructions cost to read, never what the skill does

**Out of scope:**
- `CLAUDE.md` / `AGENTS.md` content (not a `SKILL.md` or template; not named in the request)
- `evals/evals.json` files (read to verify no regression, not rewritten as part of this change, unless an assertion literally quotes trimmed wording)
- Actually performing the edits — this canvas scopes *what* to trim and flags the genuinely ambiguous calls; execution happens in `spdd-design` → `spdd-implement`
- Adding new functionality, new steps, or changing any skill's actual decision logic/flow

---

## Entities

Not a data-model feature — "entities" here are the documents in scope.

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| `spdd-agent SKILL.md` | `spdd-agent/SKILL.md` | Existing | 160 lines — orchestrator, richest in rationale prose (model-tier "Why" column, config-surface justification) |
| `spdd-canvas SKILL.md` | `spdd-canvas/SKILL.md` | Existing | 115 lines — contains one full copy of the hook/TTL setup block |
| `spdd-design SKILL.md` | `spdd-design/SKILL.md` | Existing | 59 lines — leanest file, already cross-references `spdd-canvas`'s hook offer in prose (no file read) instead of restating it |
| `spdd-implement SKILL.md` | `spdd-implement/SKILL.md` | Existing | 85 lines — second full copy of the hook/TTL setup block |
| `spdd-verify SKILL.md` | `spdd-verify/SKILL.md` | Existing | 113 lines — third full copy of the hook/TTL setup block; longest language-note paragraph |
| `spdd-sync SKILL.md` | `spdd-sync/SKILL.md` | Existing | 41 lines — has its own shorter language-note restatement |
| `spdd-migrate SKILL.md` | `spdd-migrate/SKILL.md` | Existing | 58 lines — has a *variant* of the hook block (rewrite, not install) so not part of the triplicate |
| `template-reasons.md` | `spdd-canvas/assets/template-reasons.md` | Existing | Skeleton with bracketed placeholders — already lean, no rationale prose to trim |
| `template-plan.md` | `spdd-design/assets/template-plan.md` | Existing | Already lean |
| `template-norms.md` | `spdd-canvas/assets/template-norms.md` | Existing | Already lean; the blockquote at the top (lines 3–9) is instructional for the human team filling it in, not read by any skill as operative text — candidate for keeping as-is since it is genuinely human-audience content by design |

---

## Approach

Not a code pattern from the template's checklist — this is a **content audit + targeted edit** across existing Markdown instruction files.

**Rationale:**
Read every `SKILL.md` and template in scope, classify each block of prose as (a) operative — a rule, condition, exact string, or branching instruction the executing LLM must have to behave correctly, or (b) human-facing — rationale, worked examples, or "why we chose this" framing that doesn't change what the AI does. Then separately identify verbatim/near-verbatim duplication across files. Trim (b) directly. For duplication, only consolidate via extraction into a shared file if doing so doesn't break each skill folder's standalone portability (⚠️ Confirm below) — otherwise the safe default is to trim only the *varying* rationale wrapped around an identical operative core, and leave the operative core duplicated.

---

## Structure

Files to review/edit (no new files planned unless the shared-fragment ⚠️ Confirm below resolves in favor of extraction):

```
spdd-agent/SKILL.md
spdd-canvas/SKILL.md
spdd-design/SKILL.md
spdd-implement/SKILL.md
spdd-verify/SKILL.md
spdd-sync/SKILL.md
spdd-migrate/SKILL.md
spdd-canvas/assets/template-reasons.md   (reviewed — no change expected)
spdd-design/assets/template-plan.md      (reviewed — no change expected)
spdd-canvas/assets/template-norms.md     (reviewed — no change expected, human-audience by design)
```

---

## Operations

Concrete findings and the proposed default trim/consolidation for each. `spdd-design` should turn each row into one implementation step; `spdd-implement` executes them; `spdd-verify` re-runs the affected evals.

| Type | Identifier | Description |
|------|-----------|-------------|
| Consolidate | Hook/TTL setup block (3× full duplicate) | `spdd-canvas` Step 11, `spdd-implement` Step 5, `spdd-verify` Step 9 each carry the identical ~25-line bash-check + JSON-hook + JSON-TTL block, differing only in one rationale sentence about *why* that phase benefits from the cache TTL. **Confirmed:** keep the operative snippet duplicated in all three (portability), replace each phase-specific TTL rationale sentence with a single shared short form ("this phase can run several turns inside one subagent call; without the TTL setting, Claude Code caps its prompt cache at 5 minutes regardless of plan") |
| Trim | `spdd-agent` Step 1, model-tier table "Why" column (lines ~100–105) | Justifies each suggested model tier to a human; the AI only reads the "Suggested tier" column to act. **Confirmed:** delete the column, keep its content as a one-line footnote below the table, since it's not consulted per-invocation |
| Trim | `spdd-agent` Step 1, line ~91 ("Their entries exist in the same file only so the config surface... is uniform across all six phases") | Explains a design choice; doesn't change Step 1's behavior. Default: delete |
| Trim | `spdd-agent` Step 1, line ~107 ("The last column is one worked example, not the framework's default...") | Borderline: could be read as an operative caveat against hardcoding Claude Code aliases when extending to a new host, or as a human-only aside. **Confirmed:** keep — treated as an operative caveat |
| Trim | Language-note paragraphs (`spdd-design` Step 7, `spdd-implement` Step 0, `spdd-verify` Step 7, `spdd-sync` Step 5) | Each restates "write new content in English" with a different rationale clause. The one-line operative instruction ("write all new content in English") must stay in each — a background subagent's prompt (per `spdd-agent` Step 3) carries only the skill call + never-block rule, not the full project `CLAUDE.md`, so the rule can't be assumed inherited. **Confirmed:** drop the varying rationale clause everywhere, keep one uniform short instruction line per file |
| No action (reviewed) | "Conversational response, not persisted document content" sentence (`spdd-agent` Decision transparency section; `spdd-canvas` Step 6.4) | Same rule stated twice with different wording, but each instance is one sentence — token cost of duplication is low relative to the portability risk of extracting it. Default: leave both as-is |
| Trim | `spdd-verify` Step 1 already cross-references "same lookup pattern as `spdd-implement` Step 1" in prose (not a file read); `spdd-design` Step 1 spells the same change-listing lookup out in full | **Confirmed:** apply the same short textual cross-reference style to `spdd-design` Step 1, for consistency with the precedent already used in `spdd-verify` |
| No action (reviewed) | Frontmatter `compatibility:` note + inline "Skip this step if you are not running as Claude Code" note, duplicated across `spdd-canvas`, `spdd-implement`, `spdd-verify` | Different audiences/access points (frontmatter is metadata a host or human scans upfront; the inline note is what the AI actually branches on mid-execution) — not true redundancy. Default: no change |
| No action (reviewed) | `template-norms.md` blockquote (lines 3–9) | Addressed to the human team that will fill in `spdd/norms.md`, not read by any skill as an instruction to execute — genuinely human-audience content, correctly placed. Default: no change |

---

## Norms

Mandatory conventions for this change:

- [ ] No `spdd/norms.md` exists in this project — using this repo's own `CLAUDE.md` / `AGENTS.md` as the applicable conventions instead of a team norms file
- [ ] SPDD document content (this canvas, and any resulting plan) stays in English — per `CLAUDE.md` Gotchas
- [ ] Any `SKILL.md` whose instructions actually change must have `metadata.version` bumped in its frontmatter (per repo convention/memory: "always increment metadata.version when editing a skill's instructions")
- [ ] If any edit here also changes `CLAUDE.md`'s Structure/Conventions/Gotchas sections, mirror the same edit into `AGENTS.md` (both files exist in this repo and are expected to stay in sync per project memory) — not expected to trigger for this change since scope is `SKILL.md`/template prose only, noted as a guard in case an edit spills into repo-level docs
- [ ] Each `spdd-*/SKILL.md` must remain independently loadable/self-contained — this repo's own architecture note states skills are "loaded via symlinks into `~/.claude/skills/`" individually, with "no `.claude/agents/*.md` layer," implying each skill folder is a portable, standalone unit
- [ ] `allowed-tools:` frontmatter in each file must still match what the trimmed instructions actually use — don't leave stale tool permissions after an edit

---

## Safeguards

**Tests to write:**
- [ ] Re-run each edited skill's existing `evals/evals.json` assertions (no new eval scenarios required unless a trim changes observable output, which is out of scope by definition)
- [ ] Diff each edited `SKILL.md` before/after and manually confirm every removed line matches the "human-facing only" classification, not a decision rule or exact string

**Edge cases to consider (as WHEN/THEN scenarios):**

- Scenario: A trim removes a line an eval assertion depends on
  - WHEN `evals/evals.json` for an edited skill is re-run after the edit
  - THEN any assertion that checked for the literal trimmed wording must be reconciled (updated or the trim reverted) before the change is considered done
- Scenario: Shared-fragment extraction breaks standalone distribution
  - WHEN a single `spdd-*/` folder is symlinked into `~/.claude/skills/` on its own, without its sibling skill folders present
  - THEN it must still load and execute correctly — nothing in this change may make one skill's `SKILL.md` depend on reading a file that lives outside its own folder
- Scenario: `metadata.version` not bumped
  - WHEN any `SKILL.md`'s instruction text changes, even to only remove text
  - THEN its frontmatter `metadata.version` must be incremented before the change is marked implemented
- Scenario: A background subagent loses rationale it actually needed
  - WHEN a rationale sentence is trimmed under the assumption that "the AI already knows this from `CLAUDE.md`"
  - THEN that assumption only holds for a foreground session with the project `CLAUDE.md` loaded — it does not hold for a step executed by a `spdd-agent`-launched background subagent, whose prompt (per `spdd-agent` Step 3) contains only the skill call, the never-block rule, and the phase's context table — re-check every trim against this narrower worst-case context before applying it

**Production rollback:**
This is a documentation-only repo change with no runtime/deployment surface — rollback is a normal `git revert` of the specific `SKILL.md` commit(s). No data migration, no user-facing service impact.

---

## Confirmations (resolved 2026-08-31, foreground checkpoint)

All items below were generated as `⚠️ Confirm:` by a background canvas subagent (no live user turn, no `AskUserQuestion` available) and resolved via a foreground `AskUserQuestion` checkpoint before advancing to `spdd-design`. All recommended defaults were accepted:

- Hook/TTL setup block: keep the operative bash+JSON snippet duplicated across `spdd-canvas`/`spdd-implement`/`spdd-verify` (portability); consolidate only the varying rationale sentence into one shared short form.
- `spdd-agent` Step 1 model-tier table "Why" column: shrink to a one-line footnote instead of a full column.
- `spdd-agent` Step 1 "worked example" caveat line: keep, as an operative caveat against hardcoding Claude Code aliases.
- Four language-note paragraphs (`spdd-design`/`spdd-implement`/`spdd-verify`/`spdd-sync`): drop each varying rationale clause, keep one uniform short instruction line per file.
- `spdd-design` Step 1: apply the same short textual cross-reference style `spdd-verify` Step 1 already uses toward `spdd-implement` Step 1.
- `.claude/settings.local.json` missing `"subagentPromptCacheTtl": "1h"`: added (side-effect action, executed at this checkpoint — see repo root `.claude/settings.local.json`).
- Domain/spec ambiguity: no additional `spdd/specs/` note added — this change is about the `SKILL.md` files' own prose, not about behavior the existing specs describe.
