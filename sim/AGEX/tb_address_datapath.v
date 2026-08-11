`timescale 1ns / 1ps

module tb_address_datapath;

    reg  [15:0] agex_npc;
    reg  [15:0] agex_sr1;
    reg  [15:0] agex_ir;

    reg         addr1mux_sel;
    reg  [1:0] addr2mux_sel;
    reg         lshf1_sel;
    reg         addressmux_sel;

    wire [15:0] mem_address;

    wire [15:0] addr1mux_out;
    wire [15:0] addr2mux_out;
    wire [15:0] lshf1_out;
    wire [15:0] addr2_final_out;
    wire [15:0] sext6_out;
    wire [15:0] sext9_out;
    wire [15:0] sext11_out;
    wire [15:0] zext8_lshf1_out;
    wire [15:0] address_adder_out;

    reg [15:0] expected;
    integer errors;

    address_datapath DUT (
        .agex_npc(agex_npc),
        .agex_sr1(agex_sr1),
        .agex_ir(agex_ir),

        .addr1mux_sel(addr1mux_sel),
        .addr2mux_sel(addr2mux_sel),
        .lshf1_sel(lshf1_sel),
        .addressmux_sel(addressmux_sel),

        .mem_address(mem_address),

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
        input [15:0] test_ir;
        input        test_addr1mux_sel;
        input [1:0]  test_addr2mux_sel;
        input        test_lshf1_sel;
        input        test_addressmux_sel;
        input [15:0] test_expected;

        begin
            agex_npc = test_npc;
            agex_sr1 = test_sr1;
            agex_ir  = test_ir;

            addr1mux_sel   = test_addr1mux_sel;
            addr2mux_sel   = test_addr2mux_sel;
            lshf1_sel      = test_lshf1_sel;
            addressmux_sel = test_addressmux_sel;

            expected = test_expected;

            #1;

            $display("------------------------------------------------------------");
            $display("TEST: %s", name);
            $display("NPC=%h SR1=%h IR=%h ADDR1MUX=%b ADDR2MUX=%b LSHF1=%b ADDRESSMUX=%b",
                     agex_npc, agex_sr1, agex_ir,
                     addr1mux_sel, addr2mux_sel, lshf1_sel, addressmux_sel);

            $display("SEXT6=%h SEXT9=%h SEXT11=%h ZEXT8_LSHF1=%h",
                     sext6_out, sext9_out, sext11_out, zext8_lshf1_out);

            $display("ADDR1_OUT=%h ADDR2_OUT=%h LSHF1_OUT=%h ADDR2_FINAL=%h ADDER_OUT=%h MEM_ADDRESS=%h EXPECTED=%h",
                     addr1mux_out, addr2mux_out, lshf1_out, addr2_final_out,
                     address_adder_out, mem_address, expected);

            if (mem_address !== expected) begin
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
        $display("Testing AGEX address_datapath with optional LSHF1");
        $display("============================================================");

        run_test("ADDR1=NPC, ADDR2=ZERO, no shift: 3000 + 0 = 3000",
                 16'h3000, 16'h4000, 16'h0000,
                 1'b0, 2'b00, 1'b0, 1'b0,
                 16'h3000);

        run_test("ADDR1=SR1, ADDR2=ZERO, no shift: 4000 + 0 = 4000",
                 16'h3000, 16'h4000, 16'h0000,
                 1'b1, 2'b00, 1'b0, 1'b0,
                 16'h4000);

        run_test("LDB/STB style: SR1 4000 + SEXT6(+5), no shift = 4005",
                 16'h3000, 16'h4000, 16'h0005,
                 1'b1, 2'b01, 1'b0, 1'b0,
                 16'h4005);

        run_test("LDB/STB style: SR1 4000 + SEXT6(-1), no shift = 3FFF",
                 16'h3000, 16'h4000, 16'h003F,
                 1'b1, 2'b01, 1'b0, 1'b0,
                 16'h3FFF);

        run_test("LDW/STW style: SR1 4000 + LSHF1(SEXT6(+5)) = 400A",
                 16'h3000, 16'h4000, 16'h0005,
                 1'b1, 2'b01, 1'b1, 1'b0,
                 16'h400A);

        run_test("LDW/STW style: SR1 4000 + LSHF1(SEXT6(-1)) = 3FFE",
                 16'h3000, 16'h4000, 16'h003F,
                 1'b1, 2'b01, 1'b1, 1'b0,
                 16'h3FFE);

        run_test("BR/LEA style: NPC 3000 + LSHF1(SEXT9(+5)) = 300A",
                 16'h3000, 16'h4000, 16'h0005,
                 1'b0, 2'b10, 1'b1, 1'b0,
                 16'h300A);

        run_test("BR/LEA style: NPC 3000 + LSHF1(SEXT9(-1)) = 2FFE",
                 16'h3000, 16'h4000, 16'h01FF,
                 1'b0, 2'b10, 1'b1, 1'b0,
                 16'h2FFE);

        run_test("JSR style: NPC 3000 + LSHF1(SEXT11(+5)) = 300A",
                 16'h3000, 16'h4000, 16'h0005,
                 1'b0, 2'b11, 1'b1, 1'b0,
                 16'h300A);

        run_test("JSR style: NPC 3000 + LSHF1(SEXT11(-1)) = 2FFE",
                 16'h3000, 16'h4000, 16'h07FF,
                 1'b0, 2'b11, 1'b1, 1'b0,
                 16'h2FFE);

        run_test("ADDRESSMUX selects ZEXT8_LSHF1: IR[7:0]=25, address=004A",
                 16'h3000, 16'h4000, 16'h0025,
                 1'b0, 2'b00, 1'b0, 1'b1,
                 16'h004A);

        run_test("ADDRESSMUX selects ZEXT8_LSHF1 max: IR[7:0]=FF, address=01FE",
                 16'h3000, 16'h4000, 16'h00FF,
                 1'b0, 2'b00, 1'b0, 1'b1,
                 16'h01FE);

        $display("============================================================");

        if (errors == 0)
            $display("ALL ADDRESS_DATAPATH TESTS PASSED.");
        else
            $display("ADDRESS_DATAPATH FAILED WITH %0d ERROR(S).", errors);

        $display("============================================================");

        $finish;
    end

endmodule