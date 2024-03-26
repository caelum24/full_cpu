module array_divider_4b(Q, data_operandA, data_operandB); //, clock, ctrl_DIV, data_resultRDY

    input [3:0] data_operandA, data_operandB;
    input clock, ctrl_DIV;
    output [3:0] Q;
    output data_resultRDY;

    wire [6:0] dividend;
    wire [3:0] divisor;

    
    //TODO: check if needs to be unsigned
    assign divisor = data_operandB;
    assign dividend[3:0] = data_operandA; //replace with output of negating maybe
    assign dividend[6:4] = 3'b0;

    // (Sum, Cout, Din, Bin, Cin, Ain);
    
    //row 0
    wire c_0_0, c_0_1, c_0_2, c_0_3;
    wire empty0, s_0_1, s_0_2, s_0_3;

    divider_cell cell_0_0(empty0, c_0_0, divisor[3], dividend[6], c_0_1, 1'b1);
    divider_cell cell_0_1(s_0_1, c_0_1, divisor[2], dividend[5], c_0_2, 1'b1);
    divider_cell cell_0_2(s_0_2, c_0_2, divisor[1], dividend[4], c_0_3, 1'b1);
    divider_cell cell_0_3(s_0_3, c_0_3, divisor[0], dividend[3], 1'b1, 1'b1);

    assign Q[3] = c_0_0;

    //row 1
    wire c_1_1, c_1_2, c_1_3, c_1_4;
    wire empty1, s_1_2, s_1_3, s_1_4;

    divider_cell cell_1_1(empty1, c_1_1, divisor[3], s_0_1, c_1_2, c_0_0);
    divider_cell cell_1_2(s_1_2, c_1_2, divisor[2], s_0_2, c_1_3, c_0_0);
    divider_cell cell_1_3(s_1_3, c_1_3, divisor[1], s_0_3, c_1_4, c_0_0);
    divider_cell cell_1_4(s_1_4, c_1_4, divisor[0], dividend[2], c_0_0, c_0_0);

    assign Q[2] = c_1_1;

    //row 2
    wire c_2_2, c_2_3, c_2_4, c_2_5;
    wire empty2, s_2_3, s_2_4, s_2_5;

    divider_cell cell_2_2(empty2, c_2_2, divisor[3], s_1_2, c_2_3, c_1_1);
    divider_cell cell_2_3(s_2_3, c_2_3, divisor[2], s_1_3, c_2_4, c_1_1);
    divider_cell cell_2_4(s_2_4, c_2_4, divisor[1], s_1_4, c_2_5, c_1_1);
    divider_cell cell_2_5(s_2_5, c_2_5, divisor[0], dividend[1], c_1_1, c_1_1);

    assign Q[1] = c_2_2;

    //row 3 (final row)

    wire c_3_3, c_3_4, c_3_5, c_3_6;
    wire empty3, s_3_4, s_3_5, s_3_6;

    divider_cell cell_3_3(empty3, c_3_3, divisor[3], s_2_3, c_3_4, c_2_2);
    divider_cell cell_3_4(s_3_4, c_3_4, divisor[2], s_2_4, c_3_5, c_2_2);
    divider_cell cell_3_5(s_3_5, c_3_5, divisor[1], s_2_5, c_3_6, c_2_2);
    divider_cell cell_3_6(s_3_6, c_3_6, divisor[0], dividend[0], c_2_2, c_2_2);

    assign Q[0] = c_3_3;

endmodule