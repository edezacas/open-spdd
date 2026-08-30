# REASONS: Forzar inglés en todos los documentos generados por las skills SPDD

> Generado el 2026-08-30. Revisar las líneas marcadas ⚠️ antes de generar código.
> Regla de oro: si algo falla durante el desarrollo, corregir primero este canvas, luego el código.

**Status:** Confirmed

---

## Nota sobre el dominio de este canvas

Este cambio es transversal: toca instrucciones de `spdd-canvas` y `spdd-implement`
directamente (los 2 únicos sitios con un paso explícito "Detect output language"), sus
templates (`spdd-canvas/assets/template-reasons.md`, `spdd-design/assets/template-plan.md`),
y potencialmente añade una nota defensiva equivalente en `spdd-design`, `spdd-verify` y
`spdd-sync` (que hoy no tienen paso de idioma propio y heredan el idioma del canvas/plan
que leen, pero pueden generar prosa nueva propia — p. ej. notas de discrepancia en
`spdd-verify` Step 7, o anotaciones de fold — que hoy no está garantizado que hereden el
idioma del documento en vez del idioma de la conversación).

No hay una única spec de dominio existente que cubra este cambio: `spdd/specs/spdd-agent.md`
y `spdd/specs/spdd-verify.md` son las únicas specs vivas del repo y ninguna menciona idioma.
Siguiendo la convención ya establecida (cada skill es su propio dominio), este cambio
tocará varios dominios a la vez (`spdd-canvas`, `spdd-implement`, `spdd-design`,
`spdd-verify`, `spdd-sync`). **Confirmado:** `spdd-design` divide el cambio en planes
independientes por skill (spdd-canvas+template, spdd-implement, spdd-design+template, y un
plan opcional de "notas defensivas" para spdd-verify/spdd-sync), ya que no comparten
archivos entre sí y cada skill puede versionarse y testearse por separado.

**Freshness check:** dominio no inferible con confianza a una sola carpeta (cambio
transversal a instrucciones de skills, no a código de una app con `src/<domain>/`). Se
usó `spdd/specs/spdd-agent.md` y `spdd/specs/spdd-verify.md` como referencia de contexto
(ninguna contradice este cambio); no existe `spdd/specs/general.md` en este repo — se deja
constancia aquí en vez de generarlo, según instrucción de `spdd-canvas`.

**`spdd/norms.md`:** no existe en este repo (proyecto raíz de `open-spdd`, no un proyecto
destino de las skills), por lo que no hay normas globales de equipo que traer a este canvas.

---

## Requirements

**User story:**
Como equipo que mantiene `open-spdd`, quiero que todos los documentos que las skills SPDD
generan (canvas, plan, specs vivas, y cualquier nota o anotación que las skills añadan a
esos documentos) se escriban siempre en inglés, en vez de detectar y usar el idioma del
usuario, para reducir el consumo de tokens de razonamiento del agente en tareas
posteriores que leen esos documentos como contexto.

**Acceptance criteria:**

- **[MODIFIED]** Scenario: `spdd-canvas` genera un canvas nuevo
  - WHEN `spdd-canvas` llega al paso de detectar/fijar el idioma de salida (Step 3 actual, "Detect output language")
  - THEN genera todo el contenido del `canvas.md` (encabezados de sección, User story, escenarios WHEN/THEN, Entities, Norms, Safeguards, notas de dominio) en inglés, sin importar el idioma en que el usuario describió la feature. **Confirmado:** reemplaza intencionalmente el comportamiento actual documentado en `spdd-canvas/SKILL.md` Step 3 ("Use the language detected from the user for all document content") — es el objetivo del cambio

- **[MODIFIED]** Scenario: `spdd-implement` implementa un plan
  - WHEN `spdd-implement` llega a su Step 0 actual ("Detect output language")
  - THEN cualquier contenido de documento que genere o actualice durante la implementación (notas de divergencia en canvas/plan, comentarios de código relacionados con la intención de negocio si el stack lo pide en prosa) se escribe en inglés; el código en sí ya se escribe en inglés hoy (convención global de `CLAUDE.md` del usuario, "code in English") y no cambia. **Confirmado:** mismo reemplazo intencional que el escenario anterior, aplicado a `spdd-implement/SKILL.md` Step 0

