# Plan: spdd-implement — forzar inglés en el contenido generado

> Parte del canvas en [../canvas.md](../canvas.md) — Requirements, Norms y Safeguards viven ahí y también aplican a este plan; no se duplican aquí. `spdd-implement` y `spdd-verify` siempre leen ambos archivos juntos.
> Language: traducir todos los encabezados de sección, etiquetas y contenido del cuerpo al idioma detectado del usuario.

**Status:** Verified
> Implemented: 2026-08-30
> Verified: 2026-08-30

**Depends on:** none
**Shared touchpoints:** none

**Confirmado — orden de implementación:** este plan (`plan-02`) se implementa después de `plan-01-spdd-canvas.md`. Los nuevos casos de eval en `spdd-implement/evals/evals.json` usan como ID inicial el máximo actual entre todos los `evals/evals.json` del repo + 1, calculado en el momento de implementar este plan (ya incluirá los IDs añadidos por `plan-01`) — no un número fijo.

---

## Operations

Subconjunto de las Operations del canvas que pertenecen a este plan (copiado verbatim de la tabla Operations de `canvas.md`):

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Output language" (reemplaza "Detect output language") en `spdd-canvas/SKILL.md` y `spdd-implement/SKILL.md` | Ya no detecta ni pregunta el idioma del usuario; fija directamente "English" como idioma de todo el contenido de documento generado en ese paso |

*(Nota: la fila de Operations del canvas agrupa `spdd-canvas` y `spdd-implement` en la misma fila; este plan solo implementa la parte de `spdd-implement/SKILL.md` — la parte de `spdd-canvas` vive en `plan-01-spdd-canvas.md`.)*

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Step "Detect output language" — `spdd-implement/SKILL.md` (Step 0) — mismo cambio de contenido que en `spdd-canvas`

**Structure — files to create or modify:**

```
spdd-implement/SKILL.md               (Step 0 "Detect output language" → contenido forzado a inglés; incrementar metadata.version)
spdd-implement/evals/evals.json       (nuevo(s) caso(s) equivalente(s); ID inicial = máximo actual en el repo + 1)
```
