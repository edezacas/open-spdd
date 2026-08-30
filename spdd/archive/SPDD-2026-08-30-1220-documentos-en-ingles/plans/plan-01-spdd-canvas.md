# Plan: spdd-canvas — forzar inglés en el contenido generado

> Parte del canvas en [../canvas.md](../canvas.md) — Requirements, Norms y Safeguards viven ahí y también aplican a este plan; no se duplican aquí. `spdd-implement` y `spdd-verify` siempre leen ambos archivos juntos.
> Language: traducir todos los encabezados de sección, etiquetas y contenido del cuerpo al idioma detectado del usuario.

**Status:** Verified
> Implemented: 2026-08-30
> Verified: 2026-08-30
**Depends on:** none
**Shared touchpoints:** none

**Confirmado:** la mención en `CLAUDE.md` / `AGENTS.md` (Gotchas: "los documentos SPDD se generan siempre en inglés") vive en este plan, por ser el que introduce el cambio de comportamiento principal (`spdd-canvas` Step 3).

**Confirmado — orden de implementación:** este plan (`plan-01`) se implementa antes que `plan-02-spdd-implement.md`. Los nuevos casos de eval en `spdd-canvas/evals/evals.json` usan como ID inicial el máximo actual entre todos los `evals/evals.json` del repo + 1 (52 en el momento de este canvas), calculado en el momento de implementar — no un número fijo. `plan-02` implementa después y recalcula el máximo (que ya incluirá los IDs añadidos aquí), evitando duplicados sin necesidad de rangos reservados de antemano.

---

## Operations

Subconjunto de las Operations del canvas que pertenecen a este plan (copiado verbatim de la tabla Operations de `canvas.md`):

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Output language" (reemplaza "Detect output language") en `spdd-canvas/SKILL.md` y `spdd-implement/SKILL.md` | Ya no detecta ni pregunta el idioma del usuario; fija directamente "English" como idioma de todo el contenido de documento generado en ese paso |
| Template note | `> Language: ...` en `template-reasons.md` y `template-plan.md` | Declara explícitamente que el documento se escribe en inglés, sin instrucción de traducción |

*(Nota: la fila de Operations del canvas agrupa `spdd-canvas` y `spdd-implement` en la misma fila porque ambos comparten el mismo tipo de cambio; este plan solo implementa la parte de `spdd-canvas/SKILL.md` y `spdd-canvas/assets/template-reasons.md` — la parte de `spdd-implement/SKILL.md` vive en `plan-02-spdd-implement.md`.)*

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Step "Detect output language" — `spdd-canvas/SKILL.md` (Step 3) — pasa de "usar idioma detectado" a "siempre inglés"; posible rename a "Output language"
- Nota `> Language: ...` — `spdd-canvas/assets/template-reasons.md` (línea 5)

**Structure — files to create or modify:**

```
spdd-canvas/SKILL.md                   (Step 3 "Detect output language" → contenido forzado a inglés; incrementar metadata.version)
spdd-canvas/assets/template-reasons.md (línea 5, nota "> Language: ...")
spdd-canvas/evals/evals.json           (nuevo(s) caso(s): documento en inglés con prompt de entrada en español; ID inicial = máximo actual en el repo + 1)
CLAUDE.md                              (mención breve en Gotchas — ver ⚠️ Confirm arriba)
AGENTS.md                              (mismo texto en espejo — convención "AGENTS.md mirrors CLAUDE.md")
```
