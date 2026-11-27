# Georgi – Quinteros – Riveros | Proyecto 4

**Arquitectura de Computadores**  
**Universidad de los Andes — Facultad de Ingeniería y Ciencias Aplicadas**  
**Profesor:** Jorge Gómez Mir

**Integrantes**
- Christian Georgi
- Diego Quinteros
- Felipe Riveros

## Descripción del proyecto

**Pochoco Trader** es un agente de inversión implementado en el procesador **Espino Core (RV32E)** del sistema **Pochoco SoC**, destinado a la FPGA **Lattice iCE40 HX1K** de la **Nandland Go Board**. Recibe precios de 8 bits desde una FPGA maestra mediante **SPI modo 0** y deja preparada una decisión de compra, venta o mantener para la **siguiente** transacción.

La estrategia utiliza ventanas móviles de **16 y 64 precios**, detección de tendencias, confirmación temporal, filtros de entrada, límites de pérdida y un registro estimado del efectivo disponible. Se desarrollaron y evaluaron tres implementaciones con el mismo comportamiento externo:

| Versión | Implementación | Rama Git |
|---|---|---|
| **SW** | Comparaciones ejecutadas por instrucciones RV32E, sin acelerador de trading | `exp/software-base` |
| **HW1** | Comparador de umbrales mediante registros MMIO | `aceleracion1_comparador` |
| **HW2** | Clasificador de tendencias mediante registros MMIO | `exp/aceleracion2` |

Los aceleradores HW1 y HW2 son **alternativas separadas**: comparten direcciones MMIO, pero **no están incorporados simultáneamente** en el mismo bitstream. La versión principal empleada para las pruebas del comparador es HW1.

## Arquitectura y comunicación SPI

El procesador Espino trabaja a **25 MHz** y dispone de 16 registros de 32 bits. El SoC utiliza una RAM unificada de **512 palabras × 32 bits (2 KiB)**, en la que se alojan el programa Assembly, los historiales y las variables del agente.

La FPGA maestra envía un precio por **MOSI** y recibe la decisión previa por **MISO**. El esclavo SPI utiliza también **SCLK** y **CS_n**; los datos se transmiten empezando por el bit más significativo. Al recibir un nuevo precio, Espino actualiza el algoritmo y escribe la siguiente orden en el registro `DECISION`.

### Direcciones MMIO

| Dirección | Recurso | Descripción |
|---|---|---|
| `0x80010000` | `STATUS` | Estado de recepción SPI |
| `0x80010004` | `PRICE` | Precio recibido |
| `0x80010008` | `DECISION` | Orden preparada para MISO |
| `0x8000000C` | Contador de ciclos | Contador libre de 32 bits |
| `0x80000010` | HW1: `S64` / HW2: `S16` | Primer operando del acelerador |
| `0x80000014` | HW1: precio / HW2: `S64` | Segundo operando y activación del cálculo |
| `0x80000018` | Resultado HW1/HW2 | Banderas de comparación o estado de tendencia |

**Formato de orden (8 bits):** bits `[7:6]` identifican la operación (`00` = mantener, `01` = comprar, `10` = vender); bits `[5:0]` representan la cantidad de acciones. El agente utiliza órdenes de 8 o 16 acciones.

## Algoritmo de inversión

Las sumas móviles se actualizan sin recorrer todas las muestras:

\[
S_{L,n}=S_{L,n-1}-p_{n-L}+p_n,\qquad L\in\{16,64\}.
\]

La tendencia se obtiene del indicador `T = 4*S16 - S64`:

- **Alcista:** `T >= 384`.
- **Bajista:** `T <= -384`.
- **Lateral:** valores intermedios.

La clasificación se confirma tras ocho ticks consecutivos. Para determinadas compras se utiliza además una señal de recuperación de tres unidades. En mercado lateral se comprueba `S64 >= 64*(precio + 8)`. Durante posiciones abiertas se aplican reglas de *stop-loss*, *trailing stop* y objetivo de ganancia. El programa mantiene una estimación de efectivo porque el protocolo no confirma explícitamente las operaciones ejecutadas por la maestra.

## Archivos principales

La organización puede variar entre ramas; las rutas siguientes corresponden al proyecto de trabajo utilizado en la validación.

