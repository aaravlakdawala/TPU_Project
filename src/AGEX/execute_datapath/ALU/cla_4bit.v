module cla_4bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout,
    output wire       pg,
    output wire       gg
);

    wire [3:0] p;
    wire [3:0] g;

    wire c1;
    wire c2;
    wire c3;
    wire c4;

    assign p = a ^ b;
    assign g = a & b;

    assign c1 = g[0] | (p[0] & cin);

    assign c2 = g[1] |
                (p[1] & g[0]) |
                (p[1] & p[0] & cin);

    assign c3 = g[2] |
                (p[2] & g[1]) |
                (p[2] & p[1] & g[0]) |
                (p[2] & p[1] & p[0] & cin);

    assign c4 = g[3] |
                (p[3] & g[2]) |
                (p[3] & p[2] & g[1]) |
                (p[3] & p[2] & p[1] & g[0]) |
                (p[3] & p[2] & p[1] & p[0] & cin);

    full_adder FA0 (
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .sum(sum[0]),
        .cout()
    );

    full_adder FA1 (
        .a(a[1]),
        .b(b[1]),
        .cin(c1),
        .sum(sum[1]),
        .cout()
    );

    full_adder FA2 (
        .a(a[2]),
        .b(b[2]),
        .cin(c2),
        .sum(sum[2]),
        .cout()
    );

    full_adder FA3 (
        .a(a[3]),
        .b(b[3]),
        .cin(c3),
        .sum(sum[3]),
        .cout()
    );

    assign cout = c4;

    assign pg = p[3] & p[2] & p[1] & p[0];

    assign gg = g[3] |
                (p[3] & g[2]) |
                (p[3] & p[2] & g[1]) |
                (p[3] & p[2] & p[1] & g[0]);

endmodule