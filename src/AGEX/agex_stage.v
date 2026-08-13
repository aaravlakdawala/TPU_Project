`timescale 1ns / 1ps

module agex_stage (
    input  wire        clk,
    input  wire        reset,

    /*
        Outputs of the DE/AGEX pipeline registers.
    */
    input  wire [15:0] agex_npc,
    input  wire [15:0] agex_ir,
    input  wire [15:0] agex_sr1,
    input  wire [15:0] agex_sr2,
    input  wire [2:0]  agex_cc,
    input  wire [2:0]  agex_drid,
    input  wire [20:0] agex_cs,
    input  wire        agex_v,

    /*
        MEM.STALL comes from the MEM stage.
        If MEM is stalled, AGEX must not overwrite MEM registers.
    */
    input  wire        mem_stall,

    /*
        Outputs to dependency/control logic.
    */
    output wire        ld_mem,
    output wire        v_agex_ld_cc,
    output wire        v_agex_ld_reg,
    output wire        v_agex_br_stall,

    /*
        AGEX/MEM pipeline registers.
    */
    output reg  [15:0] mem_npc,
    output reg  [15:0] mem_ir,
    output reg  [2:0]  mem_cc,
    output reg  [2:0]  mem_drid,
    output reg  [10:0] mem_cs,
    output reg  [15:0] mem_address,
    output reg  [15:0] mem_alu_result,
    output reg         mem_v,

    /*
        Optional debug outputs from the already-built datapath core.
    */
    output wire [15:0] comb_mem_address,
    output wire [15:0] comb_mem_alu_result,

    output wire [15:0] alu_result,
    output wire [15:0] shf_result,
    output wire [15:0] sr2mux_out,
    output wire [15:0] sext5_out,

    output wire [15:0] addr1mux_out,
    output wire [15:0] addr2mux_out,
    output wire [15:0] lshf1_out,
    output wire [15:0] addr2_final_out,
    output wire [15:0] sext6_out,
    output wire [15:0] sext9_out,
    output wire [15:0] sext11_out,
    output wire [15:0] zext8_lshf1_out,
    output wire [15:0] address_adder_out,

    /*
        Optional control debug outputs.
    */
    output wire [2:0]  aluk_debug,
    output wire        sr2mux_sel_debug,
    output wire        alu_resultmux_sel_debug,
    output wire        addr1mux_sel_debug,
    output wire [1:0]  addr2mux_sel_debug,
    output wire        lshf1_sel_debug,
    output wire        addressmux_sel_debug
);

    /*
        Unpack AGEX.CS into individual AGEX controls.
    */
    wire        addr1mux_sel;
    wire [1:0]  addr2mux_sel;
    wire        lshf1_sel;
    wire        addressmux_sel;
    wire        sr2mux_sel;
    wire [2:0]  aluk;
    wire        alu_resultmux_sel;

    wire        br_op;
    wire        uncond_op;
    wire        trap_op;

    wire        agex_br_stall;
    wire        dcache_en;
    wire        dcache_rw;
    wire        data_size;

    wire [1:0]  dr_valuemux;
    wire        agex_ld_reg;
    wire        agex_ld_cc;

    wire [10:0] agex_mem_cs_in;

    agex_control_unpack AGEX_CONTROL_UNPACK_UNIT (
        .agex_cs(agex_cs),

        .addr1mux_sel(addr1mux_sel),
        .addr2mux_sel(addr2mux_sel),
        .lshf1_sel(lshf1_sel),
        .addressmux_sel(addressmux_sel),
        .sr2mux_sel(sr2mux_sel),
        .aluk(aluk),
        .alu_resultmux_sel(alu_resultmux_sel),

        .br_op(br_op),
        .uncond_op(uncond_op),
        .trap_op(trap_op),

        .agex_br_stall(agex_br_stall),
        .dcache_en(dcache_en),
        .dcache_rw(dcache_rw),
        .data_size(data_size),

        .dr_valuemux(dr_valuemux),
        .agex_ld_reg(agex_ld_reg),
        .agex_ld_cc(agex_ld_cc),

        .mem_cs_in(agex_mem_cs_in)
    );

    /*
        AGEX combinational datapath.
    */
    agex_datapath_core AGEX_DATAPATH_CORE_UNIT (
        .agex_npc(agex_npc),
        .agex_sr1(agex_sr1),
        .agex_sr2(agex_sr2),
        .agex_ir(agex_ir),

        .aluk(aluk),
        .sr2mux_sel(sr2mux_sel),
        .alu_resultmux_sel(alu_resultmux_sel),

        .addr1mux_sel(addr1mux_sel),
        .addr2mux_sel(addr2mux_sel),
        .lshf1_sel(lshf1_sel),
        .addressmux_sel(addressmux_sel),

        .mem_alu_result(comb_mem_alu_result),
        .mem_address(comb_mem_address),

        .alu_result(alu_result),
        .shf_result(shf_result),
        .sr2mux_out(sr2mux_out),
        .sext5_out(sext5_out),

        .addr1mux_out(addr1mux_out),
        .addr2mux_out(addr2mux_out),
        .lshf1_out(lshf1_out),
        .addr2_final_out(addr2_final_out),
        .sext6_out(sext6_out),
        .sext9_out(sext9_out),
        .sext11_out(sext11_out),
        .zext8_lshf1_out(zext8_lshf1_out),
        .address_adder_out(address_adder_out)
    );

    /*
        If MEM is stalled, do not load the MEM pipeline registers.
        Otherwise, AGEX can advance into MEM.
    */
    assign ld_mem = ~mem_stall;

    /*
        Valid-gated AGEX control signals.
    */
    assign v_agex_ld_cc    = agex_v & agex_ld_cc;
    assign v_agex_ld_reg   = agex_v & agex_ld_reg;
    assign v_agex_br_stall = agex_v & agex_br_stall;

    /*
        AGEX/MEM pipeline registers.
    */
    always @(posedge clk) begin
        if (reset) begin
            mem_npc        <= 16'h0000;
            mem_ir         <= 16'h0000;
            mem_cc         <= 3'b000;
            mem_drid       <= 3'b000;
            mem_cs         <= 11'b00000000000;
            mem_address    <= 16'h0000;
            mem_alu_result <= 16'h0000;
            mem_v          <= 1'b0;
        end
        else if (ld_mem) begin
            mem_npc        <= agex_npc;
            mem_ir         <= agex_ir;
            mem_cc         <= agex_cc;
            mem_drid       <= agex_drid;
            mem_cs         <= agex_mem_cs_in;
            mem_address    <= comb_mem_address;
            mem_alu_result <= comb_mem_alu_result;
            mem_v          <= agex_v;
        end
    end

    /*
        Debug assignments.
    */
    assign aluk_debug              = aluk;
    assign sr2mux_sel_debug        = sr2mux_sel;
    assign alu_resultmux_sel_debug = alu_resultmux_sel;
    assign addr1mux_sel_debug      = addr1mux_sel;
    assign addr2mux_sel_debug      = addr2mux_sel;
    assign lshf1_sel_debug         = lshf1_sel;
    assign addressmux_sel_debug    = addressmux_sel;

endmodule