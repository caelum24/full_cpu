module register_32b(q, d, clk, input_en, clr);

    input [31:0] d;
    input clk, input_en, clr;
    output [31:0] q;


    genvar c;
    generate
        for (c=0; c<=31; c=c+1) begin: loop1
            dffe_ref dff1(q[c], d[c], clk, input_en, clr);
        end
    endgenerate
    



endmodule