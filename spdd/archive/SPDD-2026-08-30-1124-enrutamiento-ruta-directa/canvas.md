# REASONS: Enrutamiento ruta directa vs. flujo completo en spdd-agent

> Generado el 2026-08-30. Revisar las líneas marcadas ⚠️ antes de generar código.
> Regla de oro: si algo falla durante el desarrollo, corregir primero este canvas, luego el código.

**Status:** Confirmed

---

## Requirements

**User story:**
Como usuario de `spdd-agent`, quiero que cambios triviales (1-2 archivos, sin ambigüedad) se implementen directamente, sin pasar por canvas → design → verify, para reducir la fricción del flujo completo sin perder el control objetivo sobre cambios que sí lo necesitan.

**Acceptance criteria:**

- **[NEW]** Scenario: ruta directa se activa y se anuncia
  - WHEN el usuario describe un cambio que toca 1-2 archivos, es mecánico o de alcance evidente, y no hay ambigüedad de negocio ni de arquitectura
  - THEN `spdd-agent` muestra la línea `Ruta directa: <motivo> → implemento sin canvas.` antes de ejecutar, implementa el cambio directamente sin generar canvas ni plan, y no invoca `spdd-canvas`/`spdd-design`/`spdd-verify`

- **[NEW]** Scenario: ruta completa por defecto ante duda
  - WHEN el cambio toca 3+ archivos, requiere entender varias partes del sistema, hay cualquier ambigüedad de negocio/arquitectura, o el agente no está seguro de cuál ruta aplica
  - THEN `spdd-agent` sigue el flujo completo canvas → design → implement → verify tal como existe hoy, sin excepción — la duda siempre resuelve a favor de la ruta completa

- **[NEW]** Scenario: el bootstrap de modelos no bloquea la ruta directa
  - WHEN la decisión de enrutamiento resulta en ruta directa
  - THEN `spdd-agent` NO dispara el bootstrap de `~/.config/spdd/config.json` (Step 1 actual) antes de implementar, porque la ruta directa no lanza subagentes ni necesita esa configuración
  - ✅ Confirmado: el nuevo chequeo de routing se evalúa **antes** del Step 1 actual de bootstrap de modelos; el bootstrap solo se dispara si la decisión final es ruta completa.

- **[NEW]** Scenario: ruta directa exige tests en verde antes de tocar la spec
  - WHEN `spdd-agent` implementa por ruta directa
  - THEN corre el test suite del área afectada antes de anotar el resumen en `spdd/specs/<domain>.md`; si algún test falla, no anota nada en la spec y reporta el fallo concreto al usuario
  - ✅ Confirmado: correr tests es obligatorio en ruta directa, no opcional — sin este paso sería la única vía de escritura a la spec sin ningún control objetivo, lo que contradice el objetivo #2 de `docs/open-spdd-mejoras.md` ("reducir bugs").

- **[NEW]** Scenario: cobertura de evals de la nueva regla
  - WHEN se da esta mejora por completada
  - THEN existen en `spdd-agent/evals/evals.json` al menos 3 casos nuevos: ruta directa activada, ruta completa activada, y el caso límite de 2 vs. 3 archivos
  - ✅ Confirmado: añadir estos casos antes de cerrar el cambio (no estaba en el detalle original de `docs/open-spdd-mejoras.md`, se incorpora aquí porque este repo trata los evals como parte integral de cada skill).

**Out of scope:**
- Mejora 2 (diff vs. canvas en `spdd-verify`), Mejora 3 (detección de spec desatualizada), Mejora 4 (`spdd/norms.md`) y Mejora 5 (formato general de transparencia `[decisión automática]`) — se implementan en canvases separados, en el orden ya fijado en `docs/open-spdd-mejoras.md`.
- No se añade verificación automática de que la ruta elegida fue "la correcta" — es deliberadamente heurística y falible; el control de calidad real vive en la Mejora 2 (fuera de alcance aquí).

---

## Entities

No hay entidades de datos nuevas — es un cambio de lógica de orquestación dentro de un `SKILL.md`, no código de aplicación.

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| Sección "Routing" | `spdd-agent/SKILL.md` | New | Nueva sección al inicio del flujo, antes del Step 1 actual |
| Config de modelos (`~/.config/spdd/config.json`) | `~/.config/spdd/config.json` | Existing | Su bootstrap pasa a ser condicional: solo se dispara si la ruta es "completa" |

**Main fields:** no aplica — no hay entidad de datos nueva con campos propios; la decisión de ruta se evalúa en cada invocación y no se persiste.

