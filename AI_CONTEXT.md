# AI_CONTEXT.md — Tintorería TGM (tablero de piso / producción)

> La versión anterior en inglés se conserva en [`AI_CONTEXT.en.md`](AI_CONTEXT.en.md).
> **Aprobado por Koke el 2026-09-30.** Basado en revisión de solo lectura del 2026-09-29.
> Repo: `coquegaytan-tech0314/TINTORERIA-TGM` · rama `main` · HEAD revisado: `931609e` (2026-09-25 09:15 CDMX).
> Fuentes: el código del repo + el historial de la Perplexity Computer "Production KPI TGM-Dashboard" (`799ec5ad…`, abr–sep 2026).
> **Si el historial y el código no coinciden, gana el código** (`src/dashboard.html`); las diferencias se marcan con ⚠️ *Historial vs código*.
> Reemplaza al `AI_CONTEXT.md` en inglés (PR #3), que se conserva como `AI_CONTEXT.en.md`.

---

## 0. Reglas permanentes de Koke (leer primero)

1. **Nunca reconstruir.** "Do not rebuild. Do not start a new Computer." Todo cambio es un **seguimiento quirúrgico** sobre el mismo repo y la misma URL de Pages.
2. "No cambies la estructura del dashboard, solo mejóralo (pulido). La gente ya trabaja aquí y la empresa depende de esto" (2 jul). No cambiar datos existentes, cálculos, KPIs ni fichas guardadas; no romper el flujo de trabajo; las sugerencias nuevas deben ser opcionales y fáciles de ignorar.
3. **CONGELADO** (lista que Koke repitió de ago 30 a sep en cada pase visual; tratarla como regla permanente salvo que él diga lo contrario):
   - todos los **números y fórmulas**; colecciones y **escrituras a Firebase**;
   - **orden de pestañas**; significado en español de los campos de producción; máquina de estados de las fichas;
   - **fichas**; consultas del **calendario**; lógica de la **báscula**;
   - lógica **"Roger montaje/suavizado"** (PR aparte, congelado hasta que Koke diga GO);
   - nada de rediseño visual si no se pide.
   (Excepción ya aprobada por Koke: PR #6 del 25 sep cambió la etiqueta del dock a "Rama" y puso Monforts por defecto.)
4. **Look:** oscuro industrial, alto contraste, **nunca modo claro**; botones/áreas táctiles de **mínimo 44 px** (para guantes); kg con números tabulares. **No copiar** el look BVG/ALORA (arena `#F4EDE4`, coral `#E07A5F`, tarjetas blancas estilo Airbnb, marca Ixtapa) ni el estilo liquid-glass del "TGM commercial KPI".
5. **Idioma:** UI siempre en **español**. Mensajes para el equipo en español, claros y positivos. **Las respuestas a Koke van en inglés** (él quiere practicar).
6. **Vocabulario:** "**Colaborador**", nunca "Empleado"; "**Supervisor directo**", no "Jefe directo"; sin emoji 👑 junto a "manager". (El código actual cumple: 0 textos visibles con "Empleado", 0 "Jefe directo", 0 👑.)
7. **Mantener los dos candados** (cortina StatiCrypt + contraseña del equipo dentro de la app). No pedir a operadores que reescriban contraseñas a mitad de turno.
8. Abre en **Ficha** por defecto (aunque Tejeduría esté primera); calendarios abren en el **mes actual**; Bruckner/Rama muestra **Solo Empacado** por defecto.
9. **Nunca** imprimir, loguear ni commitear contraseñas, tampoco en mensajes de commit (regla de Koke, 2 sep).
10. Precisión: "make sure you don't make any mistakes", "Sé congruente".

## 1. Propósito y usuarios

- Tablero de producción de **Tejidos Gaytán de Moroleón (TGM)**; nació en **Tintorería** y creció a plataforma de piso: Tejeduría → Tintorería → Rama (Bruckner/Monforts) o Compactadora → Empacado → Revisado/Calidad → Estadística.
- Objetivo: reemplazar formatos de papel por captura rápida en tablet/PC y dar números del mismo día a jefes y dueño (antes llegaban con 12–24 h o semanas de atraso). Según el historial está "a prueba hasta fin de 2026".
- Usuarios: operadores y supervisores de piso (tablets compartidas, PC de la estación de Tejeduría), **Roger (Rogelio)**, ingeniero/gerente de producción (catálogo de telas, reglas de conteo semanal, Excel PRODUCCION-DIARIO), planeación (Excel "PROGRAMACION"), el área de Estadística, Koke (dueño/admin) y la dirección.
- Roles de vista (solo CSS, por dispositivo, `localStorage` `tg_tint_role`): `supervisor` (default; oculta Eficiencia, Análisis, Estadística, Duplicados y secciones `data-role="jefe"`) y `jefe` (todo). 5 clics rápidos en el pill alternan rol. No cambia datos.
- Los números son **registros reales de producción**. Nunca inventar kg, lotes, telas, colores, pedidos ni SKUs.

## 2. URL en vivo y publicación

- **URL:** https://coquegaytan-tech0314.github.io/TINTORERIA-TGM/ → HTTP 200, muestra la cortina "Tintoreria TGM · Acceso restringido"; idéntica (md5) al `index.html` de `931609e`.
- **Pages:** se sirve desde `main` / raíz (confirmado en el historial). Sin `.github/` ni Actions, sin `CNAME`.
- **Repo gemelo** `TINTORERIA-TGM-STATICRYPT` (público, Pages activo): copia cifrada de prueba creada el 2 ago; redundante desde mediados de ago, último push 17 ago. Perplexity sugirió retirarlo; no se hizo (ver §11).
- **Tag de respaldo:** `backup-pre-staticrypt-2026-08-02` → `77392a5` (última versión en texto plano antes de StatiCrypt).

### Flujo actual (desde v25, 12 sep)
1. Editar **solo** `src/dashboard.html` (fuente legible).
2. Rama + PR → merge a `main` (PR #2–#6).
3. Commit de seguimiento: `STATICRYPT_PASSWORD=… ./scripts/encrypt-dashboard.sh` → regenera `index.html` cifrado (lo hizo "Cursor Agent" tras cada merge).
4. Verificar la URL en vivo (cortina + cambio visible tras entrar). Si no se ve: recarga forzada (Cmd/Ctrl+Shift+R, o `?v=1` en Safari iPad).

- Script: `npx staticrypt` `--short --remember 30`, textos en español, color primario `#FF2E4D`, secundario `#0c1119`; sal de `.staticrypt.json` (la misma desde v19; si cambia, todos los dispositivos vuelven a pedir la cortina); contraseña solo por entorno; valida `class="staticrypt-html"`; deja "Recordar 30 días" marcado.
- **Nunca** copiar `src/dashboard.html` sobre `index.html`.
- ⚠️ *Historial vs código:* con Perplexity (v8–v24) la fuente plana vivía en su sandbox (`tintoreria/index.html`), usaba StatiCrypt 3.5.4, buscaba fugas de texto plano en el cifrado y hacía push directo a `main`. Hoy la fuente está en `src/dashboard.html` y se trabaja por PR. El historial menciona `version.json` y `firestore.rules` en el repo: **no existen** en `main` y el código no hace "version poll"; el cache-bust de v23 es recargar con `?v=<timestamp>`. La cortina se describía "morada"; el script actual usa rojo TGM `#FF2E4D`.
- Receta de emergencia que dio Perplexity (2 ago): `git reset --hard backup-pre-staticrypt-2026-08-02 && git push -f origin main`. **Destructiva, quita la cortina y borra v8–v25. No usar sin aprobación explícita.**

## 3. Estructura de archivos

| Archivo | Qué es |
| --- | --- |
| `index.html` (~4.3 MB) | Salida StatiCrypt. Es lo que sirve Pages. No se edita a mano. |
| `src/dashboard.html` (~2.1 MB, ~29.5k líneas) | **Fuente única**: HTML + CSS + JS en un archivo. |
| `src/README.md` | Cómo editar y re-cifrar. |
| `scripts/encrypt-dashboard.sh` | Re-cifra `src/dashboard.html` → `index.html`. |
| `.staticrypt.json` | Sal de StatiCrypt (no es la contraseña). No copiar su valor. |
| `data/estadistica-backfill-2026.json` (~0.9 MB) | Backfill de Estadística ene–jul 2026 (§6). |
| `AI_CONTEXT.md` | Contexto IA actual (inglés). |
| `.deploy-log.txt` | Nota de redeploy tras el 503 de Pages del 17 ago. |

CDN: Tailwind, Chart.js 4.4.1, `xlsx-js-style` 1.2.0, `xlsx-populate` 1.21.0 (Excel con contraseña), Firebase JS SDK 10.12.2. Sin build.

Bloques `<script>` en `src/dashboard.html` (líneas aprox. en `931609e`): ~33 módulo Firebase (`window.TG_FB`, evento `firebase-ready`); ~2376 candado del equipo; ~7190 Ambiente; ~7504+ lógica principal; ~27677 `data-pplx-inline-edit` (ayudante de Perplexity, solo en iframe); ~27898 chat; ~28410 sync v23 (chip, heartbeat, watchdog, auto-refresh, `forceResync`); ~28684 "Preguntar al día".

## 4. Pestañas y funciones

Dock (izq→der, `data-tab`): **Tejeduría** `tab-tejeduria` · **Ficha** `tab-capture` (activa al abrir) · **Reporte** `tab-report` · **Eficiencia** `tab-efficiency` · **T. Muerto** `tab-downtime` · **Análisis** `tab-downtime-analytics` · **Rama** `tab-bruckner` · **Compactadora** `tab-compact` · **Estadística** `tab-estadistica` · **Buscar** `tab-buscar` · **Duplicados** `tab-duplicados` · **Más**.
⚠️ *Historial vs código:* el historial llama "Bruckner" a la pestaña; desde PR #6 la etiqueta es **Rama** (mismo `data-tab`).

- **Ficha:** copia del formato "TEJIDOS GAYTAN DE MOROLEÓN · ÁREA DE TINTORERÍA TGM". Modos Abrir / Cerrar / Captura completa; panel de Fichas Abiertas (el siguiente turno cierra; la ficha abierta debe mostrar por qué); pre-llenado inteligente, recomendaciones, señales predictivas; autocorrección de tela contra el catálogo.
- **Reporte:** calendario de producción (abre en el mes actual), grupos por máquina, fichas editables, Excel del día, insights de costo químico (mes/año), vista anual, insights históricos (solo Jefe). Tarjetas Rama/Compactadora muestran **Empacado** en grande.
- **Eficiencia:** estilo hoja JETS de Koke. Desempeño = producción real / estimada (kg / `cargaEstim`); Disponibilidad = `duracionMin` / `tiempoPlanMin`. Filtros Hoy/Ayer/7 d/30 d/rango.
- **T. Muerto / Análisis:** categorías Mecánico, Eléctrico, Programación, Operación (+ Limpieza en el mapeo de imports); detección automática de huecos entre fichas.
- **Rama (Bruckner + Monforts):** Plan del día (meta, import Excel), captura (`#br_rama` abre en **Monforts**; proceso obligatorio: Empacado/Suavizado/Termofijado/Secado), historial segmentado **Solo Empacado (default)** / Reproceso / Todos, KPIs solo Empacado, "Total Empacado hoy" = Rama + Compactadora, costos por kg, pronóstico del día, resumen del día, señales predictivas.
- **Compactadora:** ruta tubular; plan del día compactadora; import Excel; "Reclasificar histórico" Bruckner→Compactadora (marca `_migratedFrom: 'bruck'`, `_migratedFromId`).
- **Estadística:** Día (formato "REPORTE DE ENTREGA DE PRODUCTO TERMINADO", celdas editables por `fecha::lote`, WhatsApp, Excel), Semanal (reporte Rama + conciliación contra Excel de Roger + QA), P. Terminado, Importar (.xlsx mensuales con contraseña tecleada en cada import, no se guarda), Reporte Express con aviso "NO FINAL", resumen para el jefe con toggle Diario/Semanal.
- **Buscar:** estado por lote/producto (Teñido → Rama → Suav/Termo → Empacado), ETA promedio por producto.
- **Duplicados:** aviso al guardar si hay mismo **lote + proceso** en los últimos **7 días** (marcar "reproceso legítimo" → `es_reproceso: true`); revisión retro de 30 días.
- **Tejeduría:** barra de sesión (turno/operador/fecha), modal "Registrar rollo" con SUMA; rango sano **22–27 kg** (alerta 20–22 / 27–30, error fuera de 20–30); import Excel (v12) e "Importar historial" por pegado (v18); báscula por Web Serial (v14–v17, **sin terminar**, §9).
- **Más:** Mi Inicio, Tareas (kanban + badge), Personal (directorio de colaboradores), Historial (bitácora), Catálogo de telas, Empacado, Revisado, Preguntar al día (solo lectura), Sincronizar ahora (v23), Ambiente.
- **Otros:** candado + selector de colaborador; "¿Sigues siendo [nombre]?" cada **12 h** (`TURN_CHECK_INTERVAL_MS`); chat con presencia; chip de frescura; "Novedades" (`TG_WHATSNEW`, `CURRENT_VERSION = 18`); tour de bienvenida (`tg_tint_onboarding_v2`).

## 5. Reglas de negocio (no cambiar sin Koke)

- **Máquinas** (`MACHINES`): `THIES-1`, `THIES-2`, `THIES-4`, `THEN-1`, `THEN-2`, `OVERFLOW`, `GASTON`, con capacidad nominal y cargas en el código. FONG'S 2 ya no existe (se remapea a THIES-4 en imports); THIES-3 y OVERFLOW-1 se quitaron. Tiempos estándar en `PROCESOS_CATALOGO` / `minutosProceso()`; carga esperada `cargaEsperada(machine, proceso)`.
- **Terminado = solo EMPACADO.** Suavizado (felpa) y Termofijado (lycra) son pases intermedios; la tela regresa para terminar en Empacado. Dos pases del mismo lote son normales, no duplicados.
- **"Químico/kg"** es el campo `apq` (costo químico MXN/kg), nunca "Kilos Aprobados". APQ ≥ 15 se marca ámbar. APRESTO ≈ $0.80/kg; suavizante en Compactadora ≈ $1.00/kg.
- **Tubular → Compactadora:** PIQUE 1F/2F, INTERLOCK (y typos), CHIFON, cualquier CARDIGAN, RIB, CUELLOS, PUÑOS. Piqué Atlante/Marsella, Felpa y Jersey → Rama. Ancho de trabajo Rama 1.40–2.10 m (teórico 2.20; `RAMA_DEFAULTS`).
- **Día de producción (v10):** Turno 3° capturado después de medianoche pertenece al día anterior. Turnos por reloj: 1° 06–14, 2° 14–22, 3° 22–06.
- **C.B. (Clase B):** la decide Revisado después de Empacado; Empacado solo marca "sospechosos".
- **Semanas — ⚠️ inconsistencia** (ver §11): según el historial el reporte Semanal usa **Lun–Sáb (6 días)** como el Excel de Roger. En el código actual:
  - Reporte Semanal Rama (`_rsWeekDates`): suma **7 fechas Lun→Dom**, el subtítulo solo muestra hasta el sábado, y el promedio de pronóstico y "días ≥100% / <85%" se calculan **/6**. El comentario lo explica como "convención Roger: etiqueta LUN–SÁB pero el TOTAL incluye domingo si hubo producción".
  - Resumen para el jefe (v13, botón "Semanal (Lun→Dom)") y "Preguntar al día → semana pasada": **Lun→Dom ISO**.
  - Estadística "Semanal" en otro punto suma "los últimos 7 días".

## 6. Datos: de dónde salen los números

### Sincronización
- Guarda **primero** en `localStorage` (`LS_KEYS`), luego `saveToCloud(collKey, record)` / `deleteFromCloud` a Firestore (fire-and-forget; doc id = `record.id`). `saveToCloud` **ignora** cualquier clave que no esté en `FB_COLLECTIONS`.
- `loadFromCloud()` baja todas las colecciones de `FB_COLLECTIONS`, mezcla por `id` (`mergeById`: gana `ts` más alto) y reescribe `localStorage`. Algunas vistas usan `onSnapshot`. `enableIndexedDbPersistence` activo. Topes `LS_CAPS` (p. ej. 2000 fichas por colección).
- v23: chip de frescura, heartbeat cada 60 s, watchdog (90 s + 30 s sin snapshots → `forceResync`), auto-refresh cada 5 min si la pantalla está inactiva (sin input enfocado, modal, tour, popover o chat abierto), resync al volver del fondo.
- **`forceResync()`** borra **todo** `localStorage` excepto: `tg_role…`, `tg_user…`, `tgm.ambience…`, `tg_chat_last_seen`, `tg_tint_auth_v1`, `tg_tint_user_session`, `tg_tint_empleado_id`, `tg_tint_session_lastcheck`, `tg_morning_prompt_date`, `tg_tint_auth_attempts_v1`, `tg_tint_auth_locked_until_v1`, `tg_onboarding…`, `tg_tint_onboarding…`, `staticrypt_…`; luego recarga con `?v=`. ⚠️ Ver riesgo en §11 (datos solo locales).

### `LS_KEYS`
`prod: tg_tint_prod_v2`, `down: tg_tint_down_v2`, `bruck: tg_tint_bruck_v2`, `compact: tg_tint_compact_v1`, `history: tg_tint_history_v2`, `metas: tg_tint_metas_v2`, `rd: tg_tint_ramadown_v2`, `telas: tg_tint_telas_v1`, `cfgRama: tg_tint_cfg_rama_v1`, `estadi: tg_tint_estadi_v1`, `empacado: tg_tint_empacado_v1`, `revisado: tg_tint_revisado_v1`, `tejeduria: tg_tint_tejeduria_v1`, `onboarding: tg_tint_onboarding_v2`. Solo locales (no van a Firestore): `metas`, `rd` (paros de rama), `cfgRama`, `estadi` (overrides de Estadística).

### Firestore (proyecto `tintoreria-tgm`, plan Blaze desde 11 may) — `FB_COLLECTIONS`
`prod`→`produccion` · `down`→`tiempos_muertos` · `bruck`→`bruckner` (Bruckner y Monforts, campo `rama`) · `compact`→`compactadora` · `planDia`→`plan_dia` (id `YYYY-MM-DD`) · `planDiaComp`→`plan_dia_compact` · `history`→`historial` · `telas`→`catalogo_telas` · `empleados`→`empleados` · `tareas`→`tareas` · `avisos`→`avisos` · `empacado`→`empacado` · `revisado`→`revisado` · `tejeduria`→`tejeduria_rollos`.
Rutas directas: `pronostico_dia/{YYYY-MM-DD}`, `chat_messages`, `chat_presence/{user}` (incl. sondas `__v23_ping__`, `__ping__`), `chat_typing/{user}`.
⚠️ *Historial vs código:*
- `config` (límites de Rama) está en las reglas según el historial, pero el código **no lo lee** (usa `RAMA_DEFAULTS` + `tg_tint_cfg_rama_v1`).
- `estadistica_imports/{fecha}` se "creó" según el historial, pero `saveToCloud('estadistica_imports', …)` **no escribe nada** porque no está en `FB_COLLECTIONS`. Igual con `telas_solicitudes`.

### Campos guardados (no inventar otros)
- **`produccion`:** `id`, `ts`, `machine`, `shift`, `operador`, `fecha`, `lote`, `tela`, `color`, `diseno`, `pedido`, `kilos`, `hEntrada`, `hSalida`, `duracionMin`, `proceso`, `apq`, `banos`, `notas`, `des`, `tiempoPlanMin`, `cargaEstim`, `estado` (`abierta`|`cerrada`); al abrir `operadorAbrir`, `shiftAbrir`; opcional `es_reproceso`; imports: `importBatch`, `usuario`.
- **`tiempos_muertos`:** `id`, `ts`, `machine`, `fecha`, `hIni`, `hFin`, `duracionMin`, `categoria`, `motivo`, `notas`.
- **`bruckner`:** `id`, `ts`, `rama`, `fecha`, `turno`, `operador`, `lote`, `tela`, `color`, `kilos`, `rend`, `metros`, `vel`, `temp`, `proceso`, `motivoPase` (default `nuevo`), `notas`, `costoFormula`, `costoColor`, `costoQuim`, `costoApresto`.
- **`compactadora`:** igual que bruckner pero `costoSuav` en vez de `costoApresto`; reclasificados llevan `_migratedFrom`, `_migratedFromId`.
- **`tejeduria_rollos`:** `id`, `fecha`, `fechaProd`, `turno`, `operador`, `maquina`, `tela`, `lote`, `rollos[]`, `total`, `count`, `captureSource` (`manual`|`scale`|`bulk_excel_estadistica`|`historial-import`), `scaleModel`, `ts` (texto ISO), `updatedAt`, `createdBy`, `updatedBy`.
- **`plan_dia` items:** `id`, `tela`, `color`, `lote`, `kg`, `rend`, `vel`, `proceso`; doc con `fecha`, `updatedAt`, `updatedBy`, `auth`.
- **`historial`:** `id`, `ts`, `user`, `module`, `action`, `machine`, `lote`, `detail`.
- Todo documento subido lleva `auth` (§8).

## 7. Cómo llegan los datos ("data drops")

Históricamente (según el historial de Perplexity):
- **Fotos de formatos de papel → transcripción.** Lotes de ~6–10 fotos (WhatsApp/Drive); primero se mostraban dudas/banderas, luego JSON o script de import. IDs determinísticos (sha1) para que re-correr no duplique; filas dudosas con `_review` en notas; fotos re-enviadas se deduplicaban por MD5.
  - Mar 2026 tintorería (~42 fotos) · Ene–Feb tintorería + T. muertos (49) · Producto Terminado/Rama ene–abr (126, `_batch:N`) · Abril tintorería + Rama (73 fotos, "batch 12").
  - Estas quedaron **embebidas en el HTML** (`RAW`, `FICHAS_RAW`, `PT_ROWS`, `PT_ROWS_RAW`, `TELAS_SEED_2026_05_25`) con auto-importadores de una sola vez por dispositivo (banderas `tg_tint_import_mar2026_v2`, `…_janfeb2026_v2`, `…_pt2026_v2`, `…_apr2026_v1`; `importBatch` `IMPORT_MAR2026_BATCH_n`, etc.). Escriben **solo a localStorage**.
  - Rama Bruckner ene–may (1,628 lotes, rehecho 2–3 jun) y Rama 2–18 jun: se subieron **directo a Firestore** `bruckner` (no están en el repo). Mayo tiene ~44% marcado para revisión.
  - Tejeduría (3 hojas, ago 21): página de revisión → "Enviar a Firebase".
- **Excel de Roger** `PRODUCCION-DIARIO.xlsx` (162 días): semilla de conciliación embebida; re-importable por CSV.
- **Estadística:** los .xlsx mensuales con contraseña (ENERO…JULIO 2026) se convirtieron a `data/estadistica-backfill-2026.json` (`version`, `generatedAt`, `source`, `stats` {files 7, days 190, rows 4709}, `overrides` con claves `"YYYY-MM-DD::<lote>"` → `tela`, `color`, `pedido`, `linea`, `turno`, `cb`, `rev`, `pla`, `com`, `monforts`, `bru`, `prog`, `aprev`; y `::_import`, `::_footer` {`calA`, `calB`, `firma`, `ejercicio`, `notas`}, `::_lotes`). Lo aplica `_estAutoBackfillOnce()` una vez por dispositivo (`tg_tint_estadi_backfill_v` ≥ `_EST_BACKFILL_VERSION = 1`) sin pisar overrides manuales.
- **Importadores en la UI:** Estadística (xlsx múltiple), Plan del día Rama y Compactadora (Excel), Tejeduría (Excel + pegado con resolución de alias), Compactadora (Excel). Exports Excel en varias pestañas.
- **Reglas para un drop nuevo:** mostrar primero lo que se va a cargar y las dudas; IDs determinísticos; marcar dudosos con `_review`; no pisar datos existentes; bandera nueva versionada; escribir a Firestore solo con GO explícito de Koke. No hay exportaciones de Sicar en el historial.

## 8. Autenticación / acceso (sin secretos)

1. **Cortina StatiCrypt** (prod desde v15, 17 ago): contraseña global; "Recordar 30 días" marcado por defecto (v24).
2. **Candado del equipo** en la app: SHA-256 de la contraseña contra `PW_HASH`; 5 intentos → bloqueo 5 min (`tg_tint_auth_attempts_v1`, `tg_tint_auth_locked_until_v1`); luego se elige/teclea el colaborador (`tg_tint_user_session`, `tg_tint_empleado_id`); sesión en `tg_tint_auth_v1`; revalidación cada 12 h.
3. **Firestore:** sin Firebase Auth. Cada documento lleva `auth: FB_AUTH_TOKEN` (igual al hash del candado). Según el historial, las reglas (pegadas a mano en la consola de Firebase, no en el repo) usan `tokenOK()` para create/update, `readableDoc()` para read/delete y niegan todo lo demás. Perplexity lo describió como "buena cerca, no bóveda".

- `firebaseConfig` (con `apiKey` web) y el hash están en `src/dashboard.html` (y cifrados en `index.html`). **No copiarlos** a otros archivos, docs, commits ni mensajes.
- Errores de sync/banner rojo tras agregar una colección nueva = casi siempre falta la regla en la consola; se arregla pegando las reglas completas (con aprobación de Koke).

## 9. Diseño / look

- Paleta `ink` (`950 #07090d` … `600 #253149`), `theme-color #07090d`, tipografía de sistema (-apple-system).
- "Apple-quiet industrial": retícula 8 px, hairlines, radios 10–16 px (`--tg-radius-*`), transiciones 150–200 ms sin rebote ni glow.
- Acento de marca **rojo TGM `#FF2E4D`** (`--tg-accent`, v25); **verde `#22c55e` = OK** (los chips de estado no se vuelven rojos); ámbar = advertencia; `#ef4444` = crítico.
- Liquid Glass (v22) **solo** en superficies flotantes (header, dock, popover Más, modales); las tarjetas KPI son sólidas.
- Ambiente (v20–21): Día / Noche / Auto (America/Mexico_City, 6:00–17:59 = Día) + tinte de estación; solo local (`tgm.ambience.*`), nunca Firebase.
- ⚠️ *Historial vs código:* el historial habla de "un solo acento verde de planta"; desde v25 el acento de chrome es rojo TGM y el verde quedó para estados OK.

## 10. Cambios típicos y cómo hacerlos

Historial de autores: v9–v24 (ago 8 – sep 2) commits directos a `main` con autor git `koke` (Perplexity Computer); ago 4–6 "Mirror encrypted desde TINTORERIA-TGM-STATICRYPT"; desde 12 sep PRs #2–#6 de `coquegaytan-tech0314` (Cursor) + commit de re-cifrado de "Cursor Agent".

Pedidos recurrentes: "mándame el link" (siempre la URL de §2); confusión de caché; errores de sync por reglas; diferencias contra papel/Excel (lotes duplicados, Suavizado/Termofijado contados como terminado, definición de semana, frontera de Turno 3, tubulares como Rama, typos de tela); mover pestañas a "Más"; botones de import/export Excel por departamento; mensajes al equipo explicando novedades.

Procedimiento:
1. Leer la zona relevante de `src/dashboard.html` antes de tocar (buscar por `id`, `data-tab`, nombre de función).
2. Diff pequeño y reversible solo en `src/dashboard.html`; respetar la lista CONGELADA (§0) y los nombres existentes (campos, colecciones, `LS_KEYS`, `data-tab`).
3. Si el piso lo va a notar: entrada nueva en `CHANGELOG` de `TG_WHATSNEW` (en español) y subir `CURRENT_VERSION`.
4. Rama + PR; esperar GO de Koke. Nada de push directo a `main`.
5. Tras el merge: re-cifrar (Koke da la contraseña por entorno) y verificar la URL en vivo.

## 11. NUNCA

- Reconstruir o reescribir el tablero; tocar lo CONGELADO sin GO explícito.
- Poner HTML sin cifrar en `index.html`; quitar cualquiera de los dos candados.
- Tocar reglas de Firebase, auth, Pages/Actions, secretos o `.staticrypt.json` sin aprobación.
- Renombrar campos, colecciones o claves de `localStorage`.
- Escribir/borrar datos de producción en Firestore por cuenta propia (borrador hasta GO).
- Commitear o imprimir contraseñas, hashes, sales, `apiKey` en archivos nuevos, `.env` o datos personales (tampoco en mensajes de commit).
- Inventar datos; tratar los históricos embebidos como "hoy".
- Usar modo claro, botones < 44 px, textos en inglés en la UI, "Empleado", o el look BVG/ALORA.
- Usar `git reset --hard` / `push -f` (receta de emergencia) sin aprobación.

## 12. Hallazgos y riesgos (del código, 2026-09-29)

1. **La cortina StatiCrypt se puede saltar:** el repo es público y Pages sirve `…/src/dashboard.html` (200) y `…/data/estadistica-backfill-2026.json` (200). El historial git público también tiene `index.html` plano (tag `backup-pre-staticrypt-2026-08-02`, commits v9–v14). Propuesta aparte: `security-fix-proposal.md`.
2. El hash del candado = token `auth` de Firestore y está en código público → las reglas "de cerca" no protegen contra quien lea el repo.
3. El repo gemelo `TINTORERIA-TGM-STATICRYPT` sigue público y en línea con un `index.html` cifrado viejo (mismo tamaño que el de v15, 17 ago), que probablemente apunta a la misma Firestore, y también publica el JSON de backfill.
4. **`forceResync` borra datos que solo viven en el dispositivo:**
   - `tg_tint_estadi_v1` (ediciones manuales de Estadística), `tg_tint_ramadown_v2` (paros de rama), `tg_tint_metas_v2`, `tg_tint_cfg_rama_v1`, `tg_tint_role` (no coincide con el patrón `tg_role`) y las banderas de import/backfill.
   - Se dispara con "Sincronizar", al tocar el chip, en el auto-refresh de cada 5 min y en el watchdog → las ediciones manuales de Estadística probablemente se pierden y el rol vuelve a Supervisor.
   - Los auto-importadores y el backfill se re-aplican en cada recarga.
   - (Lectura de código; no probado en tablet.)
5. PR **#1** (abierto, 22 ago) = arreglos "Roger montaje/suavizado", **congelado** por Koke; edita el `index.html` descifrado del flujo viejo, así que habría que rehacerlo sobre `src/dashboard.html`. La parte de Monforts ya la cubrió PR #6; el aviso "no se registró en la nube" y el Total Terminado sin Suavizado no están en el código actual.
6. `_resumenComputeBruck` (Resumen del día) solo suma `rama === 'Bruckner'`, aunque Monforts ya es la rama por defecto.
7. `tejeduria_rollos.ts` es texto ISO y `mergeById` compara `+ts` (= 0) → en Tejeduría la nube siempre gana al sincronizar.
8. `estadistica_imports` y `telas_solicitudes` nunca llegan a Firestore; `avisos` se descarga pero no hay pantalla que lo muestre.
9. Safari iPad: `QuotaExceededError` de `localStorage` (~5 MB) visto en may y jul; la limpieza prometida no quedó clara.

## 13. Pendientes / diferidos (del historial; no empezar sin GO)

1. Chat v23: mensajes directos a un colaborador (campo `to`), saltos de línea, notificaciones más inteligentes.
2. Arreglos "Roger montaje/suavizado" (PR #1) — congelado.
3. Báscula Fase 2: indicador Presicell DWI-110 (también llamado TI-1500) por Web Serial 9600 8N1; el puerto abre y se envía "P" pero **no regresan bytes** (17–21 ago). Sospechas: configuración A3/A6 no guardada, switch trasero en modo setup, línea RX del cable. Estado "parked".
4. Módulo cartón "Control de Procesos" (receta de teñido) y ligar el lote crudo de Tejeduría con Teñido: no se ha hecho.
5. Pestañas de tejido y almacén de crudo (Koke quiere cubrir toda la fábrica).
6. Reglas de Firestore: confirmar que la consola incluya todas las colecciones que usa el código (`tejeduria_rollos`, `chat_typing`, `pronostico_dia`…); errores viejos de permisos en "pronostico" se dejaron para después.
7. Limpieza de cuota de `localStorage` en Safari.
8. Retirar el repo/URL gemelo `TINTORERIA-TGM-STATICRYPT`.
9. Catálogo de telas: composiciones exactas (p. ej. Piqué Olmo es Pol/Alg), faltan mallas, columnas/cm, estabilidad.
10. Quién puede dar de alta telas rápido (`canAltaTelaRapida`, opciones A/B/C): nunca se respondió.
11. Definición de semana (§5).
12. Calidad de datos: muchas filas `_review` en Rama feb/may y dudas de transcripción de Tejeduría.

## 14. Preguntas abiertas — PENDIENTE confirmar con Koke

1. **Seguridad:** ¿qué opción de `security-fix-proposal.md` aplicamos? ¿Rotamos las contraseñas de cortina y candado (el hash y el texto plano viejo están en historial público)?
2. **`forceResync`:** ¿se han perdido ediciones de Estadística o el rol Jefe en las tablets? ¿Autorizas un arreglo mínimo (agregar las claves locales a la lista de "no borrar")?
3. **Semana:** ¿cuál es la oficial para reportes, Lun–Sáb (Excel de Roger) o Lun–Dom (resumen del jefe / Preguntar al día)? ¿El domingo suma al total semanal?
4. **Reglas de Firestore:** ¿las reglas en la consola incluyen `tejeduria_rollos`, `chat_typing` y `pronostico_dia`? ¿`estadistica_imports` debe escribir de verdad?
5. **Roger montaje/suavizado (PR #1):** ¿sigue congelado? Cuando haya GO, ¿se rehace sobre `src/dashboard.html`, y el Resumen del día debe incluir Monforts?
6. **Este archivo:** ¿reemplaza al `AI_CONTEXT.md` en inglés del repo? Como Koke pide respuestas en inglés, ¿lo quieres en inglés, en español o bilingüe?
