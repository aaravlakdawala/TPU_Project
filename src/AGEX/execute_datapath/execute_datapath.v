`timescale 1ns / 1ps

module execute_datapath (
    input  wire [15:0] agex_sr1,
    input  wire [15:0] agex_sr2,
    input  wire [15:0] agex_ir,

    input  wire [2:0]  aluk,
    input  wire        sr2mux_sel,
    input  wire        alu_resultmux_sel,

    output wire [15:0] execute_result,
    output wire [15:0] alu_result,
    output wire [15:0] shf_result,
    output wire [15:0] sr2mux_out,
    output wire [15:0] sext5_out
);

    sext5 SEXT5_UNIT (
        .in(agex_ir[4:0]),
        .out(sext5_out)
    );

    sr2mux SR2MUX_UNIT (
        .sr2(agex_sr2),
        .sext_imm5(sext5_out),
        .sel(sr2mux_sel),
        .out(sr2mux_out)
    );

    alu ALU_UNIT (
        .a(agex_sr1),
        .b(sr2mux_out),
        .aluk(aluk),
        .result(alu_result)
    );

    shf SHF_UNIT (
        .sr1(agex_sr1),
        .ir_5_0(agex_ir[5:0]),
        .result(shf_result)
    );

    alu_resultmux ALU_RESULTMUX_UNIT (
        .shf_result(shf_result),
        .alu_result(alu_result),
        .sel(alu_resultmux_sel),
        .out(execute_result)
    );

endmodule