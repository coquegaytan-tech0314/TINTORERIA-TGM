# AI_CONTEXT.md — Tintorería TGM

Source of truth for future AI edits on this repo (Grok / company-brain path).
Inspect `src/dashboard.html` before changing behavior. If this file and the code disagree, the code wins and this file should be corrected.

Live floor tablet (StatiCrypt gate): https://coquegaytan-tech0314.github.io/TINTORERIA-TGM/
Repo: `coquegaytan-tech0314/TINTORERIA-TGM`
Firebase project id: `tintoreria-tgm`

## 1. Purpose

Floor production dashboard for **Tintorería TGM** (Tejidos Gaytan de Moroleón). Operators use it in Spanish on a shared tablet: dye-house fichas, downtime, Bruckner/RAMA, compactadora, tejeduría rolls, and related floor tabs.

Do not treat it as a generic admin app. Numbers on screen are production records. Never invent kg, lotes, telas, or SKUs.

## 2. Architecture

Editable source is the single file `src/dashboard.html` (Spanish UI, Tailwind via CDN, Chart.js, Firebase JS SDK 10.12.2).

GitHub Pages does **not** serve that file directly. Publish path:

1. Edit `src/dashboard.html` only.
2. Encrypt with `scripts/encrypt-dashboard.sh`.
3. The script writes a StatiCrypt-gated `index.html`.
4. Pages serves that gated `index.html`.

`.staticrypt.json` stores the salt (32-char hex). The script reads it unless `STATICRYPT_SALT` is set.

`STATICRYPT_PASSWORD` must come from the environment only. Never commit the curtain password, never hardcode it, never put it in this file.

The script checks that `index.html` contains `class="staticrypt-html"` and defaults the “recordar 30 días” checkbox to checked. Gate copy is Spanish (“Entrar”, title “Tintoreria TGM · Acceso restringido”). Primary button color `#FF2E4D`.

There is also an in-app team lock inside `src/dashboard.html` (overlay before the dashboard). That is separate from the StatiCrypt page gate. Do not copy its hash into new files.

**Never replace `index.html` with plaintext `src/dashboard.html`.** A plaintext `index.html` on `main` would publish the floor dashboard without the curtain.

This Phase 0+1 change does **not** re-encrypt. After the owner approves, re-run `./scripts/encrypt-dashboard.sh` with `STATICRYPT_PASSWORD` set before Pages shows the new UI.

Offline-first pattern inside the dashboard:

- Read/write `localStorage` first (keys in `LS_KEYS`).
- Then `saveToCloud(collKey, record)` / `deleteFromCloud` fire-and-forget to Firestore.
- On startup, `loadFromCloud()` downloads every key in `FB_COLLECTIONS` with `getDocs`, merges by `id` (newer `ts` wins), and writes back to `localStorage`.
- Some screens also subscribe with `onSnapshot` (plan, empleados, tareas, empacado, revisado, tejeduría, chat).

Writes that go through `saveToCloud` require `window.TG_AUTH_TOKEN` to match the in-app team token and attach an `auth` field on the document. The token value already lives in source; do not duplicate it here or in commits of new docs.

## 3. Firebase

Project id: `tintoreria-tgm` (`firebaseConfig.projectId` in `src/dashboard.html`).
Client SDK only (no Cloud Functions in this repo). Firestore + IndexedDB persistence (`enableIndexedDbPersistence`).

`FB_COLLECTIONS` (names verified in source):

| Key | Collection | Where the UI keeps it |
| --- | --- | --- |
| `prod` | `produccion` | `state.prod` |
| `down` | `tiempos_muertos` | `state.down` |
| `bruck` | `bruckner` | `state.bruck` |
| `compact` | `compactadora` | `state.compact` |
| `planDia` | `plan_dia` | `PLAN_STATE` (doc id = `YYYY-MM-DD`) |
| `planDiaComp` | `plan_dia_compact` | `PLAN_COMPACT_STATE` (doc id = `YYYY-MM-DD`) |
| `history` | `historial` | `state.history` |
| `telas` | `catalogo_telas` | `state.telas` |
| `empleados` | `empleados` | `EMP_STATE.list` (also pulled into `state.empleados` by `loadFromCloud`) |
| `tareas` | `tareas` | `TAR_STATE.list` |
| `avisos` | `avisos` | `loadFromCloud` writes `state.avisos`. No dedicated renderer was found. |
| `empacado` | `empacado` | `state.empacado` |
| `revisado` | `revisado` | `state.revisado` |
| `tejeduria` | `tejeduria_rollos` | `state.tejeduria` |

