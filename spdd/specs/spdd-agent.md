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

**Scenario: eval coverage for the routing rule**
- WHEN the routing improvement is considered complete
- THEN `spdd-agent/evals/evals.json` contains cases covering: direct route activated, complete route activated, the 2-vs-3-files boundary case with a shared module, business ambiguity in a 1-file change, test failure on the direct route without auto-revert, domain fallback to `spdd/specs/general.md`, and first-run bootstrap combined with the complete route

**Scenario: direct route with no inferable domain**
- WHEN the change doesn't allow a clear domain to be inferred (doesn't follow a folder convention like `src/<domain>/`)
- THEN it uses `spdd/specs/general.md` as a fallback, the same as `spdd-canvas` already does

**Out of scope (deliberate):**
- No automatic verification is added that the chosen route ("direct" vs. "complete") was "the correct one" — it is deliberately heuristic and fallible; real quality control lives in a separate improvement (diff vs. canvas in `spdd-verify`, not yet implemented).

**Scenario: host detection runs before Step 1 reads the config**
- WHEN `spdd-agent` reaches Step 1 ("Load or bootstrap the model configuration") on the complete route
- THEN it first determines whether the current host is Claude Code (a `Bash` check of the `CLAUDECODE` env var — prints `1` for Claude Code, anything else / an error / `Bash` being unavailable means "not detected") before deciding which section of `~/.config/spdd/config.json` to read or write

**Scenario: Claude Code detected, nested config already present**
- WHEN the host is detected as Claude Code and `~/.config/spdd/config.json` already contains a `claude` namespace with all six phase values non-empty
- THEN Step 1 reads model values from that `claude` namespace and proceeds exactly as today, using those six values for Steps 4–8

**Scenario: Claude Code detected, only legacy flat config present**
- WHEN the host is detected as Claude Code and the config file exists with a top-level flat `models` key but no `claude` namespace
- THEN `spdd-agent` treats this as a one-time migration, not ordinary repair: it proposes copying the flat key's six values into a new `claude.models` namespace via a real foreground `AskUserQuestion` (writing the file is a side effect), and writes only once confirmed — it never silently reads the flat key as if it were Claude-Code-scoped, and never deletes or modifies the original flat key

**Scenario: non-Claude-Code host uses the current flat shape**
- WHEN the host is detected as anything other than Claude Code (opencode, codex, or detection is inconclusive)
- THEN Step 1 reads/writes the top-level flat `models` key exactly as it does today — no behavior change for non-Claude-Code hosts

**Scenario: first-run bootstrap under Claude Code writes the nested shape**
- WHEN `~/.config/spdd/config.json` does not exist yet and the host is detected as Claude Code
- THEN the bootstrap flow (Step 1.1) writes the new nested `claude` namespace (`{"claude": {"models": {"canvas": ..., "design": ..., "implement": ..., "verify": ..., "sync": ..., "migrate": ...}}}`) instead of the flat top-level `models` key

**Scenario: dual-key precedence when both shapes are present**
- WHEN Claude Code is detected and the config file contains both a flat `models` key and a `claude` namespace (partially migrated, or hand-edited)
- THEN Step 1 reads only from the `claude` namespace and leaves the flat key untouched — never merges or deletes it automatically

**Scenario: detection is inconclusive**
- WHEN Step 1's host-detection sub-step cannot confidently determine the host (signal absent, ambiguous, or the detection mechanism itself errors)
- THEN `spdd-agent` falls back to the flat top-level `models` shape — it never guesses `claude` on uncertain evidence, since guessing wrong on a write would corrupt the file for whichever host is actually running

**Scenario: config already complete for the applicable section (fast path)**
- WHEN `~/.config/spdd/config.json` exists and the section that applies to the detected host (`claude.models` under Claude Code, flat top-level `models` otherwise) has all six keys (`canvas`, `design`, `implement`, `verify`, `sync`, `migrate`) present as non-empty strings
- THEN Step 1 reads those six values directly from the config file and proceeds to Step 2 without reading `spdd-agent/assets/model-bootstrap.md` at all — no `AskUserQuestion` call for model selection occurs

**Scenario: config file doesn't exist yet (first-run bootstrap)**
- WHEN `~/.config/spdd/config.json` doesn't exist
- THEN Step 1 reads `spdd-agent/assets/model-bootstrap.md` and follows its first-run bootstrap flow (default-tier table, `AskUserQuestion` grouped into 1–2 calls, writing the flat or `claude`-namespaced shape per host detection)

**Scenario: one or more of the six keys is missing or empty (repair case)**
- WHEN the applicable section exists but at least one of the six keys is missing, empty, or not a string
- THEN Step 1 reads `spdd-agent/assets/model-bootstrap.md` and follows its repair flow, re-asking via `AskUserQuestion` only for the affected phase(s), leaving the other values untouched

