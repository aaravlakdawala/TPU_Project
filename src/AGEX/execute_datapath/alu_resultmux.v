`timescale 1ns / 1ps

module alu_resultmux (
    input  wire [15:0] shf_result,
    input  wire [15:0] alu_result,
    input  wire        sel,
    output wire [15:0] out
);

    mux2_16 ALU_RESULTMUX_UNIT (
        .in0(shf_result),
        .in1(alu_result),
        .sel(sel),
        .out(out)
    );

endmodule