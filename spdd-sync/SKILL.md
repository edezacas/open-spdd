---
name: spdd-sync
description: Sync a domain's living spec (spdd/specs/<domain>.md) to match code that was refactored outside the SPDD flow, without changing what it says about observable behavior. Use after a behavior-preserving refactor (rename, extract constant, restructure files) on code that already has a spec, when the spec no longer matches the code's current shape.
license: Apache-2.0
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "1.0"
---

## Instructions

### Step 1 — Locate the scope

If a domain or specific files were named, use those. Otherwise, infer the scope from the current working tree (`git status`/`git diff`) — the typical trigger is "I just refactored, sync the spec."

If `spdd/specs/<domain>.md` doesn't exist for the inferred scope, stop: this command is not a substitute for the normal flow. Tell the user to go through `spdd-canvas` first.

### Step 2 — Read the spec and the code

Read `spdd/specs/<domain>.md` in full, then the current code at every path its Structure/Entities/Operations sections mention.

### Step 3 — Compare code against spec

Look for: renamed or moved files, functions/identifiers named in Operations that no longer exist under that name, Entities whose fields changed, new files that aren't listed, files listed that no longer exist.

### Step 4 — Behavior guardrail

If anything found in Step 3 suggests a change in observable behavior — not just shape — do **not** touch the Requirements section. Stop and tell the user explicitly this isn't a sync case: behavior changes need a new canvas via `spdd-canvas`, not a sync. This is the core safeguard of this skill — it must never rewrite behavior silently.

### Step 5 — Update the spec

Update only Entities, Structure, Operations, and Norms in `spdd/specs/<domain>.md` to match the code's current shape. Requirements (the `WHEN/THEN` scenarios) stay untouched — they're the behavior contract, not the implementation shape.

If it's genuinely unclear whether something is a pure refactor or a behavior change, don't guess: mark it with `⚠️ Confirm:` directly in the spec and ask the user.

### Step 6 — Report

Show a diff-style summary: what was updated in the spec, what was left alone, and any `⚠️ Confirm:` lines added.
