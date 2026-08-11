`timescale 1ns / 1ps

module tb_alu;

    reg  [15:0] a;
    reg  [15:0] b;
    reg  [2:0]  aluk;

    wire [15:0] result;

    reg [15:0] expected;
    integer errors;

    alu DUT (
        .a(a),
        .b(b),
        .aluk(aluk),
        .result(result)
    );

    task run_test;
        input [15:0] test_a;
        input [15:0] test_b;
        input [2:0]  test_aluk;
        input [15:0] test_expected;
        input [80*8:1] op_name;

        begin
            a = test_a;
            b = test_b;
            aluk = test_aluk;

            #1;

            expected = test_expected;

            $display("time=%0t | op=%s | a=%h b=%h aluk=%b | result=%h expected=%h",
                     $time, op_name, a, b, aluk, result, expected);

            if (result !== expected) begin
                $display("ERROR: %s failed", op_name);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %s combinational result visible after #1", op_name);
            end

            $display("");
        end
    endtask

    initial begin
        errors = 0;

        $display("Testing alu...");
        $display("All operations are combinational: no clocked latency inside ALU.");
        $display("The #1 delay is only for simulation settling, not a hardware pipeline cycle.");
        $display("------------------------------------------------------------");

        run_test(16'h0003, 16'h0005, 3'b000, 16'h0008, "ADD");
        run_test(16'h00F0, 16'h0F0F, 3'b001, 16'h0000, "AND");
        run_test(16'h00F0, 16'h0F0F, 3'b010, 16'h0FFF, "XOR");
        run_test(16'h1234, 16'hABCD, 3'b011, 16'hABCD, "PASSB");
        run_test(16'h0003, 16'h0005, 3'b100, 16'h000F, "MUL");

        run_test(16'hFFFF, 16'h0001, 3'b000, 16'h0000, "ADD overflow wrap");
        run_test(16'hFFFF, 16'h0002, 3'b100, 16'hFFFE, "MUL signed low16 check");
        run_test(16'h8000, 16'hFFFF, 3'b100, 16'h8000, "MUL signed low16 check 2");

        if (errors == 0) begin
            $display("All ALU tests passed.");
            $display("");
            $display("Cycle latency summary:");
            $display("ADD   : 0 extra cycles, combinational");
            $display("AND   : 0 extra cycles, combinational");
            $display("XOR   : 0 extra cycles, combinational");
            $display("PASSB : 0 extra cycles, combinational");
            $display("MUL   : 0 extra cycles, combinational");
            $display("");
            $display("Timing note:");
            $display("MUL likely has the longest propagation delay, but not extra cycle latency.");
            $display("Use synthesis timing report to see real max delay / Fmax.");
        end
        else begin
            $display("ALU failed with %0d errors.", errors);
        end

        $finish;
    end

endmodule