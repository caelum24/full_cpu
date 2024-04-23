`timescale 1 ns/ 100 ps

module VGAController(     
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	// input BTNU, BTNL, BTNR, BTND,
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	// inout ps2_clk,
	// inout ps2_data
	//dot update stuff
	input dotWren,
	input is_Yloc,
	input [31:0] dotID, 
	input [31:0] dotLoc
	//TODO: will need to add more inputs for data from the processor
	);
	
	// Lab Memory Files Location
	 localparam FILES_PATH = "C:/Users/wjn7/Desktop/full_cpu/final_modules/";
//    localparam FILES_PATH = "./final_modules/";
	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end

	// VGA Timing Generation for a Standard VGA Screen
	localparam 
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

	wire active, screenEnd;
	wire[9:0] x;
	wire[8:0] y;
	
	VGATimingGenerator #(
		.HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
		.WIDTH(VIDEO_WIDTH))
	Display( 
		.clk25(clk25),  	   // 25MHz Pixel Clock
		.reset(reset),		   // Reset Signal
		.screenEnd(screenEnd), // High for one cycle when between two frames
		.active(active),	   // High when drawing pixels
		.hSync(hSync),  	   // Set Generated H Signal
		.vSync(vSync),		   // Set Generated V Signal
		.x(x), 				   // X Coordinate (from left)
		.y(y)); 			   // Y Coordinate (from top)	   

    
	// Image Data to Map Pixel Location to Color Address
	localparam 
		PIXEL_COUNT = VIDEO_WIDTH*VIDEO_HEIGHT, 	             // Number of pixels on the screen
		PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,           // Use built in log2 command
		BITS_PER_COLOR = 12, 	  								 // Nexys A7 uses 12 bits/color
		PALETTE_COLOR_COUNT = 256, 								 // Number of Colors available
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddr; 	 // Color address for the color palette
	assign imgAddress = x + 640*y;				 // Address calculated coordinate

	//TODO change image.mem to name of training ground background file name
	VGA_RAM #(		
		.DEPTH(PIXEL_COUNT), 				     // Set RAM depth to contain every pixel
		.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
		.MEMFILE({FILES_PATH, "image.mem"})) // Memory initialization 
	ImageData(
		.clk(clk), 						 // Falling edge of the 100 MHz clk
		.addr(imgAddress),					 // Image data address
		.dataOut(colorAddr),				 // Color palette address
		.wEn(1'b0)); 						 // We're always reading

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] colorData; // 12-bit color data at current pixel

	//TODO: initialize colors.mem from colors.csv
	VGA_RAM #(
		.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color		
		.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "colors.mem"}))  // Memory initialization
	ColorPalette(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(colorAddr),					       // Address from the ImageData RAM
		.dataOut(colorData),				       // Color at current pixel
		.wEn(1'b0)); 						       // We're always reading

    //CODE STARTS here

	//TODO: make it so that every time an input goes high, we update the vga board with where the dots have gone
	//have a 25 MHz pixel clock
    reg[17:0] mover = 0;      // Pixel counter to divide the clock
    wire slowclk;
    assign slowclk = mover[17]; // Set the clock high whenever the 18th bit is high
	always @(posedge clk) begin
		mover <= mover + 1; 
	end
   
    
	//moving the black box around the screen
    // always @(posedge slowclk) begin
    //     if (BTNU && ~BTND && refy > 0) begin
    //         refy <= refy-1;
    //     end
    //     if (BTNR && ~BTNL && refx < 590) begin
    //         refx <= refx+1;
    //     end
    //     if (BTND && ~BTNU && refy < 430) begin
    //         refy <= refy+1;
    //     end
    //     if (BTNL && ~BTNR && refx>0) begin
    //         refx <= refx-1;
    //     end
    // end
    //TODO: need to convert this motion method into registers with wires and gates 
	//registers to store reference of top left corner of goal
    reg [9:0] refx;
    reg [8:0] refy;
    
    parameter NUM_DOTS = 70;
    reg [9:0] dots_x [NUM_DOTS-1 : 0];
    reg [8:0] dots_y [NUM_DOTS-1 : 0];
    reg [NUM_DOTS-1:0] is_dots;
    
    //TODO: on posedge writeEN, dots_x[reg_input] <= [reg_value] is_x_change -> inputs come from processor 
    //TODO: use screenEnd to signal to the processor that we can start changing dot values again
	//TODO: might need to pause VGA until the calculations are done
	
//	dotWren,
//	is_Yloc,
//	[31:0] dotID, 
//	[31:0] dotLoc
	// TODO: add functionality for the champion
    genvar i;
    generate
        for (i = 0; i< NUM_DOTS; i = i+1) begin : dots_move
            initial begin
                dots_x[i] <= 320;
                dots_y[i] <= 240;
				// dots_x[i] <= 4*(i+1);
                // dots_y[i] <= 0;
                is_dots[i] <= 1'b0;
            end
//            always @(posedge screenEnd) begin //TODO this will go away once processor is implemented
//		       dots_x[i] = dots_x[i]+10-i;
//		       dots_y[i] = dots_y[i]+1;
//	       end
	       always @(posedge clk25) begin
                if (x==dots_x[i] && y==dots_y[i]) begin
                    is_dots[i] <= 1'b1;
                end
                else begin
                    is_dots[i] <= 1'b0;
                end
          end
          //TODO: Check over -> moving the dots based on inputs from processor
//          always @(posedge dotWren) begin
//            if (dotID == i) begin
//          always @(posedge dotWren) begin
//            if (dotID == i) begin
//                if (is_Yloc == 1) begin
//                    dots_y[i] <= dotLoc[8:0];
//                end
//                else begin
//                    dots_x[i] <= dotLoc[9:0];
//                end
//            end
//          end 
          always @(posedge clk25) begin
            if (dotID == i && dotWren) begin
                if (is_Yloc == 1) begin
                    dots_y[i] <= dotLoc[8:0];
                end
                else begin
                    dots_x[i] <= dotLoc[9:0];
                end
            end
          end       
      end
    endgenerate
    // reg [9:0] dotx;
    // reg [8:0] doty;
    wire is_dot;
    assign is_dot = |is_dots;
    
    initial 
    begin //SET THESE TO CHANGE WHERE THE GOAL IS
        refx <= 10'd310;
        refy <= 9'd50;
        // dotx <= 10'd20;
        // doty <= 9'd20;
    end

    reg isInBox;
//    reg is_dot;
    
    always @(posedge clk25) begin
        if (x >= refx && x < refx+20 && y >= refy && y < refy+20) begin
            isInBox <= 1'b1;
        end 
        else begin
            isInBox <= 1'b0;
        end
//        if (x==dotx && y==doty) begin
//            is_dot <= 1'b1;
//        end
//        else begin
//            is_dot <= 1'b0;
//        end
    end
    
    wire show;
    assign show = ~isInBox;
    
	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut, background; 			  // Output color 
	

	//checking if it's the background or the goal
	assign background = show ? colorData : 12'b000011010000; //TODO: SET THIS TO GOAL COLOR

	// moving the dot around the screen
//    always @(posedge screenEnd) begin
//		dotx = dotx+1;
//		doty = doty+1;
//	end 

//	wire x_equal, y_equal;
//	check_equal x_check(.A({21'd0, x}), .B({21'd0, dotx}), .is_equal(x_equal));
//	check_equal y_check(.A({22'd0,y}), .B({22'd0,doty}), .is_equal(y_equal));
	//problem-> IS_DOT DOESN'T SEEM TO BE WORKING PROPERLY
//	assign is_dot = x_equal & y_equal;
//	assign is_dot = x==dotx;
//    assign is_dot = 1'b0;
	// assign inbox = sprite_on ?  12'b111111111111 : 12'd0; // When not active, output black
    assign colorOut = is_dot ? 12'b000000000000 : background; //if a dot, output black
	// Quickly assign the output colors to their channels using concatenation
//	assign {VGA_R, VGA_G, VGA_B} = colorOut;
    assign {VGA_R, VGA_G, VGA_B} = active ? colorOut : 12'd0;
	
endmodule






/*	
// 	//LAB7 code for keyboard stuff
		
// 	reg [7:0] cur_letter;
// 	wire [7:0] rx_data;
// 	wire read_data;
//     Ps2Interface joe(.rx_data(rx_data), .read_data(read_data), .clk(clk), .ps2_clk(ps2_clk), .ps2_data(ps2_data));
    
//     always @(read_data) begin
//         cur_letter <= rx_data;
//     end
    
//     wire [7:0] ascii_out;
// 	VGA_RAM #(
// 		.DEPTH(256), 		       // Set depth to contain every color		
// 		.DATA_WIDTH(8), 		       // Set data width according to the bits per color
// 		.ADDRESS_WIDTH(8),     // Set address width according to the color count
// 		.MEMFILE({FILES_PATH, "ascii.mem"}))  // Memory initialization
// 	ascii_values(
// 		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
// 		.addr(cur_letter),					       // Address from the ImageData RAM
// 		.dataOut(ascii_out),				       // Color at current pixel
// 		.wEn(1'b0));
		
		
//     wire [18:0] sprite_row;
// 	assign sprite_row = (ascii_out - 33)*2500;
// //    assign sprite_row = 18'd0;
// 	reg [18:0] sprite_addy;
// 	always @(posedge clk25) begin
// 	   if (x >= refx && x < refx+50 && y >= refy && y < refy+50) begin
// 	       sprite_addy <= sprite_row + 50*(y-refy) + (x-refx);
// 	   end
// 	end
	
// 	wire sprite_on;
// 	VGA_RAM #(
// 		.DEPTH(4700*50), 		       // Set depth to contain every color		
// 		.DATA_WIDTH(1), 		       // Set data width according to the bits per color
// 		.ADDRESS_WIDTH(19),     // Set address width according to the color count
// 		.MEMFILE({FILES_PATH, "sprites.mem"}))  // Memory initialization
// 	sprite_value(
// 		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
// 		.addr(sprite_addy),					       // Address from the ImageData RAM
// 		.dataOut(sprite_on),				       // Color at current pixel
		.wEn(1'b0));
    
*/