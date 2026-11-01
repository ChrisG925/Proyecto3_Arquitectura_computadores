#!/usr/bin/env python3

import os
import re
from pathlib import Path

pdk_lib = os.environ.get("PDK_LIB")

if not pdk_lib:
    raise SystemExit("ERROR: Debes configurar PDK_LIB.")

origen = Path(pdk_lib) / "gf180mcu_fd_sc_mcu7t5v0.v"
destino = Path("sim/gf180_cells_functional.v")

if not origen.is_file():
    raise SystemExit(f"ERROR: No existe {origen}")

texto = origen.read_text()
patron = r"\bspecify\b.*?\bendspecify\b"

resultado, cantidad = re.subn(patron, "", texto, flags=re.S)

destino.parent.mkdir(parents=True, exist_ok=True)
destino.write_text(resultado)

print(f"Bloques specify eliminados: {cantidad}")
print(f"Archivo generado: {destino}")
