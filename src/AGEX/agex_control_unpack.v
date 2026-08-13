`timescale 1ns / 1ps

module agex_control_unpack (
    input  wire [20:0] agex_cs,

    output wire        addr1mux_sel,
    output wire [1:0]  addr2mux_sel,
    output wire        lshf1_sel,
    output wire        addressmux_sel,
    output wire        sr2mux_sel,
    output wire [2:0]  aluk,
    output wire        alu_resultmux_sel,

    output wire        br_op,
    output wire        uncond_op,
    output wire        trap_op,

    output wire        agex_br_stall,
    output wire        dcache_en,
    output wire        dcache_rw,
    output wire        data_size,

    output wire [1:0]  dr_valuemux,
    output wire        agex_ld_reg,
    output wire        agex_ld_cc,

    output wire [10:0] mem_cs_in
);

    assign addr1mux_sel      = agex_cs[0];
    assign addr2mux_sel      = {agex_cs[1], agex_cs[2]};
    assign lshf1_sel         = agex_cs[3];
    assign addressmux_sel    = agex_cs[4];
    assign sr2mux_sel        = agex_cs[5];
    assign aluk              = {agex_cs[6], agex_cs[7], agex_cs[8]};
    assign alu_resultmux_sel = agex_cs[9];

    assign br_op             = agex_cs[10];
    assign uncond_op         = agex_cs[11];
    assign trap_op           = agex_cs[12];

    assign agex_br_stall     = agex_cs[13];
    assign dcache_en         = agex_cs[14];
    assign dcache_rw         = agex_cs[15];
    assign data_size         = agex_cs[16];

    assign dr_valuemux       = {agex_cs[17], agex_cs[18]};
    assign agex_ld_reg       = agex_cs[19];
    assign agex_ld_cc        = agex_cs[20];

    /*
        Pass only MEM/SR-relevant controls forward.

        agex_cs[20:10] =
            LD.CC
            LD.REG
            DR.VALUEMUX1
            DR.VALUEMUX0
            DATA.SIZE
            DCACHE.RW
            DCACHE.EN
            BR.STALL
            TRAP.OP
            UNCOND.OP
            BR.OP

        This excludes AGEX-only datapath controls.
    */
    assign mem_cs_in = agex_cs[20:10];

endmodule