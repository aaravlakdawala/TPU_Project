`timescale 1ns / 1ps

module tb_csa16;

    reg  [15:0] x;
    reg  [15:0] y;
    reg  [15:0] z;

    wire [15:0] sum;
    wire [15:0] carry;

    reg  [15:0] expected;
    reg  [15:0] actual;

    integer errors;

    csa16 DUT (
        .x(x),
        .y(y),
        .z(z),
        .sum(sum),
        .carry(carry)
    );

    initial begin
        errors = 0;

        $display("Testing csa16...");
        $display("--------------------------------");

        x = 16'h0005;
        y = 16'h000A;
        z = 16'h0000;
        #10;
        expected = x + y + z;
        actual = sum + carry;
        $display("x=%h y=%h z=%h | sum=%h carry=%h actual=%h expected=%h",
                 x, y, z, sum, carry, actual, expected);
        if (actual !== expected) begin
            $display("ERROR");
            errors = errors + 1;
        end

        x = 16'h0001;
        y = 16'h0001;
        z = 16'h0001;
        #10;
        expected = x + y + z;
        actual = sum + carry;
        $display("x=%h y=%h z=%h | sum=%h carry=%h actual=%h expected=%h",
                 x, y, z, sum, carry, actual, expected);
        if (actual !== expected) begin
            $display("ERROR");
            errors = errors + 1;
        end

        x = 16'h00FF;
        y = 16'h0001;
        z = 16'h0001;
        #10;
        expected = x + y + z;
        actual = sum + carry;
        $display("x=%h y=%h z=%h | sum=%h carry=%h actual=%h expected=%h",
                 x, y, z, sum, carry, actual, expected);
        if (actual !== expected) begin
            $display("ERROR");
            errors = errors + 1;
        end

        x = 16'hFFFF;
        y = 16'h0001;
        z = 16'h0001;
        #10;
        expected = x + y + z;
        actual = sum + carry;
        $display("x=%h y=%h z=%h | sum=%h carry=%h actual=%h expected=%h",
                 x, y, z, sum, carry, actual, expected);
        if (actual !== expected) begin
            $display("ERROR");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("All csa16 tests passed.");
        else
            $display("csa16 failed with %0d errors.", errors);

        $finish;
    end

endmodule