- **[NEW]** Scenario: los templates ya no piden traducir a un idioma detectado
  - WHEN se genera un `canvas.md` a partir de `template-reasons.md`, o un `plan-*.md` a partir de `template-plan.md`
  - THEN la línea de nota `> Language: ...` de ambos templates deja de decir "translate ... to the language detected from the user" y pasa a decir explícitamente que el documento se escribe en inglés

- **[NEW]** Scenario: `spdd-design` genera un plan a partir de un canvas ya en inglés
  - WHEN `spdd-design` lee un canvas (ya en inglés tras este cambio) y genera uno o varios `plan-*.md`
  - THEN el contenido nuevo que redacta (no solo lo copiado del canvas) se mantiene en inglés — no reintroduce español u otro idioma aunque la conversación con el usuario esté en otro idioma

- **[NEW]** Scenario: `spdd-verify` añade prosa nueva a la spec o a notas de discrepancia
  - WHEN `spdd-verify` folda un cambio a `spdd/specs/<domain>.md` (Step 8 actual) o añade una nota de discrepancia/`⚠️ Confirm:` durante el Diff-to-canvas check (Step 7 actual)
  - THEN esa prosa nueva (no solo lo copiado del canvas/plan de origen) se escribe en inglés, igual que el resto del documento al que se añade

- **[NEW]** Scenario: `spdd-sync` actualiza una spec viva tras un refactor
  - WHEN `spdd-sync` actualiza Entities/Structure/Operations/Norms de `spdd/specs/<domain>.md` tras un refactor fuera del flujo SPDD
  - THEN el texto que redacta o modifica se mantiene en inglés, consistente con el resto de la spec ya en inglés

- **[NEW]** Scenario: respuestas conversacionales al usuario no cambian de idioma
  - WHEN cualquier skill SPDD reporta al usuario en el turno de chat (p. ej. el resumen final de `spdd-canvas` Step 12, o el reporte de `spdd-verify` Step 10) — no un archivo persistido
  - THEN esa respuesta conversacional sigue el idioma que corresponda a la conversación (p. ej. la instrucción global de `CLAUDE.md` del usuario, "Responses in Spanish"); este cambio solo fuerza inglés en el **contenido de los documentos persistidos** (`canvas.md`, `plan-*.md`, `spdd/specs/<domain>.md`), no en el chat

- **[NEW]** Scenario: `spdd-migrate` no traduce contenido histórico
  - WHEN `spdd-migrate` migra un canvas antiguo de `docs/prompts/` al layout `spdd/changes/.../canvas.md`
  - THEN reformatea Acceptance Criteria/Safeguards a WHEN/THEN como ya hace hoy, pero **no traduce** el contenido ya existente del canvas antiguo (pudo haberse escrito en cualquier idioma antes de este cambio) — solo los documentos generados **de aquí en adelante** quedan forzados a inglés

- **[NEW]** Scenario: cobertura de evals de la nueva regla
  - WHEN se da este cambio por completado
  - THEN existen casos nuevos en `spdd-canvas/evals/evals.json` y `spdd-implement/evals/evals.json` (mínimo) que verifican que el contenido del documento generado está en inglés incluso cuando el prompt de entrada está en otro idioma (p. ej. español); IDs de eval nuevos empezando en 52 (el máximo actual en todo el repo es 51, en `spdd-verify/evals/evals.json`)

