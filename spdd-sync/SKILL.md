---
name: spdd-sync
description: Sync a domain's living spec (spdd/specs/<domain>.md) to a behavior-preserving refactor made outside the SPDD flow, without changing what it says about observable behavior. Auto-triggers after a refactor (rename, extract constant, restructure files) when the spec no longer matches the code's shape.
license: Apache-2.0
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "1.4"
---

## Instructions

### Step 1 — Locate the scope

Use the named domain or files if given. Otherwise infer scope from the working tree (`git status`/`git diff`) — the typical trigger is "I just refactored, sync the spec."

If `spdd/specs/<domain>.md` doesn't exist for that scope, stop — this isn't a substitute for the normal flow. Tell the user to run `spdd-canvas` first.

### Step 2 — Read the spec and the code

Read `spdd/specs/<domain>.md` in full, then the current code at every path its Structure/Entities/Operations sections mention.

### Step 3 — Compare code against spec

Look for:

- Renamed or moved files.
- Functions/identifiers named in Operations that no longer exist under that name.
- Entities whose fields changed.
- New files not listed, or listed files that no longer exist.

### Step 4 — Behavior guardrail

Anything from Step 3 that's a change in observable behavior, not just shape → do not touch Requirements. Stop and tell the user this isn't a sync case: behavior changes need a new canvas via `spdd-canvas`. Never rewrite behavior silently — that's this skill's core safeguard.

### Step 5 — Update the spec

Update only Entities, Structure, Operations, and Norms to match the code's current shape. Requirements (`WHEN/THEN` scenarios) stay untouched — they're the behavior contract, not the implementation shape.

Genuinely unclear whether something is a refactor or a behavior change → don't guess: mark it `⚠️ Confirm:` in the spec and ask.

> **Language note:** Write all new spec text in English, regardless of the conversation's language.

### Step 6 — Report

Show what was updated in the spec, what was left alone, and any `⚠️ Confirm:` lines added.
