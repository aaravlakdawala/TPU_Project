`timescale 1ns / 1ps

module cs_decoder6to64 (
    input  wire [5:0]  a,
    output wire [63:0] y
);

    wire [7:0] upper_decode;
    wire [7:0] lower_decode;

    cs_decoder3to8 UPPER_DECODER (
        .a(a[5:3]),
        .y(upper_decode)
    );

    cs_decoder3to8 LOWER_DECODER (
        .a(a[2:0]),
        .y(lower_decode)
    );

    genvar i;
    genvar j;

    generate
        for (i = 0; i < 8; i = i + 1) begin : GEN_UPPER
            for (j = 0; j < 8; j = j + 1) begin : GEN_LOWER
                and ROW_GATE (
                    y[(i * 8) + j],
                    upper_decode[i],
                    lower_decode[j]
                );
            end
        end
    endgenerate

endmodule