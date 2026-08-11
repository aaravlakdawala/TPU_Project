`timescale 1ns / 1ps

module mul16 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] product
);

    wire [15:0] pp0;
    wire [15:0] pp1;
    wire [15:0] pp2;
    wire [15:0] pp3;
    wire [15:0] pp4;
    wire [15:0] pp5;
    wire [15:0] pp6;
    wire [15:0] pp7;
    wire [15:0] pp8;
    wire [15:0] pp9;
    wire [15:0] pp10;
    wire [15:0] pp11;
    wire [15:0] pp12;
    wire [15:0] pp13;
    wire [15:0] pp14;
    wire [15:0] pp15;

    wire [15:0] row0;
    wire [15:0] row1;

    wire cout_unused;
    wire pg_unused;
    wire gg_unused;

    pp_gen_16 PPGEN (
        .a(a),
        .b(b),
        .pp0(pp0),
        .pp1(pp1),
        .pp2(pp2),
        .pp3(pp3),
        .pp4(pp4),
        .pp5(pp5),
        .pp6(pp6),
        .pp7(pp7),
        .pp8(pp8),
        .pp9(pp9),
        .pp10(pp10),
        .pp11(pp11),
        .pp12(pp12),
        .pp13(pp13),
        .pp14(pp14),
        .pp15(pp15)
    );

    compressor_tree CTREE (
        .pp0(pp0),
        .pp1(pp1),
        .pp2(pp2),
        .pp3(pp3),
        .pp4(pp4),
        .pp5(pp5),
        .pp6(pp6),
        .pp7(pp7),
        .pp8(pp8),
        .pp9(pp9),
        .pp10(pp10),
        .pp11(pp11),
        .pp12(pp12),
        .pp13(pp13),
        .pp14(pp14),
        .pp15(pp15),
        .row0(row0),
        .row1(row1)
    );

    cla_16bit FINAL_ADD (
        .a(row0),
        .b(row1),
        .cin(1'b0),
        .sum(product),
        .cout(cout_unused),
        .pg(pg_unused),
        .gg(gg_unused)
    );

endmodule