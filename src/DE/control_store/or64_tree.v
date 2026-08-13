`timescale 1ns / 1ps

module or64_tree (
    input  wire [63:0] in,
    output wire        out
);

    wire [31:0] level1;
    wire [15:0] level2;
    wire [7:0]  level3;
    wire [3:0]  level4;
    wire [1:0]  level5;

    genvar i;

    generate
        for (i = 0; i < 32; i = i + 1) begin : GEN_LEVEL1
            or OR_L1(level1[i], in[2*i], in[(2*i) + 1]);
        end

        for (i = 0; i < 16; i = i + 1) begin : GEN_LEVEL2
            or OR_L2(level2[i], level1[2*i], level1[(2*i) + 1]);
        end

        for (i = 0; i < 8; i = i + 1) begin : GEN_LEVEL3
            or OR_L3(level3[i], level2[2*i], level2[(2*i) + 1]);
        end

        for (i = 0; i < 4; i = i + 1) begin : GEN_LEVEL4
            or OR_L4(level4[i], level3[2*i], level3[(2*i) + 1]);
        end

        for (i = 0; i < 2; i = i + 1) begin : GEN_LEVEL5
            or OR_L5(level5[i], level4[2*i], level4[(2*i) + 1]);
        end
    endgenerate

    or OR_FINAL(out, level5[0], level5[1]);

endmodule