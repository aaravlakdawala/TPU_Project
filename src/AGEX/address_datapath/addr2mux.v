`timescale 1ns / 1ps

module addr2mux (
    input  wire [15:0] zero,
    input  wire [15:0] sext6_out,
    input  wire [15:0] sext9_out,
    input  wire [15:0] sext11_out,
    input  wire [1:0]  sel,
    output wire [15:0] out
);

    mux4_16 ADDR2MUX_UNIT (
        .in0(zero),
        .in1(sext6_out),
        .in2(sext9_out),
        .in3(sext11_out),
        .sel(sel),
        .out(out)
    );

endmodule