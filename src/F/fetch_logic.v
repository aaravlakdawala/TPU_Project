`timescale 1ns / 1ps

module fetch_logic(
    input  wire       icache_r,

    input  wire       mem_stall,
    input  wire       dep_stall,

    input  wire       v_de_br_stall,
    input  wire       v_agex_br_stall,
    input  wire       v_mem_br_stall,

    input  wire [1:0] mem_pcmux,

    output wire       ld_pc,
    output wire       ld_de,
    output wire       de_v_next,

    output wire       stall_any_debug,
    output wire       mem_pc_override_debug
);

/*
    Fetch-stage control.

    This does NOT read the control store directly.

    Control-store bits affect Fetch only after they have traveled through
    DE/AGEX/MEM and become resolved signals such as:
        V.DE.BR.STALL
        V.AGEX.BR.STALL
        V.MEM.BR.STALL
        MEM.PCMUX
*/

wire br_stall_any;
wire not_br_stall_any;

wire stall_any;
wire not_stall_any;

wire mem_pc_override;
wire normal_pc_load;

wire dep_or_mem_stall;
wire not_dep_or_mem_stall;

or OR_BR_STALL_ANY(
    br_stall_any,
    v_de_br_stall,
    v_agex_br_stall,
    v_mem_br_stall
);

not NOT_BR_STALL_ANY(not_br_stall_any, br_stall_any);

or OR_STALL_ANY(
    stall_any,
    mem_stall,
    dep_stall,
    v_de_br_stall,
    v_agex_br_stall,
    v_mem_br_stall
);

not NOT_STALL_ANY(not_stall_any, stall_any);

/*
    MEM.PCMUX = 00 means normal PC + 2.
    MEM.PCMUX = 01 or 10 means later stage is redirecting PC.
*/
or OR_MEM_PC_OVERRIDE(
    mem_pc_override,
    mem_pcmux[1],
    mem_pcmux[0]
);

/*
    Normal PC load only when I-cache is ready and front-end is not frozen.
    MEM redirect is allowed to override the normal freeze.
*/
and AND_NORMAL_PC_LOAD(
    normal_pc_load,
    icache_r,
    not_stall_any
);

or OR_LD_PC(
    ld_pc,
    normal_pc_load,
    mem_pc_override
);

/*
    According to the Fetch diagram logic:
    DE is frozen by dependency stall or memory stall.

    Branch stalls do not freeze DE the same way; they cause DE.V to become 0.
*/
or OR_DEP_OR_MEM_STALL(
    dep_or_mem_stall,
    dep_stall,
    mem_stall
);

not NOT_DEP_OR_MEM_STALL(
    not_dep_or_mem_stall,
    dep_or_mem_stall
);

buf BUF_LD_DE(ld_de, not_dep_or_mem_stall);

/*
    DE.V_TEMP = ICACHE.R & no branch-stall.

    If ld_de = 0, f_de_latches holds old DE.V.
    If ld_de = 1, this value is loaded.
*/
and AND_DE_V_NEXT(
    de_v_next,
    icache_r,
    not_br_stall_any
);

buf BUF_STALL_ANY_DEBUG(stall_any_debug, stall_any);
buf BUF_MEM_PC_OVERRIDE_DEBUG(mem_pc_override_debug, mem_pc_override);

endmodule