read_db experimentos/alu_trazabilidad/asic_top_alu_placed.odb

set block [ord::get_db_block]
set encontradas 0
set colocadas 0

foreach inst [$block getInsts] {
    set nombre [$inst getName]

    if {[string first "u_alu" $nombre] >= 0} {
        incr encontradas

        if {[$inst isPlaced]} {
            gui::highlight_inst $nombre 0
            incr colocadas
        }
    }
}

puts "===== ALU EN OPENROAD ====="
puts "Celdas identificadas: $encontradas de 589"
puts "Celdas resaltadas y colocadas: $colocadas de 589"