| Archivo o carpeta | Función |
|---|---|
| `rtl/pochoco_soc.v` | Integración del núcleo, la memoria, SPI y MMIO |
| `rtl/pochoco_periph.v` | Contador de ciclos y acelerador específico de cada versión |
| `rtl/pochoco_spi_slave.v` | Recepción del precio y transmisión de decisiones por SPI |
| `rtl/espino_core/` | Procesador RV32E y sus unidades internas |
| `sw/trade.s` | Agente de inversión en Assembly |
| `sw/trade.hex` | Instrucciones ensambladas para cargar en memoria |
| `sw/assembler.py` | Ensamblador utilizado por el proyecto |
| `tb/tb_proyecto_4.sv` | Prueba corta de 2.000 ticks |
| `tb/tb_proyecto_4_test.sv` | Prueba completa de 20.000 ticks |
| `tb/practica.csv` | Serie de precios utilizada por el testbench (no siempre versionada) |
| `decisiones.csv` | Resultado económico por tick generado en simulación |
| `metricas_por_tick.csv` | Perfil de instrucciones y ciclos por tick, cuando se usa el testbench instrumentado |
| `Makefile` | Automatización de ensamblado y flujo FPGA |
| `final/` | Copias de bitstreams conservadas para trazabilidad, cuando están disponibles |

El modelo independiente se entrega como material complementario en `Proyecto4_Validacion_Independiente.zip`, con `validacion_independiente.py`, `practica.csv`, `decisiones.csv` y `decisiones_python_independiente.csv`. Para incorporarlo al repositorio, se recomienda ubicar los archivos en `validacion/`.

## Requisitos

- Git y Python 3.
- Linux, o Windows con **WSL**.
- **Icarus Verilog**: `iverilog` y `vvp`.
- **GNU Make**.
- **Yosys**, **nextpnr-ice40** y **icepack** para sintetizar y generar el bitstream.
- **iceprog** y una Nandland Go Board conectada, únicamente para programación física.
- **GTKWave** (opcional) para observar señales.

Verificar las herramientas disponibles:

```bash
python3 --version
iverilog -V
yosys -V
nextpnr-ice40 --version
make --version
```

## Descargar el proyecto

```bash
git clone https://github.com/ChrisG925/Proyecto4_Arquitectura_computadores.git
cd Proyecto4_Arquitectura_computadores
```

**Importante:** las ramas experimentales deben existir en el repositorio que se clone. Si todavía son locales, es necesario publicarlas antes de que otra persona pueda reproducir las tres variantes. La serie `tb/practica.csv` también debe estar disponible, ya que en el entorno de desarrollo se copió manualmente al crear nuevos worktrees.

Para inspeccionar las ramas:

```bash
git branch -a
```

No ejecutar `git checkout` en un árbol con cambios no guardados. Para comparar versiones sin alterar el original, se recomienda usar `git worktree`.

## Preparación del programa Assembly

Desde la raíz de **la versión elegida**:

```bash
python3 sw/assembler.py sw/trade.s sw/trade.hex
```

Es importante verificar que `sw/trade.hex` corresponde al `trade.s` de **esa misma rama**. No reutilizar el HEX de otra implementación: los accesos MMIO y las posiciones de instrucciones pueden ser diferentes.

## Simulación RTL

Los dos testbenches utilizan el mismo nombre de módulo superior, `tb_proyecto_4`; por tanto, **se compilan por separado**, nunca en un mismo comando.

Comprobar que existe el archivo `tb/practica.csv`, generar el HEX y ejecutar la prueba corta:

```bash
python3 sw/assembler.py sw/trade.s sw/trade.hex
mkdir -p build_trader

iverilog -g2012 -s tb_proyecto_4 \
  -o build_trader/tb_2000.vvp \
  tb/tb_proyecto_4.sv \
  rtl/*.v rtl/espino_core/*.v \
  /usr/share/yosys/ice40/cells_sim.v

vvp build_trader/tb_2000.vvp
```

Para la prueba completa de 20.000 precios:

```bash
iverilog -g2012 -s tb_proyecto_4 \
  -o build_trader/tb_20000.vvp \
  tb/tb_proyecto_4_test.sv \
  rtl/*.v rtl/espino_core/*.v \
  /usr/share/yosys/ice40/cells_sim.v

vvp build_trader/tb_20000.vvp
```

La ruta `/usr/share/yosys/ice40/cells_sim.v` corresponde al entorno Linux utilizado; si la instalación de Yosys emplea otra ubicación, se debe ajustar. Los archivos `decisiones.csv` se generan en el directorio desde el que se ejecute `vvp`.

**Resultados obtenidos:** prueba corta `7/7 PASS`; prueba completa `8/8 PASS`, 20.000 precios y decisiones, cero errores MISO, cuatro operaciones y patrimonio final de 9.908 unidades. Estos son resultados de **simulación RTL**, no una nueva comprobación con la FPGA maestra física.

