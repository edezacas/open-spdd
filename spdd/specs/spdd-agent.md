# Spec: spdd-agent

> Living spec for the `spdd-agent` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**Scenario: direct route activates and is announced**
- WHEN the user describes a change that touches 1-2 files, is mechanical or of evident scope, and there is no business or architectural ambiguity
- THEN `spdd-agent` shows the line `Direct route: <reason> → implementing without a canvas.` before executing, implements the change directly without generating a canvas or plan, and does not invoke `spdd-canvas`/`spdd-design`/`spdd-verify`

**Scenario: complete route by default when in doubt**
- WHEN the change touches 3+ files, requires understanding multiple parts of the system, there is any business/architectural ambiguity, or the agent is not sure which route applies
- THEN `spdd-agent` follows the complete canvas → design → implement → verify flow exactly as it exists today, with no exception — doubt always resolves in favor of the complete route

**Scenario: model bootstrap does not block the direct route**
- WHEN the routing decision resolves to direct route
- THEN `spdd-agent` does NOT trigger the `~/.config/spdd/config.json` bootstrap before implementing, because the direct route does not launch subagents and does not need that configuration; the routing check is always evaluated before Step 1's model bootstrap, and bootstrap only triggers if the final decision is the complete route

**Scenario: direct route requires passing tests before touching the spec**
- WHEN `spdd-agent` implements via the direct route
- THEN it runs the test suite for the affected area before annotating the summary in `spdd/specs/<domain>.md`; if any test fails, it does not annotate anything in the spec, reports the concrete failure to the user, and does not revert the code automatically — the decision to revert or fix is left to the human

**Scenario: direct route with no inferable domain**
- WHEN the change doesn't allow a clear domain to be inferred (doesn't follow a folder convention like `src/<domain>/`)
- THEN it uses `spdd/specs/general.md` as a fallback, the same as `spdd-canvas` already does

**Out of scope (deliberate):**
- No automatic verification is added that the chosen route ("direct" vs. "complete") was "the correct one" — it is deliberately heuristic and fallible; real quality control lives in a separate improvement (diff vs. canvas in `spdd-verify`).

**Scenario: host detection runs before Step 1 reads the config**
- WHEN `spdd-agent` reaches Step 1 ("Load or bootstrap the model configuration") on the complete route
- THEN it first determines whether the current host is Claude Code (a `Bash` check of the `CLAUDECODE` env var — prints `1` for Claude Code, anything else / an error / `Bash` being unavailable means "not detected") before deciding which section of `~/.config/spdd/config.json` to read or write

**Scenario: config already complete for the applicable section (fast path)**
- WHEN `~/.config/spdd/config.json` exists and the section that applies to the detected host (`claude.models` under Claude Code, flat top-level `models` otherwise) has all four keys (`canvas`, `design`, `implement`, `verify`) present as non-empty strings
- THEN Step 1 reads those four values directly from the config file and proceeds to Step 2 without reading `spdd-agent/assets/model-bootstrap.md` at all — no `AskUserQuestion` call for model selection occurs

**Scenario: config file doesn't exist yet (first-run bootstrap)**
- WHEN `~/.config/spdd/config.json` doesn't exist
- THEN Step 1 reads `spdd-agent/assets/first-run.md`, which hands off to `spdd-agent/assets/model-bootstrap.md`'s first-run bootstrap flow (default-tier table, `AskUserQuestion` grouped into 1–2 calls, writing the flat or `claude`-namespaced shape with the four phase keys per host detection)

**Scenario: one or more of the four keys is missing or empty (repair case)**
- WHEN the applicable section exists but at least one of the four keys is missing, empty, or not a string
- THEN Step 1 reads `spdd-agent/assets/model-bootstrap.md` and follows its repair flow, re-asking via `AskUserQuestion` only for the affected phase(s), leaving the other values untouched

**Scenario: migration case still forces the asset open even if the flat section is complete**
- WHEN Claude Code is detected, a flat top-level `models` key is present with all four values non-empty, and no `claude` namespace exists yet
- THEN Step 1 does not take the fast path (completeness alone is not enough — the section that actually applies under Claude Code is `claude.models`, which is absent); it reads `spdd-agent/assets/model-bootstrap.md` and follows the migration flow

