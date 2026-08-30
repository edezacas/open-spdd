# Plan: spdd-design — plan-*.md ya en inglés y nota defensiva propia

> Parte del canvas en [../canvas.md](../canvas.md) — Requirements, Norms y Safeguards viven ahí y también aplican a este plan; no se duplican aquí. `spdd-implement` y `spdd-verify` siempre leen ambos archivos juntos.
> Language: traducir todos los encabezados de sección, etiquetas y contenido del cuerpo al idioma detectado del usuario.

**Status:** Verified
> Implemented: 2026-08-30
**Depends on:** none
**Shared touchpoints:** none

---

## Operations

Subconjunto de las Operations del canvas que pertenecen a este plan (copiado verbatim de la tabla Operations de `canvas.md`):

| Type | Identifier | Description |
|------|-----------|-------------|
| Template note | `> Language: ...` en `template-reasons.md` y `template-plan.md` | Declara explícitamente que el documento se escribe en inglés, sin instrucción de traducción |
| Note | Nota defensiva de idioma en `spdd-design`, `spdd-verify`, `spdd-sync` | Recuerda, en el punto donde cada skill redacta prosa nueva propia (no copiada del canvas/plan de origen), que esa prosa también debe quedar en inglés |

*(Nota: la fila "Template note" del canvas cubre dos archivos; este plan solo implementa la parte de `spdd-design/assets/template-plan.md` — la parte de `spdd-canvas/assets/template-reasons.md` vive en `plan-01-spdd-canvas.md`. La fila "Note" del canvas cubre tres skills; este plan solo implementa la parte de `spdd-design/SKILL.md` — la parte de `spdd-verify`/`spdd-sync` vive en `plan-04-defensive-notes-verify-sync.md`.)*

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Nota `> Language: ...` — `spdd-design/assets/template-plan.md` (línea 4)
- Nota defensiva de idioma (nueva) — `spdd-design/SKILL.md` — antes del Step actual "Generate the plan(s)"

**Structure — files to create or modify:**

```
spdd-design/assets/template-plan.md   (línea 4, nota "> Language: ...")
spdd-design/SKILL.md                  (nueva nota defensiva de idioma antes de Step 7 "Generate the plan(s)"; incrementar metadata.version)
```

---

## Verification notes

**Resolved:** During `spdd-verify` Step 4, an eval case was added to `spdd-design/evals/evals.json` to cover the canvas Safeguards scenario "mezcla de idiomas dentro de un mismo documento" (not in this plan's originally declared Structure, but exempted from the Diff-to-canvas scope check as a verification byproduct per `spdd-verify` Step 7). It was assigned id 56 by this plan's own verification pass, which collided with id 56 independently assigned by the sibling `plan-04-defensive-notes-verify-sync.md` verification (parallel background runs, each computing "current max + 1" without seeing the other's write) — renumbered to **id 58** by the orchestrator (`spdd-agent`) after the collision was found (repo-wide max after this change: `spdd-sync` id 57). Graded by structural inspection, not a live agent run — accepted, consistent with the same grading approach used for evals 52-57 in the rest of this change.
