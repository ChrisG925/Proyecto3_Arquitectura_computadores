
module pochoco_soc_unified #(
    parameter SIMULATION = 0
) (
    input  wire       i_Clk,
    input  wire       i_Rst_n,

    input  wire [3:0] i_Switch,
    output wire [3:0] o_LED,

    output wire o_Segment1_A,
    output wire o_Segment1_B,
    output wire o_Segment1_C,
    output wire o_Segment1_D,
    output wire o_Segment1_E,
    output wire o_Segment1_F,
    output wire o_Segment1_G,

    output wire o_Segment2_A,
    output wire o_Segment2_B,
    output wire o_Segment2_C,
    output wire o_Segment2_D,
    output wire o_Segment2_E,
    output wire o_Segment2_F,
    output wire o_Segment2_G,

    input  wire i_SPI_SCLK,
    input  wire i_SPI_MOSI,
    input  wire i_SPI_CS_n,
    output wire o_SPI_MISO
);

    wire clk;
    assign clk = i_Clk;

    // Controlador de inicializacion
    wire        load_we;
    wire [31:0] load_addr;
    wire [31:0] load_data;
    wire        boot_done;

    // Mantener el procesador en reset durante la carga
    wire core_rst_ni;
    assign core_rst_ni = i_Rst_n & boot_done;

    
    pochoco_boot_loader #(
        .NUM_INSTRUCTIONS(86),
        .SIMULATION(SIMULATION)
    ) u_boot (
        .clk_i       (clk),
        .rst_ni      (i_Rst_n),
        .load_we_o   (load_we),
        .load_addr_o (load_addr),
        .load_data_o (load_data),
        .boot_done_o (boot_done)
    );

    // Conexiones procesador-memoria
    wire        instr_req;
    wire [31:0] instr_addr;
    wire [31:0] instr_rdata;

    wire        data_req;
    wire        data_we;
    wire [3:0]  data_be;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;

    // Procesador Espino
    espino_core #(
        .BootAddr(32'h00000000)
    ) u_core (
        .clk_i         (clk),
        .rst_ni        (core_rst_ni),
        .instr_req_o   (instr_req),
        .instr_addr_o  (instr_addr),
        .instr_rdata_i (instr_rdata),
        .data_req_o    (data_req),
        .data_we_o     (data_we),
        .data_be_o     (data_be),
        .data_addr_o   (data_addr),
        .data_wdata_o  (data_wdata),
        .data_rdata_i  (data_rdata)
    );

    // Decodificacion de perifericos
    wire is_mmio;
    wire per_sel;
    wire spi_sel;

    assign is_mmio = data_addr[31];
    assign per_sel = is_mmio & ~data_addr[16];
    assign spi_sel = is_mmio &  data_addr[16];

    wire ram_b_req;
    wire per_req;
    wire spi_req;

    assign ram_b_req = data_req & ~is_mmio;
    assign per_req   = data_req & per_sel;
    assign spi_req   = data_req & spi_sel;

    wire [31:0] ram_b_rdata;
    wire [31:0] per_rdata;
    wire [31:0] spi_rdata;

    reg rd_is_per;
    reg rd_is_spi;

    always @(posedge clk or negedge core_rst_ni) begin
        if (!core_rst_ni) begin
            rd_is_per <= 1'b0;
            rd_is_spi <= 1'b0;
        end
        else if (data_req && !data_we) begin
            rd_is_per <= per_sel;
            rd_is_spi <= spi_sel;
        end
    end

    assign data_rdata =
        rd_is_per ? per_rdata :
        rd_is_spi ? spi_rdata :
        ram_b_rdata;

    // Memoria unificada de 128 palabras
    pochoco_unified_ram #(
        .NumWords(128)
    ) u_unified_ram (
        .clk_i       (clk),

        .a_req_i     (instr_req & boot_done),
        .a_addr_i    (instr_addr),
        .a_rdata_o   (instr_rdata),

        .b_req_i     (ram_b_req & boot_done),
        .b_we_i      (data_we),
        .b_be_i      (data_be),
        .b_addr_i    (data_addr),
        .b_wdata_i   (data_wdata),
        .b_rdata_o   (ram_b_rdata),

        .load_we_i   (load_we),
        .load_addr_i (load_addr),
        .load_data_i (load_data)
    );

    // Perifericos
    wire [6:0] seg1;
    wire [6:0] seg2;

    pochoco_periph u_periph (
        .clk_i    (clk),
        .rst_ni   (core_rst_ni),
        .sel_i    (per_sel),
        .req_i    (per_req),
        .we_i     (data_we),
        .addr_i   (data_addr[7:0]),
        .wdata_i  (data_wdata),
        .rdata_o  (per_rdata),
        .leds_o   (o_LED),
        .btn_i    (i_Switch),
        .seg1_o   (seg1),
        .seg2_o   (seg2)
    );

    // Interfaz SPI
    pochoco_spi_slave u_spi (
        .clk_i      (clk),
        .rst_ni     (core_rst_ni),
        .sel_i      (spi_sel),
        .req_i      (spi_req),
        .we_i       (data_we),
        .addr_i     (data_addr[7:0]),
        .wdata_i    (data_wdata),
        .rdata_o    (spi_rdata),
        .spi_sclk_i (i_SPI_SCLK),
        .spi_mosi_i (i_SPI_MOSI),
        .spi_cs_n_i (i_SPI_CS_n),
        .spi_miso_o (o_SPI_MISO)
    );

    // Displays de siete segmentos activos en bajo
    assign {
        o_Segment1_G, o_Segment1_F, o_Segment1_E,
        o_Segment1_D, o_Segment1_C, o_Segment1_B,
        o_Segment1_A
    } = ~seg1;

    assign {
        o_Segment2_G, o_Segment2_F, o_Segment2_E,
        o_Segment2_D, o_Segment2_C, o_Segment2_B,
        o_Segment2_A
    } = ~seg2;

endmodule
