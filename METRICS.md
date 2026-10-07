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
