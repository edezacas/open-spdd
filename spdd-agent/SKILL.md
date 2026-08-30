---
name: spdd-agent
description: Builds a new feature end-to-end from a single plain-language description — runs canvas → design → implement → verify automatically, pausing only on required confirmations. Use when the user describes a new feature, or asks to build/add/implement something, without naming a specific /spdd-* command. Also handles requests to view or change the per-phase model configuration.
license: Apache-2.0
compatibility: Works with any agent. Per-phase model selection and subagent isolation require a host that can launch subagents with a model override (e.g. Claude Code's `Agent` tool, or opencode's Task tool with an `agent`/`model` field).
allowed-tools: Read Write Edit Bash AskUserQuestion Agent
metadata:
  author: edezacas
  version: "1.4"
---

## Instructions

### A note on "AskUserQuestion" throughout this skill

Every foreground step below (0, 1, 2, 5, 6, 8) that says "ask via `AskUserQuestion`" means: use
the host's structured, blocking question mechanism if it has one (in Claude Code, the
`AskUserQuestion` tool). If the host has no such mechanism, ask the same question in plain text in
your response and wait for the user's reply before continuing — same capability-not-identity
treatment already applied to model selection (Step 1) and subagent detection (Step 2). This does
not affect the never-block rule for background subagents (Step 3), which correctly assumes no
question mechanism of any kind is available there.

### Step 0 — Classify the request

Two kinds of input reach this skill:

- **A feature description** ("hay que implementar X", "add support for Y") → go to Step 1.
- **A request about the model configuration itself** ("usa spdd-agent para ver/cambiar el modelo de cada fase", "qué modelo usa implement", "cambia verify a sonnet") → go to Step 2's "Explicit config request" path and stop there; do not start the feature flow.

### Step 1 — Load or bootstrap the model configuration

Config lives at `~/.config/spdd/config.json` — the XDG user-config convention, global and shared across projects, not versioned in any repo, and not tied to any single host (Claude Code, opencode, codex, or any other agent reads and writes the same file).

