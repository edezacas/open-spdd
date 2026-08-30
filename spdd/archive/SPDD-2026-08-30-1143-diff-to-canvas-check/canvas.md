# REASONS: Diff-to-canvas check en spdd-verify (Mejora 2)

> Generado el 2026-08-30. Revisar las líneas marcadas ⚠️ antes de generar código.
> Regla de oro: si algo falla durante el desarrollo, corregir primero este canvas, luego el código.

**Status:** Confirmed

---

## Nota sobre el dominio de este canvas

`spdd/specs/spdd-agent.md` es la única spec viva existente en este repo, pero documenta la
Mejora 1 (enrutamiento ruta directa/completa), que es comportamiento de `spdd-agent`, no de
`spdd-verify`. Este cambio modifica exclusivamente `spdd-verify/SKILL.md` y sus evals.

**Decisión de dominio:** se usa `spdd-verify` como dominio propio (no `spdd-agent`), siguiendo
la convención ya establecida por `spdd/specs/spdd-agent.md`: en este repo, cada skill es
conceptualmente su propio dominio, y la spec de una skill documenta el comportamiento de esa
skill, no el de quien la invoca. `spdd-agent` delega en `spdd-verify` pero no es dueño de su
comportamiento interno. `spdd-verify` (Step 7, tras esta mejora) foldeará este cambio a
`spdd/specs/spdd-verify.md`, creándolo por primera vez.

---

## Requirements

**User story:**
Como equipo que usa `spdd-verify`, quiero que la verificación compare el diff real de código
contra las Operations y Norms del canvas/plan de origen antes de foldear a la spec, para que
un test en verde no pueda ocultar una divergencia silenciosa entre lo acordado y lo implementado.

**Acceptance criteria:**

- **[NEW]** Scenario: diff coherente con el canvas — continúa sin fricción
  - WHEN el diff real de los archivos modificados en la implementación cubre exactamente las Operations declaradas en el canvas/plan, sin tocar archivos/módulos no mencionados
  - THEN `spdd-verify` reporta el chequeo como pasado en un renglón corto y continúa al fold-to-spec (Step 8) sin pedir confirmación

- **[NEW]** Scenario: el diff toca un archivo no declarado en el canvas — bloquea
  - WHEN el diff real incluye cambios en un archivo o módulo que no aparece en Structure, Shared touchpoints ni Operations del canvas/plan en verificación
  - THEN `spdd-verify` detiene el proceso antes del fold, muestra la discrepancia concreta (archivo tocado vs. lo declarado en el canvas) y no marca el scope como `Verified` ni folda nada a `spdd/specs/<domain>.md`

- **[NEW]** Scenario: una Operation del canvas no tiene código correspondiente en el diff — bloquea
  - WHEN una Operation listada en el canvas/plan no tiene ningún cambio correspondiente en el diff real (código "conectado a nada" o directamente ausente)
  - THEN `spdd-verify` detiene el proceso antes del fold, nombra la Operation sin implementación real y no marca el scope como `Verified`

- **[NEW]** Scenario: discrepancia confirmada como intencional por el humano — continúa el fold
  - WHEN se detecta una discrepancia (archivo no declarado u Operation sin código) y el humano confirma explícitamente, en una sesión con turno en vivo, que es intencional
  - THEN `spdd-verify` usa `AskUserQuestion` para pedir esa confirmación, y si se confirma, continúa al fold-to-spec anotando la discrepancia aceptada como nota en el fold (p. ej. una Operation fuera de alcance para esta iteración, documentada como tal)

- **[NEW]** Scenario: discrepancia detectada corriendo como subagente en background bajo spdd-agent
  - WHEN `spdd-verify` corre como subagente en background delegado por `spdd-agent` (sin turno de usuario en vivo, sin `AskUserQuestion` disponible de forma útil) y el Diff-to-canvas check encuentra una discrepancia
  - THEN `spdd-verify` no se queda bloqueado esperando una respuesta que no puede llegar — trata la discrepancia igual que un fallo del Step 6 (Structural check/tests): detiene el proceso, deja el plan/canvas como está, no folda ni archiva nada, reporta el gap concreto, y añade una línea `⚠️ Confirm:` en el plan/canvas para que el checkpoint en foreground de `spdd-agent` la resuelva después
  - ✅ Confirmado: este comportamiento en background (tratar la discrepancia como fallo de Step 6, dejar `⚠️ Confirm:`, no foldear) es el default para subagentes sin `AskUserQuestion`.

