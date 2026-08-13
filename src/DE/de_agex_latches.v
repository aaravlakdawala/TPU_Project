`timescale 1ns / 1ps

module de_agex_latches (
    input  wire        clk,
    input  wire        reset,
    input  wire        ld_agex,

    /*
        Values coming from the DE stage.
    */
    input  wire [15:0] de_npc,
    input  wire [15:0] de_ir,

    /*
        Values coming from the register file and CC register.
    */
    input  wire [15:0] sr1_data,
    input  wire [15:0] sr2_data,
    input  wire [2:0]  cc_data,

    /*
        Destination register ID after DRMUX.
    */
    input  wire [2:0]  drid_in,

    /*
        Full 23-bit control-store output.

        Bits [2:0] are Decode-only:
            [0] SR1.NEEDED
            [1] SR2.NEEDED
            [2] DRMUX

        Bits [22:3] are latched into AGEX.CS.
    */
    input  wire [23:0] control_store_out,

    /*
        Input to AGEX.V latch.
        This comes from Decode-stage valid/bubble logic.
    */
    input  wire        agex_v_next,

    /*
        Outputs of the DE/AGEX pipeline registers.
    */
    output reg  [15:0] agex_npc,
    output reg  [15:0] agex_ir,
    output reg  [15:0] agex_sr1,
    output reg  [15:0] agex_sr2,
    output reg  [2:0]  agex_cc,
    output reg  [2:0]  agex_drid,
    output reg  [20:0] agex_cs,
    output reg         agex_v
);

    /*
        DE/AGEX pipeline-register bundle.

        Synchronous reset:
            reset only takes effect on a rising clock edge.

        Load enable:
            when ld_agex = 1, Decode values are captured into AGEX.
            when ld_agex = 0, AGEX registers hold their old values.
    */
    always @(posedge clk) begin
        if (reset) begin
            agex_npc  <= 16'h0000;
            agex_ir   <= 16'h0000;
            agex_sr1  <= 16'h0000;
            agex_sr2  <= 16'h0000;
            agex_cc   <= 3'b000;
            agex_drid <= 3'b000;
            agex_cs <= 21'b000000000000000000000;
            agex_v    <= 1'b0;
        end
        else if (ld_agex) begin
            agex_npc  <= de_npc;
            agex_ir   <= de_ir;
            agex_sr1  <= sr1_data;
            agex_sr2  <= sr2_data;
            agex_cc   <= cc_data;
            agex_drid <= drid_in;
            agex_cs   <= control_store_out[23:3];
            agex_v    <= agex_v_next;
        end
    end

endmodule