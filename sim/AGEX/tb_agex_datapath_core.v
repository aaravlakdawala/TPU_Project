`timescale 1ns / 1ps

module tb_agex_datapath_core;

    reg  [15:0] agex_npc;
    reg  [15:0] agex_sr1;
    reg  [15:0] agex_sr2;
    reg  [15:0] agex_ir;

    reg  [2:0]  aluk;
    reg         sr2mux_sel;
    reg         alu_resultmux_sel;

    reg         addr1mux_sel;
    reg  [1:0] addr2mux_sel;
    reg         lshf1_sel;
    reg         addressmux_sel;

    wire [15:0] mem_alu_result;
    wire [15:0] mem_address;

    wire [15:0] alu_result;
    wire [15:0] shf_result;
    wire [15:0] sr2mux_out;
    wire [15:0] sext5_out;

    wire [15:0] addr1mux_out;
    wire [15:0] addr2mux_out;
    wire [15:0] lshf1_out;
    wire [15:0] addr2_final_out;
    wire [15:0] sext6_out;
    wire [15:0] sext9_out;
    wire [15:0] sext11_out;
    wire [15:0] zext8_lshf1_out;
    wire [15:0] address_adder_out;

    reg [15:0] expected_alu_result;
    reg [15:0] expected_address;

    integer errors;

    agex_datapath_core DUT (
        .agex_npc(agex_npc),
        .agex_sr1(agex_sr1),
        .agex_sr2(agex_sr2),
        .agex_ir(agex_ir),

        .aluk(aluk),
        .sr2mux_sel(sr2mux_sel),
        .alu_resultmux_sel(alu_resultmux_sel),

        .addr1mux_sel(addr1mux_sel),
        .addr2mux_sel(addr2mux_sel),
        .lshf1_sel(lshf1_sel),
        .addressmux_sel(addressmux_sel),

        .mem_alu_result(mem_alu_result),
        .mem_address(mem_address),

        .alu_result(alu_result),
        .shf_result(shf_result),
        .sr2mux_out(sr2mux_out),
        .sext5_out(sext5_out),

        .addr1mux_out(addr1mux_out),
        .addr2mux_out(addr2mux_out),
        .lshf1_out(lshf1_out),
        .addr2_final_out(addr2_final_out),
        .sext6_out(sext6_out),
        .sext9_out(sext9_out),
        .sext11_out(sext11_out),
        .zext8_lshf1_out(zext8_lshf1_out),
        .address_adder_out(address_adder_out)
    );

    task run_test;
        input [80*8:1] name;

        input [15:0] test_npc;
        input [15:0] test_sr1;
        input [15:0] test_sr2;
        input [15:0] test_ir;

        input [2:0]  test_aluk;
        input        test_sr2mux_sel;
        input        test_alu_resultmux_sel;

        input        test_addr1mux_sel;
        input [1:0]  test_addr2mux_sel;
        input        test_lshf1_sel;
        input        test_addressmux_sel;

        input [15:0] test_expected_alu_result;
        input [15:0] test_expected_address;

        begin
            agex_npc = test_npc;
            agex_sr1 = test_sr1;
            agex_sr2 = test_sr2;
            agex_ir  = test_ir;

            aluk = test_aluk;
            sr2mux_sel = test_sr2mux_sel;
            alu_resultmux_sel = test_alu_resultmux_sel;

            addr1mux_sel = test_addr1mux_sel;
            addr2mux_sel = test_addr2mux_sel;
            lshf1_sel = test_lshf1_sel;
            addressmux_sel = test_addressmux_sel;

            expected_alu_result = test_expected_alu_result;
            expected_address = test_expected_address;

            #1;

            $display("------------------------------------------------------------");
            $display("TEST: %s", name);
            $display("NPC=%h SR1=%h SR2=%h IR=%h", agex_npc, agex_sr1, agex_sr2, agex_ir);

            $display("EXEC CTRL: ALUK=%b SR2MUX=%b ALU_RESULTMUX=%b",
                     aluk, sr2mux_sel, alu_resultmux_sel);

            $display("ADDR CTRL: ADDR1MUX=%b ADDR2MUX=%b LSHF1=%b ADDRESSMUX=%b",
                     addr1mux_sel, addr2mux_sel, lshf1_sel, addressmux_sel);

            $display("EXEC DEBUG: SEXT5=%h SR2MUX_OUT=%h ALU_RESULT=%h SHF_RESULT=%h",
                     sext5_out, sr2mux_out, alu_result, shf_result);

            $display("ADDR DEBUG: SEXT6=%h SEXT9=%h SEXT11=%h ZEXT8_LSHF1=%h",
                     sext6_out, sext9_out, sext11_out, zext8_lshf1_out);

            $display("ADDR DEBUG: ADDR1_OUT=%h ADDR2_OUT=%h LSHF1_OUT=%h ADDR2_FINAL=%h ADDER_OUT=%h",
                     addr1mux_out, addr2mux_out, lshf1_out, addr2_final_out, address_adder_out);

            $display("OUTPUTS: MEM_ALU_RESULT=%h EXPECTED_ALU=%h | MEM_ADDRESS=%h EXPECTED_ADDR=%h",
                     mem_alu_result, expected_alu_result, mem_address, expected_address);

            if (mem_alu_result !== expected_alu_result) begin
                $display("FAIL ALU RESULT: %s", name);
                errors = errors + 1;
            end

            if (mem_address !== expected_address) begin
                $display("FAIL ADDRESS: %s", name);
                errors = errors + 1;
            end

            if ((mem_alu_result === expected_alu_result) && (mem_address === expected_address))
                $display("PASS: %s", name);
        end
    endtask

    initial begin
        errors = 0;

        $display("============================================================");
        $display("Testing AGEX datapath core with optional address LSHF1");
        $display("============================================================");

        run_test("ADD reg + BR/LEA PC-relative shifted offset",
                 16'h3000, 16'h0003, 16'h0005, 16'h0005,
                 3'b000, 1'b0, 1'b1,
                 1'b0, 2'b10, 1'b1, 1'b0,
                 16'h0008, 16'h300A);

        run_test("ADD imm5 negative + LDW/STW base offset6 shifted negative",
                 16'h3000, 16'h4000, 16'hAAAA, 16'h003F,
                 3'b000, 1'b1, 1'b1,
                 1'b1, 2'b01, 1'b1, 1'b0,
                 16'h3FFF, 16'h3FFE);

        run_test("AND reg + NPC plus zero",
                 16'h3000, 16'h00F0, 16'h0F0F, 16'h0000,
                 3'b001, 1'b0, 1'b1,
                 1'b0, 2'b00, 1'b0, 1'b0,
                 16'h0000, 16'h3000);

        run_test("XOR reg + JSR-style shifted offset11 positive",
                 16'h3000, 16'h00F0, 16'h0F0F, 16'h0005,
                 3'b010, 1'b0, 1'b1,
                 1'b0, 2'b11, 1'b1, 1'b0,
                 16'h0FFF, 16'h300A);

        run_test("PASSB + LDB/STB base offset6 unshifted positive",
                 16'h3000, 16'h4000, 16'hABCD, 16'h0005,
                 3'b011, 1'b0, 1'b1,
                 1'b1, 2'b01, 1'b0, 1'b0,
                 16'hABCD, 16'h4005);

        run_test("MUL reg + addressmux zext8_lshf1",
                 16'h3000, 16'h0003, 16'h0005, 16'h0025,
                 3'b100, 1'b0, 1'b1,
                 1'b0, 2'b00, 1'b0, 1'b1,
                 16'h000F, 16'h004A);

        run_test("LSHF result + BR/LEA PC-relative shifted positive offset9",
                 16'h3000, 16'h0001, 16'h0000, 16'h0001,
                 3'b000, 1'b0, 1'b0,
                 1'b0, 2'b10, 1'b1, 1'b0,
                 16'h0002, 16'h3002);

        run_test("RSHFL result + addressmux zext8_lshf1",
                 16'h3000, 16'h8000, 16'h0000, 16'h001F,
                 3'b000, 1'b0, 1'b0,
                 1'b0, 2'b00, 1'b0, 1'b1,
                 16'h0001, 16'h003E);

        run_test("RSHFA result + JSR-style shifted negative offset11",
                 16'h3000, 16'h8000, 16'h0000, 16'h07F4,
                 3'b000, 1'b0, 1'b0,
                 1'b0, 2'b11, 1'b1, 1'b0,
                 16'hF800, 16'h2FE8);

        $display("============================================================");

        if (errors == 0)
            $display("ALL AGEX_DATAPATH_CORE TESTS PASSED.");
        else
            $display("AGEX_DATAPATH_CORE FAILED WITH %0d ERROR(S).", errors);

        $display("============================================================");

        $finish;
    end

endmodule