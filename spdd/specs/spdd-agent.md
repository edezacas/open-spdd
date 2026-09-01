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

**Scenario: explicit config view/change request resolves against the detected namespace**
- WHEN the user asks to view or change the per-phase model configuration ("qué modelo usa implement", "cambia verify a sonnet") while running under Claude Code
- THEN `spdd-agent` reads and writes the `claude` namespace instead of the flat top-level key, using the same host detection as the rest of this feature

**Scenario: dual-key precedence when both shapes are present**
- WHEN Claude Code is detected and the config file contains both a flat `models` key and a `claude` namespace (partially migrated, or hand-edited)
- THEN Step 1 reads only from the `claude` namespace and leaves the flat key untouched — never merges or deletes it automatically

**Scenario: detection is inconclusive**
- WHEN Step 1's host-detection sub-step cannot confidently determine the host (signal absent, ambiguous, or the detection mechanism itself errors)
- THEN `spdd-agent` falls back to the flat top-level `models` shape — it never guesses `claude` on uncertain evidence, since guessing wrong on a write would corrupt the file for whichever host is actually running

**Scenario: config file matches neither valid shape**
- WHEN the JSON parses but matches neither the flat nor the `claude`-namespaced schema (e.g. hand-edited)
- THEN `spdd-agent` treats it the same as the missing/empty-value repair path — re-asking only for what's unresolvable via `AskUserQuestion`, without overwriting unrelated valid keys

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| "Routing" section (Step 0) | `spdd-agent/SKILL.md` | Evaluates direct vs. complete route before any other step |
| Model config | `~/.config/spdd/config.json` | Conditional bootstrap: only triggers if the chosen route is "complete". Since the claude-code-config-namespace feature: flat `{"models": {...}}` by default, or nested `{"claude": {"models": {...}}}` when the host is detected as Claude Code — never both merged |
| "Load or bootstrap the model configuration" (Step 1) | `spdd-agent/SKILL.md` | Detects the host first, then branches config read/write between the flat top-level `models` key and the `claude`-namespaced `claude.models` key |
| Config bootstrap/repair evals | `spdd-agent/evals/evals.json` (evals 31–38, 48) | Covers bootstrap, repair, migration, dual-key precedence, and malformed-shape recovery for both the flat and `claude`-namespaced config shapes |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Classify change scope" (Step 0, routing decision) | Decides direct vs. complete route based on number of files and presence of business/architectural ambiguity, before invoking any phase |
| Route | Direct route | Implements without a canvas or plan, runs the test suite for the affected area, annotates a summary in `spdd/specs/<domain>.md` only if tests pass |
| Route | Complete route | canvas → design → implement → verify, unchanged from the pre-existing flow |
| Output | Transparency line | `Direct route: <reason> → implementing without a canvas.` — shown whenever the direct route is chosen, before executing any change |
| Step | "Detect Claude Code host" | Sub-step at the start of Step 1, before the existing file-exists check — a `Bash` check of the `CLAUDECODE` env var determines Claude-Code vs. other/inconclusive |
| Step | "Load or bootstrap the model configuration" (Step 1.1, bootstrap) | Writes to the `claude` namespace when Claude Code is detected, the flat top-level `models` key otherwise |
| Step | "Load or bootstrap the model configuration" (Step 1.2, existing file) | Reads from the `claude` namespace when detected and present; triggers the migration path (gated behind a real foreground `AskUserQuestion`) when detected but only the flat key is present |
| Step | "Explicit config request" | Same namespace branch as bootstrap/read, so view/change requests resolve consistently |
| Config write | `claude` namespace bootstrap | `{"claude": {"models": {"canvas": ..., "design": ..., "implement": ..., "verify": ..., "sync": ..., "migrate": ...}}}` |
| Config write | Legacy flat fallback | `{"models": {"canvas": ..., ...}}` — unchanged, used whenever Claude Code is not detected |

---

## Norms

- When in doubt between direct and complete route, ALWAYS choose the complete route.
- Do not add automatic verification that the chosen route was "the correct one".
- Increment `metadata.version` in `spdd-agent/SKILL.md` on any edit to its instructions.
- Mirror any Structure/Conventions/Gotchas edit into both `CLAUDE.md` and `AGENTS.md`.
