`timescale 1ns / 1ps

module tb_fetch_stage;

reg clk;
reg reset;

reg mem_stall;
reg dep_stall;

reg v_de_br_stall;
reg v_agex_br_stall;
reg v_mem_br_stall;

reg [1:0]  mem_pcmux;
reg [15:0] mem_target_pc;
reg [15:0] trap_pc;

reg [15:0] icache_data_in;
reg        icache_r;

wire [15:0] de_npc;
wire [15:0] de_ir;
wire        de_v;

wire [15:0] pc_debug;
wire [15:0] pc_plus2_debug;
wire [15:0] next_pc_debug;

wire ld_pc_debug;
wire ld_de_debug;
wire de_v_next_debug;

wire stall_any_debug;
wire mem_pc_override_debug;

wire [15:0] icache_addr_debug;
wire [15:0] icache_data_debug;
wire        icache_r_debug;

integer pass_count;
integer fail_count;

fetch_stage DUT (
    .clk(clk),
    .reset(reset),

    .mem_stall(mem_stall),
    .dep_stall(dep_stall),

    .v_de_br_stall(v_de_br_stall),
    .v_agex_br_stall(v_agex_br_stall),
    .v_mem_br_stall(v_mem_br_stall),

    .mem_pcmux(mem_pcmux),
    .mem_target_pc(mem_target_pc),
    .trap_pc(trap_pc),

    .icache_data_in(icache_data_in),
    .icache_r(icache_r),

    .de_npc(de_npc),
    .de_ir(de_ir),
    .de_v(de_v),

    .pc_debug(pc_debug),
    .pc_plus2_debug(pc_plus2_debug),
    .next_pc_debug(next_pc_debug),

    .ld_pc_debug(ld_pc_debug),
    .ld_de_debug(ld_de_debug),
    .de_v_next_debug(de_v_next_debug),

    .stall_any_debug(stall_any_debug),
    .mem_pc_override_debug(mem_pc_override_debug),

    .icache_addr_debug(icache_addr_debug),
    .icache_data_debug(icache_data_debug),
    .icache_r_debug(icache_r_debug)
);

always #5 clk = ~clk;

task check;
    input condition;
    input [511:0] message;
    begin
        if (condition) begin
            $display("PASS: %s", message);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: %s", message);
            fail_count = fail_count + 1;
        end
    end
endtask

task clear_controls;
    begin
        mem_stall       = 1'b0;
        dep_stall       = 1'b0;

        v_de_br_stall   = 1'b0;
        v_agex_br_stall = 1'b0;
        v_mem_br_stall  = 1'b0;

        mem_pcmux       = 2'b00;
        mem_target_pc   = 16'h0000;
        trap_pc         = 16'h0000;

        icache_data_in  = 16'h0000;
        icache_r        = 1'b1;
    end
endtask

task sample_before_clock;
    begin
        @(negedge clk);
        #1;
    end
endtask

task step_clock;
    begin
        @(posedge clk);
        #1;
    end
endtask

initial begin
    clk = 1'b0;
    reset = 1'b1;

    pass_count = 0;
    fail_count = 0;

    clear_controls();

    $display("Starting Fetch stage test...");

    /*
        Test 1:
        Reset should initialize PC to 3000 and clear DE latch.
    */
    step_clock();
    reset = 1'b0;
    #1;

    check(pc_debug == 16'h3000, "Reset initializes PC to 3000");
    check(de_npc == 16'h0000, "Reset clears DE.NPC");
    check(de_ir  == 16'h0000, "Reset clears DE.IR");
    check(de_v   == 1'b0,    "Reset clears DE.V");

    /*
        Test 2:
        Normal fetch.
        PC = 3000.
        PC+2 = 3002.
        DE gets instruction from I-cache.
        PC advances to 3002.
    */
    $display("\nRunning: normal fetch from PC 3000");

    icache_data_in = 16'h1261;
    icache_r       = 1'b1;
    mem_pcmux      = 2'b00;

    sample_before_clock();

    check(ld_pc_debug == 1'b1, "LD.PC asserted during normal fetch");
    check(ld_de_debug == 1'b1, "LD.DE asserted during normal fetch");
    check(de_v_next_debug == 1'b1, "DE.V next is valid during normal fetch");
    check(pc_debug == 16'h3000, "PC starts normal fetch at 3000");
    check(pc_plus2_debug == 16'h3002, "PC+2 computed correctly");
    check(next_pc_debug == 16'h3002, "PCMUX selects PC+2");

    step_clock();

    check(pc_debug == 16'h3002, "PC advanced to 3002");
    check(de_npc == 16'h3002, "DE.NPC captured PC+2");
    check(de_ir == 16'h1261, "DE.IR captured I-cache instruction");
    check(de_v == 1'b1, "DE.V captured valid bit");

    /*
        Test 3:
        Second normal fetch.
        PC should advance from 3002 to 3004.
    */
    $display("\nRunning: second normal fetch");

    icache_data_in = 16'h54A6;

    sample_before_clock();

    check(pc_debug == 16'h3002, "PC starts second fetch at 3002");
    check(pc_plus2_debug == 16'h3004, "PC+2 computed as 3004");
    check(next_pc_debug == 16'h3004, "PCMUX selects PC+2 for second fetch");

    step_clock();

    check(pc_debug == 16'h3004, "PC advanced to 3004");
    check(de_npc == 16'h3004, "DE.NPC captured 3004");
    check(de_ir == 16'h54A6, "DE.IR captured second instruction");
    check(de_v == 1'b1, "DE.V stays valid");

    /*
        Test 4:
        ICACHE.R = 0.
        No normal PC load.
        DE loads invalid state because I-cache is not ready.
    */
    $display("\nRunning: I-cache miss / not ready");

    icache_r       = 1'b0;
    icache_data_in = 16'h9999;

    sample_before_clock();

    check(ld_pc_debug == 1'b0, "LD.PC deasserted when ICACHE.R is 0");
    check(ld_de_debug == 1'b1, "LD.DE still asserted without DEP/MEM stall");
    check(de_v_next_debug == 1'b0, "DE.V next is invalid when ICACHE.R is 0");
    check(pc_debug == 16'h3004, "PC still 3004 before I-cache wait clock");

    step_clock();

    check(pc_debug == 16'h3004, "PC held when ICACHE.R is 0");
    check(de_ir == 16'h9999, "DE.IR captures current I-cache bus value");
    check(de_v == 1'b0, "DE.V becomes invalid when ICACHE.R is 0");

    /*
        Test 5:
        Recover from I-cache not-ready.
    */
    $display("\nRunning: recover from I-cache wait");

    icache_r       = 1'b1;
    icache_data_in = 16'h96FF;

    sample_before_clock();

    check(ld_pc_debug == 1'b1, "LD.PC reasserts after ICACHE.R returns");
    check(ld_de_debug == 1'b1, "LD.DE asserted after ICACHE.R returns");
    check(de_v_next_debug == 1'b1, "DE.V next valid after ICACHE.R returns");
    check(pc_plus2_debug == 16'h3006, "PC+2 computed as 3006 after recovery");

    step_clock();

    check(pc_debug == 16'h3006, "PC advanced after I-cache recovery");
    check(de_npc == 16'h3006, "DE.NPC captured after recovery");
    check(de_ir == 16'h96FF, "DE.IR captured after recovery");
    check(de_v == 1'b1, "DE.V valid after recovery");

    /*
        Test 6:
        DEP.STALL freezes front end.
        PC should hold.
        DE latch should hold old values.
    */
    $display("\nRunning: dependency stall freezes Fetch/DE");

    dep_stall      = 1'b1;
    icache_data_in = 16'h1111;

    sample_before_clock();

    check(ld_pc_debug == 1'b0, "LD.PC deasserted during DEP.STALL");
    check(ld_de_debug == 1'b0, "LD.DE deasserted during DEP.STALL");
    check(stall_any_debug == 1'b1, "stall_any asserted during DEP.STALL");

    step_clock();

    check(pc_debug == 16'h3006, "PC held during DEP.STALL");
    check(de_ir == 16'h96FF, "DE.IR held during DEP.STALL");
    check(de_v == 1'b1, "DE.V held during DEP.STALL");

    dep_stall = 1'b0;

    /*
        Test 7:
        MEM.STALL freezes front end.
    */
    $display("\nRunning: memory stall freezes Fetch/DE");

    mem_stall      = 1'b1;
    icache_data_in = 16'h2222;

    sample_before_clock();

    check(ld_pc_debug == 1'b0, "LD.PC deasserted during MEM.STALL");
    check(ld_de_debug == 1'b0, "LD.DE deasserted during MEM.STALL");
    check(stall_any_debug == 1'b1, "stall_any asserted during MEM.STALL");

    step_clock();

    check(pc_debug == 16'h3006, "PC held during MEM.STALL");
    check(de_ir == 16'h96FF, "DE.IR held during MEM.STALL");
    check(de_v == 1'b1, "DE.V held during MEM.STALL");

    mem_stall = 1'b0;

    /*
        Test 8:
        Branch stall should hold PC but load invalid DE.V.
        This creates a bubble while the control instruction resolves.
    */
    $display("\nRunning: branch stall inserts invalid DE instruction");

    v_de_br_stall  = 1'b1;
    icache_data_in = 16'h3333;

    sample_before_clock();

    check(ld_pc_debug == 1'b0, "LD.PC deasserted during branch stall");
    check(ld_de_debug == 1'b1, "LD.DE asserted during branch stall");
    check(de_v_next_debug == 1'b0, "DE.V next invalid during branch stall");
    check(stall_any_debug == 1'b1, "stall_any asserted during branch stall");

    step_clock();

    check(pc_debug == 16'h3006, "PC held during branch stall");
    check(de_ir == 16'h3333, "DE.IR captures bus value during branch stall");
    check(de_v == 1'b0, "DE.V becomes invalid during branch stall");

    v_de_br_stall = 1'b0;

    /*
        Test 9:
        Normal fetch again after branch stall.
    */
    $display("\nRunning: normal fetch after branch stall");

    icache_data_in = 16'h4444;

    sample_before_clock();

    check(ld_pc_debug == 1'b1, "LD.PC reasserts after branch stall clears");
    check(ld_de_debug == 1'b1, "LD.DE asserted after branch stall clears");
    check(de_v_next_debug == 1'b1, "DE.V next valid after branch stall clears");
    check(pc_plus2_debug == 16'h3008, "PC+2 computed as 3008 after branch stall");

    step_clock();

    check(pc_debug == 16'h3008, "PC advances after branch stall clears");
    check(de_ir == 16'h4444, "DE.IR captures after branch stall clears");
    check(de_v == 1'b1, "DE.V valid after branch stall clears");

    /*
        Test 10:
        MEM.PCMUX redirect to MEM.TARGET.PC.
        Even if normal front-end path is stalled, redirect should load PC.
        DE remains frozen because DEP.STALL is active.
    */
    $display("\nRunning: MEM.PCMUX target redirect");

    dep_stall       = 1'b1;
    mem_pcmux       = 2'b01;
    mem_target_pc   = 16'h4000;
    trap_pc         = 16'h5000;
    icache_data_in  = 16'h5555;

    sample_before_clock();

    check(mem_pc_override_debug == 1'b1, "MEM PC override asserted for MEM.PCMUX=01");
    check(ld_pc_debug == 1'b1, "LD.PC asserted for MEM target redirect");
    check(ld_de_debug == 1'b0, "LD.DE frozen because DEP.STALL is active");
    check(next_pc_debug == 16'h4000, "PCMUX selects MEM.TARGET.PC");

    step_clock();

    check(pc_debug == 16'h4000, "PC redirected to MEM.TARGET.PC");
    check(de_ir == 16'h4444, "DE.IR held during DEP.STALL redirect");

    dep_stall = 1'b0;
    mem_pcmux = 2'b00;

    /*
        Test 11:
        Normal fetch from redirected PC.
    */
    $display("\nRunning: normal fetch after target redirect");

    icache_data_in = 16'h7777;

    sample_before_clock();

    check(pc_debug == 16'h4000, "PC starts fetch at redirected target 4000");
    check(pc_plus2_debug == 16'h4002, "PC+2 computed as 4002");
    check(next_pc_debug == 16'h4002, "PCMUX returns to PC+2 after redirect clears");

    step_clock();

    check(pc_debug == 16'h4002, "PC advances from redirected target");
    check(de_npc == 16'h4002, "DE.NPC captured after target redirect");
    check(de_ir == 16'h7777, "DE.IR captured after target redirect");
    check(de_v == 1'b1, "DE.V valid after target redirect");

    /*
        Test 12:
        MEM.PCMUX redirect to TRAP.PC.
    */
    $display("\nRunning: MEM.PCMUX trap redirect");

    trap_pc         = 16'h0200;
    mem_pcmux       = 2'b10;
    icache_data_in  = 16'h6666;

    sample_before_clock();

    check(mem_pc_override_debug == 1'b1, "MEM PC override asserted for MEM.PCMUX=10");
    check(ld_pc_debug == 1'b1, "LD.PC asserted for trap redirect");
    check(next_pc_debug == 16'h0200, "PCMUX selects TRAP.PC");

    step_clock();

    check(pc_debug == 16'h0200, "PC redirected to TRAP.PC");

    mem_pcmux = 2'b00;

    /*
        Test 13:
        Normal fetch from trap PC.
    */
    $display("\nRunning: normal fetch after trap redirect");

    icache_data_in = 16'h8888;

    sample_before_clock();

    check(pc_debug == 16'h0200, "PC starts fetch at trap PC");
    check(pc_plus2_debug == 16'h0202, "PC+2 computed as 0202");
    check(next_pc_debug == 16'h0202, "PCMUX returns to PC+2 after trap redirect clears");

    step_clock();

    check(pc_debug == 16'h0202, "PC advances from trap PC");
    check(de_npc == 16'h0202, "DE.NPC captured after trap redirect");
    check(de_ir == 16'h8888, "DE.IR captured after trap redirect");
    check(de_v == 1'b1, "DE.V valid after trap redirect");

    /*
        Summary.
    */
    $display("\nFetch stage test complete.");
    $display("PASS count = %0d", pass_count);
    $display("FAIL count = %0d", fail_count);

    if (fail_count == 0) begin
        $display("All Fetch stage tests passed.");
    end
    else begin
        $display("Fetch stage tests FAILED.");
    end

    #10;
    $finish;
end

endmodule