**Out of scope:**
- No se traduce contenido ya existente en documentos previos (canvases archivados, specs vivas ya escritas en español como `spdd/specs/spdd-agent.md` y `spdd/specs/spdd-verify.md` en este propio repo) — el cambio es solo hacia adelante.
- No se añade ninguna opción de configuración/override para que un equipo elija otro idioma de documento (p. ej. vía `spdd/norms.md`) — el objetivo explícito del usuario es reducir tokens de razonamiento con una regla fija y simple; una opción configurable añadiría complejidad no pedida. **Confirmado:** alcance mínimo (inglés fijo, sin override), sin vía de opt-out por proyecto.
- No cambia el idioma de las respuestas conversacionales del agente al usuario en el chat (ver escenario dedicado arriba) — solo el contenido de los archivos persistidos por las skills.
- No se decide en este canvas la división exacta en planes (uno vs. varios) — queda para `spdd-design`, con el default sugerido arriba.

---

## Entities

No hay entidades de datos — es un cambio de instrucciones dentro de varios `SKILL.md` y sus templates, no código de aplicación.

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| Step "Detect output language" | `spdd-canvas/SKILL.md` (Step 3) | Existing → Modified | Pasa de "usar idioma detectado" a "siempre inglés"; posible rename a "Output language" |
| Step "Detect output language" | `spdd-implement/SKILL.md` (Step 0) | Existing → Modified | Mismo cambio de contenido |
| Nota `> Language: ...` | `spdd-canvas/assets/template-reasons.md` | Existing → Modified | Línea 5 del template |
| Nota `> Language: ...` | `spdd-design/assets/template-plan.md` | Existing → Modified | Línea 4 del template |
| Nota defensiva de idioma (nueva) | `spdd-design/SKILL.md` | New | Antes del Step actual "Generate the plan(s)" |
| Nota defensiva de idioma (nueva) | `spdd-verify/SKILL.md` | New | Cerca del Step "Fold back and archive" y del Step "Diff-to-canvas check" |
| Nota defensiva de idioma (nueva) | `spdd-sync/SKILL.md` | New | Cerca del Step "Update the spec" |

**Main fields:** no aplica.

---

## Approach

- [x] Service/internal logic only (no presentation layer)

**Rationale:**
Es un cambio de instrucciones dentro de skills markdown (no hay capa de presentación ni
persistencia propia de aplicación). El patrón más cercano es "lógica interna sin
presentación", igual que el precedente de Mejora 2 (`diff-to-canvas-check`).

---

## Structure

Files to create or modify, with real project paths:

```
spdd-canvas/SKILL.md                  (Step 3 "Detect output language" → contenido forzado a inglés; incrementar metadata.version)
spdd-canvas/assets/template-reasons.md (línea 5, nota "> Language: ...")
spdd-implement/SKILL.md               (Step 0 "Detect output language" → contenido forzado a inglés; incrementar metadata.version)
spdd-design/assets/template-plan.md   (línea 4, nota "> Language: ...")
spdd-design/SKILL.md                  (nueva nota defensiva de idioma; incrementar metadata.version)
spdd-verify/SKILL.md                  (nueva nota defensiva de idioma cerca de Steps 7 y 8; incrementar metadata.version)
spdd-sync/SKILL.md                    (nueva nota defensiva de idioma cerca de Step 5; incrementar metadata.version)
spdd-canvas/evals/evals.json          (nuevo(s) caso(s): documento en inglés con prompt de entrada en español)
spdd-implement/evals/evals.json       (nuevo(s) caso(s) equivalente(s))
CLAUDE.md / AGENTS.md                 (mención breve en Gotchas de que los documentos SPDD se generan siempre en inglés, independientemente del idioma de la conversación) — Confirmado: se documenta en ambos archivos (convención "AGENTS.md mirrors CLAUDE.md")
```

*(`spdd-migrate/SKILL.md` y `spdd-sync/SKILL.md` Step 2-4 no se tocan más allá de la nota defensiva señalada — no traducen contenido histórico, ver Out of scope.)*

---

## Operations

