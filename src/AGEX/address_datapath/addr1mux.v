`timescale 1ns / 1ps

module addr1mux (
    input  wire [15:0] npc,
    input  wire [15:0] sr1,
    input  wire        sel,
    output wire [15:0] out
);

    mux2_16 ADDR1MUX_UNIT (
        .in0(npc),
        .in1(sr1),
        .sel(sel),
        .out(out)
    );

endmodule