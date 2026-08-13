`timescale 1ns / 1ps

module f_de_latches(
    input  wire        clk,
    input  wire        reset,
    input  wire        ld_de,

    input  wire [15:0] de_npc_next,
    input  wire [15:0] de_ir_next,
    input  wire        de_v_next,

    output reg  [15:0] de_npc,
    output reg  [15:0] de_ir,
    output reg         de_v
);

always @(posedge clk) begin
    if (reset) begin
        de_npc <= 16'h0000;
        de_ir  <= 16'h0000;
        de_v   <= 1'b0;
    end
    else if (ld_de) begin
        de_npc <= de_npc_next;
        de_ir  <= de_ir_next;
        de_v   <= de_v_next;
    end
end

endmodule