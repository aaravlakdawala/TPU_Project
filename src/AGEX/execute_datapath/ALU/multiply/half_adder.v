module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);

    xor g1 (sum, a, b);
    and g2 (carry, a, b);

endmodule