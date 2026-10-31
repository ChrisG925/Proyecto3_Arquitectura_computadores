// Archivo generado automaticamente por assembler.py
// ROM combinacional de instrucciones del juego

module game_rom (
  input wire [31:0] addr_i,
  output reg [31:0] data_o
);

  always @(*) begin
    case (addr_i)
      32'h00000000: data_o = 32'h80000137;
      32'h00000004: data_o = 32'h00000493;
      32'h00000008: data_o = 32'h00000593;
      32'h0000000c: data_o = 32'h00812183;
      32'h00000010: data_o = 32'hfe018ee3;
      32'h00000014: data_o = 32'h00c12083;
      32'h00000018: data_o = 32'h00812183;
      32'h0000001c: data_o = 32'hfe019ee3;
      32'h00000020: data_o = 32'h00f00213;
      32'h00000024: data_o = 32'h00412223;
      32'h00000028: data_o = 32'h00c12303;
      32'h0000002c: data_o = 32'h077002b7;
      32'h00000030: data_o = 32'h95c28293;
      32'h00000034: data_o = 32'h00c12383;
      32'h00000038: data_o = 32'h40638433;
      32'h0000003c: data_o = 32'h00545463;
      32'h00000040: data_o = 32'hff5ff06f;
      32'h00000044: data_o = 32'h00c12383;
      32'h00000048: data_o = 32'h0070c0b3;
      32'h0000004c: data_o = 32'h003002b7;
      32'h00000050: data_o = 32'h0050f1b3;
      32'h00000054: data_o = 32'h00018e63;
      32'h00000058: data_o = 32'h001002b7;
      32'h0000005c: data_o = 32'h00518e63;
      32'h00000060: data_o = 32'h002002b7;
      32'h00000064: data_o = 32'h00518e63;
      32'h00000068: data_o = 32'h00800213;
      32'h0000006c: data_o = 32'h0180006f;
      32'h00000070: data_o = 32'h00100213;
      32'h00000074: data_o = 32'h0100006f;
      32'h00000078: data_o = 32'h00200213;
      32'h0000007c: data_o = 32'h0080006f;
      32'h00000080: data_o = 32'h00400213;
      32'h00000084: data_o = 32'h00412223;
      32'h00000088: data_o = 32'h00c12303;
      32'h0000008c: data_o = 32'h00812183;
      32'h00000090: data_o = 32'hfe018ee3;
      32'h00000094: data_o = 32'h00418463;
      32'h00000098: data_o = 32'hf89ff06f;
      32'h0000009c: data_o = 32'h00c12383;
      32'h000000a0: data_o = 32'h40638433;
      32'h000000a4: data_o = 32'h0070c0b3;
      32'h000000a8: data_o = 32'h0060c0b3;
      32'h000000ac: data_o = 32'h002622b7;
      32'h000000b0: data_o = 32'h5a028293;
      32'h000000b4: data_o = 32'h00000213;
      32'h000000b8: data_o = 32'h00000613;
      32'h000000bc: data_o = 32'h00545463;
      32'h000000c0: data_o = 32'h0280006f;
      32'h000000c4: data_o = 32'h40540433;
      32'h000000c8: data_o = 32'h00160613;
      32'h000000cc: data_o = 32'h00120213;
      32'h000000d0: data_o = 32'h00f27193;
      32'h000000d4: data_o = 32'h00a00313;
      32'h000000d8: data_o = 32'h00618463;
      32'h000000dc: data_o = 32'hfe1ff06f;
      32'h000000e0: data_o = 32'h00620213;
      32'h000000e4: data_o = 32'hfd9ff06f;
      32'h000000e8: data_o = 32'h00412023;
      32'h000000ec: data_o = 32'h00c585b3;
      32'h000000f0: data_o = 32'h00148493;
      32'h000000f4: data_o = 32'h00812183;
      32'h000000f8: data_o = 32'hfe019ee3;
      32'h000000fc: data_o = 32'h00a00513;
      32'h00000100: data_o = 32'h00a4d463;
      32'h00000104: data_o = 32'hf1dff06f;
      32'h00000108: data_o = 32'h00c12303;
      32'h0000010c: data_o = 32'h018002b7;
      32'h00000110: data_o = 32'h00c12383;
      32'h00000114: data_o = 32'h40638433;
      32'h00000118: data_o = 32'h00545463;
      32'h0000011c: data_o = 32'hff5ff06f;
      32'h00000120: data_o = 32'h00000213;
      32'h00000124: data_o = 32'h00a00293;
      32'h00000128: data_o = 32'h0055d463;
      32'h0000012c: data_o = 32'h0240006f;
      32'h00000130: data_o = 32'h405585b3;
      32'h00000134: data_o = 32'h00120213;
      32'h00000138: data_o = 32'h00f27193;
      32'h0000013c: data_o = 32'h00a00313;
      32'h00000140: data_o = 32'h00618463;
      32'h00000144: data_o = 32'hfe5ff06f;
      32'h00000148: data_o = 32'h00620213;
      32'h0000014c: data_o = 32'hfddff06f;
      32'h00000150: data_o = 32'h00412023;
      32'h00000154: data_o = 32'h0000006f;
      default: data_o = 32'h00000013; // NOP
    endcase
  end
endmodule
