module or_32bit(result, A, B);

    input [31:0] A, B;
    output [31:0] result;

    or o0(result[0], A[0], B[0]);
    or o1(result[1], A[1], B[1]);
    or o2(result[2], A[2], B[2]);
    or o3(result[3], A[3], B[3]);
    or o4(result[4], A[4], B[4]);
    or o5(result[5], A[5], B[5]);
    or o6(result[6], A[6], B[6]);
    or o7(result[7], A[7], B[7]);
    or o8(result[8], A[8], B[8]);
    or o9(result[9], A[9], B[9]);
    or o10(result[10], A[10], B[10]);
    or o11(result[11], A[11], B[11]);
    or o12(result[12], A[12], B[12]);
    or o13(result[13], A[13], B[13]);
    or o14(result[14], A[14], B[14]);
    or o15(result[15], A[15], B[15]);
    or o16(result[16], A[16], B[16]);
    or o17(result[17], A[17], B[17]);
    or o18(result[18], A[18], B[18]);
    or o19(result[19], A[19], B[19]);
    or o20(result[20], A[20], B[20]);
    or o21(result[21], A[21], B[21]);
    or o22(result[22], A[22], B[22]);
    or o23(result[23], A[23], B[23]);
    or o24(result[24], A[24], B[24]);
    or o25(result[25], A[25], B[25]);
    or o26(result[26], A[26], B[26]);
    or o27(result[27], A[27], B[27]);
    or o28(result[28], A[28], B[28]);
    or o29(result[29], A[29], B[29]);
    or o30(result[30], A[30], B[30]);
    or o31(result[31], A[31], B[31]);    

endmodule