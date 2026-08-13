`timescale 1ns / 1ps

module de_logic (
    input  wire de_v,
    input  wire dep_stall,
    input  wire mem_stall,
    input  wire br_stall,

    output wire ld_agex,
    output wire agex_v_next,
    output wire v_de_br_stall
);

    /*
        V.DE.BR.STALL:
        Decode has a valid control instruction.
        BR.STALL comes from the control store.
    */
    assign v_de_br_stall = de_v & br_stall;

    /*
        LD.AGEX:
        If MEM is stalled, previous stages must not advance.
        So do not overwrite AGEX latches.
    */
    assign ld_agex = ~mem_stall;

    /*
        AGEX.V next:
        If Decode is stalled by a dependency, insert a bubble into AGEX.
        If MEM is stalled, AGEX should hold because ld_agex = 0.
        Otherwise, pass DE.V forward.
    */
    assign agex_v_next = de_v & ~dep_stall;

endmodule