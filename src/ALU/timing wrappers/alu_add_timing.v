`timescale 1ns / 1ps

module alu_add_timing (
    input  wire        clk,
    input  wire [15:0] a_in,
    input  wire [15:0] b_in,
    output reg  [15:0] result_out
);

    reg [15:0] a_reg;
    reg [15:0] b_reg;

    wire [15:0] result_wire;

    alu DUT (
        .a(a_reg),
        .b(b_reg),
        .aluk(3'b000),
        .result(result_wire)
    );

    always @(posedge clk) begin
        a_reg      <= a_in;
        b_reg      <= b_in;
        result_out <= result_wire;
    end

endmodule