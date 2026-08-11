`timescale 1ns / 1ps

module sext9 (
    input  wire [8:0]  in,
    output wire [15:0] out
);

    buf B0  (out[0],  in[0]);
    buf B1  (out[1],  in[1]);
    buf B2  (out[2],  in[2]);
    buf B3  (out[3],  in[3]);
    buf B4  (out[4],  in[4]);
    buf B5  (out[5],  in[5]);
    buf B6  (out[6],  in[6]);
    buf B7  (out[7],  in[7]);
    buf B8  (out[8],  in[8]);

    buf B9  (out[9],  in[8]);
    buf B10 (out[10], in[8]);
    buf B11 (out[11], in[8]);
    buf B12 (out[12], in[8]);
    buf B13 (out[13], in[8]);
    buf B14 (out[14], in[8]);
    buf B15 (out[15], in[8]);

endmodule