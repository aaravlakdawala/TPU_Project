`timescale 1ns / 1ps

module mux4_16 (
    input  wire [15:0] in0,
    input  wire [15:0] in1,
    input  wire [15:0] in2,
    input  wire [15:0] in3,
    input  wire [1:0]  sel,
    output wire [15:0] out
);

    wire [15:0] low_out;
    wire [15:0] high_out;

    mux2_16 MUX_LOW (
        .in0(in0),
        .in1(in1),
        .sel(sel[0]),
        .out(low_out)
    );

    mux2_16 MUX_HIGH (
        .in0(in2),
        .in1(in3),
        .sel(sel[0]),
        .out(high_out)
    );

    mux2_16 MUX_FINAL (
        .in0(low_out),
        .in1(high_out),
        .sel(sel[1]),
        .out(out)
    );

endmodule