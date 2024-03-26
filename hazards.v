module hazards(is_MX_A, is_MX_B, is_WX_A, is_WX_B, is_WM_B, hazard_stall, oh_dx_instructions, oh_xm_instructions, oh_mw_instructions, oh_wb_instructions, dx_opcode, xm_opcode, mw_opcode, wb_opcode, xm_error_out, wb_error_out);

    input [31:0] dx_opcode, xm_opcode, mw_opcode, wb_opcode; //instructions in each stage
    input [31:0] oh_dx_instructions, oh_xm_instructions, oh_mw_instructions, oh_wb_instructions;  //32 bit OH based on what instruction that stage has (see control for guide)
    input xm_error_out, wb_error_out;
    output is_MX_A, is_MX_B, is_WX_A, is_WX_B, is_WM_B, hazard_stall;
//hazards to fix

    //data hazards

    //Stalling: read before write
        //FD.rs1 or FD.rs2 == DX.RD or XM.RD -> if an input reg of instruction in DX is output of instruction in XM or MW
            //TO FIX-> Insert a NOP going out of DX stage and halt PC and FD stage

    //Bypassing: -> how to compare-> use a bunch of XORs. If the output is all 0, then they are equal
        //MX bypassing -> if output reg in MW is an input reg in XM, bypass with mux into XM (done)
        //WX bypassing -> if output reg in WB is an input reg in XM, bypass with mux into XM (done)
        //CAN DO THIS FOR BOTH A AND B INPUT REGISTERS

        //WM bypassing -> if output reg in WB is data register in MW (register B), mux it into data

    //Stall and bypass
        //if load output is right in front of input of that register, need to stall just 1 and then bypass from wb stage



    //Instructions that will never require bypassing (the ji instructions):
        //j T
        //jal T
        //bex T
        //setx T

    //TODO!!!!!: could be a hazard for setx or if there is an error in the alu
    //TODO-> need to fix hazards for setx and other r30 operations-> rd is always 30, but I haven't done that yet
        //bext -> A is always r30 [22] (done)
        //setx -> rd is always r30 [21] (done)
    //TODO-> if there is an exception in the execute stage, I need to check on reg 30 for previous stage
    //TODO-> might have flipped the lw sw edge case thing, need to double check
    //DX hazard logic
    wire dx_is_R, dx_is_I, dx_is_Ji, dx_is_Jii; //Important for figuring out which registers are actually important for stalling and bypassing
    
    assign dx_is_R = ~|dx_opcode[31:27];
    assign dx_is_I = oh_dx_instructions[5] ||  oh_dx_instructions[7] || oh_dx_instructions[8] || oh_dx_instructions[2] || oh_dx_instructions[6];
    assign dx_is_Ji = oh_dx_instructions[1] || oh_dx_instructions[3] || oh_dx_instructions[22] || oh_dx_instructions[21];
    assign dx_is_Jii = oh_dx_instructions[4];

    wire [4:0] dx_in_A, dx_in_B, dx_out, dx_a_bridge, dx_b_bridge;
    wire hazard_stall;
    //TODO: if we can't bypass the thing later, we will need to stall it here
    
    assign dx_a_bridge = (dx_is_R || dx_is_I) ? dx_opcode[21:17] : 5'b0; //TODO: think I found a bug here, will test it for edge case
    assign dx_in_A = oh_dx_instructions[22] ? 5'd30 : dx_a_bridge; //if it's a bex, the register A is always 30
    assign dx_b_bridge = dx_is_R ? dx_opcode[16:12] : 5'b0; //if it's an R type instruction, B is rt, else, it will be overwritten in execute so doesn't matter
    assign dx_in_B = (dx_is_Jii || oh_dx_instructions[7] || oh_dx_instructions[2] || oh_dx_instructions[6]) ? dx_opcode[26:22] : dx_b_bridge; // for branching, sw, and jr, B really matters and is rd, else, B is 0

    //TODO: this could be made more efficient, as not all instructions where this is true actually need to do operations on the values
    assign hazard_stall = oh_xm_instructions[8] && ((dx_in_A == xm_out) || (dx_in_B == xm_out)) && (xm_out != 5'b0); //if we have a load and need to operate on the input
    

    //if we have a load right before any operation that requires that data (except for store)
    //TODO: some weird logic about storing for stalls

    //XM hazard logic
    wire xm_is_R, xm_is_I, xm_is_Ji, xm_is_Jii; //Important for figuring out which registers are actually important for stalling and bypassing
    
    assign xm_is_R = ~|xm_opcode[31:27];
    assign xm_is_I = oh_xm_instructions[5] ||  oh_xm_instructions[7] || oh_xm_instructions[8] || oh_xm_instructions[2] || oh_xm_instructions[6];
    assign xm_is_Ji = oh_xm_instructions[1] || oh_xm_instructions[3] || oh_xm_instructions[22] || oh_xm_instructions[21];
    assign xm_is_Jii = oh_xm_instructions[4];
    
    wire [4:0] xm_in_A, xm_in_B, xm_out, xm_a_bridge, xm_b_bridge;
    assign xm_out = (xm_is_R || oh_xm_instructions[8] || oh_xm_instructions[5]) ? xm_opcode[26:22] : 5'b0; //rd will be 26:22 if R, lw, addi instruction, else doesn't matter

    //MX Bypass
    assign xm_a_bridge = (xm_is_R || xm_is_I) ? xm_opcode[21:17] : 5'b0;
    assign xm_in_A = oh_xm_instructions[22] ? 5'd30 : xm_a_bridge; //if it's a bex, the register A is always 30

    // assign xm_in_A = (xm_is_R || xm_is_I) ? xm_opcode[21:17] : 5'b0;
    assign xm_b_bridge = xm_is_R ? xm_opcode[16:12] : 5'b0; //if it's an R type instruction, B is rt
    assign xm_in_B = (xm_is_Jii || oh_xm_instructions[7] || oh_xm_instructions[2] || oh_xm_instructions[6]) ? xm_opcode[26:22] : xm_b_bridge; // for branching, sw, and jr, B really matters and is rd, else, B is 0

    //Decide MX Bypass for A and B
    //TODO -> can have this logic and then have control to see if the value would actually be written into the register by having an early reg wren calculation
        //that way, we won't bypass if it really isn't necessary
    wire is_MX_A, is_MX_B;
    //If the output register in MW stage is input to xm stage, we need to wormhole the value in
    assign is_MX_A = (xm_in_A == mw_out) && (xm_in_A != 5'b0);
    assign is_MX_B = (xm_in_B == mw_out) && (xm_in_B != 5'b0); 

    //Decide WX Bypass for A and B
    wire is_WX_A, is_WX_B;
    //If the output register in WB stage is input to xm stage, we need to wormhole the value in
    assign is_WX_A = (xm_in_A == wb_out) && (xm_in_A != 5'b0);
    assign is_WX_B = (xm_in_B == wb_out) && (xm_in_B != 5'b0); 
    
    //mw hazard logic
    wire mw_is_R, mw_is_I, mw_is_Ji, mw_is_Jii; //Important for figuring out which registers are actually important for stalling and bypassing
    
    assign mw_is_R = ~|mw_opcode[31:27];
    assign mw_is_I = oh_mw_instructions[5] ||  oh_mw_instructions[7] || oh_mw_instructions[8] || oh_mw_instructions[2] || oh_mw_instructions[6];
    assign mw_is_Ji = oh_mw_instructions[1] || oh_mw_instructions[3] || oh_mw_instructions[22] || oh_mw_instructions[21];
    assign mw_is_Jii = oh_mw_instructions[4];

    wire [4:0] mw_in_B, mw_out, mw_out_bridge; //mw_in_A not needed
    // assign mw_out = xm_is_Ji ? 5'b0 : xm_opcode[26:22]; //rd will always be 26:22 unless JI instruction -> no longer true
    assign mw_out_bridge = (mw_is_R || oh_mw_instructions[8] || oh_mw_instructions[5]) ? mw_opcode[26:22] : 5'b0; //rd will be 26:22 if R, lw, addi instruction, else doesn't matter
    assign mw_out = (oh_xm_instructions[21] || xm_error_out) ? 5'd30 : mw_out_bridge; //setx always has rd = 30; //TODO: alu exception will go here
    //Decide WM bypass 
    wire is_WM_B;
    assign mw_in_B = oh_mw_instructions[7] ? mw_opcode[26:22] : 5'b0; // for sw B really matters and is rd, else, B is 0;
    assign is_WM_B = (mw_in_B == wb_out) && (mw_in_B != 5'b0);


    //wb hazard logic
    wire wb_is_R, wb_is_I, wb_is_Ji, wb_is_Jii; //Important for figuring out which registers are actually important for stalling and bypassing
    assign wb_is_R = ~|wb_opcode[31:27];
    assign wb_is_I = oh_wb_instructions[5] ||  oh_wb_instructions[7] || oh_wb_instructions[8] || oh_wb_instructions[2] || oh_wb_instructions[6];
    assign wb_is_Ji = oh_wb_instructions[1] || oh_wb_instructions[3] || oh_wb_instructions[22] || oh_wb_instructions[21];
    assign wb_is_Jii = oh_wb_instructions[4];

    wire [4:0] wb_out, wb_out_bridge;  // wb_in_A, wb_in_B not needed

    assign wb_out_bridge = (wb_is_R || oh_wb_instructions[8] || oh_wb_instructions[5]) ? wb_opcode[26:22] : 5'b0; //rd will be 26:22 if R, lw, addi instruction, else doesn't matter
    assign wb_out = (oh_wb_instructions[21] || wb_error_out) ? 5'd30 : wb_out_bridge; //setx always has rd = 30; //TODO: alu exception will go here
    //NOTES
        //potential edge case-> branch/jump wants us to eliminate previous two instructions, but hazard detector wants us to stall, messing it up
            //shouldnt be a problem as long as we implement the hazard control propperly

    //TODO -> when error is in mw, we don't yet have a structure to determine what the error code would be. Instead, we're stupidly outputting the value of the alu op
endmodule