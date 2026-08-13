`timescale 1ns / 1ps

module tb_de_agex_top;

    reg clk;
    reg reset;

    reg [15:0] de_npc;
    reg [15:0] de_ir;
    reg        de_v;

    reg        mem_stall;

    reg [2:0]  sr_drid;
    reg [15:0] sr_reg_data;
    reg        v_sr_ld_reg;

    reg [2:0]  sr_cc_data;
    reg        v_sr_ld_cc;

    reg [2:0]  mem_drid;
    reg        v_mem_ld_reg;
    reg        v_mem_ld_cc;

    wire        ld_agex;
    wire        agex_v_next;
    wire        v_de_br_stall;
    wire        dep_stall_debug;

    wire        ld_mem;
    wire        v_agex_ld_cc;
    wire        v_agex_ld_reg;
    wire        v_agex_br_stall;

    wire [15:0] mem_npc;
    wire [15:0] mem_ir;
    wire [2:0]  mem_cc;
    wire [2:0]  mem_drid_out;
    wire [10:0] mem_cs;
    wire [15:0] mem_address;
    wire [15:0] mem_alu_result;
    wire        mem_v;

    wire [23:0] control_store_out_debug;
    wire [20:0] agex_cs_debug;

    wire [15:0] agex_npc_debug;
    wire [15:0] agex_ir_debug;
    wire [15:0] agex_sr1_debug;
    wire [15:0] agex_sr2_debug;
    wire [2:0]  agex_cc_debug;
    wire [2:0]  agex_drid_debug;
    wire        agex_v_debug;

    wire [2:0]  aluk_debug;
    wire        sr2mux_sel_debug;
    wire        alu_resultmux_sel_debug;
    wire        addr1mux_sel_debug;
    wire [1:0]  addr2mux_sel_debug;
    wire        lshf1_sel_debug;
    wire        addressmux_sel_debug;

    wire [15:0] comb_mem_address;
    wire [15:0] comb_mem_alu_result;

    de_agex_top DUT (
        .clk(clk),
        .reset(reset),

        .de_npc(de_npc),
        .de_ir(de_ir),
        .de_v(de_v),

        .mem_stall(mem_stall),

        .sr_drid(sr_drid),
        .sr_reg_data(sr_reg_data),
        .v_sr_ld_reg(v_sr_ld_reg),

        .sr_cc_data(sr_cc_data),
        .v_sr_ld_cc(v_sr_ld_cc),

        .mem_drid(mem_drid),
        .v_mem_ld_reg(v_mem_ld_reg),
        .v_mem_ld_cc(v_mem_ld_cc),

        .ld_agex(ld_agex),
        .agex_v_next(agex_v_next),
        .v_de_br_stall(v_de_br_stall),
        .dep_stall_debug(dep_stall_debug),

        .ld_mem(ld_mem),
        .v_agex_ld_cc(v_agex_ld_cc),
        .v_agex_ld_reg(v_agex_ld_reg),
        .v_agex_br_stall(v_agex_br_stall),

        .mem_npc(mem_npc),
        .mem_ir(mem_ir),
        .mem_cc(mem_cc),
        .mem_drid_out(mem_drid_out),
        .mem_cs(mem_cs),
        .mem_address(mem_address),
        .mem_alu_result(mem_alu_result),
        .mem_v(mem_v),

        .control_store_out_debug(control_store_out_debug),
        .agex_cs_debug(agex_cs_debug),

        .agex_npc_debug(agex_npc_debug),
        .agex_ir_debug(agex_ir_debug),
        .agex_sr1_debug(agex_sr1_debug),
        .agex_sr2_debug(agex_sr2_debug),
        .agex_cc_debug(agex_cc_debug),
        .agex_drid_debug(agex_drid_debug),
        .agex_v_debug(agex_v_debug),

        .aluk_debug(aluk_debug),
        .sr2mux_sel_debug(sr2mux_sel_debug),
        .alu_resultmux_sel_debug(alu_resultmux_sel_debug),
        .addr1mux_sel_debug(addr1mux_sel_debug),
        .addr2mux_sel_debug(addr2mux_sel_debug),
        .lshf1_sel_debug(lshf1_sel_debug),
        .addressmux_sel_debug(addressmux_sel_debug),

        .comb_mem_address(comb_mem_address),
        .comb_mem_alu_result(comb_mem_alu_result)
    );

    always begin
        #5 clk = ~clk;
    end

    task check;
        input condition;
        input [255:0] message;
        begin
            if (!condition) begin
                $display("FAIL: %s", message);
                $display("Time: %0t", $time);
                $finish;
            end
            else begin
                $display("PASS: %s", message);
            end
        end
    endtask

    task write_reg;
        input [2:0]  reg_id;
        input [15:0] value;
        begin
            sr_drid      = reg_id;
            sr_reg_data  = value;
            v_sr_ld_reg  = 1'b1;
            de_v         = 1'b0;
            #10;

            v_sr_ld_reg  = 1'b0;
            sr_drid      = 3'b000;
            sr_reg_data  = 16'h0000;
            #10;
        end
    endtask

    task run_arith_test;
        input [15:0] instr;
        input [15:0] npc_value;
        input [2:0]  expected_drid;
        input [2:0]  expected_aluk;
        input        expected_sr2mux;
        input [15:0] expected_sr1;
        input [15:0] expected_sr2;
        input [15:0] expected_result;
        input [255:0] test_name;
        begin
            $display("");
            $display("Running: %s", test_name);

            de_npc = npc_value;
            de_ir  = instr;
            de_v   = 1'b1;

            /*
                First active clock edge:
                    Decode latches instruction into AGEX.
            */
            #10;

            check(dep_stall_debug == 1'b0, "No dependency stall");
            check(agex_v_debug == 1'b1, "Instruction became valid in AGEX");
            check(agex_ir_debug == instr, "AGEX.IR captured instruction");
            check(agex_drid_debug == expected_drid, "AGEX.DRID captured expected DR");
            check(agex_sr1_debug == expected_sr1, "AGEX.SR1 captured expected value");

            if (expected_sr2mux == 1'b0) begin
            check(agex_sr2_debug == expected_sr2, "AGEX.SR2 captured expected value");
            end
            else begin
            $display("PASS: AGEX.SR2 ignored for immediate-mode instruction");
            end

            check(aluk_debug == expected_aluk, "ALUK decoded correctly");
            check(sr2mux_sel_debug == expected_sr2mux, "SR2MUX decoded correctly");
            check(alu_resultmux_sel_debug == 1'b1, "ALU.RESULTMUX selects ALU result");

            /*
                While the instruction is currently in AGEX, these valid-gated
                AGEX signals should be asserted.
            */
            check(v_agex_ld_reg == 1'b1, "V.AGEX.LD.REG asserted while instruction is in AGEX");
            check(v_agex_ld_cc == 1'b1, "V.AGEX.LD.CC asserted while instruction is in AGEX");

            /*
                Stop feeding a valid Decode instruction so the next cycle
                does not keep reinserting the same instruction.
            */
            de_v = 1'b0;

            /*
                Second active clock edge:
                    AGEX result latches into MEM.
                    At the same time, Decode sends a bubble into AGEX.
            */
            #10;

            check(mem_v == 1'b1, "MEM.V captured valid instruction");
            check(mem_ir == instr, "MEM.IR captured instruction");
            check(mem_drid_out == expected_drid, "MEM.DRID captured expected DR");
            check(mem_alu_result == expected_result, "MEM.ALU.RESULT matched expected result");

            /*
                One extra bubble cycle to clear AGEX before the next test.
            */
            #10;
        end
    endtask

    initial begin
        $display("Starting DE + AGEX arithmetic integration test...");

        clk = 1'b0;
        reset = 1'b1;

        de_npc = 16'h0000;
        de_ir  = 16'h0000;
        de_v   = 1'b0;

        mem_stall = 1'b0;

        sr_drid = 3'b000;
        sr_reg_data = 16'h0000;
        v_sr_ld_reg = 1'b0;

        sr_cc_data = 3'b010;
        v_sr_ld_cc = 1'b0;

        mem_drid = 3'b000;
        v_mem_ld_reg = 1'b0;
        v_mem_ld_cc = 1'b0;

        /*
            Reset internal pipeline registers.
        */
        #12;
        reset = 1'b0;

        /*
            Preload register file through SR writeback port.

            R1 = 5
            R2 = 3
            R5 = 00FF
            R6 = 0F0F
        */
        write_reg(3'b001, 16'h0005);
        write_reg(3'b010, 16'h0003);
        write_reg(3'b101, 16'h00FF);
        write_reg(3'b110, 16'h0F0F);

        /*
            ADD R3, R1, R2

            opcode = 0001
            DR     = 011
            SR1    = 001
            bit5   = 0
            SR2    = 010

            hex = 1642
            expected = 5 + 3 = 8
            ALUK = 000
            SR2MUX = 0
        */
        run_arith_test(
            16'h1642,
            16'h3002,
            3'b011,
            3'b000,
            1'b0,
            16'h0005,
            16'h0003,
            16'h0008,
            "ADD R3, R1, R2"
        );

        /*
            ADD R3, R1, #4

            opcode = 0001
            DR     = 011
            SR1    = 001
            bit5   = 1
            imm5   = 00100

            hex = 1664
            expected = 5 + 4 = 9
            ALUK = 000
            SR2MUX = 1
        */
        run_arith_test(
            16'h1664,
            16'h3004,
            3'b011,
            3'b000,
            1'b1,
            16'h0005,
            16'h0003,
            16'h0009,
            "ADD R3, R1, #4"
        );

        /*
            AND R4, R5, R6

            opcode = 0101
            DR     = 100
            SR1    = 101
            bit5   = 0
            SR2    = 110

            hex = 5946
            expected = 00FF & 0F0F = 000F
            ALUK = 001
            SR2MUX = 0
        */
        run_arith_test(
            16'h5946,
            16'h3006,
            3'b100,
            3'b001,
            1'b0,
            16'h00FF,
            16'h0F0F,
            16'h000F,
            "AND R4, R5, R6"
        );

        /*
            AND R4, R5, #15

            opcode = 0101
            DR     = 100
            SR1    = 101
            bit5   = 1
            imm5   = 01111

            hex = 596F
            expected = 00FF & 000F = 000F
            ALUK = 001
            SR2MUX = 1
        */
        run_arith_test(
            16'h596F,
            16'h3008,
            3'b100,
            3'b001,
            1'b1,
            16'h00FF,
            16'h0F0F,
            16'h000F,
            "AND R4, R5, #15"
        );

        /*
            XOR R7, R5, R6

            opcode = 1001
            DR     = 111
            SR1    = 101
            bit5   = 0
            SR2    = 110

            hex = 9F46
            expected = 00FF ^ 0F0F = 0FF0
            ALUK = 010
            SR2MUX = 0
        */
        run_arith_test(
            16'h9F46,
            16'h300A,
            3'b111,
            3'b010,
            1'b0,
            16'h00FF,
            16'h0F0F,
            16'h0FF0,
            "XOR R7, R5, R6"
        );

        /*
            XOR R7, R5, #15

            opcode = 1001
            DR     = 111
            SR1    = 101
            bit5   = 1
            imm5   = 01111

            hex = 9F6F
            expected = 00FF ^ 000F = 00F0
            ALUK = 010
            SR2MUX = 1
        */
        run_arith_test(
            16'h9F6F,
            16'h300C,
            3'b111,
            3'b010,
            1'b1,
            16'h00FF,
            16'h0F0F,
            16'h00F0,
            "XOR R7, R5, #15"
        );

        /*
            MUL R4, R1, R2

            Custom opcode = 1010
            DR            = 100
            SR1           = 001
            bit5          = 0
            SR2           = 010

            hex = A842

            Control-store address:
                {IR[15:11], IR[5]} = 101010 = row 42

            expected = 5 * 3 = 15
            ALUK = 100
            SR2MUX = 0
        */
        run_arith_test(
            16'hA842,
            16'h300E,
            3'b100,
            3'b100,
            1'b0,
            16'h0005,
            16'h0003,
            16'h000F,
            "MUL R4, R1, R2"
        );

        $display("");
        $display("All DE + AGEX arithmetic integration tests passed.");
        $finish;
    end

endmodule