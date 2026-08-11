`timescale 1ns / 1ps

module addressmux (
    input  wire [15:0] adder_result,
    input  wire [15:0] zext_lshf1_result,
    input  wire        sel,
    output wire [15:0] out
);

    mux2_16 ADDRESSMUX_UNIT (
        .in0(adder_result),
        .in1(zext_lshf1_result),
        .sel(sel),
        .out(out)
    );

endmodule