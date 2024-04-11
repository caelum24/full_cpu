`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (clock_100, reset, SW, LED, hSync, vSync, VGA_R, VGA_G, VGA_B, AN, SEGCTRL);
	input clock_100, reset;
	input[4:0] SW;

	output[15:0] LED;
	output hSync;		// H Sync Signal
	output vSync; 		// Veritcal Sync Signal
	output[3:0] VGA_R;  // Red Signal Bits
	output[3:0] VGA_G;  // Green Signal Bits
	output[3:0] VGA_B;  // Blue Signal Bits
	output[7:0] AN;
	output[6:0] SEGCTRL;

	// Slow clock from 100 to 50MHz
	reg clock = 0;
	always @(posedge clock_100)
	begin
		clock = ~clock;
	end

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;
	wire[31:0] ctrl_write_decoded;
	wire [15:0] LED;
	wire [31:0] led_bridge;
    assign LED = led_bridge[15:0];
	
	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "fpga_test";

	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 

		// ROM
		.address_imem(instAddr), .q_imem(instData),

		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),

		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut),
		
		//7seg
		.inc_seg7(increment_seg)
		); 

	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));

	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), .SW(SW),
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB), .LED_reg_display(led_bridge));

	// Processor Memory (RAM)
	wire [31:0] memoryData, randomNum;
	
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memoryData)); //changed for muxing with MMIO

    lsfr RNG(clock, reset, randomNum); //random number module
    
    assign memDataOut = (memAddr == 9990) ? randomNum : memoryData; //if memory reading from addy 10000, grab random number
    
	// VGA CONTROL
		//the processor will need to interface with this to update dot locations
		//for now, the dot locations are hard coded to start and move themselves
	
	//wires for dictating when/how to update dot locations from the processor
	wire [31:0] dotLoc;
	wire [31:0] dotID;
	wire dotWren, is_Yloc;	
	
	assign dotWren = (memAddr >= 10240 && mwe);
	assign is_Yloc = (memAddr >= 12288);
	assign dotID = is_Yloc ? (memAddr - 12288) : (memAddr - 10240);
	assign dotLoc = memDataIn;
	
	VGAController VGA(     
		.clk(clock_100), 			// 100 MHz System Clock
		.reset(reset), 		// Reset Signal

		.hSync(hSync), 		// H Sync Signal
		.vSync(vSync), 		// Veritcal Sync Signal
		.VGA_R(VGA_R),  // Red Signal Bits
		.VGA_G(VGA_G),  // Green Signal Bits
		.VGA_B(VGA_B),  // Blue Signal Bits
		
		//dot updating
		.dotWren(dotWren),
	    .is_Yloc(is_Yloc),
	    .dotID(dotID), 
	    .dotLoc(dotLoc)
		
	);


	// 7 seg control
		//need some way for the processor to store the current generation value and then output it to this module
	reg [31:0] seg_value;
	initial
	begin
		seg_value <= 32'd0;
	end
	always @(posedge increment_seg) begin //increment_seg will come from the processor
	 	seg_value <= seg_value + 1;
	 end
	seg7_handle seg_ctrl(.clock_100(clock_100), .reset(reset), .num(seg_value[13:0]), .controls(SEGCTRL), .seg_ctrl(AN));
endmodule
