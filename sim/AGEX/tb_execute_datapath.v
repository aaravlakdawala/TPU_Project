`timescale 1ns / 1ps

module tb_execute_datapath;

    reg  [15:0] agex_sr1;
    reg  [15:0] agex_sr2;
    reg  [15:0] agex_ir;

    reg  [2:0]  aluk;
    reg         sr2mux_sel;
    reg         alu_resultmux_sel;

    wire [15:0] execute_result;
    wire [15:0] alu_result;
    wire [15:0] shf_result;
    wire [15:0] sr2mux_out;
    wire [15:0] sext5_out;

    reg [15:0] expected;
    integer errors;

    execute_datapath DUT (
        .agex_sr1(agex_sr1),
        .agex_sr2(agex_sr2),
        .agex_ir(agex_ir),
        .aluk(aluk),
        .sr2mux_sel(sr2mux_sel),
        .alu_resultmux_sel(alu_resultmux_sel),
        .execute_result(execute_result),
        .alu_result(alu_result),
        .shf_result(shf_result),
        .sr2mux_out(sr2mux_out),
        .sext5_out(sext5_out)
    );

    task run_test;
        input [80*8:1] name;
        input [15:0] test_sr1;
        input [15:0] test_sr2;
        input [15:0] test_ir;
        input [2:0]  test_aluk;
        input        test_sr2mux_sel;
        input        test_resultmux_sel;
        input [15:0] test_expected;

        begin
            agex_sr1 = test_sr1;
            agex_sr2 = test_sr2;
            agex_ir  = test_ir;

            aluk = test_aluk;
            sr2mux_sel = test_sr2mux_sel;
            alu_resultmux_sel = test_resultmux_sel;

            expected = test_expected;

            #1;

            $display("------------------------------------------------------------");
            $display("TEST: %s", name);
            $display("SR1=%h SR2=%h IR=%h ALUK=%b SR2MUX=%b RESULTMUX=%b",
                     agex_sr1, agex_sr2, agex_ir, aluk, sr2mux_sel, alu_resultmux_sel);
            $display("SEXT5=%h SR2MUX_OUT=%h ALU_RESULT=%h SHF_RESULT=%h EXECUTE_RESULT=%h EXPECTED=%h",
                     sext5_out, sr2mux_out, alu_result, shf_result, execute_result, expected);

            if (execute_result !== expected) begin
                $display("FAIL: %s", name);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %s", name);
            end
        end
    endtask

    initial begin
        errors = 0;

        $display("============================================================");
        $display("Testing AGEX execute_datapath");
        $display("This tests SEXT5, SR2MUX, ALU, SHF, and ALU_RESULTMUX.");
        $display("No clock is used here because this is only the combinational bottom execute datapath.");
        $display("============================================================");

        /*
            Control meaning:
            sr2mux_sel = 0 -> ALU B = AGEX.SR2
            sr2mux_sel = 1 -> ALU B = SEXT5(IR[4:0])

            alu_resultmux_sel = 0 -> execute_result = SHF result
            alu_resultmux_sel = 1 -> execute_result = ALU result

            ALUK:
            000 -> ADD
            001 -> AND
            010 -> XOR
            011 -> PASSB
            100 -> MUL
        */

        run_test("ADD register: 0003 + 0005 = 0008",
                 16'h0003, 16'h0005, 16'h0000,
                 3'b000, 1'b0, 1'b1,
                 16'h0008);

        run_test("ADD imm5: 0003 + SEXT5(11111=-1) = 0002",
                 16'h0003, 16'hAAAA, 16'h001F,
                 3'b000, 1'b1, 1'b1,
                 16'h0002);

        run_test("AND register: 00F0 & 0F0F = 0000",
                 16'h00F0, 16'h0F0F, 16'h0000,
                 3'b001, 1'b0, 1'b1,
                 16'h0000);

        run_test("AND imm5: 00F0 & SEXT5(11111=FFFF) = 00F0",
                 16'h00F0, 16'h1234, 16'h001F,
                 3'b001, 1'b1, 1'b1,
                 16'h00F0);

        run_test("XOR register: 00F0 ^ 0F0F = 0FFF",
                 16'h00F0, 16'h0F0F, 16'h0000,
                 3'b010, 1'b0, 1'b1,
                 16'h0FFF);

        run_test("PASSB register: pass SR2 = ABCD",
                 16'h1234, 16'hABCD, 16'h0000,
                 3'b011, 1'b0, 1'b1,
                 16'hABCD);

        run_test("MUL register: 0003 * 0005 = 000F",
                 16'h0003, 16'h0005, 16'h0000,
                 3'b100, 1'b0, 1'b1,
                 16'h000F);

        run_test("MUL low16 signed-style check: FFFF * 0002 = FFFE",
                 16'hFFFF, 16'h0002, 16'h0000,
                 3'b100, 1'b0, 1'b1,
                 16'hFFFE);

        /*
            Shift instruction fields:
            IR[5:4] = 00 -> LSHF
            IR[5:4] = 01 -> RSHFL
            IR[5:4] = 11 -> RSHFA
            IR[3:0] = shift amount
        */

        run_test("SHF LSHF: 0001 << 1 = 0002",
                 16'h0001, 16'h0000, 16'h0001,
                 3'b000, 1'b0, 1'b0,
                 16'h0002);

        run_test("SHF LSHF: 0001 << 4 = 0010",
                 16'h0001, 16'h0000, 16'h0004,
                 3'b000, 1'b0, 1'b0,
                 16'h0010);

        run_test("SHF RSHFL: 8000 >> 1 logical = 4000",
                 16'h8000, 16'h0000, 16'h0011,
                 3'b000, 1'b0, 1'b0,
                 16'h4000);

        run_test("SHF RSHFL: 8000 >> 4 logical = 0800",
                 16'h8000, 16'h0000, 16'h0014,
                 3'b000, 1'b0, 1'b0,
                 16'h0800);

        run_test("SHF RSHFA: 8000 >>> 1 arithmetic = C000",
                 16'h8000, 16'h0000, 16'h0031,
                 3'b000, 1'b0, 1'b0,
                 16'hC000);

        run_test("SHF RSHFA: 8000 >>> 4 arithmetic = F800",
                 16'h8000, 16'h0000, 16'h0034,
                 3'b000, 1'b0, 1'b0,
                 16'hF800);

        $display("============================================================");

        if (errors == 0) begin
            $display("ALL EXECUTE_DATAPATH TESTS PASSED.");
        end
        else begin
            $display("EXECUTE_DATAPATH FAILED WITH %0d ERROR(S).", errors);
        end

        $display("============================================================");

        $finish;
    end

endmodule