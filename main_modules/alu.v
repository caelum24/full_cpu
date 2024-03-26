module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    wire [31:0] add_out, sub_out, and_out, or_out, sll_out, sra_out;
    wire add_overflow, sub_overflow;
    // add your code here:

    add_32bit ADD_LOGIC(add_out, add_overflow, data_operandA, data_operandB);    
    sub_32bit SUB_LOGIC(sub_out, isNotEqual, isLessThan, sub_overflow, data_operandA, data_operandB); 
    and_32bit AND_LOGIC(and_out, data_operandA, data_operandB);
    or_32bit  OR_LOGIC(or_out, data_operandA, data_operandB);
    sll_32bit SLL_LOGIC(sll_out, data_operandA, ctrl_shiftamt);
    sra_32bit SRA_LOGIC(sra_out, data_operandA, ctrl_shiftamt);


    mux_8 CHOOSER(data_result, ctrl_ALUopcode[2:0], add_out, sub_out, and_out, or_out, sll_out, sra_out, data_operandA, data_operandA); //don't care about the last 2 inputs
    assign overflow = ctrl_ALUopcode[0] ? sub_overflow : add_overflow; //one bit mux, add is 0 and sub is 1
    // mux_2 OVERFLOW_LOGIC(overflow, ctrl_ALUopcode[0], add_overflow, sub_overflow); 32 bit mux too big for this use

    
endmodule


//problems I might encounter: 
    // no not gate, might need to replace with a nand gate
    //never really did any checking of the individual modules, mostly because I don't want to build a test bench for each thing