**Scenario: config file is not valid JSON at all (parse failure)**
- WHEN `~/.config/spdd/config.json` exists but fails to parse as JSON, or is a zero-byte file
- THEN Step 1 treats this as the malformed-shape case (opens `spdd-agent/assets/model-bootstrap.md`, follows its repair flow) rather than silently overwriting the file or treating it as "file doesn't exist" — asks for all four values since nothing can be trusted from an unparseable file, and warns the user the existing file couldn't be parsed before writing over it

**Scenario: explicit config request, user wants to change a value**
- WHEN the user asks to change one or more phase values (regardless of whether the config was already complete)
- THEN Step 1's completeness check always classifies an explicit change request as "not complete" — even when the applicable section is already fully valid — so it reads `spdd-agent/assets/model-bootstrap.md` for the `AskUserQuestion` mechanics needed to ask only for the phases being changed, then writes back to the applicable section

**Scenario: dependent plans launch on Implemented, not Verified**
- WHEN `spdd-agent` orders plans by their `Depends on:` field and plan B depends on plan A
- THEN B's implement phase launches once A has reached `Status: Implemented` (matching `spdd-implement` Step 3's dependency check) — never waiting for A to be `Status: Verified`; verification still runs per plan and the fold/archive waits for every plan `Verified`

**Scenario: zero-Confirm canvas still reaches Confirmed**
- WHEN the Step 5 checkpoint gate finds zero `⚠️ Confirm:` lines in a saved canvas
- THEN the orchestrator sets `**Status:** Confirmed` on the canvas and proceeds straight to the design phase — a canvas never lingers as `Draft` after its checkpoint

**Scenario: delegated canvas skips the applicability guard**
- WHEN `spdd-agent` delegates the canvas phase after deciding the complete route
- THEN the subagent prompt states that routing was already decided, so `spdd-canvas` Step 2 (applicability guard) is skipped

**Scenario: first run shows an onboarding guide before anything is asked**
- WHEN `spdd-agent` runs the complete route and Step 1's completeness check classifies the run as first-run bootstrap (`~/.config/spdd/config.json` does not exist)
- THEN the skill presents, in the conversation's language and before the model-choice questions, a brief guide — what the canvas → design → implement → verify flow does, that it pauses at foreground checkpoints to resolve `⚠️ Confirm:` lines, and where artifacts are written (`spdd/changes/<id>/`, `spdd/specs/<domain>.md`) — content lives in `spdd-agent/assets/first-run.md`, read only for this case

**Scenario: per-phase guidance during the first run**
- WHEN the first-run case fired earlier in the same run
- THEN as each phase launches (Steps 4, 6, 7, 8), `spdd-agent` adds one short line in the conversation's language saying what the phase does and what will come back, alongside the existing `[automatic decision]` transparency lines — first run only, never again on later runs

**Scenario: direct route on first use stays lean**
- WHEN `~/.config/spdd/config.json` doesn't exist but Step 0's routing decision is direct route
- THEN the direct route behaves exactly as always — no onboarding, no config bootstrap; the onboarding fires on the user's first complete-route run instead

**Scenario: subagent capability is detected once per run, not per phase (v2.0 simplification)**
- WHEN `spdd-agent` reaches Step 2
- THEN it determines, once, whether the host's subagent mechanism (if any) accepts a per-call model override, and uses that single determination — Isolated (with or without model override) or Inline — for every phase launched later in the run; there is no per-phase mode switch for Claude Code or Inline mode. (Step 2b, v2.1, adds one narrow, opencode-only per-phase check — see below — it never applies to Claude Code or Inline mode.)

**Scenario: model is always passed when the mechanism accepts one**
- WHEN Step 2 determined the host's subagent mechanism accepts a model override
- THEN every subagent call in Step 3, for every phase, sets `model` to that phase's value from `config.json` — unconditionally, with no branch that could skip it

**Scenario: Claude Code's Agent tool accepts a per-call model override**
- WHEN Step 2 runs under Claude Code
- THEN it always classifies Claude Code as accepting a model override — `model` is genuinely applied per phase via the `Agent` tool's `model` param on every call