### Corrección de temporización SPI

Se reprodujo un fallo del primer bit de MISO cuando el intervalo entre la activación de `CS_n` y el primer flanco de `SCLK` era de 80 ns: dos ventas se recibían como órdenes de mantener. Se corrigió la selección del primer bit desde el registro de transmisión y la prueba pasó de `6/8` a `8/8` verificaciones. La corrección está comprobada en simulación; falta una nueva prueba física con la maestra externa.

## Comparación de las tres versiones

Para utilizar árboles de trabajo independientes, partiendo de un clon que contenga las ramas correspondientes:

```bash
git worktree add ../Proyecto4_sw exp/software-base
git worktree add ../Proyecto4_hw1 aceleracion1_comparador
git worktree add ../Proyecto4_hw2 exp/aceleracion2
```

En cada carpeta, colocar la **misma** serie `tb/practica.csv`, generar `sw/trade.hex` y ejecutar el testbench completo con los comandos anteriores. Conservar los `decisiones.csv` fuera de esas carpetas o con nombres distintos para no sobrescribirlos.

La comparación realizada cotejó las seis columnas `tick`, `precio`, `decision`, `caja`, `acciones` y `patrimonio`: **20.000 filas idénticas entre SW, HW1 y HW2**, sin diferencias registradas.

### Recursos y rendimiento

| Métrica | SW | HW1: comparador | HW2: clasificador |
|---|---:|---:|---:|
| Instrucciones estáticas | 208 | 206 | 209 |
| LC utilizadas (de 1.280) | 1.212 | 1.271 | 1.271 |
| BRAM utilizadas (de 16) | 12 | 12 | 12 |
| Fmáx post-ruteo | 44,39 MHz | 42,56 MHz | 44,28 MHz |
| IC promedio/tick | 67,7220 | 64,8796 | 65,8504 |
| Ciclos promedio/tick | 158,6019 | 153,8740 | 156,8264 |
| CPI global | 2,3420 | 2,3717 | 2,3816 |
| Ciclos máximos/tick | 319 | 320 | 325 |
| Speedup frente a SW | 1,000000× | **1,030726×** | 1,011321× |

Los tiempos se evaluaron a **25 MHz**. HW1 reduce los ciclos promedio respecto de SW un **2,981 %** y HW2 un **1,1194 %**. Las dos aceleraciones cumplen el objetivo de frecuencia y los recursos de la iCE40 HX1K, aunque dejan poco margen de celdas lógicas libres.

Los valores de IC y ciclos corresponden a la fase desde la recepción completa del precio SPI hasta la escritura MMIO de `DECISION`; **no incluyen** el tiempo de espera entre ticks ni toda la transferencia SPI.

## Validación independiente en Python

Además de la equivalencia entre las tres variantes RTL, se desarrolló un modelo conductual independiente en Python. No interpreta las instrucciones Assembly ni copia sus decisiones: reproduce la estrategia y la ejecución de órdenes de la maestra, y compara cada registro con el CSV de referencia.

Descomprimir `Proyecto4_Validacion_Independiente.zip` y ejecutar **desde la carpeta que contiene** los archivos:

```bash
python3 validacion_independiente.py
```

El script espera en la misma carpeta `practica.csv` y `decisiones.csv`, genera `decisiones_python_independiente.csv` y compara los campos `tick`, `precio`, `decision`, `caja`, `acciones` y `patrimonio`.

**Resultado comprobado del paquete de validación:** `PASS`, **20.000 coincidencias y cero diferencias**; patrimonio final 9.908 y cuatro órdenes ejecutadas.

**Precaución sobre los datos:** durante el desarrollo se utilizaron archivos distintos con el mismo nombre `practica.csv`. El CSV del **paquete de validación Python** comienza en **165** y termina en **160**. No mezclar su comparación financiera con la de otra serie que comienza en 151 y termina en 98. Si se cambia el conjunto de entrada, deben volver a generarse y contrastarse los resultados correspondientes.

## Comparación económica

Sobre la serie incluida en el paquete de validación Python, con capital inicial de 10.000 y comisión de 5 unidades por operación:

| Estrategia | Patrimonio final | Caída máxima absoluta |
|---|---:|---:|
| No operar | 10.000 | 0 |
| Comprar y mantener | 9.695 | 9.300 |
| Algoritmo adaptativo | 9.908 | 130 |

