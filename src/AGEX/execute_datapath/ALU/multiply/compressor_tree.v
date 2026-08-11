`timescale 1ns / 1ps

module compressor_tree (
    input  wire [15:0] pp0,
    input  wire [15:0] pp1,
    input  wire [15:0] pp2,
    input  wire [15:0] pp3,
    input  wire [15:0] pp4,
    input  wire [15:0] pp5,
    input  wire [15:0] pp6,
    input  wire [15:0] pp7,
    input  wire [15:0] pp8,
    input  wire [15:0] pp9,
    input  wire [15:0] pp10,
    input  wire [15:0] pp11,
    input  wire [15:0] pp12,
    input  wire [15:0] pp13,
    input  wire [15:0] pp14,
    input  wire [15:0] pp15,

    output wire [15:0] row0,
    output wire [15:0] row1
);

    // ============================================================
    // Stage 1: 16 rows -> 11 rows
    // ============================================================

    wire [15:0] s1_0, c1_0;
    wire [15:0] s1_1, c1_1;
    wire [15:0] s1_2, c1_2;
    wire [15:0] s1_3, c1_3;
    wire [15:0] s1_4, c1_4;

    csa16 S1_CSA0 (.x(pp0),  .y(pp1),  .z(pp2),  .sum(s1_0), .carry(c1_0));
    csa16 S1_CSA1 (.x(pp3),  .y(pp4),  .z(pp5),  .sum(s1_1), .carry(c1_1));
    csa16 S1_CSA2 (.x(pp6),  .y(pp7),  .z(pp8),  .sum(s1_2), .carry(c1_2));
    csa16 S1_CSA3 (.x(pp9),  .y(pp10), .z(pp11), .sum(s1_3), .carry(c1_3));
    csa16 S1_CSA4 (.x(pp12), .y(pp13), .z(pp14), .sum(s1_4), .carry(c1_4));

    // Stage 1 rows:
    // s1_0, c1_0, s1_1, c1_1, s1_2, c1_2, s1_3, c1_3, s1_4, c1_4, pp15


    // ============================================================
    // Stage 2: 11 rows -> 8 rows
    // ============================================================

    wire [15:0] s2_0, c2_0;
    wire [15:0] s2_1, c2_1;
    wire [15:0] s2_2, c2_2;

    csa16 S2_CSA0 (.x(s1_0), .y(c1_0), .z(s1_1), .sum(s2_0), .carry(c2_0));
    csa16 S2_CSA1 (.x(c1_1), .y(s1_2), .z(c1_2), .sum(s2_1), .carry(c2_1));
    csa16 S2_CSA2 (.x(s1_3), .y(c1_3), .z(s1_4), .sum(s2_2), .carry(c2_2));

    // Stage 2 rows:
    // s2_0, c2_0, s2_1, c2_1, s2_2, c2_2, c1_4, pp15


    // ============================================================
    // Stage 3: 8 rows -> 6 rows
    // ============================================================

    wire [15:0] s3_0, c3_0;
    wire [15:0] s3_1, c3_1;

    csa16 S3_CSA0 (.x(s2_0), .y(c2_0), .z(s2_1), .sum(s3_0), .carry(c3_0));
    csa16 S3_CSA1 (.x(c2_1), .y(s2_2), .z(c2_2), .sum(s3_1), .carry(c3_1));

    // Stage 3 rows:
    // s3_0, c3_0, s3_1, c3_1, c1_4, pp15


    // ============================================================
    // Stage 4: 6 rows -> 4 rows
    // ============================================================

    wire [15:0] s4_0, c4_0;
    wire [15:0] s4_1, c4_1;

    csa16 S4_CSA0 (.x(s3_0), .y(c3_0), .z(s3_1), .sum(s4_0), .carry(c4_0));
    csa16 S4_CSA1 (.x(c3_1), .y(c1_4), .z(pp15), .sum(s4_1), .carry(c4_1));

    // Stage 4 rows:
    // s4_0, c4_0, s4_1, c4_1


    // ============================================================
    // Stage 5: 4 rows -> 3 rows
    // ============================================================

    wire [15:0] s5_0, c5_0;

    csa16 S5_CSA0 (.x(s4_0), .y(c4_0), .z(s4_1), .sum(s5_0), .carry(c5_0));

    // Stage 5 rows:
    // s5_0, c5_0, c4_1


    // ============================================================
    // Stage 6: 3 rows -> 2 rows
    // ============================================================

    csa16 S6_CSA0 (.x(s5_0), .y(c5_0), .z(c4_1), .sum(row0), .carry(row1));

endmodule