**Scenario: opencode's Task tool has no per-call model override (2026-09-07 correction)**
- WHEN Step 2 runs under opencode and no dedicated agent file applies to the phase being launched (Step 2b below)
- THEN it dispatches that phase as Isolated-mode-without-override — per opencode's own documentation, an ad-hoc subagent always runs at the model of the primary agent that invoked it, with no per-invocation model field at all. `spdd-agent` never passes a `model` field to opencode's Task tool in this case, and never implies per-phase model selection is in effect; the transparency line states plainly that the phase runs at the conversation's own model

**Scenario: opencode dedicated-agent gap is detected and offered (v2.1)**
- WHEN `~/.config/opencode/` exists on the machine and at least one of the four `~/.config/opencode/agents/spdd-<phase>.md` files is missing, malformed, or has a `spdd-agent:model-source` marker that no longer matches `config.json`'s current flat `models` value for that phase
- THEN Step 2b shows one transparency line noting the gap and asks via a real foreground `AskUserQuestion` whether to run `spdd-agent/assets/install-opencode-agents.sh` now, "yes" recommended — this check runs once per `spdd-agent` invocation, on any host, never per phase, and never fires at all when `~/.config/opencode/` doesn't exist

**Scenario: opencode dedicated-agent offer accepted**
- WHEN the user accepts Step 2b's offer
- THEN `spdd-agent` runs `install-opencode-agents.sh` via `Bash`, reports which of the four files were written or left unchanged, and — if the current host is opencode — Step 3 dispatches every phase that now has a well-formed, up-to-date file to it by name (`subagent_type: "spdd-<phase>"`), never passing a `model` field, since the named agent's own frontmatter carries it

**Scenario: opencode dedicated-agent offer declined**
- WHEN the user declines Step 2b's offer
- THEN nothing is written, the run continues in Isolated-mode-without-override for every phase lacking a file, and the offer fires again on the next `spdd-agent` invocation while the gap persists

**Scenario: opencode dedicated agents already up to date**
- WHEN all four files exist, are well-formed, and their markers match `config.json`'s current flat values
- THEN Step 2b makes no transparency line and no offer — silent pass-through — and, on an opencode host, Step 3 dispatches every phase by name using those files

**Scenario: malformed opencode agent file treated as absent**
- WHEN one of the four files exists but has unparseable frontmatter or an empty body
- THEN Step 2b treats it the same as missing — includes it in the gap, offers to (re)write it — and never blocks or crashes over the bad file

**Scenario: this mechanism never changes Claude Code's own dispatch**
- WHEN Step 2b runs under Claude Code (with or without opencode also present on the machine)
- THEN Claude Code's own Step 2/Step 3 behavior is byte-identical to the v2.0 fix — always Isolated-mode-with-override, generic `subagent_type`, no per-phase file check — regardless of what Step 2b finds or does for opencode's files

