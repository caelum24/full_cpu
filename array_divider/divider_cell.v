module divider_cell(Sum, Cout, Din, Bin, Cin, Ain);

    input Ain, Bin, Cin, Din;
    output Sum, Cout;
    
    wire w_add_A;
    xor add_A(w_add_A, Ain, Din);
    full_adder FA(Sum, Cout, w_add_A, Bin, Cin);

endmodule