---

## Approach

- [x] Service/internal logic only (no presentation layer)

**Rationale:**
Es lógica de orquestación dentro de una skill markdown (no hay capa de presentación ni persistencia propia). El patrón más cercano de la lista es "lógica interna sin presentación": una regla de decisión evaluada en cada invocación del agente.

---

## Structure

Files to create or modify, with real project paths:

```
spdd-agent/SKILL.md          (nueva sección "Routing"; reordena el Step 1 actual detrás de ella)
spdd-agent/evals/evals.json  (nuevos casos: ruta directa, ruta completa, caso límite 2 vs 3 archivos)
```

---

## Operations

*(Adaptado: no hay endpoints/HTTP — son pasos del flujo de orquestación de `spdd-agent`.)*

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Classify change scope" (nuevo Step, antes del Step 1 actual) | Decide ruta directa vs. completa según nº de archivos y presencia de ambigüedad de negocio/arquitectura |
| Route | Ruta directa | Implementa sin canvas ni plan, corre el test suite del área afectada, anota resumen en `spdd/specs/<domain>.md` |
| Route | Ruta completa | Comportamiento actual sin cambios: canvas → design → implement → verify |
| Output | Línea de transparencia | `Ruta directa: <motivo> → implemento sin canvas.` — se muestra siempre que se elige ruta directa, antes de ejecutar cualquier cambio |

---

## Norms

Mandatory project conventions for this feature:

- [ ] Simplicity First: el cambio en `spdd-agent/SKILL.md` debe quedar lo más simple posible, impacto mínimo sobre las secciones existentes (CLAUDE.md global)
- [ ] Ante la duda entre ruta directa y completa, elegir SIEMPRE la ruta completa (regla de seguridad explícita en `docs/open-spdd-mejoras.md`, Mejora 1)
- [ ] No añadir verificación automática de que la ruta fue "la correcta" (documento "Qué NO hacer", `docs/open-spdd-mejoras.md`)
- [ ] Incrementar `metadata.version` de `spdd-agent/SKILL.md` al guardar los cambios (convención del proyecto para cualquier edición de instrucciones de una skill)

---

## Safeguards

**Tests to write:**
- [ ] Ruta directa se activa correctamente en un cambio de 1-2 archivos sin ambigüedad
- [ ] Ruta completa se activa correctamente en un cambio de 3+ archivos
- [ ] Caso límite: 2 archivos pero módulo compartido → ruta completa

**Edge cases to consider (as WHEN/THEN scenarios — `spdd-verify` writes a targeted test for each one not already covered):**

- Scenario: caso límite exactamente en el borde (2 vs. 3 archivos, pero módulo compartido)
  - WHEN el cambio descrito toca exactamente 2 archivos pero afecta a un módulo compartido por varias features
  - THEN `spdd-agent` lo trata como ambigüedad de arquitectura y elige ruta completa — el conteo de archivos por sí solo no basta

- Scenario: ambigüedad de negocio en cambio de 1 archivo
  - WHEN el cambio toca un único archivo pero introduce una regla de negocio nueva o no evidente
  - THEN `spdd-agent` elige ruta completa

- Scenario: fallo de tests en ruta directa
  - WHEN el test suite del área afectada falla tras implementar en ruta directa
  - THEN `spdd-agent` no anota nada en `spdd/specs/<domain>.md`, reporta el fallo concreto al usuario, y no revierte el código automáticamente — deja la decisión de revertir o corregir al humano
  - ✅ Confirmado: no se revierte automáticamente el código en caso de fallo — se muestra el fallo y se deja la decisión al humano, consistente con el resto del flujo (nunca fuerza una divergencia cerrada en silencio).

- Scenario: ruta directa sin dominio inferible
  - WHEN el cambio no permite inferir un dominio claro (no sigue convención de carpetas tipo `src/<domain>/`)
  - THEN usa `spdd/specs/general.md` como fallback, igual que ya hace `spdd-canvas` Step 6

- Scenario: primera vez sin config de modelos y ruta completa elegida
  - WHEN la decisión de enrutamiento es "ruta completa" y `~/.config/spdd/config.json` no existe todavía
  - THEN se dispara el bootstrap del Step 1 normalmente, sin cambios respecto al comportamiento actual

**Production rollback:**
No aplica código de producción de un proyecto destino — el cambio es a un `SKILL.md` de este propio repo. Revertir = `git revert` del commit que modifica `spdd-agent/SKILL.md` y `spdd-agent/evals/evals.json`.
