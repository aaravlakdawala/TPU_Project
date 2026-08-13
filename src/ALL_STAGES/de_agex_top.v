`timescale 1ns / 1ps

module de_agex_top (
    input  wire        clk,
    input  wire        reset,

    /*
        Inputs from Fetch/DE pipeline registers.
        For now, a testbench can drive these directly.
    */
    input  wire [15:0] de_npc,
    input  wire [15:0] de_ir,
    input  wire        de_v,

    /*
        MEM.STALL comes backward from MEM.
        Until MEM exists, a testbench can drive this directly.
    */
    input  wire        mem_stall,

    /*
        SR-stage writeback inputs.
        Until SR exists, a testbench can drive these directly.
    */
    input  wire [2:0]  sr_drid,
    input  wire [15:0] sr_reg_data,
    input  wire        v_sr_ld_reg,

    input  wire [2:0]  sr_cc_data,
    input  wire        v_sr_ld_cc,

    /*
        MEM-stage dependency inputs.
        Until MEM exists, a testbench can drive these directly.
    */
    input  wire [2:0]  mem_drid,
    input  wire        v_mem_ld_reg,
    input  wire        v_mem_ld_cc,

    /*
        Decode outputs.
    */
    output wire        ld_agex,
    output wire        agex_v_next,
    output wire        v_de_br_stall,
    output wire        dep_stall_debug,

    /*
        AGEX outputs to MEM.
    */
    output wire        ld_mem,
    output wire        v_agex_ld_cc,
    output wire        v_agex_ld_reg,
    output wire        v_agex_br_stall,

    output wire [15:0] mem_npc,
    output wire [15:0] mem_ir,
    output wire [2:0]  mem_cc,
    output wire [2:0]  mem_drid_out,
    output wire [10:0] mem_cs,
    output wire [15:0] mem_address,
    output wire [15:0] mem_alu_result,
    output wire        mem_v,

    /*
        Useful debug outputs.
    */
    output wire [23:0] control_store_out_debug,
    output wire [20:0] agex_cs_debug,

    output wire [15:0] agex_npc_debug,
    output wire [15:0] agex_ir_debug,
    output wire [15:0] agex_sr1_debug,
    output wire [15:0] agex_sr2_debug,
    output wire [2:0]  agex_cc_debug,
    output wire [2:0]  agex_drid_debug,
    output wire        agex_v_debug,

    output wire [2:0]  aluk_debug,
    output wire        sr2mux_sel_debug,
    output wire        alu_resultmux_sel_debug,
    output wire        addr1mux_sel_debug,
    output wire [1:0]  addr2mux_sel_debug,
    output wire        lshf1_sel_debug,
    output wire        addressmux_sel_debug,

    output wire [15:0] comb_mem_address,
    output wire [15:0] comb_mem_alu_result
);

    /*
        Wires between DE and AGEX.
    */
    wire [15:0] agex_npc;
    wire [15:0] agex_ir;
    wire [15:0] agex_sr1;
    wire [15:0] agex_sr2;
    wire [2:0]  agex_cc;
    wire [2:0]  agex_drid;
    wire [20:0] agex_cs;
    wire        agex_v;

    /*
        Decode stage.
    */
    de_stage DE_STAGE_UNIT (
        .clk(clk),
        .reset(reset),

        .de_npc(de_npc),
        .de_ir(de_ir),
        .de_v(de_v),

        .mem_stall(mem_stall),

        .sr_drid(sr_drid),
        .sr_reg_data(sr_reg_data),
        .v_sr_ld_reg(v_sr_ld_reg),

        .sr_cc_data(sr_cc_data),
        .v_sr_ld_cc(v_sr_ld_cc),

        /*
            Feedback from AGEX for dependency checking.
            AGEX.DRID is the destination register currently sitting in AGEX.
            V.AGEX.LD.REG and V.AGEX.LD.CC come from agex_stage.
        */
        .agex_drid_in(agex_drid),
        .mem_drid(mem_drid),

        .v_agex_ld_reg(v_agex_ld_reg),
        .v_mem_ld_reg(v_mem_ld_reg),

        .v_agex_ld_cc(v_agex_ld_cc),
        .v_mem_ld_cc(v_mem_ld_cc),

        .ld_agex(ld_agex),
        .agex_v_next(agex_v_next),
        .v_de_br_stall(v_de_br_stall),
        .dep_stall_debug(dep_stall_debug),

        .agex_npc(agex_npc),
        .agex_ir(agex_ir),
        .agex_sr1(agex_sr1),
        .agex_sr2(agex_sr2),
        .agex_cc(agex_cc),
        .agex_drid(agex_drid),
        .agex_cs(agex_cs),
        .agex_v(agex_v),

        .control_store_out_debug(control_store_out_debug),

        .sr1_id_debug(),
        .sr2_id_debug(),
        .drid_debug(),
        .sr1_data_debug(),
        .sr2_data_debug(),
        .cc_data_debug(),

        .sr1_needed_debug(),
        .sr2_needed_debug(),
        .de_br_op_debug(),
        .br_stall_debug(),

        .r0_debug(),
        .r1_debug(),
        .r2_debug(),
        .r3_debug(),
        .r4_debug(),
        .r5_debug(),
        .r6_debug(),
        .r7_debug()
    );

    /*
        AGEX stage.
    */
    agex_stage AGEX_STAGE_UNIT (
        .clk(clk),
        .reset(reset),

        .agex_npc(agex_npc),
        .agex_ir(agex_ir),
        .agex_sr1(agex_sr1),
        .agex_sr2(agex_sr2),
        .agex_cc(agex_cc),
        .agex_drid(agex_drid),
        .agex_cs(agex_cs),
        .agex_v(agex_v),

        .mem_stall(mem_stall),

        .ld_mem(ld_mem),
        .v_agex_ld_cc(v_agex_ld_cc),
        .v_agex_ld_reg(v_agex_ld_reg),
        .v_agex_br_stall(v_agex_br_stall),

        .mem_npc(mem_npc),
        .mem_ir(mem_ir),
        .mem_cc(mem_cc),
        .mem_drid(mem_drid_out),
        .mem_cs(mem_cs),
        .mem_address(mem_address),
        .mem_alu_result(mem_alu_result),
        .mem_v(mem_v),

        .comb_mem_address(comb_mem_address),
        .comb_mem_alu_result(comb_mem_alu_result),

        .alu_result(),
        .shf_result(),
        .sr2mux_out(),
        .sext5_out(),

        .addr1mux_out(),
        .addr2mux_out(),
        .lshf1_out(),
        .addr2_final_out(),
        .sext6_out(),
        .sext9_out(),
        .sext11_out(),
        .zext8_lshf1_out(),
        .address_adder_out(),

        .aluk_debug(aluk_debug),
        .sr2mux_sel_debug(sr2mux_sel_debug),
        .alu_resultmux_sel_debug(alu_resultmux_sel_debug),
        .addr1mux_sel_debug(addr1mux_sel_debug),
        .addr2mux_sel_debug(addr2mux_sel_debug),
        .lshf1_sel_debug(lshf1_sel_debug),
        .addressmux_sel_debug(addressmux_sel_debug)
    );

    /*
        Debug assignments for DE-to-AGEX boundary.
    */
    assign agex_cs_debug   = agex_cs;
    assign agex_npc_debug  = agex_npc;
    assign agex_ir_debug   = agex_ir;
    assign agex_sr1_debug  = agex_sr1;
    assign agex_sr2_debug  = agex_sr2;
    assign agex_cc_debug   = agex_cc;
    assign agex_drid_debug = agex_drid;
    assign agex_v_debug    = agex_v;

endmodule