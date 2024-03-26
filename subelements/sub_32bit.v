module sub_32bit(sub_out, isNotEqual, isLessThan, sub_overflow, data_operandA, data_operandB);

    input [31:0] data_operandA, data_operandB;
    
    output [31:0] sub_out;
    output isNotEqual, isLessThan, sub_overflow;

    wire [31:0] not_operandB;
    //i'm pretty sure nots exist
    not not0(not_operandB[0], data_operandB[0]);
    not not1(not_operandB[1], data_operandB[1]);
    not not2(not_operandB[2], data_operandB[2]);
    not not3(not_operandB[3], data_operandB[3]);
    not not4(not_operandB[4], data_operandB[4]);
    not not5(not_operandB[5], data_operandB[5]);
    not not6(not_operandB[6], data_operandB[6]);
    not not7(not_operandB[7], data_operandB[7]);
    not not8(not_operandB[8], data_operandB[8]);
    not not9(not_operandB[9], data_operandB[9]);
    not not10(not_operandB[10], data_operandB[10]);
    not not11(not_operandB[11], data_operandB[11]);
    not not12(not_operandB[12], data_operandB[12]);
    not not13(not_operandB[13], data_operandB[13]);
    not not14(not_operandB[14], data_operandB[14]);
    not not15(not_operandB[15], data_operandB[15]);
    not not16(not_operandB[16], data_operandB[16]);
    not not17(not_operandB[17], data_operandB[17]);
    not not18(not_operandB[18], data_operandB[18]);
    not not19(not_operandB[19], data_operandB[19]);
    not not20(not_operandB[20], data_operandB[20]);
    not not21(not_operandB[21], data_operandB[21]);
    not not22(not_operandB[22], data_operandB[22]);
    not not23(not_operandB[23], data_operandB[23]);
    not not24(not_operandB[24], data_operandB[24]);
    not not25(not_operandB[25], data_operandB[25]);
    not not26(not_operandB[26], data_operandB[26]);
    not not27(not_operandB[27], data_operandB[27]);
    not not28(not_operandB[28], data_operandB[28]);
    not not29(not_operandB[29], data_operandB[29]);
    not not30(not_operandB[30], data_operandB[30]);
    not not31(not_operandB[31], data_operandB[31]);

    wire c_in;
    assign c_in = 1; //adding 1 to the inverted B

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

    cla_8b cla0_7(sub_out[7:0], P0, G0, c_msb7, data_operandA[7:0], not_operandB[7:0], c_in); //adding 1st 8

    //generating c8
    and gen_pc0(pc0, c_in, P0);
    or gen_c8(c8, pc0, G0); // decide c8 for carry

    cla_8b cla8_15(sub_out[15:8], P1, G1, c_msb15, data_operandA[15:8], not_operandB[15:8], c8); //adding 2nd 8

    //generating c16
    and gen_pc1a(pc1a, c_in, P0, P1);
    and gen_pc1b(pc1b, G0, P1);
    or gen_c16(c16, pc1a, pc1b, G1); // decide c16 for carry

    cla_8b cla16_23(sub_out[23:16], P2, G2, c_msb23, data_operandA[23:16], not_operandB[23:16], c16); //adding 3rd 8


    //generating c24
    and gen_pc2a(pc2a, c_in, P0, P1, P2);
    and gen_pc2b(pc2b, G0, P1, P2);
    and gen_pc2c(pc2c, G1, P2);
    or gen_c24(c24, pc2a, pc2b, pc2c, G2); // decide c24 for carry

    cla_8b cla24_31(sub_out[31:24], P3, G3, c_msb31, data_operandA[31:24], not_operandB[31:24], c24); //adding 4th 8

    //subtraction complete, now need to generate overflow:

    //generating c32
    and gen_pc3a(pc3a, c_in, P0, P1, P2, P3);
    and gen_pc3b(pc3b, G0, P1, P2, P3);
    and gen_pc3c(pc3c, G1, P2, P3);
    and gen_pc3d(pc3d, G2, P3);
    or gen_c32(c32, pc3a, pc3b, pc3c, pc3d, G3); // decide c32 for carry

    
    //overflow occurs if carry in and carry out to the MSB are different
    xor overflow(sub_overflow, c32, c_msb31);

    //islessthan -> found a bug with this, if we have an overflow, the out may be positive, but the input was still less than
    wire lt, not_over, subout_over;
    and lt_input_based(lt, data_operandA[31], not_operandB[31]); //if A is negative and B is positive, we will have less than for sure
    not opp_over(not_over, sub_overflow);
    and gen_subout_over(subout_over, not_over, sub_out[31]); //true if not an overflow and we get a negative output
    or gen_Less_Than(isLessThan, subout_over, lt);
    // assign isLessThan = sub_out[31]; //if MSB of sub_out is 1, the result is negative, making A less than B

    //isNotEqual -> if any bit isn't 0, then A != B
    //**big ahh or gate
    or notEqual(isNotEqual, sub_out[0], sub_out[1], sub_out[2], sub_out[3], sub_out[4], sub_out[5], sub_out[6], sub_out[7],
                            sub_out[8], sub_out[9], sub_out[10], sub_out[11], sub_out[12], sub_out[13], sub_out[14], sub_out[15],
                            sub_out[16], sub_out[17], sub_out[18], sub_out[19], sub_out[20], sub_out[21], sub_out[22], sub_out[23],
                            sub_out[24], sub_out[25], sub_out[26], sub_out[27], sub_out[28], sub_out[29], sub_out[30], sub_out[31]);

endmodule