Other paths used in code (not all are keys of `FB_COLLECTIONS`):

- `pronostico_dia/{YYYY-MM-DD}` — fields read/written: `pronostico`, `causaExtra`, `updatedAt`, `updatedBy`, `auth`. Memory cache: `_pronoCache`.
- `chat_messages` — `addDoc` fields: `user`, `text`, `ts` (server timestamp), `ts_ms`, `auth`. Listener: last 50 by `ts` desc, held in the chat script’s `chatState`.
- `chat_presence/{user}` — `user`, `lastSeen`, `lastSeen_ms`, `auth`. Also read: `chat_presence/__v23_ping__` and `chat_presence/__ping__` as freshness probes.
- `chat_typing/{user}` — `user`, `ts`, `ts_ms`, `auth`.

Not a live read, despite a comment: `config/rama_bruckner`. RAMA limits in the running page are `RAMA_DEFAULTS` plus `localStorage` key `tg_tint_cfg_rama_v1` (`state.cfgRama`: `anchoMin`, `anchoMaxOperativo`, `anchoMaxTeorico`, `notas`).

`saveToCloud('telas_solicitudes', …)` is called from the catálogo flow, but `telas_solicitudes` is **not** a key of `FB_COLLECTIONS`, so `saveToCloud` returns without writing. Do not “fix” that unless someone explicitly asks.

Local-only (not in `FB_COLLECTIONS`): `state.rd` tiempos muertos de rama, `localStorage` `tg_tint_ramadown_v2`.

### Fields the page actually stores (do not invent others)

**`produccion` / `state.prod` ficha** (from `saveProd` / `saveFichaAbrir`): `id`, `ts`, `machine`, `shift`, `operador`, `fecha`, `lote`, `tela`, `color`, `diseno`, `pedido`, `kilos`, `hEntrada`, `hSalida`, `duracionMin`, `proceso`, `apq`, `banos`, `notas`, `des`, `tiempoPlanMin`, `cargaEstim`, `estado` (`abierta` | `cerrada`). Open fichas also set `operadorAbrir`, `shiftAbrir`. A reproceso flag may set `es_reproceso`. Cierre can add merma / notas de cierre on the same record (see the cerrar-ficha modal). Historical imports may also carry `importBatch`.

**`tiempos_muertos` / `state.down`:** `id`, `ts`, `machine`, `fecha`, `hIni`, `hFin`, `duracionMin`, `categoria`, `motivo`, `notas`. Some rows are marked `_auto` or `_editable`.

**`state.rd` (local rama paros):** `id`, `rama` (`Bruckner` or `Monforts`), `fecha`, `hIni`, `hFin`, `duracionMin`, `categoria`, `motivo`, `notas`.

**`bruckner` / `state.bruck`:** `id`, `ts`, `rama`, `fecha`, `turno`, `operador`, `lote`, `tela`, `color`, `kilos`, `rend`, `metros`, `vel`, `temp`, `proceso`, `motivoPase`, `notas`, `costoFormula`, `costoColor`, `costoQuim`, `costoApresto`.

**`compactadora` / `state.compact`:** `id`, `ts`, `fecha`, `turno`, `operador`, `lote`, `tela`, `color`, `kilos`, `metros`, `vel`, `temp`, `proceso`, `motivoPase`, `notas`, `costoFormula`, `costoColor`, `costoQuim`, `costoSuav`, plus aliases `machine: 'Compactadora'`, `rama: 'Compactadora'`.

**`tejeduria_rollos` / `state.tejeduria`:** `id`, `fecha`, `fechaProd`, `turno`, `operador`, `maquina`, `tela`, `lote`, `rollos` (array of weights), `total`, `count`, `captureSource`, `scaleModel`, `ts`, `updatedAt`, `createdBy`, `updatedBy`.

**`plan_dia` items:** `id`, `tela`, `color`, `lote`, `kg` (meta), `rend`, `vel`, `proceso` (`Suavizado` | `Termofijado` | `Empacado` | `Otros`). Doc also has `fecha`, `updatedAt`, `updatedBy`, `auth`.