```json
{
  "models": {
    "canvas": "opus", "design": "opus", "implement": "sonnet",
    "verify": "opus", "sync": "sonnet", "migrate": "sonnet"
  }
}
```
(shown with Claude Code aliases as a concrete example — any host's own model identifiers are equally valid here, see below)

Only `canvas`, `design`, `implement`, and `verify` are ever used by this skill's own flow (Steps 4–8) — `sync` and `migrate` keep their independent auto-trigger and run standalone, outside this orchestrator. Their entries exist in the same file only so the config surface (Step 2) is uniform across all six phases.

Each value is a free-text model identifier in whatever form the current host's subagent mechanism accepts — not a fixed enum. On Claude Code that's `opus` / `sonnet` / `haiku` / `fable`; on a host like opencode it's a provider-qualified id (e.g. `anthropic/claude-sonnet-4-5`, `openai/gpt-5`) or whatever string that host's model-override field expects. This skill never validates the string against a host-specific list — it only checks that a value is present and non-empty, and passes it through verbatim to the subagent call in Step 3.

1. If the file doesn't exist: this is first-run bootstrap. Before touching the user's feature request, propose a default model per phase (table below) via `AskUserQuestion`, grouped into 1–2 calls of up to 4 questions each. The choice of options depends on the host's capability, not its identity: if the host's model-override field accepts a small fixed set of named aliases (e.g. Claude Code's `opus`/`sonnet`/`haiku`/`fable`), offer that set as options with the table's suggested tier pre-marked "(Recommended)". If the host instead takes an arbitrary model-identifier string, offer the table's suggested tier as the recommended free-text default and let the user type the exact identifier they want via `AskUserQuestion`'s "Other". Write the confirmed selections to `~/.config/spdd/config.json` (create `~/.config/spdd/` if needed).
2. If the file exists: read it and check each of the six values is a non-empty string. Treat a missing or empty value as absent and re-ask only for that phase (same `AskUserQuestion` mechanism), then write the corrected file back.

| Phase | Suggested tier | Fixed-alias example (Claude Code) | Why |
|---|---|---|---|
| `canvas` | high-reasoning | `opus` | Ambiguity/risk detection and REASONS drafting is the highest reasoning-density phase. |
| `design` | high-reasoning | `opus` | Deciding one plan vs. several and mapping dependencies is an architectural call. |
| `implement` | fast/cheap | `sonnet` | Executes a plan already validated by a human; favors speed/cost. |
| `verify` | high-reasoning | `opus` | Finding edge cases and checking against Norms/Safeguards benefits from strong reasoning. |
| `sync` | fast/cheap | `sonnet` | Mechanical spec↔code sync after a refactor. |
| `migrate` | fast/cheap | `sonnet` | Mostly mechanical layout migration. |

The last column is one worked example, not the framework's default — any host with its own fixed alias set (present or future) maps `Suggested tier` to that set the same way.

**Explicit config request** (from Step 0): read the current file (bootstrap first if missing, per above), show the six current values, and if the user asked to change one or more, ask only for those via `AskUserQuestion` with the same host-capability-based options (fixed alias set vs. free text) as bootstrap, then write the file back. Report the resulting config and stop — do not proceed to Step 3.

### Step 2 — Detect subagent support

Check whether the current host exposes a mechanism to launch an isolated subagent with a model override — in Claude Code, the `Agent` tool (`subagent_type` + `model`); in opencode, the Task tool with an `agent`/`model` field; other hosts may name this differently but the shape is the same: spawn an isolated worker, pick its model, give it a prompt. If such a mechanism exists, use **Isolated mode** (Step 3). If it doesn't, use **Inline mode** (Step 3-alt).

### Step 3 — Isolated mode: phase invocation contract

For each phase, build one subagent call: generic `subagent_type` the host provides for ad-hoc work (in Claude Code, `general-purpose`), `model` from the config loaded in Step 1, and a self-contained `prompt`. The `prompt` always includes, in this order:

1. **The skill call**, naming the phase skill (`spdd-canvas`, `spdd-design`, `spdd-implement`, or `spdd-verify`) and the exact context it needs (table in Step 4) — nothing more, nothing from this conversation's history.
2. **The never-block rule**, verbatim:

   > You do not have `AskUserQuestion` — you're running in the background, with no live user turn. Never stay blocked waiting for an answer that cannot arrive. If a step asks you to confirm a **content decision**, take the suggested default, continue, and add a `⚠️ Confirm:` line so it gets resolved later. If it asks you to confirm an **action with a side effect** (writing config, installing hooks, anything outside the artifact you're generating), do not execute it or assume a default in its favor — skip it, leave it noted as a pending `⚠️ Confirm:`, and don't touch the filesystem for that step.

3. **What to report back on completion**: the file path saved (or updated), a short summary, and every pending `⚠️ Confirm:` line.

Each subagent call is asynchronous: this skill's turn ends when it's issued, and resumes on the completion notification. Do not simulate or predict a subagent's result — wait for the real one.

### Step 3-alt — Inline mode

If Step 2 found no subagent mechanism: invoke `Skill(<phase>)` directly in the current context, with the same context scoping as the table in Step 4. This runs synchronously in the foreground, so `AskUserQuestion` is available for real — the never-block rule doesn't apply, and any `⚠️ Confirm:` the phase raises can be resolved immediately instead of deferred. Orchestration and checkpoints (Steps 4–8) stay the same either way; only isolation and per-phase model are lost.

### Step 4 — Canvas phase

Launch (or run inline) the `canvas` phase. Context: the user's feature description, verbatim — it isn't in any file yet.

### Step 5 — Checkpoint gate: canvas

Once the canvas is saved, if it contains any `⚠️ Confirm:` lines, do not advance. Resolve **every one** with a real `AskUserQuestion` call in the foreground — split across as many calls of up to 4 questions as needed, never skipped for volume. Present the phase's default as the recommended option, never as an assumed answer. Update `canvas.md` with the confirmed values and set `**Status:** Confirmed`.

If the canvas has zero `⚠️ Confirm:` lines, skip straight to Step 6.

### Step 6 — Design phase

Launch (or run inline) the `design` phase. Context: the path to the now-confirmed `canvas.md`. Apply the same checkpoint gate as Step 5 to every `⚠️ Confirm:` line across the resulting plan(s) before advancing.

### Step 7 — Implement phase, per plan

Order the plans by their `Depends on:` field (topological order — a plan never launches before every plan it depends on has finished Step 8). For each plan in that order, launch (or run inline) the `implement` phase. Context: the path to that one plan only — not the other plans, not the canvas beyond what `spdd-implement` itself reads.

### Step 8 — Verify phase

Once every plan for the change is `Status: Implemented`, launch (or run inline) the `verify` phase per plan (or once, if the change was never split). Context: the path to the plan (or canvas) being verified.

If a verify run reports a non-trivial divergence (not a cosmetic gap), reopen the relevant checkpoint: bring the finding to the user in the foreground via `AskUserQuestion`, and if it requires touching the plan or canvas, loop back to the appropriate step (5, 6, or 7) instead of forcing the divergence closed silently.

### Step 9 — Final report

Report, in one summary: the canvas path, the plan(s) produced and their dependency order, what was implemented, what got folded into `spdd/specs/` and archived, and — for each checkpoint — what was asked and what the user decided.
