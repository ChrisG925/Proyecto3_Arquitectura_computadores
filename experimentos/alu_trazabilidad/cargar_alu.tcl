set pdk $::env(PDK_ROOT)
set base "$pdk/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0"

read_lef "$base/techlef/gf180mcu_fd_sc_mcu7t5v0__nom.tlef"
read_lef "$base/lef/gf180mcu_fd_sc_mcu7t5v0.lef"



read_verilog experimentos/alu_trazabilidad/asic_top_flat.v
link_design asic_top

set block [ord::get_db_block]
set total 0
set alu 0

foreach inst [$block getInsts] {
    incr total
    if {[string first "u_alu" [$inst getName]] >= 0} {
        incr alu
    }
}

puts "===== RESULTADO ====="
puts "Instancias totales: $total"
puts "Instancias ALU: $alu"
