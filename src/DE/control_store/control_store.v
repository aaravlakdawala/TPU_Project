`timescale 1ns / 1ps

module control_store (
    input  wire [15:0] de_ir,
    output wire [23:0] cs
);

    /*
        New 24-bit control-store layout:

        cs[0]       SR1.NEEDED
        cs[1]       SR2.NEEDED
        cs[2]       DRMUX
        cs[3]       ADDR1MUX
        cs[4]       ADDR2MUX1
        cs[5]       ADDR2MUX0
        cs[6]       LSHF1
        cs[7]       ADDRESSMUX
        cs[8]       SR2MUX
        cs[9]       ALUK2
        cs[10]      ALUK1
        cs[11]      ALUK0
        cs[12]      ALU.RESULTMUX
        cs[13]      BR.OP
        cs[14]      UNCOND.OP
        cs[15]      TRAP.OP
        cs[16]      BR.STALL
        cs[17]      DCACHE.EN
        cs[18]      DCACHE.RW
        cs[19]      DATA.SIZE
        cs[20]      DR.VALUEMUX1
        cs[21]      DR.VALUEMUX0
        cs[22]      LD.REG
        cs[23]      LD.CC
    */

    wire [5:0]  control_store_address;
    wire [63:0] row_select;

    /*
        Lab 6 control-store address:
            {DE.IR[15:11], DE.IR[5]}
    */
    assign control_store_address = {
        de_ir[15:11],
        de_ir[5]
    };

    cs_decoder6to64 ADDRESS_DECODER (
        .a(control_store_address),
        .y(row_select)
    );

    /*
        These masks were generated from your 64-row, 24-bit cntrlstore.txt.

        MASK bit i corresponds to control-store row i.
        Example:
            MASK_ALUK2[40] = 1
            MASK_ALUK2[41] = 1
            MASK_ALUK2[42] = 1
            MASK_ALUK2[43] = 1

        That is what makes rows 40-43 select ALUK = 100 for MUL.
    */

    localparam [63:0] MASK_SR1_NEEDED     = 64'b0000000011111111000011111111000011111111111100111111111111110000;
    localparam [63:0] MASK_SR2_NEEDED     = 64'b0000000000000000000001010101000011110000010100001111000001010000;
    localparam [63:0] MASK_DRMUX          = 64'b1111000000000000000000000000000000000000000011110000000000000000;
    localparam [63:0] MASK_ADDR1MUX       = 64'b0000000000001111000000000000000011111111000000111111111100000000;
    localparam [63:0] MASK_ADDR2MUX1      = 64'b0000111100000000000000000000000000000000000011000000000000001111;
    localparam [63:0] MASK_ADDR2MUX0      = 64'b0000000000000000000000000000000011111111000011001111111100000000;
    localparam [63:0] MASK_LSHF1          = 64'b0000111100000000000000000000000011111111000011000000000000001111;
    localparam [63:0] MASK_ADDRESSMUX     = 64'b0000111100001111000000000000000011111111000011111111111100001111;
    localparam [63:0] MASK_SR2MUX         = 64'b0000000000000000000010101010000000000000101000000000000010100000;
    localparam [63:0] MASK_ALUK2          = 64'b0000000000000000000011110000000000000000000000000000000000000000;
    localparam [63:0] MASK_ALUK1          = 64'b0000000000000000000000001111000011110000000000001111000000000000;
    localparam [63:0] MASK_ALUK0          = 64'b0000000000000000000000000000000011110000111100001111000000000000;
    localparam [63:0] MASK_ALU_RESULTMUX  = 64'b0000000000000000000011111111000011110000111100001111000011110000;
    localparam [63:0] MASK_BR_OP          = 64'b0000000000000000000000000000000000000000000000000000000000001111;
    localparam [63:0] MASK_UNCOND_OP      = 64'b0000000000001111000000000000000000000000000011110000000000000000;
    localparam [63:0] MASK_TRAP_OP        = 64'b1111000000000000000000000000000000000000000000000000000000000000;
    localparam [63:0] MASK_BR_STALL       = 64'b1111000000001111000000000000000000000000000011110000000000001111;
    localparam [63:0] MASK_DCACHE_EN      = 64'b1111000000000000000000000000000011111111000000001111111100000000;
    localparam [63:0] MASK_DCACHE_RW      = 64'b0000000000000000000000000000000011110000000000001111000000000000;
    localparam [63:0] MASK_DATA_SIZE      = 64'b1111000000000000000000000000000011111111000000000000000000000000;
    localparam [63:0] MASK_DR_VALUEMUX1   = 64'b1111000011110000000011111111000000000000111111110000000011110000;
    localparam [63:0] MASK_DR_VALUEMUX0   = 64'b0000000011110000000011111111000000001111111100000000111111110000;
    localparam [63:0] MASK_LD_REG         = 64'b1111111111110000000011111111000000001111111111110000111111110000;
    localparam [63:0] MASK_LD_CC          = 64'b0000000011110000000011111111000000001111111100000000111111110000;

    rom_column #(.MASK(MASK_SR1_NEEDED)) ROM_CS0 (
        .row_select(row_select),
        .control_bit(cs[0])
    );

    rom_column #(.MASK(MASK_SR2_NEEDED)) ROM_CS1 (
        .row_select(row_select),
        .control_bit(cs[1])
    );

    rom_column #(.MASK(MASK_DRMUX)) ROM_CS2 (
        .row_select(row_select),
        .control_bit(cs[2])
    );

    rom_column #(.MASK(MASK_ADDR1MUX)) ROM_CS3 (
        .row_select(row_select),
        .control_bit(cs[3])
    );

    rom_column #(.MASK(MASK_ADDR2MUX1)) ROM_CS4 (
        .row_select(row_select),
        .control_bit(cs[4])
    );

    rom_column #(.MASK(MASK_ADDR2MUX0)) ROM_CS5 (
        .row_select(row_select),
        .control_bit(cs[5])
    );

    rom_column #(.MASK(MASK_LSHF1)) ROM_CS6 (
        .row_select(row_select),
        .control_bit(cs[6])
    );

    rom_column #(.MASK(MASK_ADDRESSMUX)) ROM_CS7 (
        .row_select(row_select),
        .control_bit(cs[7])
    );

    rom_column #(.MASK(MASK_SR2MUX)) ROM_CS8 (
        .row_select(row_select),
        .control_bit(cs[8])
    );

    rom_column #(.MASK(MASK_ALUK2)) ROM_CS9 (
        .row_select(row_select),
        .control_bit(cs[9])
    );

    rom_column #(.MASK(MASK_ALUK1)) ROM_CS10 (
        .row_select(row_select),
        .control_bit(cs[10])
    );

    rom_column #(.MASK(MASK_ALUK0)) ROM_CS11 (
        .row_select(row_select),
        .control_bit(cs[11])
    );

    rom_column #(.MASK(MASK_ALU_RESULTMUX)) ROM_CS12 (
        .row_select(row_select),
        .control_bit(cs[12])
    );

    rom_column #(.MASK(MASK_BR_OP)) ROM_CS13 (
        .row_select(row_select),
        .control_bit(cs[13])
    );

    rom_column #(.MASK(MASK_UNCOND_OP)) ROM_CS14 (
        .row_select(row_select),
        .control_bit(cs[14])
    );

    rom_column #(.MASK(MASK_TRAP_OP)) ROM_CS15 (
        .row_select(row_select),
        .control_bit(cs[15])
    );

    rom_column #(.MASK(MASK_BR_STALL)) ROM_CS16 (
        .row_select(row_select),
        .control_bit(cs[16])
    );

    rom_column #(.MASK(MASK_DCACHE_EN)) ROM_CS17 (
        .row_select(row_select),
        .control_bit(cs[17])
    );

    rom_column #(.MASK(MASK_DCACHE_RW)) ROM_CS18 (
        .row_select(row_select),
        .control_bit(cs[18])
    );

    rom_column #(.MASK(MASK_DATA_SIZE)) ROM_CS19 (
        .row_select(row_select),
        .control_bit(cs[19])
    );

    rom_column #(.MASK(MASK_DR_VALUEMUX1)) ROM_CS20 (
        .row_select(row_select),
        .control_bit(cs[20])
    );

    rom_column #(.MASK(MASK_DR_VALUEMUX0)) ROM_CS21 (
        .row_select(row_select),
        .control_bit(cs[21])
    );

    rom_column #(.MASK(MASK_LD_REG)) ROM_CS22 (
        .row_select(row_select),
        .control_bit(cs[22])
    );

    rom_column #(.MASK(MASK_LD_CC)) ROM_CS23 (
        .row_select(row_select),
        .control_bit(cs[23])
    );

endmodule