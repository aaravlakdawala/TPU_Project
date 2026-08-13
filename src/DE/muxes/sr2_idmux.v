`timescale 1ns / 1ps

module sr2_idmux (
    input  wire [2:0] de_ir_2_0,
    input  wire [2:0] de_ir_11_9,
    input  wire       sr2_idmux_sel,
    output wire [2:0] sr2_id
);

    wire not_sel;

    wire a0_path;
    wire a1_path;
    wire a2_path;

    wire b0_path;
    wire b1_path;
    wire b2_path;

    not NOT_SEL(not_sel, sr2_idmux_sel);

    /*
        sel = 0 -> DE.IR[2:0]
        sel = 1 -> DE.IR[11:9]
    */
    and A0_PATH(a0_path, de_ir_2_0[0],  not_sel);
    and A1_PATH(a1_path, de_ir_2_0[1],  not_sel);
    and A2_PATH(a2_path, de_ir_2_0[2],  not_sel);

    and B0_PATH(b0_path, de_ir_11_9[0], sr2_idmux_sel);
    and B1_PATH(b1_path, de_ir_11_9[1], sr2_idmux_sel);
    and B2_PATH(b2_path, de_ir_11_9[2], sr2_idmux_sel);

    or OUT0(sr2_id[0], a0_path, b0_path);
    or OUT1(sr2_id[1], a1_path, b1_path);
    or OUT2(sr2_id[2], a2_path, b2_path);

endmodule