`timescale 1ns / 1ps

module alu (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [2:0]  aluk,
    output wire [15:0] result
);

    wire [15:0] add_result;
    wire [15:0] and_result;
    wire [15:0] xor_result;
    wire [15:0] passb_result;
    wire [15:0] mul_result;
    wire [15:0] zero_result;

    wire [15:0] level1_0;
    wire [15:0] level1_1;
    wire [15:0] level1_2;

    wire [15:0] level2_0;
    wire [15:0] level2_1;

    wire cout_unused;
    wire pg_unused;
    wire gg_unused;

    cla_16bit ADD_UNIT (
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(add_result),
        .cout(cout_unused),
        .pg(pg_unused),
        .gg(gg_unused)
    );

    and16 AND_UNIT (
        .a(a),
        .b(b),
        .y(and_result)
    );

    xor16 XOR_UNIT (
        .a(a),
        .b(b),
        .y(xor_result)
    );

    passb16 PASSB_UNIT (
        .b(b),
        .y(passb_result)
    );

    mul16 MUL_UNIT (
        .a(a),
        .b(b),
        .product(mul_result)
    );

    zero16 ZERO_UNIT (
        .y(zero_result)
    );

    // aluk 000 -> ADD
    // aluk 001 -> AND
    mux2_16 MUX_L1_0 (
        .in0(add_result),
        .in1(and_result),
        .sel(aluk[0]),
        .out(level1_0)
    );

    // aluk 010 -> XOR
    // aluk 011 -> PASSB
    mux2_16 MUX_L1_1 (
        .in0(xor_result),
        .in1(passb_result),
        .sel(aluk[0]),
        .out(level1_1)
    );

    // aluk 100 -> MUL
    // aluk 101 -> ZERO / unused
    mux2_16 MUX_L1_2 (
        .in0(mul_result),
        .in1(zero_result),
        .sel(aluk[0]),
        .out(level1_2)
    );

    // aluk 00x vs 01x
    mux2_16 MUX_L2_0 (
        .in0(level1_0),
        .in1(level1_1),
        .sel(aluk[1]),
        .out(level2_0)
    );

    // aluk 10x vs 11x
    mux2_16 MUX_L2_1 (
        .in0(level1_2),
        .in1(zero_result),
        .sel(aluk[1]),
        .out(level2_1)
    );

    // aluk 0xx vs 1xx
    mux2_16 MUX_L3_0 (
        .in0(level2_0),
        .in1(level2_1),
        .sel(aluk[2]),
        .out(result)
    );

endmodule