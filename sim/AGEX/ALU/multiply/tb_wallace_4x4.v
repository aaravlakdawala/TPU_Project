`timescale 1ns/1ps

module tb_wallace_4x4;

    reg  [3:0] a;
    reg  [3:0] b;

    wire [7:0] product;

    integer i;
    integer j;
    integer errors;

    wallace_4x4 dut (
        .a(a),
        .b(b),
        .product(product)
    );

    initial begin
        errors = 0;

        $display("Testing 4x4 Wallace multiplier");
        $display("--------------------------------");

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0];
                b = j[3:0];

                #10;

                if (product !== (i * j)) begin
                    $display("ERROR: %0d * %0d = %0d, got %0d",
                             i, j, i * j, product);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0) begin
            $display("All 4x4 Wallace multiplier tests passed.");
        end else begin
            $display("Total errors: %0d", errors);
        end

        $finish;
    end

endmodule