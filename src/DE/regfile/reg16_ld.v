// src/DE/regfile/reg16_ld.v
`timescale 1ns / 1ps

module reg16_ld (
    input  wire        clk,
    input  wire        reset,
    input  wire        load_en,
    input  wire [15:0] d,
    output wire [15:0] q
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : GEN_DFFS
            dff_en_reset DFF_UNIT (
                .clk(clk),
                .reset(reset),
                .load_en(load_en),
                .d(d[i]),
                .q(q[i])
            );
        end
    endgenerate

endmodule