**Scenario: migration case still forces the asset open even if the flat section is complete**
- WHEN Claude Code is detected, a flat top-level `models` key is present with all six values non-empty, and no `claude` namespace exists yet
- THEN Step 1 does not take the fast path (completeness alone is not enough — the section that actually applies under Claude Code is `claude.models`, which is absent); it reads `spdd-agent/assets/model-bootstrap.md` and follows the migration flow

**Scenario: config file matches neither valid shape**
- WHEN the JSON parses but matches neither the flat nor the `claude`-namespaced schema for the six phase values
- THEN Step 1 cannot confirm completeness from the lightweight check alone, so it reads `spdd-agent/assets/model-bootstrap.md` and follows the same repair path documented there — re-asking only for what's unresolvable via `AskUserQuestion`, without overwriting unrelated valid top-level keys

**Scenario: config file is not valid JSON at all (parse failure)**
- WHEN `~/.config/spdd/config.json` exists but fails to parse as JSON, or is a zero-byte file
- THEN Step 1 treats this the same as the malformed-shape case (opens `spdd-agent/assets/model-bootstrap.md`, follows its repair flow) rather than silently overwriting the file or treating it as "file doesn't exist" — asks for all six values since nothing can be trusted from an unparseable file, and warns the user the existing file couldn't be parsed before writing over it

**Scenario: explicit config request, read-only, config already complete**
- WHEN the user asks to view (not change) the current per-phase models and the applicable section is already complete
- THEN Step 1's completeness check treats this as complete, takes the fast path, and reports the six values directly — `spdd-agent/assets/model-bootstrap.md` is not opened for a pure read of an already-complete config

**Scenario: explicit config request, user wants to change a value**
- WHEN the user asks to change one or more phase values (regardless of whether the config was already complete)
- THEN Step 1's completeness check always classifies an explicit change request as "not complete" — even when the applicable section is already fully valid — so it reads `spdd-agent/assets/model-bootstrap.md` for the `AskUserQuestion` mechanics (host-capability-based options) needed to ask only for the phases being changed, then writes back to the applicable section. There is no separate "explicit config request" step in `SKILL.md` — this routes through the same completeness-check/fast-path/asset-read branching as every other case, and the asset owns the only description of the `AskUserQuestion` mechanics involved.

**Scenario: dependent plans launch on Implemented, not Verified**
- WHEN `spdd-agent` orders plans by their `Depends on:` field and plan B depends on plan A
- THEN B's implement phase launches once A has reached `Status: Implemented` (matching `spdd-implement` Step 3's dependency check) — never waiting for A to be `Status: Verified`, which would deadlock against Step 8's "once every plan is Implemented" precondition; verification still runs per plan and the fold/archive waits for every plan `Verified`

**Scenario: zero-Confirm canvas still reaches Confirmed**
- WHEN the Step 5 checkpoint gate finds zero `⚠️ Confirm:` lines in a saved canvas
- THEN the orchestrator sets `**Status:** Confirmed` on the canvas and proceeds straight to the design phase — a canvas never lingers as `Draft` after its checkpoint

**Scenario: delegated canvas skips the applicability guard**
- WHEN `spdd-agent` delegates the canvas phase after deciding the complete route
- THEN the subagent prompt states that routing was already decided, so `spdd-canvas` Step 2 (applicability guard) is skipped — the user is never re-asked for the canvas they already requested via the orchestrator

