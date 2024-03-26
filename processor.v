/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */
	//controls wire declaration 
    wire choose_alu_B, alu_addi, alu_sub, is_bne, is_blt, wren_dmem, wren_reg_d, choose_reg_din, reg_b_choose, is_jump, xm_is_jal, wb_is_jal, is_jr, xm_is_setxT, wb_is_setxT, dx_is_bex, xm_is_bex, mw_wren_reg_d;
    wire is_MX_A, is_MX_B, is_WX_A, is_WX_B, is_WM_B, hazard_stall;
    wire input_en;
    assign input_en = 1'b1; 
    
    //FD STAGE

    //program counter
    wire [31:0] incremented_pc, pc_output, pc_input;

    wire valid_bj;
    //Note: the blt logic is flipped for greater than because it was easier to make register B output rd and then flip the 
    //outputs here than add new logic to do the correct subtract
    assign valid_bj = (isNotEqual && is_bne) || (~isLessThan && isNotEqual && is_blt) || (isNotEqual && xm_is_bex) || is_jump; //checking whether branch/jump should occur

    assign pc_input = valid_bj ? pc_hopper : incremented_pc; //chooses between incrementing and changing to branched/jumped location

    register_32b program_counter(pc_output, pc_input, clock, (input_en && ~multdiv_halt && ~hazard_stall), reset); 
    add_32bit pc_incrementer(.add_out(incremented_pc), .data_operandA(pc_output), .data_operandB(32'd1));
    assign address_imem = pc_output;

    //latch for f/d stage, working with instruction memory
    wire [31:0] f_opcode, fd_pc_out;
    register_32b fd_pc(fd_pc_out, pc_output, ~clock, (input_en && ~multdiv_halt && ~hazard_stall), reset); //QUESTION: changing pc_output from incremented_pc made the jumps and branches work?
    wire [31:0] fd_clean_op;
    mux_2 fd_branch_cleaner(fd_clean_op, valid_bj, q_imem, 32'b0);
    register_32b fd_instruction(f_opcode, fd_clean_op, ~clock, (input_en && ~multdiv_halt && ~hazard_stall), reset);
    

    //DX STAGE
    //reading and writing regfile
    //data_writeReg assigned as output to final stage (done)
    //assign ctrl_writeReg = ;  which reg to write to (done)
    // wren_reg_d will decide if we can write into the write register
    assign ctrl_writeEnable = wren_reg_d; 
    // assign ctrl_writeEnable = 1'b1;//debug
    // assign ctrl_writeReg = pc_output;//debug
    // assign data_writeReg = 32'b0000_0000_0000_0000_0000_0000_0000_0011; //debug step

    //for lw and sw
    assign ctrl_readRegA = dx_is_bex ? 5'd30 : f_opcode[21:17];  //which reg to read A from (30 for bexT)
    wire [4:0] read_regB_bridge;
    assign read_regB_bridge = reg_b_choose ? f_opcode[26:22] : f_opcode[16:12] ; //which reg to read B from -> for sw, rd is B
    assign ctrl_readRegB = dx_is_bex ? 5'd0 : read_regB_bridge; //choosing between opcode and bex for final register read value
	
    //latch for D/X stage
    wire [31:0] dx_opcode, dx_pc_out, dx_A_out, dx_B_out;
    register_32b dx_pc(dx_pc_out, fd_pc_out, ~clock, (input_en && ~multdiv_halt), reset);
    register_32b dx_A(dx_A_out, data_readRegA, ~clock, (input_en && ~multdiv_halt), reset);
    register_32b dx_B(dx_B_out, data_readRegB, ~clock, (input_en && ~multdiv_halt), reset);

    wire [31:0] dx_clean_op;
    mux_2 dx_branch_cleaner(dx_clean_op, (valid_bj || hazard_stall), f_opcode, 32'b0);
    register_32b dx_instruction(dx_opcode, dx_clean_op, ~clock, (input_en && ~multdiv_halt), reset);  

    wire [31:0] xm_A_or_bp, xm_B_or_bp; //xm input decided between dx latch and bypassing options
    
    //TODO: could make this more efficient by pulling the other one in instead
    wire [31:0] bypass_bridge, bypass_error, expected_bypass_value;
    mux_4 bypass_alu_error_input(bypass_bridge, xm_opcode[3:2], 32'd1, 32'd3, 32'd4, 32'd5);
    mux_2 bypass_alu_or_imm_error(bypass_error, xm_opcode[27], bypass_bridge, 32'd2); //deciphering what the error value would be if there was one
    mux_2 bypass_write_data(expected_bypass_value, xm_error_out, xm_o_out, bypass_error); //choosing what value to send to register file if error vs not
    // EXPECTED BYPASS VALUE INCORRECT IN BRANCH-> LW NEEDS TO STALL ONE FOR BNE
    mux_4 A_bypass(xm_A_or_bp, {(is_WX_A && ctrl_writeEnable), (is_MX_A && mw_wren_reg_d)}, dx_A_out, expected_bypass_value, data_writeReg, expected_bypass_value); //both 0, normal, 1 or 1, choose that, but 11-> choose xm because it is closest for bypass
    mux_4 B_bypass(xm_B_or_bp, {(is_WX_B && ctrl_writeEnable), (is_MX_B && mw_wren_reg_d)}, dx_B_out, expected_bypass_value, data_writeReg, expected_bypass_value);

    //XM STAGE
    wire [31:0] alu_in_B, sx_17_out, sx_27_out, pc_hopper, branch_result, data_result;
    wire isNotEqual, isLessThan;
    wire overflow;
    s_ext17_32 extender_17(sx_17_out, dx_opcode[16:0]);
    s_ext27_32 extender_27(sx_27_out, dx_opcode[26:0]); //QUESTION: is this logical or arithmetic extension?

    mux_2 alu_in(alu_in_B, choose_alu_B, xm_B_or_bp, sx_17_out); //choose between sx immediate and input B from register

    add_32bit pc_branch_calc(.add_out(branch_result), .data_operandA(dx_pc_out), .data_operandB(sx_17_out)); //adding branch immediate to incremented pc
    wire [31:0] jump_bridge;
    wire use_sx_27;
    assign use_sx_27 = is_jump || xm_is_bex;
    mux_2 branch_jump_chooser(jump_bridge, use_sx_27, branch_result, sx_27_out); //produces new PC value from jump or branch to be muxed in
    mux_2 jr_chooser(pc_hopper, is_jr, jump_bridge, alu_in_B); //chooses between previous mux result and jr choice
    

    //determining alu opcode based on what instruction is running
    wire [4:0] alu_opcode, alu_helper;
    mux_2_5b select_alu_helper(alu_helper, alu_addi, dx_opcode[6:2], 5'b0);
    mux_2_5b select_alu_op(alu_opcode, alu_sub, alu_helper, 5'd1); //differentiating between alu and addi
    alu x_alu(.data_operandA(xm_A_or_bp), .data_operandB(alu_in_B), .ctrl_ALUopcode(alu_opcode), .ctrl_shiftamt(dx_opcode[11:7]), .data_result(data_result), .isNotEqual(isNotEqual), .isLessThan(isLessThan), .overflow(overflow));

    wire ctrl_MULT, ctrl_DIV, multdiv_exception, multdiv_resultRDY, is_mult, is_div;
    
    and mult_controller(is_mult, ~|dx_opcode[31:27], ~alu_opcode[4], ~alu_opcode[3], alu_opcode[2], alu_opcode[1], ~alu_opcode[0]); //based on proper alu_op bits and opcode
    and div_controller(is_div, ~|dx_opcode[31:27], ~alu_opcode[4], ~alu_opcode[3], alu_opcode[2], alu_opcode[1], alu_opcode[0]); //based on proper alu_op bits and opcode

    wire mul_p1, mul_p2, div_p1, div_p2;
    dffe_ref mul_control1(mul_p1, is_mult, clock, input_en, multdiv_resultRDY);
    dffe_ref mul_control2(mul_p2, mul_p1, clock, input_en, multdiv_resultRDY);
    assign ctrl_MULT = mul_p1 && ~mul_p2; //creates a 1 cycle pulse for ctrl_MULT to be high

    dffe_ref div_control1(div_p1, is_div, clock, input_en, multdiv_resultRDY);
    dffe_ref div_control2(div_p2, div_p1, clock, input_en, multdiv_resultRDY);
    assign ctrl_DIV = div_p1 && ~div_p2; //creates a 1 cycle pulse for ctrl_DIV to be high

    wire multdiv_halt;
    // assign multdiv_halt = 1'b0;
    // assign multdiv_resultRDY = 1'b0;
    // dffe_ref halter(multdiv_halt, (is_mult && ~multdiv_resultRDY) || (is_div && ~multdiv_resultRDY), clock, input_en, reset); //changing clock to not clock works
    assign multdiv_halt = (is_mult && ~multdiv_resultRDY) || (is_div && ~multdiv_resultRDY);

    wire [31:0] multdiv_result;
    // //QUESTION: how do we put exceptions in register 30? is it immediate or when we get to wb?
    // and mult_controller(ctrl_MULT, ~alu_opcode[4], ~alu_opcode[3], alu_opcode[2], alu_opcode[1], ~alu_opcode[0]); //based on proper alu_op bits
    // and div_controller(ctrl_DIV, ~alu_opcode[4], ~alu_opcode[3], alu_opcode[2], alu_opcode[1], alu_opcode[0]); //based on proper alu_op bits
    
    multdiv muldiv_operator(.data_operandA(xm_A_or_bp), .data_operandB(alu_in_B), .ctrl_MULT(ctrl_MULT), .ctrl_DIV(ctrl_DIV), .is_div(is_div), .clock(clock), .data_result(multdiv_result), .data_exception(multdiv_exception), .data_resultRDY(multdiv_resultRDY));

    wire [31:0] xm_result, xm_result_bridge, xm_result_bridge2;    
    mux_2 jal_xm_out(xm_result_bridge, xm_is_jal, data_result, dx_pc_out);
    mux_2 setxT_xm_out(xm_result_bridge2, xm_is_setxT, xm_result_bridge, sx_27_out); //potentially outputting T to writing stages later for setxT
    mux_2 multdiv_out(xm_result, (is_div || is_mult), xm_result_bridge2, multdiv_result); //outputting multdiv result if multdiv
        //NB: sometimes alu_in_B is rd, it's usually rt, but it is rd for sw

    //latch for X/M
    wire [31:0] xm_o_out, xm_b_out, xm_opcode;
    register_32b xm_instruction(xm_opcode, dx_opcode, ~clock, (input_en && ~multdiv_halt), reset);
    register_32b xm_o(xm_o_out, xm_result, ~clock, (input_en && ~multdiv_halt), reset); // will go into a of data memory and to o
    register_32b xm_b(xm_b_out, xm_B_or_bp, ~clock, (input_en && ~multdiv_halt), reset); //will go into d of data memory
    wire error_catch, xm_error_out;
    assign error_catch = (overflow && ~(is_mult || is_div)) || (multdiv_exception && (is_mult || is_div)); 
    // assign error_catch = overflow || ;
    dffe_ref xm_error(xm_error_out, error_catch, ~clock, (input_en && ~multdiv_halt), reset);


    //MW STAGE

    //memory stuff will go here
    
    assign address_dmem = xm_o_out; //address of memory to read/write
    //WM Bypass
    mux_2 mem_data_in(data, (is_WM_B && ctrl_writeEnable), xm_b_out, data_writeReg);
    // assign data = (is_WM_B && ctrl_writeEnable) ? data_writeReg : xm_b_out; //data to put through into memory if appropriate -> bypassed sometimes
    assign wren = wren_dmem; //will dictate if the data memory can be written to

    //latch for M/W
    wire [31:0] mw_opcode, mw_o_out, mw_d_out;
    wire error_out;
    register_32b mw_instruction(mw_opcode, xm_opcode, ~clock, input_en, reset); //mw_opcode part will go to regfile for datawrite
    register_32b mw_o(mw_o_out, xm_o_out, ~clock, input_en, reset);
    register_32b mw_d(mw_d_out, q_dmem, ~clock, input_en, reset); //input comes from data memory
    dffe_ref mw_error(error_out, xm_error_out, ~clock, input_en, reset); //flags if there was an error in the alu operations
    // assign data_writeReg = ; //debugging line

    //wb stage
    wire [4:0] write_reg_bridge;
    //QUESTION: could we also have these errors for lw and sw because they deal with adding???
    wire [31:0] expected_data, reg_error_value, error_value;
    mux_2 choose_mem_or_op(expected_data, choose_reg_din, mw_o_out, mw_d_out); //determining if alu or memory info is passed

    mux_4 reg_alu_error_input(reg_error_value, mw_opcode[3:2], 32'd1, 32'd3, 32'd4, 32'd5);
    mux_2 reg_or_imm_error(error_value, mw_opcode[27], reg_error_value, 32'd2); //deciphering what the error value would be if there was one
    mux_2 register_write_data(data_writeReg, error_out, expected_data, error_value); //choosing what value to send to register file if error vs not
    assign write_reg_bridge = (wb_is_setxT || error_out) ? 5'd30 : mw_opcode[26:22]; //to write data into 30 for setxT, also for alu errors
    assign ctrl_writeReg = wb_is_jal ? 5'd31 : write_reg_bridge; //where to write data into regfile (31 for jal)

    //asynchronous stuff:

    //controls
    // wire choose_alu_B, alu_addi, wren_dmem, wren_reg_d, choose_reg_din;
    wire [31:0] oh_dx_instructions, oh_xm_instructions, oh_mw_instructions, oh_wb_instructions;
    control controller(choose_alu_B, alu_addi, alu_sub, wren_dmem, wren_reg_d, choose_reg_din, reg_b_choose, is_jump, is_bne, is_blt, xm_is_jal, wb_is_jal, is_jr, xm_is_setxT, wb_is_setxT, dx_is_bex, xm_is_bex, mw_wren_reg_d, oh_dx_instructions, oh_xm_instructions, oh_mw_instructions, oh_wb_instructions, f_opcode[31:27], dx_opcode[31:27], xm_opcode[31:27], mw_opcode[31:27]); //output opcode from previous goes to this
	hazards hazard_fixer(is_MX_A, is_MX_B, is_WX_A, is_WX_B, is_WM_B, hazard_stall, oh_dx_instructions, oh_xm_instructions, oh_mw_instructions, oh_wb_instructions, f_opcode, dx_opcode, xm_opcode, mw_opcode, xm_error_out, error_out);
    /* END CODE */

    //PROBLEM: JAL always gives a PC+1 that is 1 more than expected
        //After further analysis, blt and bgt suffer from the same issue, accidentally skipping 1 instruction in the path after a jump or branch

    //TODO: technically, if we got an overflow on the address while trying to do a lw or sw, we should turn off wren to memory and register file
    //This would also apply to some of the other operations as well

    //LEFT TO COMPLETE:
        //todo: could implement fast branching/jumps/branch prediction
        //todo: weird bug where I jump one thing short but the nop stuff saves me?


    //bugs I encountered:
        //lots of typos
        //figuring out when to default to registers like 30 or 31
        //forgot about lw stall for a bit, but then messed up the implementation, causing me to fail sort
        //gradescope was hitting errors that weren't happening locally, and I had to restart part of the project to get it to work
        //implementing the multdiv stalling took multiple attempts with different implementations
        // error bypassing from mem to execute-> made a second mux system because I didn't want to deal with it (oops)
endmodule
