`timescale 1ns / 1ps

module fetch_stage(
    input  wire        clk,
    input  wire        reset,

    input  wire        mem_stall,
    input  wire        dep_stall,

    input  wire        v_de_br_stall,
    input  wire        v_agex_br_stall,
    input  wire        v_mem_br_stall,

    input  wire [1:0]  mem_pcmux,
    input  wire [15:0] mem_target_pc,
    input  wire [15:0] trap_pc,

    input  wire [15:0] icache_data_in,
    input  wire        icache_r,

    output wire [15:0] de_npc,
    output wire [15:0] de_ir,
    output wire        de_v,

    output wire [15:0] pc_debug,
    output wire [15:0] pc_plus2_debug,
    output wire [15:0] next_pc_debug,

    output wire        ld_pc_debug,
    output wire        ld_de_debug,
    output wire        de_v_next_debug,

    output wire        stall_any_debug,
    output wire        mem_pc_override_debug,

    output wire [15:0] icache_addr_debug,
    output wire [15:0] icache_data_debug,
    output wire        icache_r_debug
);

wire ld_pc;
wire ld_de;
wire de_v_next;

fetch_logic FETCH_LOGIC_UNIT (
    .icache_r(icache_r),

    .mem_stall(mem_stall),
    .dep_stall(dep_stall),

    .v_de_br_stall(v_de_br_stall),
    .v_agex_br_stall(v_agex_br_stall),
    .v_mem_br_stall(v_mem_br_stall),

    .mem_pcmux(mem_pcmux),

    .ld_pc(ld_pc),
    .ld_de(ld_de),
    .de_v_next(de_v_next),

    .stall_any_debug(stall_any_debug),
    .mem_pc_override_debug(mem_pc_override_debug)
);

fetch_datapath FETCH_DATAPATH_UNIT (
    .clk(clk),
    .reset(reset),

    .ld_pc(ld_pc),
    .ld_de(ld_de),
    .de_v_next(de_v_next),

    .mem_pcmux(mem_pcmux),
    .mem_target_pc(mem_target_pc),
    .trap_pc(trap_pc),

    .icache_data_in(icache_data_in),
    .icache_r_in(icache_r),

    .de_npc(de_npc),
    .de_ir(de_ir),
    .de_v(de_v),

    .pc_debug(pc_debug),
    .pc_plus2_debug(pc_plus2_debug),
    .next_pc_debug(next_pc_debug),

    .icache_addr_debug(icache_addr_debug),
    .icache_data_debug(icache_data_debug),
    .icache_r_debug(icache_r_debug)
);

assign ld_pc_debug     = ld_pc;
assign ld_de_debug     = ld_de;
assign de_v_next_debug = de_v_next;

endmodule