`timescale 1ns / 1ps

module icache(
    input  wire [15:0] pc,

    /*
        Temporary external instruction source.

        The documentation shows an I-CACHE block, but it does not define
        the internal cache organization: no tag/index/line-size/miss-latency
        spec is given in the provided Lab 6 document.

        So for now this module models the documented Fetch-stage interface:
            PC/address in
            instruction word out
            ICACHE.R ready out

        Later, if cache specs are provided, only this module should be
        replaced. Fetch should not need to change.
    */
    input  wire [15:0] instr_mem_data_in,
    input  wire        instr_mem_ready_in,

    output wire [15:0] icache_addr,
    output wire [15:0] icache_data_out,
    output wire        icache_r
);

assign icache_addr     = pc;
assign icache_data_out = instr_mem_data_in;
assign icache_r        = instr_mem_ready_in;

endmodule