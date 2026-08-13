// src/DE/regfile/dff_en_reset.v
`timescale 1ns / 1ps

module dff_en_reset (
    input  wire clk,
    input  wire reset,
    input  wire load_en,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin
        if (reset)
            q <= 1'b0;
        else if (load_en)
            q <= d;
    end

endmodule