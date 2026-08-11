`timescale 1ns / 1ps

module zext8_lshf1 (
    input  wire [7:0]  in,
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

    buf B9  (out[9],  z);
    buf B10 (out[10], z);
    buf B11 (out[11], z);
    buf B12 (out[12], z);
    buf B13 (out[13], z);
    buf B14 (out[14], z);
    buf B15 (out[15], z);

endmodule