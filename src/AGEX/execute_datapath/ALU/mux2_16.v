`timescale 1ns / 1ps

module mux2_16 (
    input  wire [15:0] in0,
    input  wire [15:0] in1,
    input  wire        sel,
    output wire [15:0] out
);

    wire nsel;

    wire [15:0] a0;
    wire [15:0] a1;

    not N0 (nsel, sel);

    and A0_0  (a0[0],  in0[0],  nsel);
    and A0_1  (a0[1],  in0[1],  nsel);
    and A0_2  (a0[2],  in0[2],  nsel);
    and A0_3  (a0[3],  in0[3],  nsel);
    and A0_4  (a0[4],  in0[4],  nsel);
    and A0_5  (a0[5],  in0[5],  nsel);
    and A0_6  (a0[6],  in0[6],  nsel);
    and A0_7  (a0[7],  in0[7],  nsel);
    and A0_8  (a0[8],  in0[8],  nsel);
    and A0_9  (a0[9],  in0[9],  nsel);
    and A0_10 (a0[10], in0[10], nsel);
    and A0_11 (a0[11], in0[11], nsel);
    and A0_12 (a0[12], in0[12], nsel);
    and A0_13 (a0[13], in0[13], nsel);
    and A0_14 (a0[14], in0[14], nsel);
    and A0_15 (a0[15], in0[15], nsel);

    and A1_0  (a1[0],  in1[0],  sel);
    and A1_1  (a1[1],  in1[1],  sel);
    and A1_2  (a1[2],  in1[2],  sel);
    and A1_3  (a1[3],  in1[3],  sel);
    and A1_4  (a1[4],  in1[4],  sel);
    and A1_5  (a1[5],  in1[5],  sel);
    and A1_6  (a1[6],  in1[6],  sel);
    and A1_7  (a1[7],  in1[7],  sel);
    and A1_8  (a1[8],  in1[8],  sel);
    and A1_9  (a1[9],  in1[9],  sel);
    and A1_10 (a1[10], in1[10], sel);
    and A1_11 (a1[11], in1[11], sel);
    and A1_12 (a1[12], in1[12], sel);
    and A1_13 (a1[13], in1[13], sel);
    and A1_14 (a1[14], in1[14], sel);
    and A1_15 (a1[15], in1[15], sel);

    or O0  (out[0],  a0[0],  a1[0]);
    or O1  (out[1],  a0[1],  a1[1]);
    or O2  (out[2],  a0[2],  a1[2]);
    or O3  (out[3],  a0[3],  a1[3]);
    or O4  (out[4],  a0[4],  a1[4]);
    or O5  (out[5],  a0[5],  a1[5]);
    or O6  (out[6],  a0[6],  a1[6]);
    or O7  (out[7],  a0[7],  a1[7]);
    or O8  (out[8],  a0[8],  a1[8]);
    or O9  (out[9],  a0[9],  a1[9]);
    or O10 (out[10], a0[10], a1[10]);
    or O11 (out[11], a0[11], a1[11]);
    or O12 (out[12], a0[12], a1[12]);
    or O13 (out[13], a0[13], a1[13]);
    or O14 (out[14], a0[14], a1[14]);
    or O15 (out[15], a0[15], a1[15]);

endmodule