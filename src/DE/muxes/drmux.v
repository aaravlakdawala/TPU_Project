`timescale 1ns / 1ps

module drmux (
    input  wire [2:0] de_ir_11_9,
    input  wire       drmux_sel,
    output wire [2:0] drid
);

    wire not_sel;

    wire a0_path;
    wire a1_path;
    wire a2_path;

    wire r7_0_path;
    wire r7_1_path;
    wire r7_2_path;

    not NOT_SEL(not_sel, drmux_sel);

    /*
        sel = 0 -> DE.IR[11:9]
        sel = 1 -> 3'b111
    */
    and A0_PATH(a0_path, de_ir_11_9[0], not_sel);
    and A1_PATH(a1_path, de_ir_11_9[1], not_sel);
    and A2_PATH(a2_path, de_ir_11_9[2], not_sel);

    /*
        R7 is 3'b111, so each bit is selected when drmux_sel = 1.
    */
    and R7_0_PATH(r7_0_path, 1'b1, drmux_sel);
    and R7_1_PATH(r7_1_path, 1'b1, drmux_sel);
    and R7_2_PATH(r7_2_path, 1'b1, drmux_sel);

    or OUT0(drid[0], a0_path, r7_0_path);
    or OUT1(drid[1], a1_path, r7_1_path);
    or OUT2(drid[2], a2_path, r7_2_path);

endmodule