- **[NEW]** Scenario: cobertura de evals de la nueva comprobación
  - WHEN se da esta mejora por completada
  - THEN existen en `spdd-verify/evals/evals.json` al menos 4 casos nuevos: diff coherente con canvas (pasa), diff con archivo no declarado (bloquea y reporta), Operation del canvas sin código correspondiente (bloquea y reporta), discrepancia confirmada como intencional por el humano (continúa el fold)

**Out of scope:**
- Mejora 4 (`spdd/norms.md` como fuente adicional de verificación) — el Diff-to-canvas check de este cambio valida solo contra el canvas/plan de origen, no contra normas globales de proyecto; eso es una mejora separada y posterior según el orden de `docs/open-spdd-mejoras.md`.
- No se introduce análisis estático de código (linters, AST, etc.) — la comparación diff-vs-canvas se hace con el propio razonamiento del agente al leer el diff, igual que ya hace `spdd-canvas` para generar el canvas.
- No se cambia el comportamiento del Step 3 (Structural check) existente — el nuevo paso lo complementa usando diff real de git en vez de solo lectura de rutas declaradas, pero Step 3 se mantiene igual.

---

## Entities

No hay entidades de datos nuevas — es un cambio de lógica de verificación dentro de un `SKILL.md`, no código de aplicación.

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| Sección "Diff-to-canvas check" | `spdd-verify/SKILL.md` | New | Nuevo Step 7, insertado entre el actual Step 6 (Mark status) y el actual Step 7 (Fold back and archive, pasa a ser Step 8) |
| `spdd/specs/spdd-verify.md` | `spdd/specs/spdd-verify.md` | New | Se crea la primera vez que este cambio se folde vía el propio `spdd-verify` (no en esta fase de canvas) |

**Main fields:** no aplica — no hay entidad de datos nueva con campos propios.

---

## Approach

- [x] Service/internal logic only (no presentation layer)

**Rationale:**
Es lógica de verificación dentro de una skill markdown (no hay capa de presentación ni
persistencia propia). El patrón más cercano de la lista es "lógica interna sin presentación":
un paso de comprobación evaluado en cada invocación de `spdd-verify`, antes del fold-to-spec.

---

## Structure

Files to create or modify, with real project paths:

```
spdd-verify/SKILL.md          (nuevo Step 7 "Diff-to-canvas check"; renumera Steps 7-9 actuales a 8-10; incrementar metadata.version)
spdd-verify/evals/evals.json  (nuevos casos: diff coherente, archivo no declarado, Operation sin código, discrepancia confirmada como intencional)
```

---

## Operations

*(Adaptado: no hay endpoints/HTTP — son pasos del flujo de verificación de `spdd-verify`.)*

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Diff-to-canvas check" (nuevo Step 7, entre el Step 6 actual "Mark status" y el Step 7 actual "Fold back and archive") | Obtiene el diff real de los archivos modificados en esta implementación (`git diff` para cambios sin commitear; `git log -p`/`git log --stat` sobre las rutas declaradas en Structure/Shared touchpoints del plan/canvas si ya están commiteados) y lo compara punto por punto contra las Operations y Norms del canvas/plan en verificación |
| Check | Cobertura de Operations | Cada Operation del canvas/plan debe tener código correspondiente en el diff; si falta alguna, es una discrepancia bloqueante |
| Check | Alcance del diff | Ningún archivo/módulo tocado en el diff puede quedar fuera de Structure, Shared touchpoints u Operations del canvas/plan; si lo hace, es una discrepancia bloqueante — excepto los archivos de test que el propio Step 4 de `spdd-verify` creó durante esta misma verificación, que quedan exentos del chequeo por ser un subproducto esperado de la verificación, no del diff de implementación original |
| Gate | Discrepancia en sesión con turno en vivo (foreground) | Usa `AskUserQuestion` para preguntar al humano si la discrepancia es intencional; si confirma, continúa al fold anotando la discrepancia aceptada; si no confirma o no responde con claridad, detiene el proceso sin foldear |
| Gate | Discrepancia en subagente background (delegado por `spdd-agent`) | No usa `AskUserQuestion` (no hay turno de usuario en vivo) — trata la discrepancia igual que un fallo del Step 6: detiene el proceso, no folda, reporta el gap, deja una línea `⚠️ Confirm:` en el plan/canvas |
| Report | Discrepancia concreta | Formato: "Canvas declara: `<Operation o ruta>` → Código real: `<lo que el diff muestra o su ausencia>`" — nunca un genérico "no coincide" |

