
`timescale 1ns/1ps

module tb_asic_unified;

    reg clk;
    reg rst_n;
    reg [3:0] switches;

    wire [3:0] leds;

    wire s1a, s1b, s1c, s1d, s1e, s1f, s1g;
    wire s2a, s2b, s2c, s2d, s2e, s2f, s2g;

    wire spi_miso;

    // Segunda arquitectura: memoria unificada
    pochoco_soc_unified #(
        .SIMULATION(1)
    ) dut (
        .i_Clk(clk),
        .i_Rst_n(rst_n),

        .i_Switch(switches),
        .o_LED(leds),

        .o_Segment1_A(s1a),
        .o_Segment1_B(s1b),
        .o_Segment1_C(s1c),
        .o_Segment1_D(s1d),
        .o_Segment1_E(s1e),
        .o_Segment1_F(s1f),
        .o_Segment1_G(s1g),

        .o_Segment2_A(s2a),
        .o_Segment2_B(s2b),
        .o_Segment2_C(s2c),
        .o_Segment2_D(s2d),
        .o_Segment2_E(s2e),
        .o_Segment2_F(s2f),
        .o_Segment2_G(s2g),

        .i_SPI_SCLK(1'b0),
        .i_SPI_MOSI(1'b0),
        .i_SPI_CS_n(1'b1),
        .o_SPI_MISO(spi_miso)
    );

    // Reloj de 10 MHz
    initial clk = 0;
    always #50 clk = ~clk;

    // Evitar que la simulacion quede bloqueada
    initial begin
        #100000000;
        $display("TEST FAIL: timeout de simulacion");
        $fatal(1);
    end

    initial begin
        rst_n = 0;
        switches = 4'b0000;

        $dumpfile("sim/asic_unified_wave.vcd");
        $dumpvars(0, tb_asic_unified);

        $display("Inicio simulacion memoria unificada");

        // Reset inicial
        repeat (5) @(negedge clk);
        rst_n = 1;

        $display("Reset liberado");

        // Esperar la carga de las 86 instrucciones
        wait (dut.boot_done === 1'b1);

        $display("Boot Loader finalizado");
        $display("Tiempo=%0t ns", $time);

        // Dar tiempo al procesador para arrancar
        repeat (100) @(negedge clk);

        // Iniciar juego
        switches = 4'b0001;
        $display("Boton de inicio presionado");

        repeat (20) @(negedge clk);

        switches = 4'b0000;
        $display("Boton liberado");

        // Esperar que aparezca el objetivo
        wait (leds === 4'b0001);

        $display("LED objetivo detectado: %b", leds);

        repeat (20) @(negedge clk);

        // Probar boton incorrecto
        switches = 4'b0010;
        $display("Boton incorrecto presionado");

        repeat (20) @(negedge clk);

        switches = 4'b0000;
        $display("Boton incorrecto liberado");

        // Comprobar que vuelve al estado inicial del juego
        wait (leds === 4'b1111);

        $display("TEST PASS: boton incorrecto reinicia la ronda");

        repeat (300) @(negedge clk);

        $display("LEDs al finalizar: %b", leds);
        $display("Fin de simulacion");

        $finish;
    end

    // Registrar cambios de LEDs
    always @(leds) begin
        $display("Tiempo=%0t ns | LEDs=%b", $time, leds);
    end

endmodule
