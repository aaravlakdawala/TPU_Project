`timescale 1ns / 1ps

module pc_reg(
    input  wire        clk,
    input  wire        reset,
    input  wire        ld_pc,
    input  wire [15:0] pc_in,
    output reg  [15:0] pc_out
);

always @(posedge clk) begin
    if (reset) begin
        pc_out <= 16'h3000;
    end
    else if (ld_pc) begin
        pc_out <= pc_in;
    end
end

endmodule