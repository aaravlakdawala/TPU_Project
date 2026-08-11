`timescale 1ns / 1ps

module tb_agex_stage;

    reg clk;
    reg reset;

    reg [15:0] agex_npc;
    reg [15:0] agex_ir;
    reg [15:0] agex_sr1;
    reg [15:0] agex_sr2;
    reg [2:0]  agex_cc;
    reg [2:0]  agex_drid;
    reg        agex_v;

    reg [2:0]  aluk;
    reg        sr2mux_sel;
    reg        alu_resultmux_sel;

    reg        addr1mux_sel;
    reg [1:0]  addr2mux_sel;
    reg        lshf1_sel;
    reg        addressmux_sel;

    reg        agex_ld_cc;
    reg        agex_ld_reg;
    reg        agex_br_stall;

    reg [10:0] agex_mem_cs_in;
    reg        mem_stall;

    wire       ld_mem;
    wire       v_agex_ld_cc;
    wire       v_agex_ld_reg;
    wire       v_agex_br_stall;

    wire [15:0] mem_npc;
    wire [15:0] mem_ir;
    wire [2:0]  mem_cc;
    wire [2:0]  mem_drid;
    wire [10:0] mem_cs;
    wire [15:0] mem_address;
    wire [15:0] mem_alu_result;
    wire        mem_v;

    wire [15:0] comb_mem_address;
    wire [15:0] comb_mem_alu_result;

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

    integer errors;

    agex_stage DUT (
        .clk(clk),
        .reset(reset),

        .agex_npc(agex_npc),
        .agex_ir(agex_ir),
        .agex_sr1(agex_sr1),
        .agex_sr2(agex_sr2),
        .agex_cc(agex_cc),
        .agex_drid(agex_drid),
        .agex_v(agex_v),

        .aluk(aluk),
        .sr2mux_sel(sr2mux_sel),
        .alu_resultmux_sel(alu_resultmux_sel),

        .addr1mux_sel(addr1mux_sel),
        .addr2mux_sel(addr2mux_sel),
        .lshf1_sel(lshf1_sel),
        .addressmux_sel(addressmux_sel),

        .agex_ld_cc(agex_ld_cc),
        .agex_ld_reg(agex_ld_reg),
        .agex_br_stall(agex_br_stall),

        .agex_mem_cs_in(agex_mem_cs_in),
        .mem_stall(mem_stall),

        .ld_mem(ld_mem),
        .v_agex_ld_cc(v_agex_ld_cc),
        .v_agex_ld_reg(v_agex_ld_reg),
        .v_agex_br_stall(v_agex_br_stall),

        .mem_npc(mem_npc),
        .mem_ir(mem_ir),
        .mem_cc(mem_cc),
        .mem_drid(mem_drid),
        .mem_cs(mem_cs),
        .mem_address(mem_address),
        .mem_alu_result(mem_alu_result),
        .mem_v(mem_v),

        .comb_mem_address(comb_mem_address),
        .comb_mem_alu_result(comb_mem_alu_result),

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

    always begin
        #5 clk = ~clk;
    end

    task check16;
        input [120*8:1] name;
        input [15:0] actual;
        input [15:0] expected;
        begin
            if (actual !== expected) begin
                $display("FAIL: %s actual=%h expected=%h", name, actual, expected);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %s = %h", name, actual);
            end
        end
    endtask

    task check3;
        input [120*8:1] name;
        input [2:0] actual;
        input [2:0] expected;
        begin
            if (actual !== expected) begin
                $display("FAIL: %s actual=%b expected=%b", name, actual, expected);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %s = %b", name, actual);
            end
        end
    endtask

    task check11;
        input [120*8:1] name;
        input [10:0] actual;
        input [10:0] expected;
        begin
            if (actual !== expected) begin
                $display("FAIL: %s actual=%b expected=%b", name, actual, expected);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %s = %b", name, actual);
            end
        end
    endtask

    task check1;
        input [120*8:1] name;
        input actual;
        input expected;
        begin
            if (actual !== expected) begin
                $display("FAIL: %s actual=%b expected=%b", name, actual, expected);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %s = %b", name, actual);
            end
        end
    endtask

    initial begin
        errors = 0;
        clk = 0;
        reset = 1;

        agex_npc = 16'h0000;
        agex_ir = 16'h0000;
        agex_sr1 = 16'h0000;
        agex_sr2 = 16'h0000;
        agex_cc = 3'b000;
        agex_drid = 3'b000;
        agex_v = 1'b0;

        aluk = 3'b000;
        sr2mux_sel = 1'b0;
        alu_resultmux_sel = 1'b1;

        addr1mux_sel = 1'b0;
        addr2mux_sel = 2'b00;
        lshf1_sel = 1'b0;
        addressmux_sel = 1'b0;

        agex_ld_cc = 1'b0;
        agex_ld_reg = 1'b0;
        agex_br_stall = 1'b0;

        agex_mem_cs_in = 11'b00000000000;
        mem_stall = 1'b0;

        $display("============================================================");
        $display("Testing AGEX stage pipeline registers");
        $display("============================================================");

        #12;
        reset = 0;

        /*
            Test 1:
            Normal advance into MEM.
            ADD: SR1 + SR2 = 0003 + 0005 = 0008
            Address: NPC + LSHF1(SEXT9(IR[8:0])) = 3000 + 000A = 300A
        */
        agex_npc = 16'h3000;
        agex_ir = 16'h0005;
        agex_sr1 = 16'h0003;
        agex_sr2 = 16'h0005;
        agex_cc = 3'b001;
        agex_drid = 3'b010;
        agex_v = 1'b1;

        aluk = 3'b000;
        sr2mux_sel = 1'b0;
        alu_resultmux_sel = 1'b1;

        addr1mux_sel = 1'b0;
        addr2mux_sel = 2'b10;
        lshf1_sel = 1'b1;
        addressmux_sel = 1'b0;

        agex_ld_cc = 1'b1;
        agex_ld_reg = 1'b1;
        agex_br_stall = 1'b0;

        agex_mem_cs_in = 11'b10101010101;
        mem_stall = 1'b0;

        #1;
        check1("ld_mem when mem_stall=0", ld_mem, 1'b1);
        check1("v_agex_ld_cc when valid", v_agex_ld_cc, 1'b1);
        check1("v_agex_ld_reg when valid", v_agex_ld_reg, 1'b1);
        check1("v_agex_br_stall when not control", v_agex_br_stall, 1'b0);

        @(posedge clk);
        #1;

        check16("mem_npc after normal load", mem_npc, 16'h3000);
        check16("mem_ir after normal load", mem_ir, 16'h0005);
        check3 ("mem_cc after normal load", mem_cc, 3'b001);
        check3 ("mem_drid after normal load", mem_drid, 3'b010);
        check11("mem_cs after normal load", mem_cs, 11'b10101010101);
        check16("mem_alu_result after normal load", mem_alu_result, 16'h0008);
        check16("mem_address after normal load", mem_address, 16'h300A);
        check1 ("mem_v after normal load", mem_v, 1'b1);

        /*
            Test 2:
            MEM stall freezes AGEX/MEM registers.
            Change inputs, but mem_stall=1, so MEM outputs should stay same.
        */
        agex_npc = 16'h4000;
        agex_ir = 16'h003F;
        agex_sr1 = 16'h4000;
        agex_sr2 = 16'hAAAA;
        agex_cc = 3'b100;
        agex_drid = 3'b111;
        agex_v = 1'b1;

        aluk = 3'b000;
        sr2mux_sel = 1'b1;
        alu_resultmux_sel = 1'b1;

        addr1mux_sel = 1'b1;
        addr2mux_sel = 2'b01;
        lshf1_sel = 1'b1;
        addressmux_sel = 1'b0;

        agex_ld_cc = 1'b1;
        agex_ld_reg = 1'b1;
        agex_br_stall = 1'b1;

        agex_mem_cs_in = 11'b01010101010;
        mem_stall = 1'b1;

        #1;
        check1("ld_mem when mem_stall=1", ld_mem, 1'b0);
        check1("v_agex_br_stall valid control", v_agex_br_stall, 1'b1);

        @(posedge clk);
        #1;

        check16("mem_npc frozen during mem_stall", mem_npc, 16'h3000);
        check16("mem_ir frozen during mem_stall", mem_ir, 16'h0005);
        check3 ("mem_cc frozen during mem_stall", mem_cc, 3'b001);
        check3 ("mem_drid frozen during mem_stall", mem_drid, 3'b010);
        check11("mem_cs frozen during mem_stall", mem_cs, 11'b10101010101);
        check16("mem_alu_result frozen during mem_stall", mem_alu_result, 16'h0008);
        check16("mem_address frozen during mem_stall", mem_address, 16'h300A);
        check1 ("mem_v frozen during mem_stall", mem_v, 1'b1);

        /*
            Test 3:
            Bubble behavior.
            AGEX.V = 0. Values can move forward, but MEM.V should become 0.
            Gated outputs should also be 0.
        */
        mem_stall = 1'b0;

        agex_npc = 16'h5000;
        agex_ir = 16'h0001;
        agex_sr1 = 16'h0001;
        agex_sr2 = 16'h0002;
        agex_cc = 3'b010;
        agex_drid = 3'b001;
        agex_v = 1'b0;

        aluk = 3'b000;
        sr2mux_sel = 1'b0;
        alu_resultmux_sel = 1'b1;

        addr1mux_sel = 1'b0;
        addr2mux_sel = 2'b00;
        lshf1_sel = 1'b0;
        addressmux_sel = 1'b0;

        agex_ld_cc = 1'b1;
        agex_ld_reg = 1'b1;
        agex_br_stall = 1'b1;

        agex_mem_cs_in = 11'b11111111111;

        #1;
        check1("v_agex_ld_cc when bubble", v_agex_ld_cc, 1'b0);
        check1("v_agex_ld_reg when bubble", v_agex_ld_reg, 1'b0);
        check1("v_agex_br_stall when bubble", v_agex_br_stall, 1'b0);

        @(posedge clk);
        #1;

        check16("mem_npc after bubble load", mem_npc, 16'h5000);
        check16("mem_alu_result after bubble load", mem_alu_result, 16'h0003);
        check16("mem_address after bubble load", mem_address, 16'h5000);
        check1 ("mem_v after bubble load", mem_v, 1'b0);

        $display("============================================================");

        if (errors == 0)
            $display("ALL AGEX_STAGE TESTS PASSED.");
        else
            $display("AGEX_STAGE FAILED WITH %0d ERROR(S).", errors);

        $finish;
    end

endmodule