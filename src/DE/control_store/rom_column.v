`timescale 1ns / 1ps

module rom_column #(
    parameter [63:0] MASK = 64'b0
)(
    input  wire [63:0] row_select,
    output wire        control_bit
);

    wire [63:0] active_connections;

    genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : GEN_CONNECTIONS
            and CONNECTION_GATE (
                active_connections[i],
                row_select[i],
                MASK[i]
            );
        end
    endgenerate

    or64_tree OR_PLANE (
        .in(active_connections),
        .out(control_bit)
    );

endmodule