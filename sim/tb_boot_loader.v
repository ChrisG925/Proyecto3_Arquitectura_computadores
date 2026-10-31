
`timescale 1ns/1ps

module tb_boot_loader;

    reg clk;
    reg rst_n;

    wire load_we;
    wire [31:0] load_addr;
    wire [31:0] load_data;
    wire boot_done;

    integer count;

    // Controlador que vamos a probar
    pochoco_boot_loader #(
        .NUM_INSTRUCTIONS(86)
    ) dut (
        .clk_i(clk),
        .rst_ni(rst_n),
        .load_we_o(load_we),
        .load_addr_o(load_addr),
        .load_data_o(load_data),
        .boot_done_o(boot_done)
    );

    // Reloj de 10 MHz
    initial clk = 0;
    always #50 clk = ~clk;

    initial begin
        rst_n = 0;
        count = 0;

        $display("Inicio prueba Boot Loader");

        repeat (5) @(negedge clk);
        rst_n = 1;

        wait (boot_done == 1);

        @(negedge clk);

        $display("Carga finalizada");
        $display("Instrucciones cargadas: %0d", count);

        if (count == 86)
            $display("TEST PASS: 86 instrucciones cargadas");
        else
            $display("TEST FAIL: cantidad incorrecta");

        $finish;
    end

    // Contar escrituras y verificar direcciones
    always @(posedge clk) begin
        if (load_we) begin
            if (load_addr !== count * 4) begin
                $display("ERROR: direccion incorrecta");
                $finish;
            end

            count = count + 1;
        end
    end

endmodule