**`historial` entry:** `id`, `ts`, `user`, `module`, `action`, `machine`, `lote`, `detail`.

**Machines** coded in `MACHINES`: `THIES-1`, `THIES-2`, `THIES-4`, `THEN-1`, `THEN-2`, `OVERFLOW`, `GASTON`. Expected load is `cargaEsperada(machine, proceso)`. Desempeño on a ficha is `kilos / carga estimada`. The Eficiencia tab uses the same ratio summed per machine (real kg / suma de `cargaEstim`). Disponibilidad on that tab is `duracionMin / tiempoPlanMin`.

Dye-house standard minutes live in `PROCESOS_CATALOGO` / `minutosProceso()`.

## 4. Domain glossary (UI Spanish)

- **Ficha** — production card for one dye load on a machine. Modes: Abrir (entry, `estado: abierta`), Cerrar (the next shift finishes it), Captura completa (in and out in one shift, `cerrada`).
- **Lote** — lot id typed by the operator (`lote`). Not a SKU master.
- **Tela** — fabric name (`tela`). **Diseño** is a separate field (`diseno`) on the ficha.
- **Color**, **pedido** — color and order id on the ficha.
- **Kg / kilos** — weight in kilograms (`kilos`). Tejeduría roll weight is `total` (sum of `rollos`).
- **Tejeduría** — greige rolls before dyeing (`tejeduria_rollos`). Not the dye house.
- **Turno** — shift, usually `1°`, `2°`, `3°`.
- **Proceso** — process text (teñido, lavado, descrude, etc.).
- **Baños** — number of baths on the ficha (`banos`).
- **Químico / kg** — the ficha field `apq` (MXN per kg on the form). Do not rename it casually.
- **Tiempos muertos** — machine downtime (`tiempos_muertos`). Categories used in the form include Mecánico, Eléctrico, Programación, Operación, Limpieza.
- **Bruckner / RAMA** — finishing stenter. Records live in `bruckner` with `rama: 'Bruckner'`. **Monforts** is the other frame stored in the same collection (`rama: 'Monforts'`).
- **Compactadora** — tubular route for narrow fabrics (piqué, interlock, rib, etc.), collection `compactadora`.
- **Eficiencia / desempeño** — real kg vs expected load for that machine and process. Not OEE unless the Eficiencia tab’s own columns say so.
- **Disponibilidad** — actual minutes vs planned process minutes (Eficiencia tab).
- **Plan del día** — planned RAMA lines for a date (`plan_dia`). Meta kg is `item.kg`.
- **Pronóstico del día** — a single number on `pronostico_dia`, not the plan lines.
- **Empacado / Revisado** — packing and quality sheets (rollos de primera y sospechosos).
- **Reproceso** — `es_reproceso` when the operator confirms a repeated lote+proceso.
- **Catálogo** — fabric catalog (`catalogo_telas`).
- **Historial** — audit bitácora, not the production fichas.
- **Más** — overflow nav (Inicio, Tareas, Personal, Historial, Catálogo, Empacado, Revisado, Ambiente, Sincronizar ahora, Preguntar al día).

## 5. Hard rules

- Never invent kg, lotes, telas, colores, pedidos, or SKUs. If the loaded data does not have it, say so.
- Never casually rewrite the live floor dashboard (layout, formulas, ficha flow, eficiencia math) outside the task.
- Never put plaintext dashboard HTML in `index.html` on `main`. Encrypt first.
- Never commit passwords, salts as “the password”, API keys into new files, or `.env` secrets. The Firebase web config and the team hash already exist in `src/dashboard.html`; do not spread them.
- Do not edit Firebase security rules, GitHub Actions, auth, or secrets unless the user explicitly asks.
- Write actions on production data are **ask-first / drafts-until-GO**. A draft the operator can read is not permission to `setDoc`.
- Do not run `scripts/encrypt-dashboard.sh` in an agent session unless the owner has supplied `STATICRYPT_PASSWORD` and asked for the encrypt step.
- Historical batch JSON embedded in `src/dashboard.html` is import payload behind localStorage flags. It is not “today’s floor” and must not be quoted as a live answer.

