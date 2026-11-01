read_db experimentos/alu_trazabilidad/asic_top_alu_placed.odb

set block [ord::get_db_block]
set total 0
set colocadas 0
set sin_colocar 0

foreach inst [$block getInsts] {
    set nombre [$inst getName]

    if {[string first "u_alu" $nombre] >= 0} {
        incr total

        if {[$inst isPlaced]} {
            incr colocadas
        } else {
            incr sin_colocar
        }
    }
}

puts "===== VERIFICACIÓN FÍSICA DE LA ALU ====="
puts "Celdas ALU encontradas: $total"
puts "Celdas ALU colocadas: $colocadas"
puts "Celdas ALU sin colocar: $sin_colocar"
