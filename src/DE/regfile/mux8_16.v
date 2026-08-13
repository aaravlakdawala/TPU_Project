`timescale 1ns / 1ps

module mux8_16 (
    input  wire [15:0] in0,
    input  wire [15:0] in1,
    input  wire [15:0] in2,
    input  wire [15:0] in3,
    input  wire [15:0] in4,
    input  wire [15:0] in5,
    input  wire [15:0] in6,
    input  wire [15:0] in7,

    input  wire [2:0]  sel,

    output wire [15:0] out
);

    wire nsel2;
    wire nsel1;
    wire nsel0;

    not NOT_SEL2(nsel2, sel[2]);
    not NOT_SEL1(nsel1, sel[1]);
    not NOT_SEL0(nsel0, sel[0]);

    wire choose0;
    wire choose1;
    wire choose2;
    wire choose3;
    wire choose4;
    wire choose5;
    wire choose6;
    wire choose7;

    and CHOOSE0(choose0, nsel2, nsel1, nsel0);
    and CHOOSE1(choose1, nsel2, nsel1, sel[0]);
    and CHOOSE2(choose2, nsel2, sel[1], nsel0);
    and CHOOSE3(choose3, nsel2, sel[1], sel[0]);
    and CHOOSE4(choose4, sel[2], nsel1, nsel0);
    and CHOOSE5(choose5, sel[2], nsel1, sel[0]);
    and CHOOSE6(choose6, sel[2], sel[1], nsel0);
    and CHOOSE7(choose7, sel[2], sel[1], sel[0]);

    wire [15:0] gated0;
    wire [15:0] gated1;
    wire [15:0] gated2;
    wire [15:0] gated3;
    wire [15:0] gated4;
    wire [15:0] gated5;
    wire [15:0] gated6;
    wire [15:0] gated7;

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : GEN_MUX_BITS
            and GATE0(gated0[i], in0[i], choose0);
            and GATE1(gated1[i], in1[i], choose1);
            and GATE2(gated2[i], in2[i], choose2);
            and GATE3(gated3[i], in3[i], choose3);
            and GATE4(gated4[i], in4[i], choose4);
            and GATE5(gated5[i], in5[i], choose5);
            and GATE6(gated6[i], in6[i], choose6);
            and GATE7(gated7[i], in7[i], choose7);

            or OUT_OR(
                out[i],
                gated0[i],
                gated1[i],
                gated2[i],
                gated3[i],
                gated4[i],
                gated5[i],
                gated6[i],
                gated7[i]
            );
        end
    endgenerate

endmodule