*(No hay endpoints/HTTP — son pasos de instrucciones dentro de skills markdown.)*

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Output language" (reemplaza "Detect output language") en `spdd-canvas/SKILL.md` y `spdd-implement/SKILL.md` | Ya no detecta ni pregunta el idioma del usuario; fija directamente "English" como idioma de todo el contenido de documento generado en ese paso |
| Template note | `> Language: ...` en `template-reasons.md` y `template-plan.md` | Declara explícitamente que el documento se escribe en inglés, sin instrucción de traducción |
| Note | Nota defensiva de idioma en `spdd-design`, `spdd-verify`, `spdd-sync` | Recuerda, en el punto donde cada skill redacta prosa nueva propia (no copiada del canvas/plan de origen), que esa prosa también debe quedar en inglés |
| Boundary | Documento persistido vs. respuesta conversacional | El forzado a inglés aplica solo a contenido de `canvas.md`, `plan-*.md` y `spdd/specs/<domain>.md`; las respuestas de chat al usuario siguen las reglas de idioma de la conversación (p. ej. `CLAUDE.md` del usuario) |

---

## Norms

Mandatory project conventions for this feature:

- [ ] Simplicity First: reemplazar la instrucción de detección por una instrucción fija de "English", sin lógica condicional ni configuración adicional (CLAUDE.md global, "Simplicity First")
- [ ] Incrementar `metadata.version` de cada `SKILL.md` editado (spdd-canvas, spdd-implement, y los que reciban la nota defensiva: spdd-design, spdd-verify, spdd-sync) — convención del proyecto registrada en `MEMORY.md` del usuario ("Bump SKILL.md version")
- [ ] Si se documenta este cambio en `CLAUDE.md`, mirror el mismo texto en `AGENTS.md` — convención del proyecto registrada en `MEMORY.md` del usuario ("AGENTS.md mirrors CLAUDE.md")
- [ ] No traducir contenido histórico ya existente (canvases archivados, specs vivas ya escritas en otro idioma) — el cambio es estrictamente hacia adelante

---

## Safeguards

**Tests to write:**
- [ ] `spdd-canvas` con un prompt de entrada en español (o cualquier idioma no inglés) genera un `canvas.md` cuyo contenido está en inglés
- [ ] `spdd-implement` con contexto en español añade notas de divergencia en inglés
- [ ] Los templates ya no contienen la frase "language detected from the user"
- [ ] Contenido histórico (documentos ya existentes antes de este cambio) permanece sin modificar/traducir

**Edge cases to consider (as WHEN/THEN scenarios — `spdd-verify` writes a targeted test for each one not already covered):**

- Scenario: usuario escribe la descripción de la feature enteramente en español
  - WHEN el usuario invoca `/spdd-canvas` con una descripción en español
  - THEN el `canvas.md` generado tiene todos sus encabezados, escenarios y notas en inglés; la respuesta conversacional de reporte al usuario puede seguir en español

- Scenario: `spdd-verify` añade una nota `⚠️ Confirm:` nueva durante el Diff-to-canvas check
  - WHEN se detecta una discrepancia y `spdd-verify` escribe la nota de discrepancia directamente en el canvas/plan (documento persistido)
  - THEN esa nota se redacta en inglés, no en el idioma de la conversación en curso

- Scenario: mezcla de idiomas dentro de un mismo documento (regresión a evitar)
  - WHEN un plan se genera a partir de un canvas ya en inglés, pero el agente que ejecuta `spdd-design` recibe instrucciones adicionales del usuario en español
  - THEN el `plan-*.md` resultante no mezcla español e inglés — todo el contenido del documento queda en inglés

- Scenario: documento previo a este cambio, ya en español, se vuelve a tocar (p. ej. por `spdd-sync`)
  - WHEN `spdd-sync` actualiza una spec viva que ya existía en español antes de este cambio (p. ej. `spdd/specs/spdd-agent.md` en este propio repo)
  - THEN `spdd-sync` no re-traduce automáticamente el contenido existente de la spec a inglés como efecto colateral de una actualización parcial — solo el texto nuevo que redacta queda en inglés, dejando una mezcla temporal aceptada hasta que el equipo decida migrar manualmente. **Confirmado:** comportamiento por defecto, sin señalar la mezcla como algo a revisar

**Production rollback:**
No aplica código de producción de un proyecto destino — el cambio es a varios `SKILL.md` y templates de este propio repo. Revertir = `git revert` de los commits que modifican los `SKILL.md`, templates y evals afectados.
