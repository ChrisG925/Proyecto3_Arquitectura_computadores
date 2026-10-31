
module pochoco_boot_loader #(
    parameter NUM_INSTRUCTIONS = 86,
    parameter SIMULATION = 0
) (
    input  wire        clk_i,
    input  wire        rst_ni,

    output wire        load_we_o,
    output wire [31:0] load_addr_o,
    output wire [31:0] load_data_o,
    output wire        boot_done_o
);

    reg [7:0] boot_addr_q;
    reg       boot_done_q;

    wire [31:0] rom_addr;
    wire [31:0] rom_data;

    assign rom_addr = {22'b0, boot_addr_q, 2'b00};

    // Seleccionar el programa segun el modo
    generate
        if (SIMULATION) begin : gen_sim
            game_sim_rom u_rom (
                .addr_i(rom_addr),
                .data_o(rom_data)
            );
        end
        else begin : gen_asic
            game_rom u_rom (
                .addr_i(rom_addr),
                .data_o(rom_data)
            );
        end
    endgenerate

    assign load_we_o   = rst_ni && !boot_done_q;
    assign load_addr_o = rom_addr;
    assign load_data_o = rom_data;
    assign boot_done_o = boot_done_q;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            boot_addr_q <= 8'd0;
            boot_done_q <= 1'b0;
        end
        else if (!boot_done_q) begin
            if (boot_addr_q == NUM_INSTRUCTIONS - 1)
                boot_done_q <= 1'b1;
            else
                boot_addr_q <= boot_addr_q + 8'd1;
        end
    end

endmodule
