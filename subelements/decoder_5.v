module decoder_5(out, select);

    output [31:0] out;
    input [4:0] select;
    wire [31:0] enable;
    assign enable = 1;

    assign out = enable << select;

endmodule