`timescale 1ns / 1ps

module address_adder (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] sum
);

    supply0 zero_cin;
    wire unused_cout;

    cla_16bit ADDR_ADDER_UNIT (
        .a(a),
        .b(b),
        .cin(zero_cin),
        .sum(sum),
        .cout(unused_cout)
    );

endmodule