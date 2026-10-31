
`timescale 1ns/1ps

module tb_unified_ram;

    reg clk = 0;
    reg rst_n = 0;

    wire load_we;
    wire [31:0] load_addr;
    wire [31:0] load_data;
    wire boot_done;

    wire [31:0] instr_rdata;

    integer i;
    integer errors;

    // Reloj de 10 MHz
    always #50 clk = ~clk;

    // Controlador de carga
    pochoco_boot_loader #(
        .NUM_INSTRUCTIONS(86)
    ) u_boot (
        .clk_i(clk),
        .rst_ni(rst_n),
        .load_we_o(load_we),
        .load_addr_o(load_addr),
        .load_data_o(load_data),
        .boot_done_o(boot_done)
    );

    // Memoria unificada
    pochoco_unified_ram #(
        .NumWords(128)
    ) u_ram (
        .clk_i(clk),

        .a_req_i(1'b0),
        .a_addr_i(32'b0),
        .a_rdata_o(instr_rdata),

        .b_req_i(1'b0),
        .b_we_i(1'b0),
        .b_be_i(4'b0000),
        .b_addr_i(32'b0),
        .b_wdata_i(32'b0),
        .b_rdata_o(),

        .load_we_i(load_we),
        .load_addr_i(load_addr),
        .load_data_i(load_data)
    );

    // ROM de referencia
    reg [31:0] check_addr;
    wire [31:0] expected_data;

    game_rom u_reference (
        .addr_i(check_addr),
        .data_o(expected_data)
    );

    initial begin
        errors = 0;
        check_addr = 0;

        $display("Inicio prueba memoria unificada");

        repeat (5) @(negedge clk);
        rst_n = 1;

        wait (boot_done == 1);
        @(negedge clk);

        // Comprobar las 86 instrucciones
        for (i = 0; i < 86; i = i + 1) begin
            check_addr = i * 4;
            #1;

            if (u_ram.mem[i] !== expected_data) begin
                $display(
                    "ERROR palabra %0d: RAM=%h ROM=%h",
                    i, u_ram.mem[i], expected_data
                );
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("TEST PASS: 86 instrucciones correctas");
        else
            $display("TEST FAIL: %0d errores", errors);

        $finish;
    end

endmodule
