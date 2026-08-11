module pp_gen_16 (
    input  wire [15:0] a,
    input  wire [15:0] b,

    output wire [15:0] pp0,
    output wire [15:0] pp1,
    output wire [15:0] pp2,
    output wire [15:0] pp3,
    output wire [15:0] pp4,
    output wire [15:0] pp5,
    output wire [15:0] pp6,
    output wire [15:0] pp7,
    output wire [15:0] pp8,
    output wire [15:0] pp9,
    output wire [15:0] pp10,
    output wire [15:0] pp11,
    output wire [15:0] pp12,
    output wire [15:0] pp13,
    output wire [15:0] pp14,
    output wire [15:0] pp15
);

    assign pp0[0]  = a[0] & b[0];
    assign pp0[1]  = a[0] & b[1];
    assign pp0[2]  = a[0] & b[2];
    assign pp0[3]  = a[0] & b[3];
    assign pp0[4]  = a[0] & b[4];
    assign pp0[5]  = a[0] & b[5];
    assign pp0[6]  = a[0] & b[6];
    assign pp0[7]  = a[0] & b[7];
    assign pp0[8]  = a[0] & b[8];
    assign pp0[9]  = a[0] & b[9];
    assign pp0[10] = a[0] & b[10];
    assign pp0[11] = a[0] & b[11];
    assign pp0[12] = a[0] & b[12];
    assign pp0[13] = a[0] & b[13];
    assign pp0[14] = a[0] & b[14];
    assign pp0[15] = a[0] & b[15];

    assign pp1[0]  = 1'b0;
    assign pp1[1]  = a[1] & b[0];
    assign pp1[2]  = a[1] & b[1];
    assign pp1[3]  = a[1] & b[2];
    assign pp1[4]  = a[1] & b[3];
    assign pp1[5]  = a[1] & b[4];
    assign pp1[6]  = a[1] & b[5];
    assign pp1[7]  = a[1] & b[6];
    assign pp1[8]  = a[1] & b[7];
    assign pp1[9]  = a[1] & b[8];
    assign pp1[10] = a[1] & b[9];
    assign pp1[11] = a[1] & b[10];
    assign pp1[12] = a[1] & b[11];
    assign pp1[13] = a[1] & b[12];
    assign pp1[14] = a[1] & b[13];
    assign pp1[15] = a[1] & b[14];

    assign pp2[0]  = 1'b0;
    assign pp2[1]  = 1'b0;
    assign pp2[2]  = a[2] & b[0];
    assign pp2[3]  = a[2] & b[1];
    assign pp2[4]  = a[2] & b[2];
    assign pp2[5]  = a[2] & b[3];
    assign pp2[6]  = a[2] & b[4];
    assign pp2[7]  = a[2] & b[5];
    assign pp2[8]  = a[2] & b[6];
    assign pp2[9]  = a[2] & b[7];
    assign pp2[10] = a[2] & b[8];
    assign pp2[11] = a[2] & b[9];
    assign pp2[12] = a[2] & b[10];
    assign pp2[13] = a[2] & b[11];
    assign pp2[14] = a[2] & b[12];
    assign pp2[15] = a[2] & b[13];

    assign pp3[0]  = 1'b0;
    assign pp3[1]  = 1'b0;
    assign pp3[2]  = 1'b0;
    assign pp3[3]  = a[3] & b[0];
    assign pp3[4]  = a[3] & b[1];
    assign pp3[5]  = a[3] & b[2];
    assign pp3[6]  = a[3] & b[3];
    assign pp3[7]  = a[3] & b[4];
    assign pp3[8]  = a[3] & b[5];
    assign pp3[9]  = a[3] & b[6];
    assign pp3[10] = a[3] & b[7];
    assign pp3[11] = a[3] & b[8];
    assign pp3[12] = a[3] & b[9];
    assign pp3[13] = a[3] & b[10];
    assign pp3[14] = a[3] & b[11];
    assign pp3[15] = a[3] & b[12];

    assign pp4[0]  = 1'b0;
    assign pp4[1]  = 1'b0;
    assign pp4[2]  = 1'b0;
    assign pp4[3]  = 1'b0;
    assign pp4[4]  = a[4] & b[0];
    assign pp4[5]  = a[4] & b[1];
    assign pp4[6]  = a[4] & b[2];
    assign pp4[7]  = a[4] & b[3];
    assign pp4[8]  = a[4] & b[4];
    assign pp4[9]  = a[4] & b[5];
    assign pp4[10] = a[4] & b[6];
    assign pp4[11] = a[4] & b[7];
    assign pp4[12] = a[4] & b[8];
    assign pp4[13] = a[4] & b[9];
    assign pp4[14] = a[4] & b[10];
    assign pp4[15] = a[4] & b[11];

    assign pp5[0]  = 1'b0;
    assign pp5[1]  = 1'b0;
    assign pp5[2]  = 1'b0;
    assign pp5[3]  = 1'b0;
    assign pp5[4]  = 1'b0;
    assign pp5[5]  = a[5] & b[0];
    assign pp5[6]  = a[5] & b[1];
    assign pp5[7]  = a[5] & b[2];
    assign pp5[8]  = a[5] & b[3];
    assign pp5[9]  = a[5] & b[4];
    assign pp5[10] = a[5] & b[5];
    assign pp5[11] = a[5] & b[6];
    assign pp5[12] = a[5] & b[7];
    assign pp5[13] = a[5] & b[8];
    assign pp5[14] = a[5] & b[9];
    assign pp5[15] = a[5] & b[10];

    assign pp6[0]  = 1'b0;
    assign pp6[1]  = 1'b0;
    assign pp6[2]  = 1'b0;
    assign pp6[3]  = 1'b0;
    assign pp6[4]  = 1'b0;
    assign pp6[5]  = 1'b0;
    assign pp6[6]  = a[6] & b[0];
    assign pp6[7]  = a[6] & b[1];
    assign pp6[8]  = a[6] & b[2];
    assign pp6[9]  = a[6] & b[3];
    assign pp6[10] = a[6] & b[4];
    assign pp6[11] = a[6] & b[5];
    assign pp6[12] = a[6] & b[6];
    assign pp6[13] = a[6] & b[7];
    assign pp6[14] = a[6] & b[8];
    assign pp6[15] = a[6] & b[9];

    assign pp7[0]  = 1'b0;
    assign pp7[1]  = 1'b0;
    assign pp7[2]  = 1'b0;
    assign pp7[3]  = 1'b0;
    assign pp7[4]  = 1'b0;
    assign pp7[5]  = 1'b0;
    assign pp7[6]  = 1'b0;
    assign pp7[7]  = a[7] & b[0];
    assign pp7[8]  = a[7] & b[1];
    assign pp7[9]  = a[7] & b[2];
    assign pp7[10] = a[7] & b[3];
    assign pp7[11] = a[7] & b[4];
    assign pp7[12] = a[7] & b[5];
    assign pp7[13] = a[7] & b[6];
    assign pp7[14] = a[7] & b[7];
    assign pp7[15] = a[7] & b[8];

    assign pp8[0]  = 1'b0;
    assign pp8[1]  = 1'b0;
    assign pp8[2]  = 1'b0;
    assign pp8[3]  = 1'b0;
    assign pp8[4]  = 1'b0;
    assign pp8[5]  = 1'b0;
    assign pp8[6]  = 1'b0;
    assign pp8[7]  = 1'b0;
    assign pp8[8]  = a[8] & b[0];
    assign pp8[9]  = a[8] & b[1];
    assign pp8[10] = a[8] & b[2];
    assign pp8[11] = a[8] & b[3];
    assign pp8[12] = a[8] & b[4];
    assign pp8[13] = a[8] & b[5];
    assign pp8[14] = a[8] & b[6];
    assign pp8[15] = a[8] & b[7];

    assign pp9[0]  = 1'b0;
    assign pp9[1]  = 1'b0;
    assign pp9[2]  = 1'b0;
    assign pp9[3]  = 1'b0;
    assign pp9[4]  = 1'b0;
    assign pp9[5]  = 1'b0;
    assign pp9[6]  = 1'b0;
    assign pp9[7]  = 1'b0;
    assign pp9[8]  = 1'b0;
    assign pp9[9]  = a[9] & b[0];
    assign pp9[10] = a[9] & b[1];
    assign pp9[11] = a[9] & b[2];
    assign pp9[12] = a[9] & b[3];
    assign pp9[13] = a[9] & b[4];
    assign pp9[14] = a[9] & b[5];
    assign pp9[15] = a[9] & b[6];

    assign pp10[0]  = 1'b0;
    assign pp10[1]  = 1'b0;
    assign pp10[2]  = 1'b0;
    assign pp10[3]  = 1'b0;
    assign pp10[4]  = 1'b0;
    assign pp10[5]  = 1'b0;
    assign pp10[6]  = 1'b0;
    assign pp10[7]  = 1'b0;
    assign pp10[8]  = 1'b0;
    assign pp10[9]  = 1'b0;
    assign pp10[10] = a[10] & b[0];
    assign pp10[11] = a[10] & b[1];
    assign pp10[12] = a[10] & b[2];
    assign pp10[13] = a[10] & b[3];
    assign pp10[14] = a[10] & b[4];
    assign pp10[15] = a[10] & b[5];

    assign pp11[0]  = 1'b0;
    assign pp11[1]  = 1'b0;
    assign pp11[2]  = 1'b0;
    assign pp11[3]  = 1'b0;
    assign pp11[4]  = 1'b0;
    assign pp11[5]  = 1'b0;
    assign pp11[6]  = 1'b0;
    assign pp11[7]  = 1'b0;
    assign pp11[8]  = 1'b0;
    assign pp11[9]  = 1'b0;
    assign pp11[10] = 1'b0;
    assign pp11[11] = a[11] & b[0];
    assign pp11[12] = a[11] & b[1];
    assign pp11[13] = a[11] & b[2];
    assign pp11[14] = a[11] & b[3];
    assign pp11[15] = a[11] & b[4];

    assign pp12[0]  = 1'b0;
    assign pp12[1]  = 1'b0;
    assign pp12[2]  = 1'b0;
    assign pp12[3]  = 1'b0;
    assign pp12[4]  = 1'b0;
    assign pp12[5]  = 1'b0;
    assign pp12[6]  = 1'b0;
    assign pp12[7]  = 1'b0;
    assign pp12[8]  = 1'b0;
    assign pp12[9]  = 1'b0;
    assign pp12[10] = 1'b0;
    assign pp12[11] = 1'b0;
    assign pp12[12] = a[12] & b[0];
    assign pp12[13] = a[12] & b[1];
    assign pp12[14] = a[12] & b[2];
    assign pp12[15] = a[12] & b[3];

    assign pp13[0]  = 1'b0;
    assign pp13[1]  = 1'b0;
    assign pp13[2]  = 1'b0;
    assign pp13[3]  = 1'b0;
    assign pp13[4]  = 1'b0;
    assign pp13[5]  = 1'b0;
    assign pp13[6]  = 1'b0;
    assign pp13[7]  = 1'b0;
    assign pp13[8]  = 1'b0;
    assign pp13[9]  = 1'b0;
    assign pp13[10] = 1'b0;
    assign pp13[11] = 1'b0;
    assign pp13[12] = 1'b0;
    assign pp13[13] = a[13] & b[0];
    assign pp13[14] = a[13] & b[1];
    assign pp13[15] = a[13] & b[2];

    assign pp14[0]  = 1'b0;
    assign pp14[1]  = 1'b0;
    assign pp14[2]  = 1'b0;
    assign pp14[3]  = 1'b0;
    assign pp14[4]  = 1'b0;
    assign pp14[5]  = 1'b0;
    assign pp14[6]  = 1'b0;
    assign pp14[7]  = 1'b0;
    assign pp14[8]  = 1'b0;
    assign pp14[9]  = 1'b0;
    assign pp14[10] = 1'b0;
    assign pp14[11] = 1'b0;
    assign pp14[12] = 1'b0;
    assign pp14[13] = 1'b0;
    assign pp14[14] = a[14] & b[0];
    assign pp14[15] = a[14] & b[1];

    assign pp15[0]  = 1'b0;
    assign pp15[1]  = 1'b0;
    assign pp15[2]  = 1'b0;
    assign pp15[3]  = 1'b0;
    assign pp15[4]  = 1'b0;
    assign pp15[5]  = 1'b0;
    assign pp15[6]  = 1'b0;
    assign pp15[7]  = 1'b0;
    assign pp15[8]  = 1'b0;
    assign pp15[9]  = 1'b0;
    assign pp15[10] = 1'b0;
    assign pp15[11] = 1'b0;
    assign pp15[12] = 1'b0;
    assign pp15[13] = 1'b0;
    assign pp15[14] = 1'b0;
    assign pp15[15] = a[15] & b[0];

endmodule