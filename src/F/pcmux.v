`timescale 1ns / 1ps

module pcmux(
    input  wire [15:0] pc_plus2,
    input  wire [15:0] mem_target_pc,
    input  wire [15:0] trap_pc,
    input  wire [1:0]  mem_pcmux,
    output wire [15:0] next_pc
);

/*
    MEM.PCMUX:
        00 -> PC + 2
        01 -> MEM.TARGET.PC
        10 -> TRAP.PC
        11 -> treat as TRAP.PC / unused safe case
*/

wire sel_pc_plus2;
wire sel_mem_target;
wire sel_trap;
wire not_s1;
wire not_s0;

not NOT_S1(not_s1, mem_pcmux[1]);
not NOT_S0(not_s0, mem_pcmux[0]);

and SEL_PC_PLUS2(sel_pc_plus2, not_s1, not_s0);
and SEL_MEM_TARGET(sel_mem_target, not_s1, mem_pcmux[0]);
buf SEL_TRAP(sel_trap, mem_pcmux[1]);

genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : PCMUX_BITS
        wire pc_path;
        wire mem_path;
        wire trap_path;

        and AND_PC(pc_path, pc_plus2[i], sel_pc_plus2);
        and AND_MEM(mem_path, mem_target_pc[i], sel_mem_target);
        and AND_TRAP(trap_path, trap_pc[i], sel_trap);

        or OR_NEXT_PC(next_pc[i], pc_path, mem_path, trap_path);
    end
endgenerate

endmodule