`timescale 1ns / 1ps

module agex_datapath_core (
    input  wire [15:0] agex_npc,
    input  wire [15:0] agex_sr1,
    input  wire [15:0] agex_sr2,
    input  wire [15:0] agex_ir,

    input  wire [2:0]  aluk,
    input  wire        sr2mux_sel,
    input  wire        alu_resultmux_sel,

    input  wire        addr1mux_sel,
    input  wire [1:0]  addr2mux_sel,
    input  wire        lshf1_sel,
    input  wire        addressmux_sel,

    output wire [15:0] mem_alu_result,
    output wire [15:0] mem_address,

    output wire [15:0] alu_result,
    output wire [15:0] shf_result,
    output wire [15:0] sr2mux_out,
    output wire [15:0] sext5_out,

    output wire [15:0] addr1mux_out,
    output wire [15:0] addr2mux_out,
    output wire [15:0] lshf1_out,
    output wire [15:0] addr2_final_out,
    output wire [15:0] sext6_out,
    output wire [15:0] sext9_out,
    output wire [15:0] sext11_out,
    output wire [15:0] zext8_lshf1_out,
    output wire [15:0] address_adder_out
);

    execute_datapath EXECUTE_DATAPATH_UNIT (
        .agex_sr1(agex_sr1),
        .agex_sr2(agex_sr2),
        .agex_ir(agex_ir),

        .aluk(aluk),
        .sr2mux_sel(sr2mux_sel),
        .alu_resultmux_sel(alu_resultmux_sel),

        .execute_result(mem_alu_result),
        .alu_result(alu_result),
        .shf_result(shf_result),
        .sr2mux_out(sr2mux_out),
        .sext5_out(sext5_out)
    );

    address_datapath ADDRESS_DATAPATH_UNIT (
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

endmodule