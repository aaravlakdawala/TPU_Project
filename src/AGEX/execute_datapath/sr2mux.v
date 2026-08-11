`timescale 1ns / 1ps

module sr2mux (
    input  wire [15:0] sr2,
    input  wire [15:0] sext_imm5,
    input  wire        sel,
    output wire [15:0] out
);

    mux2_16 SR2MUX_UNIT (
        .in0(sr2),
        .in1(sext_imm5),
        .sel(sel),
        .out(out)
    );

endmodule