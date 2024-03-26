module sra_32bit(sra_out, data_operandA, ctrl_shiftamt);

    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;
    output [31:0] sra_out;
    wire [31:0] wsr_1, wsr_2, wsr_4, wsr_8, wsr_16; //outputs of the shift modules
    wire [31:0] os_1, os_2, os_4, os_8, os_16; //outputs of the mux choices for each shift option


    sr_1b sr_1(wsr_1, data_operandA);
    mux_2 one_b(os_1, ctrl_shiftamt[0], data_operandA, wsr_1);

    sr_2b sr_2(wsr_2, os_1);
    mux_2 two_b(os_2, ctrl_shiftamt[1], os_1, wsr_2);

    sr_4b sr_4(wsr_4, os_2);
    mux_2 four_b(os_4, ctrl_shiftamt[2], os_2, wsr_4);

    sr_8b sr_8(wsr_8, os_4);
    mux_2 eight_b(os_8, ctrl_shiftamt[3], os_4, wsr_8);

    sr_16b sr_16(wsr_16, os_8);
    mux_2 sixteen_b(os_16, ctrl_shiftamt[4], os_8, wsr_16);
    assign sra_out = os_16;

endmodule