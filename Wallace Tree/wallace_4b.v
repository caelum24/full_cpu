module wallace_tree_4b(result, data_operandA, data_operandB);

input [3:0] data_operandA, data_operandB;
output [7:0] result;

//row 0

// wirename row_column
wire w_0_0, w_0_1, w_0_2, w_0_3;

assign w_0_0 = data_operandA[0] & data_operandB[0];
assign w_0_1 = data_operandA[1] & data_operandB[0];
assign w_0_2 = data_operandA[2] & data_operandB[0];
assign w_0_3 = ~(data_operandA[3] & data_operandB[0]);

assign result[0] = w_0_0;

//row 1
wire w_1_1, w_1_2, w_1_3, w_1_4;
wire s_1_1, s_1_2, s_1_3, s_1_4;
wire c_1_1, c_1_2, c_1_3, c_1_4;

assign w_1_1 = data_operandA[0] & data_operandB[1];
assign w_1_2 = data_operandA[1] & data_operandB[1];
assign w_1_3 = data_operandA[2] & data_operandB[1];
assign w_1_4 = ~(data_operandA[3] & data_operandB[1]);

full_adder adder_1_1(.S(s_1_1), .Cout(c_1_1), .A(w_0_1), .B(w_1_1), .Cin(1'b0));
full_adder adder_1_2(.S(s_1_2), .Cout(c_1_2), .A(w_0_2), .B(w_1_2), .Cin(c_1_1));
full_adder adder_1_3(.S(s_1_3), .Cout(c_1_3), .A(w_0_3), .B(w_1_3), .Cin(c_1_2));
full_adder adder_1_4(.S(s_1_4), .Cout(c_1_4), .A(1'b1), .B(w_1_4), .Cin(c_1_3));

assign result[1] = s_1_1;

//row 2
wire w_2_2, w_2_3, w_2_4, w_2_5;
wire s_2_2, s_2_3, s_2_4, s_2_5;
wire c_2_2, c_2_3, c_2_4, c_2_5;

assign w_2_2 = data_operandA[0] & data_operandB[2];
assign w_2_3 = data_operandA[1] & data_operandB[2];
assign w_2_4 = data_operandA[2] & data_operandB[2];
assign w_2_5 = ~(data_operandA[3] & data_operandB[2]);

full_adder adder_2_2(.S(s_2_2), .Cout(c_2_2), .A(s_1_2), .B(w_2_2), .Cin(1'b0));
full_adder adder_2_3(.S(s_2_3), .Cout(c_2_3), .A(s_1_3), .B(w_2_3), .Cin(c_2_2));
full_adder adder_2_4(.S(s_2_4), .Cout(c_2_4), .A(s_1_4), .B(w_2_4), .Cin(c_2_3));
full_adder adder_2_5(.S(s_2_5), .Cout(c_2_5), .A(c_1_4), .B(w_2_5), .Cin(c_2_4));

assign result[2] = s_2_2;

//row 3 (final row)
wire w_3_3, w_3_4, w_3_5, w_3_6;
wire s_3_3, s_3_4, s_3_5, s_3_6, s_3_7;
wire c_3_3, c_3_4, c_3_5, c_3_6, c_3_7;

assign w_3_3 = ~(data_operandA[0] & data_operandB[3]);
assign w_3_4 = ~(data_operandA[1] & data_operandB[3]);
assign w_3_5 = ~(data_operandA[2] & data_operandB[3]);
assign w_3_6 = data_operandA[3] & data_operandB[3];

full_adder adder_3_3(.S(s_3_3), .Cout(c_3_3), .A(s_2_3), .B(w_3_3), .Cin(1'b0));
full_adder adder_3_4(.S(s_3_4), .Cout(c_3_4), .A(s_2_4), .B(w_3_4), .Cin(c_3_3));
full_adder adder_3_5(.S(s_3_5), .Cout(c_3_5), .A(s_2_5), .B(w_3_5), .Cin(c_3_4));
full_adder adder_3_6(.S(s_3_6), .Cout(c_3_6), .A(c_2_5), .B(w_3_6), .Cin(c_3_5));
full_adder adder_3_7(.S(s_3_7), .Cout(c_3_7), .A(1'b1), .B(c_3_6), .Cin(1'b0));

assign result[3] = s_3_3;
assign result[4] = s_3_4;
assign result[5] = s_3_5;
assign result[6] = s_3_6;
assign result[7] = s_3_7;


endmodule