module cla_8b(out, P0, G0, c_msb, data_operandA, data_operandB, c_in);

    input [7:0] data_operandA, data_operandB;
    input c_in;
    output [7:0] out;
    output P0, G0;
    output c_msb;

    wire p0, p1, p2, p3, p4, p5, p6, p7; //propogate (x+y)

    //output from the and of carry ins and propogates
    //wiring to aid with quick calculation of carries simultaneously
    wire pc0;
    wire pc1a, pc1b;
    wire pc2a, pc2b, pc2c;
    wire pc3a, pc3b, pc3c, pc3d; 
    wire pc4a, pc4b, pc4c, pc4d, pc4e;
    wire pc5a, pc5b, pc5c, pc5d, pc5e, pc5f;
    wire pc6a, pc6b, pc6c, pc6d, pc6e, pc6f, pc6g; 
    wire pc7b, pc7c, pc7d, pc7e, pc7f, pc7g, pc7h;  //pc7a missing because it generates P0 here


    wire g0, g1, g2, g3, g4, g5, g6, g7; // generate x & y
    
    wire c1, c2, c3, c4, c5, c6, c7; //carry out of each bit calculated simultaneously

    //generating c1
    or gen_p0(p0, data_operandA[0], data_operandB[0]);
    and gen_prop1(pc0, c_in, p0);
    and gen_g0(g0, data_operandA[0], data_operandB[0]);

    or gen_c1(c1, pc0, g0); // decide c1 for carry

    //generating c2
    or gen_p1(p1, data_operandA[1], data_operandB[1]);
    and gen_prop1a(pc1a, c_in, p0, p1);
    and gen_prop1b(pc1b, g0, p1);
    and gen_g1(g1, data_operandA[1], data_operandB[1]);
    
    or gen_c2(c2, pc1a, pc1b, g1);

    //generating c3
    or gen_p2(p2, data_operandA[2], data_operandB[2]);
    and gen_prop2a(pc2a, c_in, p0, p1, p2);
    and gen_prop2b(pc2b, g0, p1, p2);
    and gen_prop2c(pc2c, g1, p2);

    and gen_g2(g2, data_operandA[2], data_operandB[2]);
    
    or gen_c3(c3, pc2a, pc2b, pc2c, g2);

    //generating c4
    or gen_p3(p3, data_operandA[3], data_operandB[3]);
    and gen_prop3a(pc3a, c_in, p0, p1, p2, p3);
    and gen_prop3b(pc3b, g0, p1, p2, p3);
    and gen_prop3c(pc3c, g1, p2, p3);
    and gen_prop3d(pc3d, g2, p3);

    and gen_g3(g3, data_operandA[3], data_operandB[3]);
    
    or gen_c4(c4, pc3a, pc3b, pc3c, pc3d, g3);

    //generating c5
    or gen_p4(p4, data_operandA[4], data_operandB[4]);
    and gen_prop4a(pc4a, c_in, p0, p1, p2, p3, p4);
    and gen_prop4b(pc4b, g0, p1, p2, p3, p4);
    and gen_prop4c(pc4c, g1, p2, p3, p4);
    and gen_prop4d(pc4d, g2, p3, p4);
    and gen_prop4e(pc4e, g3, p4);

    and gen_g4(g4, data_operandA[4], data_operandB[4]);
    
    or gen_c5(c5, pc4a, pc4b, pc4c, pc4d, pc4e, g4);

    //generating c6
    or gen_p5(p5, data_operandA[5], data_operandB[5]);
    and gen_prop5a(pc5a, c_in, p0, p1, p2, p3, p4, p5);
    and gen_prop5b(pc5b, g0, p1, p2, p3, p4, p5);
    and gen_prop5c(pc5c, g1, p2, p3, p4, p5);
    and gen_prop5d(pc5d, g2, p3, p4, p5);
    and gen_prop5e(pc5e, g3, p4, p5);
    and gen_prop5f(pc5f, g4, p5);

    and gen_g5(g5, data_operandA[5], data_operandB[5]);
    
    or gen_c6(c6, pc5a, pc5b, pc5c, pc5d, pc5e, pc5f, g5);

    //generating c7
    or gen_p6(p6, data_operandA[6], data_operandB[6]);
    and gen_prop6a(pc6a, c_in, p0, p1, p2, p3, p4, p5, p6);
    and gen_prop6b(pc6b, g0, p1, p2, p3, p4, p5, p6);
    and gen_prop6c(pc6c, g1, p2, p3, p4, p5, p6);
    and gen_prop6d(pc6d, g2, p3, p4, p5, p6);
    and gen_prop6e(pc6e, g3, p4, p5, p6);
    and gen_prop6f(pc6f, g4, p5, p6);
    and gen_prop6g(pc6g, g5, p6);

    and gen_g6(g6, data_operandA[6], data_operandB[6]);
    
    or gen_c7(c7, pc6a, pc6b, pc6c, pc6d, pc6e, pc6f, pc6g, g6);

    assign c_msb = c7; //makes overflow calculations easier in the add and sub units

    //generating P0 and G0
    or gen_p7(p7, data_operandA[7], data_operandB[7]);
    
    and gen_prop7b(pc7b, g0, p1, p2, p3, p4, p5, p6, p7);
    and gen_prop7c(pc7c, g1, p2, p3, p4, p5, p6, p7);
    and gen_prop7d(pc7d, g2, p3, p4, p5, p6, p7);
    and gen_prop7e(pc7e, g3, p4, p5, p6, p7);
    and gen_prop7f(pc7f, g4, p5, p6, p7);
    and gen_prop7g(pc7g, g5, p6, p7);
    and gen_prop7h(pc7h, g6, p7);

    and gen_g7(g7, data_operandA[7], data_operandB[7]);
    
    or gen_G0(G0, pc7b, pc7c, pc7d, pc7e, pc7f, pc7g, pc7h, g7);
    and gen_P0(P0, p0, p1, p2, p3, p4, p5, p6, p7);


    //c0-c7 have been established, now need to actually do the bit math to get the output
    xor result0(out[0], data_operandA[0], data_operandB[0], c_in);
    xor result1(out[1], data_operandA[1], data_operandB[1], c1);
    xor result2(out[2], data_operandA[2], data_operandB[2], c2);
    xor result3(out[3], data_operandA[3], data_operandB[3], c3);
    xor result4(out[4], data_operandA[4], data_operandB[4], c4);
    xor result5(out[5], data_operandA[5], data_operandB[5], c5);
    xor result6(out[6], data_operandA[6], data_operandB[6], c6);
    xor result7(out[7], data_operandA[7], data_operandB[7], c7);

endmodule

