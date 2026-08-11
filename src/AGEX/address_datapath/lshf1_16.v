`timescale 1ns / 1ps

module lshf1_16 (
    input  wire [15:0] in,
    output wire [15:0] out
);

    supply0 z;

    buf B0  (out[0],  z);
    buf B1  (out[1],  in[0]);
    buf B2  (out[2],  in[1]);
    buf B3  (out[3],  in[2]);
    buf B4  (out[4],  in[3]);
    buf B5  (out[5],  in[4]);
    buf B6  (out[6],  in[5]);
    buf B7  (out[7],  in[6]);
    buf B8  (out[8],  in[7]);
    buf B9  (out[9],  in[8]);
    buf B10 (out[10], in[9]);
    buf B11 (out[11], in[10]);
    buf B12 (out[12], in[11]);
    buf B13 (out[13], in[12]);
    buf B14 (out[14], in[13]);
    buf B15 (out[15], in[14]);

endmodule