
module pochoco_instruccion_rom #(
    parameter SIMULATION = 0
) (
    input  wire        clk_i,
    input  wire        req_i,
    input  wire [31:0] addr_i,
    output reg  [31:0] rdata_o
);

    wire [31:0] rom_data;

    // Seleccionar ROM original o ROM de simulacion
    generate
        if (SIMULATION == 1) begin : gen_sim_rom

            game_sim_rom u_rom (
                .addr_i (addr_i),
                .data_o (rom_data)
            );

        end else begin : gen_asic_rom

            game_rom u_rom (
                .addr_i (addr_i),
                .data_o (rom_data)
            );

        end
    endgenerate

    // Lectura sincronica: conserva la temporizacion original
    always @(posedge clk_i) begin
        if (req_i)
            rdata_o <= rom_data;
    end

endmodule
