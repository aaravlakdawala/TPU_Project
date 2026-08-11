`timescale 1ns / 1ps

module tb_compressor_tree;

    reg [15:0] a;
    reg [15:0] b;

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

    wire [15:0] row0;
    wire [15:0] row1;

    reg [15:0] actual;
    reg [15:0] expected;

    integer errors;

    pp_gen_16 PPGEN (
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

    compressor_tree DUT (
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
        .pp15(pp15),
        .row0(row0),
        .row1(row1)
    );

    task run_test;
        input [15:0] test_a;
        input [15:0] test_b;
        begin
            a = test_a;
            b = test_b;
            #10;

            actual = row0 + row1;
            expected = a * b;

            $display("a=%h b=%h | row0=%h row1=%h actual=%h expected=%h",
                     a, b, row0, row1, actual, expected);

            if (actual !== expected) begin
                $display("ERROR");
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        $display("Testing compressor_tree...");
        $display("--------------------------------");

        run_test(16'h0000, 16'h0000);
        run_test(16'h0001, 16'h0001);
        run_test(16'h0003, 16'h0005);
        run_test(16'h0004, 16'h0007);
        run_test(16'h000F, 16'h000F);
        run_test(16'h00FF, 16'h0002);
        run_test(16'h00FF, 16'h00FF);
        run_test(16'hFFFF, 16'h0001);
        run_test(16'hFFFF, 16'h0002);
        run_test(16'h1234, 16'h0003);
        run_test(16'h1234, 16'h5678);
        run_test(16'hFFFF, 16'hFFFF);

        if (errors == 0)
            $display("All compressor_tree tests passed.");
        else
            $display("compressor_tree failed with %0d errors.", errors);

        $finish;
    end

endmodule