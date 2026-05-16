`timescale 1ns / 1ps

module csa16 (
    input  wire [15:0] x,
    input  wire [15:0] y,
    input  wire [15:0] z,
    output wire [15:0] sum,
    output wire [15:0] carry
);

    wire c16_unused;

    assign carry[0] = 1'b0;

    full_adder FA0  (.a(x[0]),  .b(y[0]),  .cin(z[0]),  .sum(sum[0]),  .cout(carry[1]));
    full_adder FA1  (.a(x[1]),  .b(y[1]),  .cin(z[1]),  .sum(sum[1]),  .cout(carry[2]));
    full_adder FA2  (.a(x[2]),  .b(y[2]),  .cin(z[2]),  .sum(sum[2]),  .cout(carry[3]));
    full_adder FA3  (.a(x[3]),  .b(y[3]),  .cin(z[3]),  .sum(sum[3]),  .cout(carry[4]));
    full_adder FA4  (.a(x[4]),  .b(y[4]),  .cin(z[4]),  .sum(sum[4]),  .cout(carry[5]));
    full_adder FA5  (.a(x[5]),  .b(y[5]),  .cin(z[5]),  .sum(sum[5]),  .cout(carry[6]));
    full_adder FA6  (.a(x[6]),  .b(y[6]),  .cin(z[6]),  .sum(sum[6]),  .cout(carry[7]));
    full_adder FA7  (.a(x[7]),  .b(y[7]),  .cin(z[7]),  .sum(sum[7]),  .cout(carry[8]));
    full_adder FA8  (.a(x[8]),  .b(y[8]),  .cin(z[8]),  .sum(sum[8]),  .cout(carry[9]));
    full_adder FA9  (.a(x[9]),  .b(y[9]),  .cin(z[9]),  .sum(sum[9]),  .cout(carry[10]));
    full_adder FA10 (.a(x[10]), .b(y[10]), .cin(z[10]), .sum(sum[10]), .cout(carry[11]));
    full_adder FA11 (.a(x[11]), .b(y[11]), .cin(z[11]), .sum(sum[11]), .cout(carry[12]));
    full_adder FA12 (.a(x[12]), .b(y[12]), .cin(z[12]), .sum(sum[12]), .cout(carry[13]));
    full_adder FA13 (.a(x[13]), .b(y[13]), .cin(z[13]), .sum(sum[13]), .cout(carry[14]));
    full_adder FA14 (.a(x[14]), .b(y[14]), .cin(z[14]), .sum(sum[14]), .cout(carry[15]));
    full_adder FA15 (.a(x[15]), .b(y[15]), .cin(z[15]), .sum(sum[15]), .cout(c16_unused));

endmodule