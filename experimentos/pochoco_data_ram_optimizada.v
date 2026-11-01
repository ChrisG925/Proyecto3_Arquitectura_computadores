module pochoco_data_ram #(
    parameter NumWords = 64
) (
    input wire clk_i,
    input wire req_i,
    input wire we_i,
    input wire [3:0] be_i,
    input wire [31:0] addr_i,
    input wire [31:0] wdata_i,
    output reg [31:0] rdata_o
);

    localparam AddrW = $clog2(NumWords);

    reg [31:0] mem [0:NumWords-1];
    wire [AddrW-1:0] word_addr = addr_i[AddrW+1:2];

    wire write_enable = req_i && we_i;

    genvar i;
    generate
        for (i = 0; i < NumWords; i = i + 1) begin : GEN_RAM
            wire word_we = write_enable && (word_addr == i);

            always @(posedge clk_i) begin
                if (word_we && be_i[0])
                    mem[i][7:0] <= wdata_i[7:0];

                if (word_we && be_i[1])
                    mem[i][15:8] <= wdata_i[15:8];

                if (word_we && be_i[2])
                    mem[i][23:16] <= wdata_i[23:16];

                if (word_we && be_i[3])
                    mem[i][31:24] <= wdata_i[31:24];
            end
        end
    endgenerate

    always @(posedge clk_i)
        rdata_o <= mem[word_addr];

endmodule
