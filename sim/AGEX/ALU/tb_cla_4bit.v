`timescale 1ns/1ps

module tb_cla_4bit;

    reg  [3:0] a;
    reg  [3:0] b;
    reg        cin;

    wire [3:0] sum;
    wire       cout;
    wire       pg;
    wire       gg;

    cla_4bit dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout),
        .pg(pg),
        .gg(gg)
    );

    initial begin
        $display("Testing 4-bit CLA");
        $display(" a    b   cin | cout sum | expected");

        a = 4'd0;  b = 4'd0;  cin = 1'b0; #10;
        $display("%d + %d + %b |  %b   %d  | %d", a, b, cin, cout, sum, a + b + cin);

        a = 4'd3;  b = 4'd5;  cin = 1'b0; #10;
        $display("%d + %d + %b |  %b   %d  | %d", a, b, cin, cout, sum, a + b + cin);

        a = 4'd7;  b = 4'd1;  cin = 1'b1; #10;
        $display("%d + %d + %b |  %b   %d  | %d", a, b, cin, cout, sum, a + b + cin);

        a = 4'd8;  b = 4'd7;  cin = 1'b0; #10;
        $display("%d + %d + %b |  %b   %d  | %d", a, b, cin, cout, sum, a + b + cin);

        a = 4'd15; b = 4'd1;  cin = 1'b0; #10;
        $display("%d + %d + %b |  %b   %d  | %d", a, b, cin, cout, sum, a + b + cin);

        a = 4'd15; b = 4'd15; cin = 1'b1; #10;
        $display("%d + %d + %b |  %b   %d  | %d", a, b, cin, cout, sum, a + b + cin);

        $finish;
    end

endmodule