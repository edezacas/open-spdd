---
name: spdd-canvas
description: Generate a REASONS canvas for a new feature and save it to docs/prompts/. Use BEFORE writing code. Trigger when the user mentions a new feature, wants to implement something, asks for a canvas, or requests a structured prompt before coding.
license: Apache-2.0
metadata:
  author: edezacas
  version: "1.0"
argument-hint: "<brief feature description>"
allowed-tools: Read Write Edit Bash AskUserQuestion
---

## Today's date

!`date +%Y-%m-%d`

## Instructions

Generate a REASONS canvas for this feature: $ARGUMENTS

Follow these steps in order:

### Step 1 — Guard: require a feature description

If `$ARGUMENTS` is empty or blank, ask the user for a brief feature description before continuing.

### Step 1.5 — Detect output language

Read `~/.claude/CLAUDE.md`. Use the configured response language for all document content. If none is configured, use the language of the user's request.

### Step 2 — Read the base template

Read [template-reasons.md](assets/template-reasons.md).

### Step 3 — Understand the project

If the stack and conventions are not clear from the project context, inspect the project structure before generating the canvas.

### Step 4 — Determine layers

Only ask about layers if the feature description explicitly mentions two separate concerns (e.g. "backend + frontend", "API + CLI"). If so, ask: one canvas per layer or a single unified canvas?

### Step 5 — Generate a filled canvas

Fill the template with real, project-specific content. Use actual file paths, the project's real model layer, and concrete operations — no generic placeholders.

Mark any decision that requires user input with `⚠️ Confirm:` and propose a sensible default.

### Step 6 — Save the file

Save to `docs/prompts/SPDD-YYYY-MM-DD-slug.md` (kebab-case slug, today's date). Create the directory if needed.

### Step 7 — Ensure the SPDD hook is present

Check whether `.claude/settings.local.json` already contains the SPDD guard hook:

```bash
grep -q 'SPDD' .claude/settings.local.json 2>/dev/null && echo "exists" || echo "missing"
```

If **missing**, ask the user whether to add it. If confirmed, merge the following into `hooks.PreToolUse` (create the key if absent) and write back to `.claude/settings.local.json`:

```json
{
  "matcher": "Edit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "unresolved=$(grep -rl '⚠️ Confirm:' docs/prompts/SPDD-*.md 2>/dev/null); if [ -n \"$unresolved\" ]; then echo \"SPDD WARNING: unresolved canvas items in: $unresolved — review before editing code.\"; fi"
    }
  ]
}
```

### Step 8 — Report back

Show the saved file path, a 3-bullet summary, and all `⚠️ Confirm:` lines the user must resolve before implementing.
