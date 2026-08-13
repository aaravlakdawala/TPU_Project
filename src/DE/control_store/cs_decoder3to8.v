`timescale 1ns / 1ps

module cs_decoder3to8 (
    input  wire [2:0] a,
    output wire [7:0] y
);

    wire na2;
    wire na1;
    wire na0;

    not NOT_A2(na2, a[2]);
    not NOT_A1(na1, a[1]);
    not NOT_A0(na0, a[0]);

    and ROW0(y[0], na2, na1, na0);
    and ROW1(y[1], na2, na1, a[0]);
    and ROW2(y[2], na2, a[1], na0);
    and ROW3(y[3], na2, a[1], a[0]);
    and ROW4(y[4], a[2], na1, na0);
    and ROW5(y[5], a[2], na1, a[0]);
    and ROW6(y[6], a[2], a[1], na0);
    and ROW7(y[7], a[2], a[1], a[0]);

endmodule