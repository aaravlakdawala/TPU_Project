// src/DE/regfile/regfile.v
`timescale 1ns / 1ps

module regfile (
    input  wire        clk,
    input  wire        reset,

    /*
        Read addresses from Decode.
        SR1 comes from DE.IR[8:6].
        SR2 comes from SR2.IDMUX output.
    */
    input  wire [2:0]  sr1_id,
    input  wire [2:0]  sr2_id,

    /*
        Writeback from SR stage.
    */
    input  wire [2:0]  sr_drid,
    input  wire [15:0] sr_reg_data,
    input  wire        v_sr_ld_reg,

    /*
        Read outputs to DE/AGEX latches.
    */
    output wire [15:0] sr1_data,
    output wire [15:0] sr2_data,

    /*
        Optional debug outputs.
    */
    output wire [15:0] r0_out,
    output wire [15:0] r1_out,
    output wire [15:0] r2_out,
    output wire [15:0] r3_out,
    output wire [15:0] r4_out,
    output wire [15:0] r5_out,
    output wire [15:0] r6_out,
    output wire [15:0] r7_out
);

    wire [7:0] drid_decoded;
    wire [7:0] reg_load_en;

    decoder3to8 WRITE_DECODER (
        .a(sr_drid),
        .y(drid_decoded)
    );

    /*
        Only the selected register writes, and only when SR has a valid
        register-write instruction.
    */
    and R0_LOAD(reg_load_en[0], drid_decoded[0], v_sr_ld_reg);
    and R1_LOAD(reg_load_en[1], drid_decoded[1], v_sr_ld_reg);
    and R2_LOAD(reg_load_en[2], drid_decoded[2], v_sr_ld_reg);
    and R3_LOAD(reg_load_en[3], drid_decoded[3], v_sr_ld_reg);
    and R4_LOAD(reg_load_en[4], drid_decoded[4], v_sr_ld_reg);
    and R5_LOAD(reg_load_en[5], drid_decoded[5], v_sr_ld_reg);
    and R6_LOAD(reg_load_en[6], drid_decoded[6], v_sr_ld_reg);
    and R7_LOAD(reg_load_en[7], drid_decoded[7], v_sr_ld_reg);

    reg16_ld R0 (
        .clk(clk),
        .reset(reset),
        .load_en(reg_load_en[0]),
        .d(sr_reg_data),
        .q(r0_out)
    );

    reg16_ld R1 (
        .clk(clk),
        .reset(reset),
        .load_en(reg_load_en[1]),
        .d(sr_reg_data),
        .q(r1_out)
    );

    reg16_ld R2 (
        .clk(clk),
        .reset(reset),
        .load_en(reg_load_en[2]),
        .d(sr_reg_data),
        .q(r2_out)
    );

    reg16_ld R3 (
        .clk(clk),
        .reset(reset),
        .load_en(reg_load_en[3]),
        .d(sr_reg_data),
        .q(r3_out)
    );

    reg16_ld R4 (
        .clk(clk),
        .reset(reset),
        .load_en(reg_load_en[4]),
        .d(sr_reg_data),
        .q(r4_out)
    );

    reg16_ld R5 (
        .clk(clk),
        .reset(reset),
        .load_en(reg_load_en[5]),
        .d(sr_reg_data),
        .q(r5_out)
    );

    reg16_ld R6 (
        .clk(clk),
        .reset(reset),
        .load_en(reg_load_en[6]),
        .d(sr_reg_data),
        .q(r6_out)
    );

    reg16_ld R7 (
        .clk(clk),
        .reset(reset),
        .load_en(reg_load_en[7]),
        .d(sr_reg_data),
        .q(r7_out)
    );

    /*
        Two combinational read ports.
    */
    mux8_16 SR1_READ_MUX (
        .in0(r0_out),
        .in1(r1_out),
        .in2(r2_out),
        .in3(r3_out),
        .in4(r4_out),
        .in5(r5_out),
        .in6(r6_out),
        .in7(r7_out),
        .sel(sr1_id),
        .out(sr1_data)
    );

    mux8_16 SR2_READ_MUX (
        .in0(r0_out),
        .in1(r1_out),
        .in2(r2_out),
        .in3(r3_out),
        .in4(r4_out),
        .in5(r5_out),
        .in6(r6_out),
        .in7(r7_out),
        .sel(sr2_id),
        .out(sr2_data)
    );

endmodule