La referencia comprar y mantener supone una compra inmediata de la mayor cantidad asequible de acciones y conservación hasta el último precio. El protocolo SPI real ejecuta órdenes con un tick de desfase, por lo que esa referencia es una **convención financiera analítica** y no una simulación de una orden SPI diferida.

## Amdahl, Ops/s y roofline

A partir del perfilado RTL de la variante SW, las regiones de comparación lateral y clasificación representaron respectivamente **10,7970 %** y **10,6522 %** de los ciclos de procesamiento. Estas fracciones corresponden a rangos de PC e incluyen instrucciones de control.

Para la ley de Amdahl, el límite ideal al acelerar infinitamente cada región es aproximadamente **1,1210×** para HW1 y **1,1192×** para HW2. Las mediciones globales fueron **1,030726×** y **1,011321×**. Un escenario con aceleración local supuesta `s = 2` es una **estimación analítica**, no una medición experimental del periférico.

Definiendo una operación útil del agente como **procesar un precio y preparar su decisión**, la capacidad equivalente de cálculo a 25 MHz es aproximadamente:

| Versión | Decisiones/s equivalentes |
|---|---:|
| SW | 157.627 |
| HW1 | 162.471 |
| HW2 | 159.412 |

Estos valores excluyen el tiempo SPI y las esperas entre transacciones; **no representan el caudal observado de la maestra**. El informe incluye un análisis roofline del kernel de actualización de ventana basado en operaciones y tráfico mínimo estimado, pero **no dispone de una medición independiente del ancho de banda RAM sostenido**. Por ello no debe describirse como un roofline experimental validado.

## Síntesis y generación de bitstream

En el flujo del proyecto se utiliza la tarea:

```bash
make trade
```

Antes de ejecutarla, revisar el `Makefile` de la rama activa y confirmar que selecciona **Pochoco Trader**, el firmware `sw/trade.hex` y el archivo de restricciones de la Go Board. Para consultar las tareas presentes:

```bash
make help
# Si no existe el objetivo help:
make -n trade
```

El flujo FPGA utiliza **Yosys**, **nextpnr-ice40** e **icepack**. Los resultados de síntesis y frecuencia indicados arriba corresponden al enrutamiento de las tres implementaciones. El archivo de salida del flujo de trading puede encontrarse en `build_trader/`, mientras que las revisiones preservadas pueden almacenarse en `final/`.

**Atención:** no suponer que `make all` programa el trader: en versiones heredadas del repositorio esta tarea puede referirse al juego anterior. No ejecutar programación física (`iceprog` u otro objetivo que la invoque) sin verificar antes el bitstream y tener la Go Board conectada.

## Integración física y limitaciones

La versión HW1 con SPI corregido cerró temporización a 25 MHz. No obstante, la prueba física observada durante la competencia no entregó una confirmación completa de las órdenes, y la corrección del primer bit MISO se verificó después mediante **simulación RTL**, sin repetir la prueba con la FPGA maestra del profesor.

La contabilidad que estima Espino supone que las órdenes se ejecutan como fueron solicitadas. Si la maestra rechaza, reduce o ejecuta parcialmente una orden sin confirmarlo, la estimación local puede diferir de la cartera real.

## Archivos generados y reproducción completa

Los archivos VVP, registros de simulación, CSV de decisiones, trazas de perfilado y salidas de síntesis se generan localmente y pueden estar excluidos por `.gitignore`. Antes de entregar el repositorio, comprobar qué evidencias quedaron versionadas y conservar una copia de los artefactos relevantes.

Secuencia recomendada para reproducir el Proyecto 4:

1. Instalar las herramientas y clonar el repositorio.
2. Obtener las ramas `exp/software-base`, `aceleracion1_comparador` y `exp/aceleracion2`.
3. Disponer del `practica.csv` correcto y mantenerlo idéntico para las tres variantes.
4. Ensamblar `trade.s` dentro de cada rama.
5. Ejecutar por separado los bancos RTL de 2.000 y 20.000 ticks.
6. Comparar los registros `decisiones.csv` y consultar los perfiles de ciclos e instrucciones.
7. Ejecutar la validación Python desde el paquete de evidencia correspondiente a la misma serie.
8. Sintetizar y enrutar cada variante, conservando métricas LC, BRAM y Fmáx.
9. Revisar los resultados económicos, Amdahl y roofline en el informe técnico.

**Este README documenta la organización y reproducción del proyecto.** Los fundamentos, tablas detalladas, fórmulas, evidencias y limitaciones se desarrollan en el informe del Proyecto 4.