**Scenario: install-opencode-agents.sh fails loudly when the flat `models` key was never bootstrapped (2026-09-07)**
- WHEN Step 2b's offer is accepted on a machine where `~/.config/spdd/config.json` exists but holds only a `claude` namespace (e.g. `spdd-agent` has so far only ever run under Claude Code) and no flat top-level `models` key at all
- THEN `install-opencode-agents.sh` never reads `claude.models` as a fallback — the two sections are independent per-host configs, not a fallback chain (same rule as the opencode-model-section memory: opencode's real values live only in the flat key, which may hold entirely different, non-Claude-Code model identifiers). All four phases are skipped with a warning; since all four skipped, the script exits non-zero with a message explaining the flat key is missing and pointing at running `spdd-agent` once under opencode to bootstrap it — it never exits 0 while silently writing nothing

**Scenario: eval coverage for the routing and dispatch rules**
- WHEN this domain is considered complete
- THEN `spdd-agent/evals/evals.json` contains cases covering: direct route activated, complete route activated, the 2-vs-3-files boundary case, business ambiguity in a 1-file change, test failure on the direct route without auto-revert, domain fallback to `spdd/specs/general.md`, first-run bootstrap combined with the complete route, Isolated-mode dispatch always carrying `model` on Claude Code, opencode's fixed no-override ad-hoc behavior (eval 72), the Step 2b opencode dedicated-agent gap/offer/accept/decline/up-to-date/malformed cases, and install-opencode-agents.sh's hard failure when the flat `models` key was never bootstrapped (eval 107)

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| "Routing" section (Step 0) | `spdd-agent/SKILL.md` | Evaluates direct vs. complete route before any other step |
| Model config | `~/.config/spdd/config.json` | Conditional bootstrap: only triggers if the chosen route is "complete". Flat `{"models": {...}}` by default, or nested `{"claude": {"models": {...}}}` under Claude Code — never both merged. Four keys only: `canvas`, `design`, `implement`, `verify` (`sync`/`migrate` removed 2026-09-07 — neither skill ever took a model override) |
| "Load or bootstrap the model configuration" (Step 1) | `spdd-agent/SKILL.md` | Detects the host first, then runs a lightweight completeness check against the applicable section; reads `spdd-agent/assets/model-bootstrap.md` only when that section isn't already complete or a value change was explicitly requested |
| Model-bootstrap asset | `spdd-agent/assets/model-bootstrap.md` | Holds the first-run bootstrap, repair, migration, malformed/unparseable-config, and explicit-value-change flows plus both JSON shape examples (4-key schema) — read conditionally, not always loaded |
| First-run asset | `spdd-agent/assets/first-run.md` | First-run onboarding: guide text, bootstrap hand-off, per-phase one-liner templates. Read only when Step 1's completeness check classifies the run as the file-doesn't-exist case (2026-09-07: no longer offers a dedicated-agent layer — removed along with `spdd-install`) |
| "Detect subagent capability" (Step 2) | `spdd-agent/SKILL.md` | Single, once-per-run determination (2026-09-07 simplification, replacing the four-level Dedicated/Isolated/Inline scheme): Isolated-with-model-override / Isolated-without-override / Inline. No per-phase detection |
| "Isolated mode: phase invocation contract" (Step 3) | `spdd-agent/SKILL.md` | For Claude Code (always) and opencode without a matching dedicated file: generic `subagent_type` + unconditional `model` from config.json whenever the mechanism accepts one + self-contained prompt (skill call, never-block rule, report contract). For opencode with a well-formed, up-to-date dedicated file: named `subagent_type: "spdd-<phase>"`, no `model` field, prompt skips the never-block rule/report contract (the named agent's own body carries both) |
| "opencode dedicated-agent check" (Step 2b, v2.1) | `spdd-agent/SKILL.md` | Once per run, any host: if `~/.config/opencode/` exists, checks all four `~/.config/opencode/agents/spdd-<phase>.md` files for presence/well-formedness/marker-match against config.json's flat `models`; offers (foreground `AskUserQuestion`) to run `install-opencode-agents.sh` on any gap; never fires if opencode isn't present; never affects Claude Code's own dispatch |
| opencode dedicated-agent installer | `spdd-agent/assets/install-opencode-agents.sh` | Self-contained script (v2.1): reads only `~/.config/spdd/config.json`'s flat `models` key (deliberately never `claude.models` — independent per-host configs, not a fallback chain), writes only `~/.config/opencode/agents/spdd-{canvas,design,implement,verify}.md` with a translated `model:` and a `spdd-agent:model-source=<raw>` marker; idempotent (skips a file whose marker already matches); exits 0 with a no-op message if `~/.config/opencode/` doesn't exist; exits 1 with actionable guidance (not a silent no-op) if the config file exists but the flat `models` key is missing/empty for all four phases. Never reads another skill's folder — the defect that broke the original `spdd-install` |
| "Inline mode" (Step 3-alt) | `spdd-agent/SKILL.md` | Runs the phase inline in the foreground when Step 2 found no subagent mechanism: `AskUserQuestion` is available for real, the never-block rule doesn't apply |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Classify change scope" (Step 0, routing decision) | Decides direct vs. complete route based on number of files and presence of business/architectural ambiguity, before invoking any phase |
| Route | Direct route | Implements without a canvas or plan, runs the test suite for the affected area, annotates a summary in `spdd/specs/<domain>.md` only if tests pass |
| Route | Complete route | canvas → design → implement → verify |
| Step | "Detect Claude Code host" | Sub-step at the start of Step 1 — a `Bash` check of the `CLAUDECODE` env var determines Claude-Code vs. other/inconclusive |
| Step | "Completeness check" (Step 1) | Reads `~/.config/spdd/config.json`, inspects only the applicable section (4 keys), classifies the run as fast-path / first-run bootstrap / repair / migration / malformed-or-unparseable / explicit-change-requested |
| Step | "Fast path" (Step 1) | On classification "complete": reads the four values directly and proceeds to Step 2; `model-bootstrap.md` never opened |
| Step | "Detect subagent capability" (Step 2) | Once per run: does the host's subagent mechanism accept a model override? → Isolated-with-override / Isolated-without-override / Inline. One transparency line |
| Step | "Isolated mode invocation contract" (Step 3) | For each phase: subagent call with unconditional `model` (when accepted) + prompt (skill call, never-block rule verbatim, report contract); on opencode with a matching dedicated file, dispatches by name instead (no `model` field, prompt carries only the skill call) |
| Step | "opencode dedicated-agent check" (Step 2b) | Once per run: gap-check the four `~/.config/opencode/agents/spdd-<phase>.md` files against config.json; foreground offer to run the installer script on any gap |
| Script | `install-opencode-agents.sh` | Translates each phase's flat `models` value through the alias table, writes/resyncs the matching opencode agent file, idempotent via the model-source marker |
| Step | "Checkpoint gate: canvas" (Step 5) | Resolves every `⚠️ Confirm:` line in the foreground (up to 4 per call); with zero Confirm lines it sets `**Status:** Confirmed` and skips straight to the design phase |
| Step | "Implement phase, per plan" (Step 7) | Topological order by `Depends on:` — a plan never launches before every plan it depends on has reached `Status: Implemented`; context is that one plan only |

---

## Norms

- When in doubt between direct and complete route, ALWAYS choose the complete route.
- Do not add automatic verification that the chosen route was "the correct one".
- The authoritative version of a skill is the `metadata.version` in its own `SKILL.md` frontmatter — spec Norms never restate a version counter.
- The never-block rule quoted verbatim in Step 3 is an exact string — edits elsewhere in the file must never alter it.
- Claude Code's subagent model dispatch has exactly one path (Step 2 + Step 3, since 2026-09-07) with no per-phase mode switch — the original `spdd-install` skill and its dedicated-per-phase-agent layer were removed because they required sibling-skill-folder access that a real per-skill install (e.g. via `npx skills add`) cannot provide, and because the branching they added was the likely cause of dropped `model` overrides. Do not reintroduce a per-phase dispatch mode on Claude Code without solving that distribution problem first.
- opencode's dedicated-agent mechanism (Step 2b, v2.1) is opencode-only by design and self-contained: `spdd-agent/assets/install-opencode-agents.sh` lives inside `spdd-agent`'s own folder, reads only `~/.config/spdd/config.json`, and writes only `~/.config/opencode/agents/` — it never reads another skill's folder, avoiding the exact defect that sank the original `spdd-install`. It exists because opencode's Task tool has no per-call model override at all (unlike Claude Code), so a named agent file with a static `model:` is the *only* way to get per-phase models there — not an optional performance layer. Do not extend this mechanism to Claude Code; Claude Code doesn't need it and doing so would reintroduce the removed branching.
- Whether a host's subagent mechanism accepts a per-invocation model override is a fixed fact about that host, sourced from its own documentation — never inferred, guessed, or probed at runtime by trying it and seeing what happens. Claude Code: yes. opencode: no, confirmed against opencode's own docs (2026-09-07) — an ad-hoc subagent always runs at the model of the primary agent that invoked it.
- Lazy-load pattern for the first-run asset: `spdd-agent/assets/first-run.md` is read only when Step 1's completeness check classifies the run as the file-doesn't-exist case.
- Onboarding text never leaks into artifacts: the first-run guide and the per-phase one-liners exist only in the orchestrator's foreground conversation; project-level setup (guard hook, `subagentPromptCacheTtl`, `spdd/` scaffolding, `spdd/norms.md`) stays per-project lazy in the phase skills.
- Shared sections of the mirror docs — Structure, Conventions, Gotchas — must stay byte-identical across `CLAUDE.md` and `AGENTS.md`; audience-specific sections may differ by design.
