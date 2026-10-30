
`timescale 1ns/1ps

module tb_asic_top;

    reg clk;
    reg rst_n;
    reg [3:0] switches;

    wire [3:0] leds;

    wire s1a, s1b, s1c, s1d, s1e, s1f, s1g;
    wire s2a, s2b, s2c, s2d, s2e, s2f, s2g;

    wire spi_miso;


    asic_top #(
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

    // Reloj de 10 MHz: periodo de 100 ns
    initial clk = 0;
    always #50 clk = ~clk;

    initial begin
        rst_n = 0;
        switches = 4'b0000;

        $dumpfile("sim/asic_wave.vcd");
        $dumpvars(0, tb_asic_top);

        $display("Inicio simulacion ASIC");

        // Reset durante cinco ciclos
        repeat (5) @(negedge clk);
        rst_n = 1;

        $display("Reset liberado");

        // Esperar a que el programa arranque
        repeat (100) @(negedge clk);

        // Pulsar boton 1 para iniciar
        switches = 4'b0001;
        $display("Boton de inicio presionado");

        repeat (20) @(negedge clk);

        switches = 4'b0000;
        $display("Boton liberado");


    wait (leds == 4'b0001);

    $display("LED objetivo detectado: %b", leds);

    // Esperar 20 ciclos antes de responder
    repeat (20) @(negedge clk);

    // Presionar el boton correcto
    switches = 4'b0010;
    $display("Boton incorrecto presionado");



    // Mantener pulsado durante 20 ciclos
    repeat (20) @(negedge clk);

    // Soltar el boton
    switches = 4'b0000;
    $display("Boton incorrecto liberado");

    // Esperar para observar el resultado
    repeat (300) @(negedge clk);

    $display("LEDs al finalizar: %b", leds);

        $display("Fin de simulacion");

        $finish;
    end

    // Mostrar cambios en LEDs
    always @(leds) begin
        $display("Tiempo=%0t ns | LEDs=%b", $time, leds);
    end

endmodule
