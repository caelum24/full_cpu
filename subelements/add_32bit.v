module add_32bit (add_out, add_overflow, data_operandA, data_operandB);

    input [31:0] data_operandA, data_operandB;
    
    output [31:0] add_out;
    output add_overflow;

    wire c_in;
    assign c_in = 0; //setting carry in to 0 because we're adding

    //propogate and generate wires across cla blocks
    wire P0, P1, P2, P3;
    wire G0, G1, G2, G3;

    //wires for quick calculating the carries between blocks
    wire pc0;
    wire pc1a, pc1b;
    wire pc2a, pc2b, pc2c;
    wire pc3a, pc3b, pc3c, pc3d;

    //carries between blocks
    wire c8, c16, c24, c32;
    wire c_msb7, c_msb15, c_msb23, c_msb31; //carry in to the msb of the cla, only c_msb31 does something (determines overflow)

    cla_8b cla0_7(add_out[7:0], P0, G0, c_msb7, data_operandA[7:0], data_operandB[7:0], c_in); //adding 1st 8

    //generating c8
    and gen_pc0(pc0, c_in, P0);
    or gen_c8(c8, pc0, G0); // decide c8 for carry

    cla_8b cla8_15(add_out[15:8], P1, G1, c_msb15, data_operandA[15:8], data_operandB[15:8], c8); //adding 2nd 8

    //generating c16
    and gen_pc1a(pc1a, c_in, P0, P1);
    and gen_pc1b(pc1b, G0, P1);
    or gen_c16(c16, pc1a, pc1b, G1); // decide c16 for carry

    cla_8b cla16_23(add_out[23:16], P2, G2, c_msb23, data_operandA[23:16], data_operandB[23:16], c16); //adding 3rd 8


    //generating c24
    and gen_pc2a(pc2a, c_in, P0, P1, P2);
    and gen_pc2b(pc2b, G0, P1, P2);
    and gen_pc2c(pc2c, G1, P2);
    or gen_c24(c24, pc2a, pc2b, pc2c, G2); // decide c24 for carry

    cla_8b cla24_31(add_out[31:24], P3, G3, c_msb31, data_operandA[31:24], data_operandB[31:24], c24); //adding 4th 8

    //addition complete, now need to generate overflow:

    //generating c32
    and gen_pc3a(pc3a, c_in, P0, P1, P2, P3);
    and gen_pc3b(pc3b, G0, P1, P2, P3);
    and gen_pc3c(pc3c, G1, P2, P3);
    and gen_pc3d(pc3d, G2, P3);
    or gen_c32(c32, pc3a, pc3b, pc3c, pc3d, G3); // decide c32 for carry

    
    //overflow occurs if carry in and carry out to the MSB are different
    xor overflow(add_overflow, c32, c_msb31);
    


endmodule