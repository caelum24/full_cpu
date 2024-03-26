module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, is_div,
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock, is_div;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    //Counter to determine data ready 
    wire [2:0] count;
    wire count_reset;
    assign count_reset = (ctrl_DIV || ctrl_MULT);
    mod_8_counter staller(count, clock, 1'b1, count_reset);

    // wire [31:0] latched_A, latched_B; //will use this as output of registers to hold values of A and B while data is propogating
    //multiplication
    wire [63:0] mult_result;
    wire mult_RDY;
    wallace_tree_32b god(mult_result, data_operandA, data_operandB);
    // assign mult_RDY = 1'b1; // TODO: will possibly need to clock this 2+ cycles
    assign mult_RDY = count[2] && ~count[1] && ~count[0];
    
    wire mult_exception, mult_zeros, mult_ones;

    assign mult_zeros = |mult_result[63:31];
    assign mult_ones = &mult_result[63:31];
    and mult_data_exception(mult_exception, mult_zeros, ~mult_ones);

    //will need to implement a 2+ cycle counter before flashing data_resultRDY

    //divider
    wire [31:0] div_result; //quotient
    array_divider_32b slower_god(div_result, data_operandA, data_operandB);
    wire div_exception, div_RDY;
    
    assign div_exception = ~|data_operandB;
    // assign div_RDY = 1'b1; // TODO: will  need to clock this 2+ cycles
    assign div_RDY = (count[2] && count[1] && ~count[0]); //wait 6 cycles for divide?

    //latch to assert whether a mult or div is currently occuring
    wire choice_exception, current_process;
    assign current_process = is_div;
    // latch exception_chooser(current_process, ctrl_MULT, ctrl_DIV); // 0 is mult, 1 is div
    // dffe_ref proc_chooser(current_process, ctrl_DIV, clock, ctrl_DIV, ctrl_MULT);

    //will later use logic to get the div implemented with this first
    
    assign data_result = current_process ? div_result : mult_result[31:0];
    // assign data_result = mult_result[31:0];
    //exception determining
    
    assign data_exception = current_process ? div_exception : mult_exception; //mux to determine the data exception
    
    //data ready?
    assign data_resultRDY = current_process ? div_RDY : mult_RDY;
        // assign data_resultRDY = 1'b1;




endmodule