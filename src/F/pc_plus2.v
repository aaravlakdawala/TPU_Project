`timescale 1ns / 1ps

module pc_plus2(
    input  wire [15:0] pc,
    output wire [15:0] pc_plus2
);

wire [15:0] carry;

buf BUF_SUM0(pc_plus2[0], pc[0]);

not NOT_SUM1(pc_plus2[1], pc[1]);
buf BUF_CARRY1(carry[1], pc[1]);

genvar i;
generate
    for (i = 2; i < 16; i = i + 1) begin : PLUS2_BITS
        xor XOR_SUM(pc_plus2[i], pc[i], carry[i-1]);
        and AND_CARRY(carry[i], pc[i], carry[i-1]);
    end
endgenerate

endmodule