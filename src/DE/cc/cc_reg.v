// src/DE/cc/cc_reg.v
`timescale 1ns / 1ps

module cc_reg (
    input  wire       clk,
    input  wire       reset,

    /*
        Writeback from SR stage.

        SR.CC.DATA is the newly computed condition-code value.
        V.SR.LD.CC is the valid-gated condition-code write enable.
    */
    input  wire [2:0] sr_cc_data,
    input  wire       v_sr_ld_cc,

    /*
        Current condition codes read by Decode.

        cc_out[2] = N
        cc_out[1] = Z
        cc_out[0] = P
    */
    output reg  [2:0] cc_out
);

    /*
        Synchronous reset.

        After reset, we choose Z = 1 as the clean default condition-code state:
            N = 0
            Z = 1
            P = 0

        If your lab shell/code initializes CC differently, match that instead.
    */
    always @(posedge clk) begin
        if (reset) begin
            cc_out <= 3'b010;
        end
        else if (v_sr_ld_cc) begin
            cc_out <= sr_cc_data;
        end
    end

endmodule