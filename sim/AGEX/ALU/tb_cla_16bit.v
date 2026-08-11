`timescale 1ns/1ps

module tb_cla_16bit;

    reg  [15:0] a;
    reg  [15:0] b;
    reg         cin;

    wire [15:0] sum;
    wire        cout;
    wire        pg;
    wire        gg;

    reg  [16:0] expected;

    cla_16bit dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout),
        .pg(pg),
        .gg(gg)
    );

    task run_test;
        input [15:0] test_a;
        input [15:0] test_b;
        input        test_cin;
        begin
            a = test_a;
            b = test_b;
            cin = test_cin;

            expected = test_a + test_b + test_cin;

            #10;

            $display("a=%h b=%h cin=%b | cout=%b sum=%h | expected=%h",
                     a, b, cin, cout, sum, expected);

            if ({cout, sum} !== expected) begin
                $display("ERROR: expected %h but got %h", expected, {cout, sum});
            end
        end
    endtask

    initial begin
        $display("Testing 16-bit CLA");
        $display("--------------------------------------");

        run_test(16'h0000, 16'h0000, 1'b0);
        run_test(16'h0003, 16'h0005, 1'b0);
        run_test(16'h00FF, 16'h0001, 1'b0);
        run_test(16'h0F0F, 16'h0001, 1'b1);
        run_test(16'h1234, 16'h1111, 1'b0);
        run_test(16'h7FFF, 16'h0001, 1'b0);
        run_test(16'hFFFF, 16'h0001, 1'b0);
        run_test(16'hFFFF, 16'hFFFF, 1'b1);

        $display("--------------------------------------");
        $display("Finished 16-bit CLA test");

        $finish;
    end

endmodule