`timescale 1ns / 1ps

module dependency_check (
    /*
        Decode-stage instruction information.
    */
    input  wire        de_v,

    input  wire [2:0]  de_sr1_id,
    input  wire [2:0]  de_sr2_id,

    input  wire        sr1_needed,
    input  wire        sr2_needed,
    input  wire        de_br_op,

    /*
        Destination registers from later stages.
    */
    input  wire [2:0]  agex_drid,
    input  wire [2:0]  mem_drid,
    input  wire [2:0]  sr_drid,

    /*
        Valid-gated register write signals from later stages.
    */
    input  wire        v_agex_ld_reg,
    input  wire        v_mem_ld_reg,
    input  wire        v_sr_ld_reg,

    /*
        Valid-gated condition-code write signals from later stages.
    */
    input  wire        v_agex_ld_cc,
    input  wire        v_mem_ld_cc,
    input  wire        v_sr_ld_cc,

    /*
        Final dependency stall output.
    */
    output wire        dep_stall
);

    /*
        Register match checks.

        These only say "same register number."
        They do not yet mean "stall."
    */
    wire sr1_match_agex;
    wire sr1_match_mem;
    wire sr1_match_sr;

    wire sr2_match_agex;
    wire sr2_match_mem;
    wire sr2_match_sr;

    reg_match3 SR1_AGEX_MATCH (
        .a(de_sr1_id),
        .b(agex_drid),
        .match(sr1_match_agex)
    );

    reg_match3 SR1_MEM_MATCH (
        .a(de_sr1_id),
        .b(mem_drid),
        .match(sr1_match_mem)
    );

    reg_match3 SR1_SR_MATCH (
        .a(de_sr1_id),
        .b(sr_drid),
        .match(sr1_match_sr)
    );

    reg_match3 SR2_AGEX_MATCH (
        .a(de_sr2_id),
        .b(agex_drid),
        .match(sr2_match_agex)
    );

    reg_match3 SR2_MEM_MATCH (
        .a(de_sr2_id),
        .b(mem_drid),
        .match(sr2_match_mem)
    );

    reg_match3 SR2_SR_MATCH (
        .a(de_sr2_id),
        .b(sr_drid),
        .match(sr2_match_sr)
    );

    /*
        SR1 dependency:
            Decode instruction needs SR1
            AND some older instruction will write that same register.
    */
    wire sr1_dep_agex;
    wire sr1_dep_mem;
    wire sr1_dep_sr;
    wire sr1_dep_any;

    and SR1_DEP_AGEX(sr1_dep_agex, sr1_needed, sr1_match_agex, v_agex_ld_reg);
    and SR1_DEP_MEM (sr1_dep_mem,  sr1_needed, sr1_match_mem,  v_mem_ld_reg);
    and SR1_DEP_SR  (sr1_dep_sr,   sr1_needed, sr1_match_sr,   v_sr_ld_reg);

    or SR1_DEP_OR(sr1_dep_any, sr1_dep_agex, sr1_dep_mem, sr1_dep_sr);

    /*
        SR2 dependency:
            Decode instruction needs SR2
            AND some older instruction will write that same register.
    */
    wire sr2_dep_agex;
    wire sr2_dep_mem;
    wire sr2_dep_sr;
    wire sr2_dep_any;

    and SR2_DEP_AGEX(sr2_dep_agex, sr2_needed, sr2_match_agex, v_agex_ld_reg);
    and SR2_DEP_MEM (sr2_dep_mem,  sr2_needed, sr2_match_mem,  v_mem_ld_reg);
    and SR2_DEP_SR  (sr2_dep_sr,   sr2_needed, sr2_match_sr,   v_sr_ld_reg);

    or SR2_DEP_OR(sr2_dep_any, sr2_dep_agex, sr2_dep_mem, sr2_dep_sr);

    /*
        Condition-code dependency:
            If Decode has a branch instruction,
            and an older instruction has not yet finished writing CC,
            then Decode must stall.
    */
    wire cc_writer_in_pipe;
    wire cc_dep;

    or CC_WRITER_OR(
        cc_writer_in_pipe,
        v_agex_ld_cc,
        v_mem_ld_cc,
        v_sr_ld_cc
    );

    and CC_DEP_AND(cc_dep, de_br_op, cc_writer_in_pipe);

    /*
        Any dependency causes DEP.STALL,
        but only if the instruction in Decode is valid.
    */
    wire dep_before_valid;

    or DEP_OR(dep_before_valid, sr1_dep_any, sr2_dep_any, cc_dep);

    and DEP_VALID_AND(dep_stall, de_v, dep_before_valid);

endmodule