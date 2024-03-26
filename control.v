module control(choose_alu_B, alu_addi, alu_sub, wren_dmem, wren_reg_d, choose_reg_din, reg_b_choose, is_jump, is_bne, is_blt, xm_is_jal, wb_is_jal, is_jr, xm_is_setxT, wb_is_setxT, dx_is_bex, xm_is_bex, mw_wren_reg_d, dx_instructions, xm_instructions, mw_instructions, wb_instructions, dx_opcode, xm_opcode, mw_opcode, wb_opcode);

    input [4:0] dx_opcode, xm_opcode, mw_opcode, wb_opcode; //aluop can get dealt with in the alu
    output choose_alu_B, alu_addi, alu_sub, wren_dmem, wren_reg_d, choose_reg_din, reg_b_choose, is_jump, is_bne, is_blt, xm_is_jal, wb_is_jal, is_jr, xm_is_setxT, wb_is_setxT, dx_is_bex, xm_is_bex, mw_wren_reg_d;
    output [31:0] dx_instructions, xm_instructions, mw_instructions, wb_instructions;
    wire [31:0] dx_instructions, xm_instructions, mw_instructions, wb_instructions;

    //control for dx stage
    decoder_5 dx_op_decoder(dx_instructions, dx_opcode);
    wire dx_alu, dx_addi, dx_sw, dx_lw, dx_jT, dx_bne, dx_jalT, dx_jr, dx_blt, dx_bex, dx_setx;
    assign dx_alu = dx_instructions[0];
    assign dx_addi = dx_instructions[5];
    assign dx_sw = dx_instructions[7];
    assign dx_lw = dx_instructions[8];
    assign dx_jT = dx_instructions[1];
    assign dx_bne = dx_instructions[2];
    assign dx_jalT = dx_instructions[3];
    assign dx_jr = dx_instructions[4];
    assign dx_blt = dx_instructions[6];
    assign dx_bex = dx_instructions[22];
    assign dx_setx = dx_instructions[21];

    wire reg_b_choose, dx_is_bex; 
    assign reg_b_choose = dx_sw || dx_bne || dx_blt || dx_jr; //blt will require some rejiggering in the muxing because we're doing the opposite thing here
    assign dx_is_bex = dx_bex;






    //control for xm stage
    decoder_5 xm_op_decoder(xm_instructions, xm_opcode);
    wire xm_alu, xm_addi, xm_sw, xm_lw, xm_jT, xm_bne, xm_jalT, xm_jr, xm_blt, xm_bex, xm_setx;
    assign xm_alu = xm_instructions[0];
    assign xm_addi = xm_instructions[5];
    assign xm_sw = xm_instructions[7];
    assign xm_lw = xm_instructions[8];
    assign xm_jT = xm_instructions[1];
    assign xm_bne = xm_instructions[2];
    assign xm_jalT = xm_instructions[3];
    assign xm_jr = xm_instructions[4];
    assign xm_blt = xm_instructions[6];
    assign xm_bex = xm_instructions[22];
    assign xm_setx = xm_instructions[21];

    wire choose_alu_B, alu_addi, alu_sub, is_jump, is_bne, is_blt, xm_is_jal, is_jr, xm_is_setxT, xm_is_bex;
    assign choose_alu_B = xm_addi || xm_lw || xm_sw; //determines if alu is using B or immediate 
    assign alu_addi = xm_addi || xm_lw || xm_sw; //making alu do an add instruction
    assign alu_sub = xm_blt || xm_bne || xm_bex;
    assign is_jump = xm_jT || xm_jalT || xm_jr;
    assign is_bne = xm_bne;
    assign is_blt = xm_blt;
    assign xm_is_jal = xm_jalT;
    assign is_jr = xm_jr;
    assign xm_is_setxT = xm_setx;
    assign xm_is_bex = xm_bex;







    //control for mw stage
    decoder_5 mw_op_decoder(mw_instructions, mw_opcode);
    wire mw_alu, mw_addi, mw_sw, mw_lw, mw_jT, mw_bne, mw_jalT, mw_jr, mw_blt, mw_bex, mw_setx;
    assign mw_alu = mw_instructions[0];
    assign mw_addi = mw_instructions[5];
    assign mw_sw = mw_instructions[7];
    assign mw_lw = mw_instructions[8];
    assign mw_jT = mw_instructions[1];
    assign mw_bne = mw_instructions[2];
    assign mw_jalT = mw_instructions[3];
    assign mw_jr = mw_instructions[4];
    assign mw_blt = mw_instructions[6];
    assign mw_bex = mw_instructions[22];
    assign mw_setx = mw_instructions[21];

    wire wren_dmem, mw_wren_reg_d;
    assign wren_dmem = mw_sw; //Determines if we can write to memory
    assign mw_wren_reg_d = mw_alu || mw_addi || mw_lw || mw_jalT || mw_setx; //check one stage early if this instruction allows write into register file




    //control for wb stage
    decoder_5 wb_op_decoder(wb_instructions, wb_opcode);
    wire wb_alu, wb_addi, wb_sw, wb_lw, wb_jT, wb_bne, wb_jalT, wb_jr, wb_blt, wb_bex, wb_setx;
    assign wb_alu = wb_instructions[0];
    assign wb_addi = wb_instructions[5];
    assign wb_sw = wb_instructions[7];
    assign wb_lw = wb_instructions[8];
    assign wb_jT = wb_instructions[1];
    assign wb_bne = wb_instructions[2];
    assign wb_jalT = wb_instructions[3];
    assign wb_jr = wb_instructions[4];
    assign wb_blt = wb_instructions[6];
    assign wb_bex = wb_instructions[22];
    assign wb_setx = wb_instructions[21];

    wire wren_reg_d, choose_reg_din, wb_is_jal;
    assign wren_reg_d = wb_alu || wb_addi || wb_lw || wb_jalT || wb_setx; //allows write into register file
    assign choose_reg_din = wb_lw; 
    assign wb_is_jal = wb_jalT;
    assign wb_is_setxT = wb_setx;

endmodule