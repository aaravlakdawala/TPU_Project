`timescale 1ns / 1ps

module address_datapath (
    input  wire [15:0] agex_npc,
    input  wire [15:0] agex_sr1,
    input  wire [15:0] agex_ir,

    input  wire        addr1mux_sel,
    input  wire [1:0]  addr2mux_sel,
    input  wire        lshf1_sel,
    input  wire        addressmux_sel,

    output wire [15:0] mem_address,

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

    supply0 z;

    wire [15:0] zero16_wire;

    buf Z0  (zero16_wire[0],  z);
    buf Z1  (zero16_wire[1],  z);
    buf Z2  (zero16_wire[2],  z);
    buf Z3  (zero16_wire[3],  z);
    buf Z4  (zero16_wire[4],  z);
    buf Z5  (zero16_wire[5],  z);
    buf Z6  (zero16_wire[6],  z);
    buf Z7  (zero16_wire[7],  z);
    buf Z8  (zero16_wire[8],  z);
    buf Z9  (zero16_wire[9],  z);
    buf Z10 (zero16_wire[10], z);
    buf Z11 (zero16_wire[11], z);
    buf Z12 (zero16_wire[12], z);
    buf Z13 (zero16_wire[13], z);
    buf Z14 (zero16_wire[14], z);
    buf Z15 (zero16_wire[15], z);

    sext6 SEXT6_UNIT (
        .in(agex_ir[5:0]),
        .out(sext6_out)
    );

    sext9 SEXT9_UNIT (
        .in(agex_ir[8:0]),
        .out(sext9_out)
    );

    sext11 SEXT11_UNIT (
        .in(agex_ir[10:0]),
        .out(sext11_out)
    );

    zext8_lshf1 ZEXT8_LSHF1_UNIT (
        .in(agex_ir[7:0]),
        .out(zext8_lshf1_out)
    );

    addr1mux ADDR1MUX_UNIT (
        .npc(agex_npc),
        .sr1(agex_sr1),
        .sel(addr1mux_sel),
        .out(addr1mux_out)
    );

    addr2mux ADDR2MUX_UNIT (
        .zero(zero16_wire),
        .sext6_out(sext6_out),
        .sext9_out(sext9_out),
        .sext11_out(sext11_out),
        .sel(addr2mux_sel),
        .out(addr2mux_out)
    );

    lshf1_16 LSHF1_UNIT (
        .in(addr2mux_out),
        .out(lshf1_out)
    );

    mux2_16 LSHF1MUX_UNIT (
        .in0(addr2mux_out),
        .in1(lshf1_out),
        .sel(lshf1_sel),
        .out(addr2_final_out)
    );

    address_adder ADDRESS_ADDER_UNIT (
        .a(addr1mux_out),
        .b(addr2_final_out),
        .sum(address_adder_out)
    );

    addressmux ADDRESSMUX_UNIT (
        .adder_result(address_adder_out),
        .zext_lshf1_result(zext8_lshf1_out),
        .sel(addressmux_sel),
        .out(mem_address)
    );

endmodule