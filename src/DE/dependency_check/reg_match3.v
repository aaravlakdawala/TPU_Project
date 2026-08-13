`timescale 1ns / 1ps

module reg_match3 (
    input  wire [2:0] a,
    input  wire [2:0] b,
    output wire       match
);

    wire xnor0_out;
    wire xnor1_out;
    wire xnor2_out;

    xnor XNOR0(xnor0_out, a[0], b[0]);
    xnor XNOR1(xnor1_out, a[1], b[1]);
    xnor XNOR2(xnor2_out, a[2], b[2]);

    and MATCH_AND(match, xnor0_out, xnor1_out, xnor2_out);

endmodule