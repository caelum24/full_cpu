module check_equal(A, B, is_equal)
    input [31:0] A, B;
    output is_equal;

    wire [31:0] equal_bits;

    // Compare each bit using XOR gates
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            assign equal_bits[i] = A[i] ^ B[i];
        end
    endgenerate

    assign is_equal = (|equal_bits) ? 1'b0 : 1'b1; // Equal if all bits are 0
