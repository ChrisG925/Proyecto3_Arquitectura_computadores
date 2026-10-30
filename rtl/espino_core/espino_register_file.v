
module espino_register_file (
    input  wire        clk_i,
    input  wire        rst_ni,

    input  wire [3:0]  raddr_a_i,
    output wire [31:0] rdata_a_o,

    input  wire [3:0]  raddr_b_i,
    output wire [31:0] rdata_b_o,

    input  wire [3:0]  waddr_i,
    input  wire [31:0] wdata_i,
    input  wire        we_i
);

    // 16 registros de 32 bits (RV32E)
    reg [31:0] registers [0:15];

    // Salidas de lectura sincronicas
    reg [31:0] rdata_a_q;
    reg [31:0] rdata_b_q;

    assign rdata_a_o = rdata_a_q;
    assign rdata_b_o = rdata_b_q;

    // Escritura y lectura en el flanco positivo
    always @(posedge clk_i) begin

        // x0 siempre debe ser cero
        if (we_i && (waddr_i != 4'd0)) begin
            registers[waddr_i] <= wdata_i;
        end

        // Lectura del puerto A
        if (raddr_a_i == 4'd0)
            rdata_a_q <= 32'b0;
        else
            rdata_a_q <= registers[raddr_a_i];

        // Lectura del puerto B
        if (raddr_b_i == 4'd0)
            rdata_b_q <= 32'b0;
        else
            rdata_b_q <= registers[raddr_b_i];

    end

    // Reset externo no utilizado en este modulo
    wire _unused = rst_ni;

endmodule
