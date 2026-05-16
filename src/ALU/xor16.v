`timescale 1ns / 1ps

module xor16 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] y
);

    xor G0  (y[0],  a[0],  b[0]);
    xor G1  (y[1],  a[1],  b[1]);
    xor G2  (y[2],  a[2],  b[2]);
    xor G3  (y[3],  a[3],  b[3]);
    xor G4  (y[4],  a[4],  b[4]);
    xor G5  (y[5],  a[5],  b[5]);
    xor G6  (y[6],  a[6],  b[6]);
    xor G7  (y[7],  a[7],  b[7]);
    xor G8  (y[8],  a[8],  b[8]);
    xor G9  (y[9],  a[9],  b[9]);
    xor G10 (y[10], a[10], b[10]);
    xor G11 (y[11], a[11], b[11]);
    xor G12 (y[12], a[12], b[12]);
    xor G13 (y[13], a[13], b[13]);
    xor G14 (y[14], a[14], b[14]);
    xor G15 (y[15], a[15], b[15]);

endmodule