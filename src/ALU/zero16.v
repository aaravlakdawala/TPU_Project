`timescale 1ns / 1ps

module zero16 (
    output wire [15:0] y
);

    supply0 GND;

    buf G0  (y[0],  GND);
    buf G1  (y[1],  GND);
    buf G2  (y[2],  GND);
    buf G3  (y[3],  GND);
    buf G4  (y[4],  GND);
    buf G5  (y[5],  GND);
    buf G6  (y[6],  GND);
    buf G7  (y[7],  GND);
    buf G8  (y[8],  GND);
    buf G9  (y[9],  GND);
    buf G10 (y[10], GND);
    buf G11 (y[11], GND);
    buf G12 (y[12], GND);
    buf G13 (y[13], GND);
    buf G14 (y[14], GND);
    buf G15 (y[15], GND);

endmodule