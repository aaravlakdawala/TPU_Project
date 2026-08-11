`timescale 1ns / 1ps


module shf (
    input  wire [15:0] sr1,
    input  wire [5:0]  ir_5_0,
    output wire [15:0] result
);

    wire [15:0] lshf_result;
    wire [15:0] rshfl_result;
    wire [15:0] rshfa_result;
    wire [15:0] right_result;

    wire right_shift_sel;
    wire arithmetic_shift_sel;

    buf RIGHT_SEL_BUF (
        right_shift_sel,
        ir_5_0[4]
    );

    buf ARITH_SEL_BUF (
        arithmetic_shift_sel,
        ir_5_0[5]
    );

    lshf16 LSHF_UNIT (
        .in(sr1),
        .amount(ir_5_0[3:0]),
        .out(lshf_result)
    );

    rshfl16 RSHFL_UNIT (
        .in(sr1),
        .amount(ir_5_0[3:0]),
        .out(rshfl_result)
    );

    rshfa16 RSHFA_UNIT (
        .in(sr1),
        .amount(ir_5_0[3:0]),
        .out(rshfa_result)
    );

    mux2_16 RIGHT_SHIFT_TYPE_MUX (
        .in0(rshfl_result),
        .in1(rshfa_result),
        .sel(arithmetic_shift_sel),
        .out(right_result)
    );

    mux2_16 SHIFT_TYPE_MUX (
        .in0(lshf_result),
        .in1(right_result),
        .sel(right_shift_sel),
        .out(result)
    );

endmodule


module lshf16 (
    input  wire [15:0] in,
    input  wire [3:0]  amount,
    output wire [15:0] out
);

    wire [15:0] s1;
    wire [15:0] s2;
    wire [15:0] s4;
    wire [15:0] sh1;
    wire [15:0] sh2;
    wire [15:0] sh4;
    wire [15:0] sh8;

    supply0 z;

    buf B1_0  (sh1[0],  z);
    buf B1_1  (sh1[1],  in[0]);
    buf B1_2  (sh1[2],  in[1]);
    buf B1_3  (sh1[3],  in[2]);
    buf B1_4  (sh1[4],  in[3]);
    buf B1_5  (sh1[5],  in[4]);
    buf B1_6  (sh1[6],  in[5]);
    buf B1_7  (sh1[7],  in[6]);
    buf B1_8  (sh1[8],  in[7]);
    buf B1_9  (sh1[9],  in[8]);
    buf B1_10 (sh1[10], in[9]);
    buf B1_11 (sh1[11], in[10]);
    buf B1_12 (sh1[12], in[11]);
    buf B1_13 (sh1[13], in[12]);
    buf B1_14 (sh1[14], in[13]);
    buf B1_15 (sh1[15], in[14]);

    mux2_16 M1 (.in0(in), .in1(sh1), .sel(amount[0]), .out(s1));

    buf B2_0  (sh2[0],  z);
    buf B2_1  (sh2[1],  z);
    buf B2_2  (sh2[2],  s1[0]);
    buf B2_3  (sh2[3],  s1[1]);
    buf B2_4  (sh2[4],  s1[2]);
    buf B2_5  (sh2[5],  s1[3]);
    buf B2_6  (sh2[6],  s1[4]);
    buf B2_7  (sh2[7],  s1[5]);
    buf B2_8  (sh2[8],  s1[6]);
    buf B2_9  (sh2[9],  s1[7]);
    buf B2_10 (sh2[10], s1[8]);
    buf B2_11 (sh2[11], s1[9]);
    buf B2_12 (sh2[12], s1[10]);
    buf B2_13 (sh2[13], s1[11]);
    buf B2_14 (sh2[14], s1[12]);
    buf B2_15 (sh2[15], s1[13]);

    mux2_16 M2 (.in0(s1), .in1(sh2), .sel(amount[1]), .out(s2));

    buf B4_0  (sh4[0],  z);
    buf B4_1  (sh4[1],  z);
    buf B4_2  (sh4[2],  z);
    buf B4_3  (sh4[3],  z);
    buf B4_4  (sh4[4],  s2[0]);
    buf B4_5  (sh4[5],  s2[1]);
    buf B4_6  (sh4[6],  s2[2]);
    buf B4_7  (sh4[7],  s2[3]);
    buf B4_8  (sh4[8],  s2[4]);
    buf B4_9  (sh4[9],  s2[5]);
    buf B4_10 (sh4[10], s2[6]);
    buf B4_11 (sh4[11], s2[7]);
    buf B4_12 (sh4[12], s2[8]);
    buf B4_13 (sh4[13], s2[9]);
    buf B4_14 (sh4[14], s2[10]);
    buf B4_15 (sh4[15], s2[11]);

    mux2_16 M4 (.in0(s2), .in1(sh4), .sel(amount[2]), .out(s4));

    buf B8_0  (sh8[0],  z);
    buf B8_1  (sh8[1],  z);
    buf B8_2  (sh8[2],  z);
    buf B8_3  (sh8[3],  z);
    buf B8_4  (sh8[4],  z);
    buf B8_5  (sh8[5],  z);
    buf B8_6  (sh8[6],  z);
    buf B8_7  (sh8[7],  z);
    buf B8_8  (sh8[8],  s4[0]);
    buf B8_9  (sh8[9],  s4[1]);
    buf B8_10 (sh8[10], s4[2]);
    buf B8_11 (sh8[11], s4[3]);
    buf B8_12 (sh8[12], s4[4]);
    buf B8_13 (sh8[13], s4[5]);
    buf B8_14 (sh8[14], s4[6]);
    buf B8_15 (sh8[15], s4[7]);

    mux2_16 M8 (.in0(s4), .in1(sh8), .sel(amount[3]), .out(out));

endmodule


module rshfl16 (
    input  wire [15:0] in,
    input  wire [3:0]  amount,
    output wire [15:0] out
);

    wire [15:0] s1;
    wire [15:0] s2;
    wire [15:0] s4;
    wire [15:0] sh1;
    wire [15:0] sh2;
    wire [15:0] sh4;
    wire [15:0] sh8;

    supply0 z;

    buf B1_0  (sh1[0],  in[1]);
    buf B1_1  (sh1[1],  in[2]);
    buf B1_2  (sh1[2],  in[3]);
    buf B1_3  (sh1[3],  in[4]);
    buf B1_4  (sh1[4],  in[5]);
    buf B1_5  (sh1[5],  in[6]);
    buf B1_6  (sh1[6],  in[7]);
    buf B1_7  (sh1[7],  in[8]);
    buf B1_8  (sh1[8],  in[9]);
    buf B1_9  (sh1[9],  in[10]);
    buf B1_10 (sh1[10], in[11]);
    buf B1_11 (sh1[11], in[12]);
    buf B1_12 (sh1[12], in[13]);
    buf B1_13 (sh1[13], in[14]);
    buf B1_14 (sh1[14], in[15]);
    buf B1_15 (sh1[15], z);

    mux2_16 M1 (.in0(in), .in1(sh1), .sel(amount[0]), .out(s1));

    buf B2_0  (sh2[0],  s1[2]);
    buf B2_1  (sh2[1],  s1[3]);
    buf B2_2  (sh2[2],  s1[4]);
    buf B2_3  (sh2[3],  s1[5]);
    buf B2_4  (sh2[4],  s1[6]);
    buf B2_5  (sh2[5],  s1[7]);
    buf B2_6  (sh2[6],  s1[8]);
    buf B2_7  (sh2[7],  s1[9]);
    buf B2_8  (sh2[8],  s1[10]);
    buf B2_9  (sh2[9],  s1[11]);
    buf B2_10 (sh2[10], s1[12]);
    buf B2_11 (sh2[11], s1[13]);
    buf B2_12 (sh2[12], s1[14]);
    buf B2_13 (sh2[13], s1[15]);
    buf B2_14 (sh2[14], z);
    buf B2_15 (sh2[15], z);

    mux2_16 M2 (.in0(s1), .in1(sh2), .sel(amount[1]), .out(s2));

    buf B4_0  (sh4[0],  s2[4]);
    buf B4_1  (sh4[1],  s2[5]);
    buf B4_2  (sh4[2],  s2[6]);
    buf B4_3  (sh4[3],  s2[7]);
    buf B4_4  (sh4[4],  s2[8]);
    buf B4_5  (sh4[5],  s2[9]);
    buf B4_6  (sh4[6],  s2[10]);
    buf B4_7  (sh4[7],  s2[11]);
    buf B4_8  (sh4[8],  s2[12]);
    buf B4_9  (sh4[9],  s2[13]);
    buf B4_10 (sh4[10], s2[14]);
    buf B4_11 (sh4[11], s2[15]);
    buf B4_12 (sh4[12], z);
    buf B4_13 (sh4[13], z);
    buf B4_14 (sh4[14], z);
    buf B4_15 (sh4[15], z);

    mux2_16 M4 (.in0(s2), .in1(sh4), .sel(amount[2]), .out(s4));

    buf B8_0  (sh8[0],  s4[8]);
    buf B8_1  (sh8[1],  s4[9]);
    buf B8_2  (sh8[2],  s4[10]);
    buf B8_3  (sh8[3],  s4[11]);
    buf B8_4  (sh8[4],  s4[12]);
    buf B8_5  (sh8[5],  s4[13]);
    buf B8_6  (sh8[6],  s4[14]);
    buf B8_7  (sh8[7],  s4[15]);
    buf B8_8  (sh8[8],  z);
    buf B8_9  (sh8[9],  z);
    buf B8_10 (sh8[10], z);
    buf B8_11 (sh8[11], z);
    buf B8_12 (sh8[12], z);
    buf B8_13 (sh8[13], z);
    buf B8_14 (sh8[14], z);
    buf B8_15 (sh8[15], z);

    mux2_16 M8 (.in0(s4), .in1(sh8), .sel(amount[3]), .out(out));

endmodule


module rshfa16 (
    input  wire [15:0] in,
    input  wire [3:0]  amount,
    output wire [15:0] out
);

    wire sign;
    wire [15:0] s1;
    wire [15:0] s2;
    wire [15:0] s4;
    wire [15:0] sh1;
    wire [15:0] sh2;
    wire [15:0] sh4;
    wire [15:0] sh8;

    buf SIGN_BUF (sign, in[15]);

    buf B1_0  (sh1[0],  in[1]);
    buf B1_1  (sh1[1],  in[2]);
    buf B1_2  (sh1[2],  in[3]);
    buf B1_3  (sh1[3],  in[4]);
    buf B1_4  (sh1[4],  in[5]);
    buf B1_5  (sh1[5],  in[6]);
    buf B1_6  (sh1[6],  in[7]);
    buf B1_7  (sh1[7],  in[8]);
    buf B1_8  (sh1[8],  in[9]);
    buf B1_9  (sh1[9],  in[10]);
    buf B1_10 (sh1[10], in[11]);
    buf B1_11 (sh1[11], in[12]);
    buf B1_12 (sh1[12], in[13]);
    buf B1_13 (sh1[13], in[14]);
    buf B1_14 (sh1[14], in[15]);
    buf B1_15 (sh1[15], sign);

    mux2_16 M1 (.in0(in), .in1(sh1), .sel(amount[0]), .out(s1));

    buf B2_0  (sh2[0],  s1[2]);
    buf B2_1  (sh2[1],  s1[3]);
    buf B2_2  (sh2[2],  s1[4]);
    buf B2_3  (sh2[3],  s1[5]);
    buf B2_4  (sh2[4],  s1[6]);
    buf B2_5  (sh2[5],  s1[7]);
    buf B2_6  (sh2[6],  s1[8]);
    buf B2_7  (sh2[7],  s1[9]);
    buf B2_8  (sh2[8],  s1[10]);
    buf B2_9  (sh2[9],  s1[11]);
    buf B2_10 (sh2[10], s1[12]);
    buf B2_11 (sh2[11], s1[13]);
    buf B2_12 (sh2[12], s1[14]);
    buf B2_13 (sh2[13], s1[15]);
    buf B2_14 (sh2[14], sign);
    buf B2_15 (sh2[15], sign);

    mux2_16 M2 (.in0(s1), .in1(sh2), .sel(amount[1]), .out(s2));

    buf B4_0  (sh4[0],  s2[4]);
    buf B4_1  (sh4[1],  s2[5]);
    buf B4_2  (sh4[2],  s2[6]);
    buf B4_3  (sh4[3],  s2[7]);
    buf B4_4  (sh4[4],  s2[8]);
    buf B4_5  (sh4[5],  s2[9]);
    buf B4_6  (sh4[6],  s2[10]);
    buf B4_7  (sh4[7],  s2[11]);
    buf B4_8  (sh4[8],  s2[12]);
    buf B4_9  (sh4[9],  s2[13]);
    buf B4_10 (sh4[10], s2[14]);
    buf B4_11 (sh4[11], s2[15]);
    buf B4_12 (sh4[12], sign);
    buf B4_13 (sh4[13], sign);
    buf B4_14 (sh4[14], sign);
    buf B4_15 (sh4[15], sign);

    mux2_16 M4 (.in0(s2), .in1(sh4), .sel(amount[2]), .out(s4));

    buf B8_0  (sh8[0],  s4[8]);
    buf B8_1  (sh8[1],  s4[9]);
    buf B8_2  (sh8[2],  s4[10]);
    buf B8_3  (sh8[3],  s4[11]);
    buf B8_4  (sh8[4],  s4[12]);
    buf B8_5  (sh8[5],  s4[13]);
    buf B8_6  (sh8[6],  s4[14]);
    buf B8_7  (sh8[7],  s4[15]);
    buf B8_8  (sh8[8],  sign);
    buf B8_9  (sh8[9],  sign);
    buf B8_10 (sh8[10], sign);
    buf B8_11 (sh8[11], sign);
    buf B8_12 (sh8[12], sign);
    buf B8_13 (sh8[13], sign);
    buf B8_14 (sh8[14], sign);
    buf B8_15 (sh8[15], sign);

    mux2_16 M8 (.in0(s4), .in1(sh8), .sel(amount[3]), .out(out));

endmodule