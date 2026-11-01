#!/usr/bin/env bash
set -euo pipefail

mkdir -p experimentos/alu_trazabilidad

yosys -Q -T -p '
read_json librelane/runs/sintesis_hierarchy/06-yosys-synthesis/asic_top.nl.v.json
hierarchy -top asic_top
flatten -noscopeinfo -scopename
select -module asic_top
write_json experimentos/alu_trazabilidad/asic_top_flat.json
write_verilog -norename -noattr experimentos/alu_trazabilidad/asic_top_flat.v
'

echo "Netlist auxiliar generado correctamente."
