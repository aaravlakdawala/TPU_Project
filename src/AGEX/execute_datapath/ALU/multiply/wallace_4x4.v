module wallace_4x4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [7:0] product
);

    // Partial products
    wire pp00, pp01, pp02, pp03;
    wire pp10, pp11, pp12, pp13;
    wire pp20, pp21, pp22, pp23;
    wire pp30, pp31, pp32, pp33;

    assign pp00 = a[0] & b[0];
    assign pp01 = a[0] & b[1];
    assign pp02 = a[0] & b[2];
    assign pp03 = a[0] & b[3];

    assign pp10 = a[1] & b[0];
    assign pp11 = a[1] & b[1];
    assign pp12 = a[1] & b[2];
    assign pp13 = a[1] & b[3];

    assign pp20 = a[2] & b[0];
    assign pp21 = a[2] & b[1];
    assign pp22 = a[2] & b[2];
    assign pp23 = a[2] & b[3];

    assign pp30 = a[3] & b[0];
    assign pp31 = a[3] & b[1];
    assign pp32 = a[3] & b[2];
    assign pp33 = a[3] & b[3];

    // Product bit 0 is direct
    assign product[0] = pp00;

    // Column 1
    wire c1;

    half_adder HA1 (
        .a(pp10),
        .b(pp01),
        .sum(product[1]),
        .carry(c1)
    );

    // Column 2
    wire s2a, c2a;
    wire c2b;

    full_adder FA2A (
        .a(pp20),
        .b(pp11),
        .cin(pp02),
        .sum(s2a),
        .cout(c2a)
    );

    half_adder HA2B (
        .a(s2a),
        .b(c1),
        .sum(product[2]),
        .carry(c2b)
    );

    // Column 3
    wire s3a, c3a;
    wire s3b, c3b;
    wire c3c;

    full_adder FA3A (
        .a(pp30),
        .b(pp21),
        .cin(pp12),
        .sum(s3a),
        .cout(c3a)
    );

    full_adder FA3B (
        .a(pp03),
        .b(c2a),
        .cin(c2b),
        .sum(s3b),
        .cout(c3b)
    );

    half_adder HA3C (
        .a(s3a),
        .b(s3b),
        .sum(product[3]),
        .carry(c3c)
    );

    // Column 4
    wire s4a, c4a;
    wire s4b, c4b;
    wire c4c;

    full_adder FA4A (
        .a(pp31),
        .b(pp22),
        .cin(pp13),
        .sum(s4a),
        .cout(c4a)
    );

    full_adder FA4B (
        .a(c3a),
        .b(c3b),
        .cin(c3c),
        .sum(s4b),
        .cout(c4b)
    );

    half_adder HA4C (
        .a(s4a),
        .b(s4b),
        .sum(product[4]),
        .carry(c4c)
    );

    // Column 5
    wire s5a, c5a;
    wire c5b;

    full_adder FA5A (
        .a(pp32),
        .b(pp23),
        .cin(c4a),
        .sum(s5a),
        .cout(c5a)
    );

    full_adder FA5B (
        .a(c4b),
        .b(c4c),
        .cin(s5a),
        .sum(product[5]),
        .cout(c5b)
    );

    // Column 6 and 7
    full_adder FA6A (
        .a(pp33),
        .b(c5a),
        .cin(c5b),
        .sum(product[6]),
        .cout(product[7])
    );

endmodule