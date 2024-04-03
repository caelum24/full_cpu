module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, SW, data_writeReg,
	data_readRegA, data_readRegB, LED_reg_display
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, SW;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB, LED_reg_display;
//	output [31:0] all_regs [31:0];
	
//	wire [31:0] all_regs [31:0];

	// wire [31:0] name [0:31];
	wire [31:0] we, ctrl_write_decoded, ctrl_readA_decoded, ctrl_readB_decoded, LED_decoded;
	// add your code here
	

	//building the decoders for write and read
	decoder_5 write_decoded(ctrl_write_decoded, ctrl_writeReg);
	decoder_5 readA_decoded(ctrl_readA_decoded, ctrl_readRegA);
	decoder_5 readB_decoded(ctrl_readB_decoded, ctrl_readRegB);
	decoder_5 all_regs_decoded(LED_decoded, SW);

	//generating the 0 register
	wire [31:0] q;
	// and and_we_register(we[r], ctrl_writeEnable, ctrl_write_decoded[r]); //use decoding from ctrl_writeReg
	register register_iter(q, 32'b0, clock, 1'b0, ctrl_reset); //we[r] -> never write to register 0
	assign data_readRegA = ctrl_readA_decoded[0] ? q : 32'bz;
	assign data_readRegB = ctrl_readB_decoded[0] ? q : 32'bz;
	assign LED_reg_display = LED_decoded[0] ? q : 32'bz;

	// generating registers with read and write logic around them
	genvar r;
    generate
		for (r=1; r<=31; r=r+1) begin: loop1
			wire [31:0] q;
            and and_we_register(we[r], ctrl_writeEnable, ctrl_write_decoded[r]); //use decoding from ctrl_writeReg
			register register_iter(q, data_writeReg, clock, we[r], ctrl_reset);
			assign data_readRegA = ctrl_readA_decoded[r] ? q : 32'bz;
			assign data_readRegB = ctrl_readB_decoded[r] ? q : 32'bz;
            assign LED_reg_display = LED_decoded[r] ? q : 32'bz;
        end
    endgenerate

endmodule
