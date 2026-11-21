# Métricas TGM

Definiciones que el código de `src/dashboard.html` ya calcula. La hora de la semana de producción es **America/Mexico_City** (UTC−6, sin horario de verano).

## Semana de producción

Lunes **00:00** a sábado **23:59**, tres turnos. El domingo es mantenimiento y normalmente no hay producción. Si hay registros de domingo, se atribuyen a la semana lun–sáb que acaba de terminar (el domingo es el día siguiente a ese sábado).

- **Semana pasada** = el lun–sáb ya cerrado más reciente, más ese domingo. De lunes a sábado la semana en curso no entra. Si hoy es domingo, esa semana ya cerró e incluye el domingo de hoy.
- El texto del resumen lo dice así: `Semana lun 28 sep – sáb 3 oct (incluye domingo si hubo producción)`, y cuenta los registros del rango.
- Misma regla en Preguntar al día, el resumen al jefe, el reporte semanal, «Esta semana» del reporte, Eficiencia y Tiempos muertos cuando el rango es la semana, y el chip semanal de Estadística.
- «Últimos 7 días» del filtro de Eficiencia sigue siendo siete días corridos. En Preguntar al día, esa frase pide la semana cerrada, no siete días corridos.

## Turnos

`_estClassifyTurno`: 1° de 06:00 a 14:00, 2° de 14:00 a 22:00, 3° el resto (22:00 a 06:00).

## Día de producción

`_prodDayForRecord` (el turno capturado manda):

- Antes de las 06:00 el registro pertenece al día anterior.
- Turno 3° capturado antes de las 14:00 pertenece al día anterior.

## Terminado (resumen al jefe y reporte semanal)

`_resumenComputeBruck` solo suma Bruckner (`rama` vacía o `Bruckner`). Monforts no entra en esa suma.

- **Bruto:** kilos del campo `kilos`, por proceso (`suav`, `termo`, `empac`; si el texto trae suavizado y termofijado, el kilo se parte a la mitad).
- **Neto:** el bruto menos los pases con `motivoPase` de reproceso (`mod_ancho`, `reproceso_calidad`, `reproceso_otro`, `reproceso_desconocido`). Vacío o `nuevo` sí cuenta.
- **Terminado del día** en el reporte semanal: `empacadoNeto + otrosNeto`. Suavizado y termofijado son etapa intermedia y no entran en esa cifra.
- **Compactadora** (`_resumenComputeComp`): solo filas cuyo `proceso` contiene «empac».
- **Total del mensaje al jefe:** terminado neto de Rama + esa compactadora.

## Eficiencia del reporte semanal

Si el pronóstico del día es mayor que 0: `terminado neto / pronóstico × 100`. Si no hay pronóstico, la eficiencia de ese día es 0.

## Desempeño de una ficha

`calcDesempeno`: `kilos reales / carga esperada de esa máquina y proceso × 100`, redondeado. Puede pasar de 100.

## Semáforo de proceso (fichas abiertas)

Solo lectura, en la tarjeta de cada ficha con `estado === 'abierta'` (vista normal y vista nueva). No escribe Firestore, no agrega campos y no cambia `PROCESOS_CATALOGO`, `minutosProceso()`, `tiempoPlanMin` ni el semáforo de antigüedad (2 h / 6 h).

La tabla editable es `TIEMPOS_ESTANDAR` en `src/dashboard.html`:

| Clave | Etiqueta | Horas |
| --- | --- | --- |
| `blanqueo_pol_alg` | Blanqueo Pol-Alg | 5 |
| `blanqueo_pol` | Blanqueo Poliéster | 5.5 |
| `pol_claro` | Poliéster tono claro | 7 |
| `pol_oscuro` | Poliéster tono oscuro | 8 |
| `pol_alg_claro` | Pol-Alg tono claro | 11.5 |
| `pol_alg_oscuro` | Pol-Alg tono oscuro | 13 |
| `alg_claro` | Algodón 100% tono claro | 7 |
| `alg_oscuro` | Algodón 100% tono oscuro | 8 |
| `pol_lycra` | Poliéster lycra | 9 |
| `lavado_tela` | Lavado tela | 3 |
| `lavado_maquina` | Lavado máquina | 4 |

El texto en pantalla dice «Pol-Alg». El typo de papel `Pol-Aly` solo se lee como Pol-Alg; no se muestra.

Colores, sobre el tiempo desde `fecha` + `hEntrada` (la misma entrada que `fichaAging`, sin cambiar sus umbrales):

- Verde: menos del 80 % del estándar.
- Ámbar: del 80 % al 100 %, inclusive.
- Rojo: más del 100 %. El texto es «+1 h 20 m sobre estándar».
- El reloj cuenta minutos ya cumplidos (no redondea los segundos hacia arriba).
- Gris «Sin estándar»: no hubo una sola fila segura.
- Gris «Sin hora de entrada»: la fila sí está clara, pero falta `hEntrada` o `fecha`.

### Cómo se elige la fila

Se leen campos que la ficha ya guarda. No hay campo `fibra` ni `tono`. `motivoApertura` es por qué sigue abierta (reproceso, carros, laboratorio…); no elige el estándar. `diseno` es el diseño en la captura viva; no se usa como fibra. `tiempoPlanMin` es el cálculo viejo y no se lee.

1. `proceso`, normalizado (minúsculas, sin acento, `½` aparte). Si mezcla dos trabajos (descrude, ½, ¼, matiz, baño ciego, lavado junto con teñido o blanqueo), queda en «Sin estándar».
2. Lavado exacto: «lavado (de) máquina» → Lavado máquina. «lavado (de) tela(s)» → Lavado tela. «Lavado», «Lavado Felpas», «Lavado x manchas» y lo demás no entran.
3. Fibra y tono escritos en `proceso`:
   - `pol` / `poliéster` sin algodón → Poliéster. `pol` + `alg` / `algodón` (también el typo `aly`) → Pol-Alg. La palabra `algodón` sin poliéster → Algodón 100 %. `poliéster` + `lycra` / `elastano` → Poliéster lycra.
   - `blanco` o `blanqueo` / `bqueo` → blanqueo (Poliéster 5.5 h, Pol-Alg 5 h). `claro` → tono claro. `oscuro` / `obscuro` → tono oscuro. `medio` no tiene fila.
   - Los botones actuales caen aquí: «Teñido Pol + Algodón Oscuro/Claro/Blanco», «Poliéster Blanco», «Poliéster Obscuro», «Lavado de Máquina», «Lavado Telas».
4. Si `proceso` ya nombra una fila y la tela del catálogo (match exacto de `tela` contra `nombre`, composición en `composicion`) dice otra fibra, «Sin estándar». No se elige entre las dos. Si la tela no está en el catálogo, se respeta el proceso.
5. La tela solo completa un hueco: «Teñido» o «Blanqueo» sin fibra, o «Teñido pol» sin tono. Composición `Poliéster/Elastano` (sin algodón) en un teñido de poliéster → Poliéster lycra, porque esa fila no parte el tono. `Poliéster/Algodón` (aunque lleve elastano) es Pol-Alg y aún necesita claro u oscuro. `Algodón 100%` es algodón y aún necesita tono.
6. El tono que falta se toma de `color` solo si la palabra es `claro`, `oscuro` u `obscuro` («azul oscuro», «gris claro»). Negro, rojo, rosa o blanco en el color no se interpretan.

`Poliéster/Microfibra` y `Poliéster Multifilamento` cuentan como poliéster. Acrílico y nylon no tienen fila.