---

## Norms

Mandatory project conventions for this feature:

- [ ] Simplicity First: el nuevo paso no introduce análisis estático ni herramientas externas — solo lectura de diff y razonamiento del agente (CLAUDE.md global, "Simplicity First")
- [ ] El nuevo paso complementa el Step 3 (Structural check) existente sin duplicarlo: Step 3 sigue comprobando declaración de rutas; el nuevo Step 7 usa el diff real de git como evidencia objetiva (`docs/open-spdd-mejoras.md`, Mejora 2, principio "Trust what the system can derive, not agent narration")
- [ ] Incrementar `metadata.version` de `spdd-verify/SKILL.md` al guardar los cambios (convención del proyecto para cualquier edición de instrucciones de una skill — ver `MEMORY.md` del usuario)
- [ ] Nunca foldear a `spdd/specs/<domain>.md` mientras exista una discrepancia sin resolver — ni en foreground sin confirmación explícita, ni en background bajo `spdd-agent` (regla de seguridad explícita de Mejora 2: "detener el proceso", no continuar en silencio)

---

## Safeguards

**Tests to write:**
- [ ] Diff coherente con el canvas → el chequeo pasa y continúa al fold sin pedir confirmación
- [ ] Diff con archivo no declarado en el canvas → bloquea el fold y reporta la discrepancia concreta
- [ ] Operation del canvas sin código correspondiente en el diff → bloquea el fold y reporta la discrepancia concreta
- [ ] Discrepancia confirmada como intencional por el humano (foreground) → continúa el fold-back

**Edge cases to consider (as WHEN/THEN scenarios — `spdd-verify` writes a targeted test for each one not already covered):**

- Scenario: diff coherente con el canvas
  - WHEN el diff real cubre exactamente las Operations declaradas y no toca nada fuera de Structure/Shared touchpoints
  - THEN el chequeo pasa, se reporta como pasado y continúa al fold-to-spec sin pedir confirmación

- Scenario: archivo no declarado en el canvas
  - WHEN el diff incluye cambios en un archivo que no aparece en Structure, Shared touchpoints ni Operations del canvas/plan
  - THEN se detiene el proceso, se reporta "Canvas declara: [lista de rutas] → Código real: incluye además `<archivo>`, no declarado" y no se folda ni marca `Verified`

- Scenario: Operation sin código correspondiente
  - WHEN una Operation del canvas/plan no tiene ningún cambio correspondiente en el diff real
  - THEN se detiene el proceso, se reporta "Canvas declara Operation: `<identifier>` → Código real: sin cambios correspondientes en el diff" y no se folda ni marca `Verified`

- Scenario: discrepancia confirmada como intencional
  - WHEN se detecta una discrepancia y, en sesión foreground, el humano confirma explícitamente vía `AskUserQuestion` que es intencional
  - THEN se continúa al fold-to-spec, anotando la discrepancia aceptada como nota junto a la Operation/archivo afectado en el fold

- Scenario: discrepancia en background bajo spdd-agent
  - WHEN se detecta una discrepancia corriendo como subagente en background, sin `AskUserQuestion` disponible con turno en vivo
  - THEN se detiene el proceso sin bloquear esperando respuesta, se deja el plan/canvas como está con una línea `⚠️ Confirm:` añadida, no se folda ni archiva nada, y se reporta el gap para que el checkpoint en foreground de `spdd-agent` lo resuelva

- Scenario: archivos de test creados por el propio Step 4 no disparan falso positivo
  - WHEN el diff incluye archivos de test nuevos que el propio Step 4 de `spdd-verify` escribió durante esta misma verificación (no parte del código de implementación original)
  - THEN esos archivos quedan exentos del chequeo de alcance del diff — no cuentan como "archivo no declarado"

**Production rollback:**
No aplica código de producción de un proyecto destino — el cambio es a un `SKILL.md` de este propio repo. Revertir = `git revert` del commit que modifica `spdd-verify/SKILL.md` y `spdd-verify/evals/evals.json`.
