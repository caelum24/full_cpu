module sll_32bit(sll_out, data_operandA, ctrl_shiftamt);

    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;
    output [31:0] sll_out;
    wire [31:0] wsl_1, wsl_2, wsl_4, wsl_8, wsl_16; //outputs of the shift modules
    wire [31:0] os_1, os_2, os_4, os_8, os_16; //outputs of the mux choices for each shift option


    sl_1b sl_1(wsl_1, data_operandA);
    mux_2 one_b(os_1, ctrl_shiftamt[0], data_operandA, wsl_1);

    sl_2b sl_2(wsl_2, os_1);
    mux_2 two_b(os_2, ctrl_shiftamt[1], os_1, wsl_2);

    sl_4b sl_4(wsl_4, os_2);
    mux_2 four_b(os_4, ctrl_shiftamt[2], os_2, wsl_4);

    sl_8b sl_8(wsl_8, os_4);
    mux_2 eight_b(os_8, ctrl_shiftamt[3], os_4, wsl_8);

    sl_16b sl_16(wsl_16, os_8);
    mux_2 sixteen_b(os_16, ctrl_shiftamt[4], os_8, wsl_16);
    assign sll_out = os_16;

endmodule