## 6. Phase 1 read-only data contract

**Preguntar al día** answers only from data already on the page. It does not call Firestore, does not call `save` / `saveToCloud` / `logChange`, and does not touch `localStorage`.

READ (allowed):

- `state.prod`, `state.down`, `state.bruck`, `state.compact`, `state.tejeduria`, `state.rd`
- `PLAN_STATE.fecha` / `PLAN_STATE.items` and `PLAN_COMPACT_STATE` (already subscribed or cached)
- `_pronoCache` **only if that date is already cached** — do not `getDoc` to fill it. A cached `{ pronostico: 0, causaExtra: '' }` is also what `_pronoLoad` stores when the document is missing or the read fails, so Phase 1 must not state that as a confirmed forecast of 0 kg.
- Helpers already used by the UI: `todayISO`, `fmtKg`, `getFichasAbiertas`, `fichaAging`, `MACHINES`, `cargaEsperada`

“Hoy” means `fecha === todayISO()` (local date, same helper as the fichas). Tejeduría uses `fechaProd` when present, otherwise `fecha`. Fichas **en proceso** are `estado === 'abierta'` at any date (`getFichasAbiertas`), not “opened today” only. A resumen for another period still lists those open fichas, labeled as abiertas actuales (any date), so they are not read as production of that period.

**Resumen de ayer** is the previous local calendar day (`todayISO` minus one day). **Resumen semana pasada** is the last completed Monday–Sunday week before the week that contains today (same Lun→Dom week as the jefe resumen). It is not a rolling 7 days and it does not include the week in progress. **Resumen mes pasado** is the previous calendar month (day 1 through the last day), not a rolling 30 days. Free text such as «día anterior», «última semana» / «últimos 7 días» / «semana anterior», and «último mes» / «últimos 30 días» / «mes anterior» maps onto those same closed windows. The draft title and body name the concrete ISO range. Filters stay on data already in memory. Week and month answers say the counts are only what this tablet has loaded (local cache caps, about 2000 recent fichas per collection) and are not a full cloud period. No Firestore read is added to fill gaps. Plan del día and pronóstico stay on hoy and are not mixed into ayer / semana / mes. Other hoy-only chips (tiempos muertos hoy, eficiencia) stay on today unless the free text itself names ayer, semana, or mes — then the answer is the ranged resumen.

Desempeño in an answer uses the Eficiencia formula for **today’s fichas only**: sum of `kilos` / sum of `cargaEstim` (or `cargaEsperada` when the stored estimate is missing). It does not change the chart.

WRITE (out of scope for Phase 1):

- Any Firestore write (`setDoc`, `addDoc`, `deleteDoc`, batch, plan save, chat, pronóstico).
- `localStorage` / `sessionStorage` writes, including “remember this answer”.
- Creating collections. Chat collections stay as they are; Preguntar al día does not use them.
- **Aceptar** only hides the draft card in the DOM. **Cerrar** closes the panel. Neither persists anything.

If the question is outside those structures, the UI must say in Spanish that it cannot answer from the loaded data. Zeros are allowed only as counts of empty in-memory arrays.

Phase 1 does not answer from `state.empacado`, `state.revisado`, `state.telas`, `state.history`, `EMP_STATE`, `TAR_STATE`, or chat. Those remain available for a later phase; they are not a reason to guess.

## 7. Roadmap

| Phase | What | Status |
| --- | --- | --- |
| 0 | This file | Done in the Phase 0+1 change |
| 1 | **Preguntar al día** — Spanish, read-only, template/heuristic answers, ephemeral UI. Entry: **Más → Preguntar al día**. Chips: resumen del día, resumen de ayer, resumen semana pasada (lun→dom ya cerrada), resumen mes pasado (mes calendario anterior), lotes en proceso, tiempos muertos hoy, eficiencia por máquina. Free text can also ask Bruckner/RAMA, compactadora, tejeduría, plan del día, or a lote id. Ayer / semana / mes change the resumen window only from memory already loaded. | Done as UI only. Not on Pages until re-encrypt. |
| 2 | Natural language → **draft actions** (drafts-until-GO). Operator must confirm before any Firebase write. | Not implemented |
| 3 | RAG / SOPs over procedures | Not implemented |

Do not start Phase 2 or 3 from this file alone.