**Scenario: model-bootstrap opens lean (v1.13 trim)**
- WHEN `spdd-agent/assets/model-bootstrap.md` is read
- THEN it opens with a ≤2-sentence scope note, states flat-key immutability once (migration section), and keeps both JSON shape examples and every `AskUserQuestion` mechanic intact

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| "Routing" section (Step 0) | `spdd-agent/SKILL.md` | Evaluates direct vs. complete route before any other step |
| Model config | `~/.config/spdd/config.json` | Conditional bootstrap: only triggers if the chosen route is "complete". Since the claude-code-config-namespace feature: flat `{"models": {...}}` by default, or nested `{"claude": {"models": {...}}}` when the host is detected as Claude Code — never both merged |
| "Load or bootstrap the model configuration" (Step 1) | `spdd-agent/SKILL.md` | Detects the host first, then runs a lightweight completeness check against the applicable section (flat top-level `models` or `claude`-namespaced `claude.models`); reads `spdd-agent/assets/model-bootstrap.md` only when that section isn't already complete or a value change was explicitly requested |
| Model-bootstrap asset | `spdd-agent/assets/model-bootstrap.md` | Holds the first-run bootstrap, repair, migration, malformed/unparseable-config, and explicit-value-change flows plus both JSON shape examples — read conditionally, not always loaded. Sole owner of every `AskUserQuestion` mechanic and config write for these cases; `SKILL.md` only routes to it, never restates its content |
| Config bootstrap/repair/lazy-load evals | `spdd-agent/evals/evals.json` (evals 31–38, 48, 67–68) | Covers bootstrap, repair, migration, dual-key precedence, malformed-shape recovery, the fast path (67), and parse failure (68), for both the flat and `claude`-namespaced config shapes |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Classify change scope" (Step 0, routing decision) | Decides direct vs. complete route based on number of files and presence of business/architectural ambiguity, before invoking any phase |
| Route | Direct route | Implements without a canvas or plan, runs the test suite for the affected area, annotates a summary in `spdd/specs/<domain>.md` only if tests pass |
| Route | Complete route | canvas → design → implement → verify, unchanged from the pre-existing flow |
| Output | Transparency line | `Direct route: <reason> → implementing without a canvas.` — shown whenever the direct route is chosen, before executing any change |
| Step | "Detect Claude Code host" | Sub-step at the start of Step 1, before the completeness check — a `Bash` check of the `CLAUDECODE` env var determines Claude-Code vs. other/inconclusive |
| Step | "Completeness check" (Step 1) | Reads `~/.config/spdd/config.json` (if present), inspects only the applicable section, and classifies the run as fast-path / first-run bootstrap / repair / migration / malformed-or-unparseable / explicit-change-requested — an explicit request to change a value always classifies as "not complete", even if the section was already valid |
| Step | "Fast path" (Step 1) | On classification "complete" (and no explicit change requested): reads the six values directly. For the feature flow, proceeds to Step 2; for a read-only explicit config request, reports the values and stops. `spdd-agent/assets/model-bootstrap.md` is never opened, no `AskUserQuestion` call is made |
| Step | "Open model-bootstrap.md" (Step 1) | On any other classification (including an explicit change request): reads `spdd-agent/assets/model-bootstrap.md` and follows the flow documented there for that specific case — it is the sole owner of every `AskUserQuestion` mechanic and config write for these cases, `SKILL.md` never restates them. Once it finishes: proceeds to Step 2 for the feature flow, or reports the resulting config and stops for an explicit config request |
| Step | "Load or bootstrap the model configuration" (Step 1.1, bootstrap) | Writes to the `claude` namespace when Claude Code is detected, the flat top-level `models` key otherwise; the `AskUserQuestion` mechanics and default-tier table live only in `spdd-agent/assets/model-bootstrap.md`, read only when the completeness check finds the file missing |
| Step | "Load or bootstrap the model configuration" (Step 1.2, existing file) | Reads from the `claude` namespace when detected and present; triggers the migration path (gated behind a real foreground `AskUserQuestion`) when detected but only the flat key is present — repair/migration mechanics live only in `spdd-agent/assets/model-bootstrap.md`, read only when the completeness check finds the applicable section incomplete |
| Config write | `claude` namespace bootstrap | `{"claude": {"models": {"canvas": ..., "design": ..., "implement": ..., "verify": ..., "sync": ..., "migrate": ...}}}` |
| Config write | Legacy flat fallback | `{"models": {"canvas": ..., ...}}` — unchanged, used whenever Claude Code is not detected |
| Asset | `spdd-agent/assets/model-bootstrap.md` — First-run bootstrap section | Default-tier table, tier rationale, `AskUserQuestion` mechanics grouped into 1–2 calls, writes flat or `claude`-namespaced shape per host detection |
| Asset | `spdd-agent/assets/model-bootstrap.md` — Repair section | Re-asks only for missing/empty/malformed phase values via `AskUserQuestion`, writes back to the applicable section only |
| Asset | `spdd-agent/assets/model-bootstrap.md` — Migration section | Proposes copying the flat `models` six values into a new `claude.models` namespace via a real foreground `AskUserQuestion`; writes only once confirmed; never touches the original flat key |
| Asset | `spdd-agent/assets/model-bootstrap.md` — JSON shape examples | Both the flat `{"models": {...}}` and `claude`-namespaced `{"claude": {"models": {...}}}` examples |
| Step | "Phase invocation contract" (Step 3) | Each subagent prompt carries: the skill call + the exact context listed for that phase in Steps 4–8 (canvas delegation adds: routing already decided, applicability guard skipped), the never-block rule verbatim, and report-back per the phase skill's own Report step |
| Step | "Checkpoint gate: canvas" (Step 5) | Resolves every `⚠️ Confirm:` line in the foreground (up to 4 per call); with zero Confirm lines it sets `**Status:** Confirmed` and skips straight to the design phase |
| Step | "Implement phase, per plan" (Step 7) | Topological order by `Depends on:` — a plan never launches before every plan it depends on has reached `Status: Implemented` (matching `spdd-implement` Step 3's dependency check); context is that one plan only |

---

## Norms

- When in doubt between direct and complete route, ALWAYS choose the complete route.
- Do not add automatic verification that the chosen route was "the correct one".
- Increment `metadata.version` in `spdd-agent/SKILL.md` on any edit to its instructions (currently at 1.13, cumulative across changes).
- The never-block rule quoted verbatim in Step 3 is an exact string — edits elsewhere in the file (including meta-section compression) must never alter it (verified byte-identical after the v1.12 compression).
- Mirror any Structure/Conventions/Gotchas edit into both `CLAUDE.md` and `AGENTS.md`.
