`timescale 1ns/1ps

module tb_pp_gen_16;

    reg  [15:0] a;
    reg  [15:0] b;

    wire [15:0] pp0;
    wire [15:0] pp1;
    wire [15:0] pp2;
    wire [15:0] pp3;
    wire [15:0] pp4;
    wire [15:0] pp5;
    wire [15:0] pp6;
    wire [15:0] pp7;
    wire [15:0] pp8;
    wire [15:0] pp9;
    wire [15:0] pp10;
    wire [15:0] pp11;
    wire [15:0] pp12;
    wire [15:0] pp13;
    wire [15:0] pp14;
    wire [15:0] pp15;

    pp_gen_16 DUT (
        .a(a),
        .b(b),
        .pp0(pp0),
        .pp1(pp1),
        .pp2(pp2),
        .pp3(pp3),
        .pp4(pp4),
        .pp5(pp5),
        .pp6(pp6),
        .pp7(pp7),
        .pp8(pp8),
        .pp9(pp9),
        .pp10(pp10),
        .pp11(pp11),
        .pp12(pp12),
        .pp13(pp13),
        .pp14(pp14),
        .pp15(pp15)
    );

    initial begin
        $display("Testing pp_gen_16...");

        a = 16'h0003;
        b = 16'h0005;
        #10;

        $display("Test 1: a=%h b=%h", a, b);
        $display("pp0  = %h, expected 0005", pp0);
        $display("pp1  = %h, expected 000a", pp1);
        $display("pp2  = %h, expected 0000", pp2);
        $display("");

        if (pp0 !== 16'h0005) $display("ERROR: pp0 wrong");
        if (pp1 !== 16'h000A) $display("ERROR: pp1 wrong");
        if (pp2 !== 16'h0000) $display("ERROR: pp2 wrong");

        a = 16'h0004;
        b = 16'h0007;
        #10;

        $display("Test 2: a=%h b=%h", a, b);
        $display("pp0  = %h, expected 0000", pp0);
        $display("pp1  = %h, expected 0000", pp1);
        $display("pp2  = %h, expected 001c", pp2);
        $display("");

        if (pp0 !== 16'h0000) $display("ERROR: pp0 wrong");
        if (pp1 !== 16'h0000) $display("ERROR: pp1 wrong");
        if (pp2 !== 16'h001C) $display("ERROR: pp2 wrong");

        a = 16'h8000;
        b = 16'h0001;
        #10;

        $display("Test 3: a=%h b=%h", a, b);
        $display("pp15 = %h, expected 8000", pp15);
        $display("");

        if (pp15 !== 16'h8000) $display("ERROR: pp15 wrong");

        a = 16'hFFFF;
        b = 16'h0001;
        #10;

        $display("Test 4: a=%h b=%h", a, b);
        $display("pp0  = %h, expected 0001", pp0);
        $display("pp1  = %h, expected 0002", pp1);
        $display("pp2  = %h, expected 0004", pp2);
        $display("pp15 = %h, expected 8000", pp15);

        if (pp0  !== 16'h0001) $display("ERROR: pp0 wrong");
        if (pp1  !== 16'h0002) $display("ERROR: pp1 wrong");
        if (pp2  !== 16'h0004) $display("ERROR: pp2 wrong");
        if (pp15 !== 16'h8000) $display("ERROR: pp15 wrong");

        $display("Finished pp_gen_16 test.");
        $finish;
    end

endmodule