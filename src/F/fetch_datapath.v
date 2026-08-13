`timescale 1ns / 1ps

module fetch_datapath(
    input  wire        clk,
    input  wire        reset,

    input  wire        ld_pc,
    input  wire        ld_de,
    input  wire        de_v_next,

    input  wire [1:0]  mem_pcmux,
    input  wire [15:0] mem_target_pc,
    input  wire [15:0] trap_pc,

    input  wire [15:0] icache_data_in,
    input  wire        icache_r_in,

    output wire [15:0] de_npc,
    output wire [15:0] de_ir,
    output wire        de_v,

    output wire [15:0] pc_debug,
    output wire [15:0] pc_plus2_debug,
    output wire [15:0] next_pc_debug,

    output wire [15:0] icache_addr_debug,
    output wire [15:0] icache_data_debug,
    output wire        icache_r_debug
);

wire [15:0] pc_current;
wire [15:0] pc_plus2_value;
wire [15:0] next_pc;

wire [15:0] icache_addr;
wire [15:0] icache_data_out;
wire        icache_r_out;

pc_reg PC_REG_UNIT (
    .clk(clk),
    .reset(reset),
    .ld_pc(ld_pc),
    .pc_in(next_pc),
    .pc_out(pc_current)
);

pc_plus2 PC_PLUS2_UNIT (
    .pc(pc_current),
    .pc_plus2(pc_plus2_value)
);

pcmux PCMUX_UNIT (
    .pc_plus2(pc_plus2_value),
    .mem_target_pc(mem_target_pc),
    .trap_pc(trap_pc),
    .mem_pcmux(mem_pcmux),
    .next_pc(next_pc)
);

icache ICACHE_UNIT (
    .pc(pc_current),
    .instr_mem_data_in(icache_data_in),
    .instr_mem_ready_in(icache_r_in),
    .icache_addr(icache_addr),
    .icache_data_out(icache_data_out),
    .icache_r(icache_r_out)
);

f_de_latches F_DE_LATCHES_UNIT (
    .clk(clk),
    .reset(reset),
    .ld_de(ld_de),
    .de_npc_next(pc_plus2_value),
    .de_ir_next(icache_data_out),
    .de_v_next(de_v_next),
    .de_npc(de_npc),
    .de_ir(de_ir),
    .de_v(de_v)
);

assign pc_debug          = pc_current;
assign pc_plus2_debug    = pc_plus2_value;
assign next_pc_debug     = next_pc;

assign icache_addr_debug = icache_addr;
assign icache_data_debug = icache_data_out;
assign icache_r_debug    = icache_r_out;

endmodule