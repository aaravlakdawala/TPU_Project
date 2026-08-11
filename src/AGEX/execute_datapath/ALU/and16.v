`timescale 1ns / 1ps

module and16 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] y
);

    and G0  (y[0],  a[0],  b[0]);
    and G1  (y[1],  a[1],  b[1]);
    and G2  (y[2],  a[2],  b[2]);
    and G3  (y[3],  a[3],  b[3]);
    and G4  (y[4],  a[4],  b[4]);
    and G5  (y[5],  a[5],  b[5]);
    and G6  (y[6],  a[6],  b[6]);
    and G7  (y[7],  a[7],  b[7]);
    and G8  (y[8],  a[8],  b[8]);
    and G9  (y[9],  a[9],  b[9]);
    and G10 (y[10], a[10], b[10]);
    and G11 (y[11], a[11], b[11]);
    and G12 (y[12], a[12], b[12]);
    and G13 (y[13], a[13], b[13]);
    and G14 (y[14], a[14], b[14]);
    and G15 (y[15], a[15], b[15]);

endmodule