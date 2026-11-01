read_db librelane/runs/fisico_rom_util60/final/odb/asic_top.odb

set block [ord::get_db_block]
set encontrados 0

for {set i 17057} {$i <= 17544} {incr i} {
    set nombre "_${i}_"
    set inst [$block findInst $nombre]

    if {$inst ne "NULL"} {
        gui::highlight_inst $nombre 0
        incr encontrados
    }
}

puts "Flip-flops resaltados: $encontrados de 488"
