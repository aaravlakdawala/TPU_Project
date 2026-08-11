`timescale 1ns / 1ps

module tb_mul16;

    reg  [15:0] a;
    reg  [15:0] b;

    wire [15:0] product;

    reg [15:0] expected;

    integer errors;

    mul16 DUT (
        .a(a),
        .b(b),
        .product(product)
    );

    task run_test;
        input [15:0] test_a;
        input [15:0] test_b;
        begin
            a = test_a;
            b = test_b;
            #10;

            expected = a * b;

            $display("a=%h b=%h | product=%h expected=%h",
                     a, b, product, expected);

            if (product !== expected) begin
                $display("ERROR");
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        $display("Testing mul16...");
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
        run_test(16'hFFFF, 16'hFFFF);
        run_test(16'h1234, 16'h0003);
        run_test(16'h1234, 16'h5678);
        run_test(16'h8000, 16'h0002);
        run_test(16'h8000, 16'hFFFF);
        run_test(16'hFFFE, 16'h0002);

        if (errors == 0)
            $display("All mul16 tests passed.");
        else
            $display("mul16 failed with %0d errors.", errors);

        $finish;
    end

endmodule