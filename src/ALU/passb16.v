`timescale 1ns / 1ps

module passb16 (
    input  wire [15:0] b,
    output wire [15:0] y
);

    buf G0  (y[0],  b[0]);
    buf G1  (y[1],  b[1]);
    buf G2  (y[2],  b[2]);
    buf G3  (y[3],  b[3]);
    buf G4  (y[4],  b[4]);
    buf G5  (y[5],  b[5]);
    buf G6  (y[6],  b[6]);
    buf G7  (y[7],  b[7]);
    buf G8  (y[8],  b[8]);
    buf G9  (y[9],  b[9]);
    buf G10 (y[10], b[10]);
    buf G11 (y[11], b[11]);
    buf G12 (y[12], b[12]);
    buf G13 (y[13], b[13]);
    buf G14 (y[14], b[14]);
    buf G15 (y[15], b[15]);

endmodule