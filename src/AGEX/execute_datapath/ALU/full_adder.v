module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);

    wire axorb;
    wire carry1;
    wire carry2;

    xor g1 (axorb, a, b);
    xor g2 (sum, axorb, cin);

    and g3 (carry1, a, b);
    and g4 (carry2, axorb, cin);

    or  g5 (cout, carry1, carry2);

endmodule