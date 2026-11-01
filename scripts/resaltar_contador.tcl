read_db librelane/runs/fisico_rom_100ns_actualizado/final/odb/asic_top.odb

set block [ord::get_db_block]
set encontrados 0

for {set i 19748} {$i <= 19779} {incr i} {
    set nombre "_${i}_"
    set inst [$block findInst $nombre]

    if {$inst ne "NULL"} {
        gui::highlight_inst $nombre 0
        incr encontrados
    }
}

puts "Flip-flops del contador resaltados: $encontrados de 32"
