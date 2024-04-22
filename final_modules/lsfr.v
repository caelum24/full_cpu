module lsfr(clock, reset, randNum);

    //it works for now ig, but we may want to split it into 4 separate value generators
    input clock, reset;
    output [31:0] randNum;
    wire [3:0] random_acc;
    
    
    wire limiter;
    
    reg [31:0] lfsr_reg;  // Register to hold the LFSR state
    reg [31:0] lfsr_reg1, lfsr_reg2, lfsr_reg3;
    
    // Initialize the LFSR register value upon startup
    initial begin
        lfsr_reg = 32'b10101110101011110110100101101100;  // Set initial value to a specific value
        lfsr_reg1 = 32'b11011100011000111000001001000000;
        lfsr_reg2 = 32'b01001101111001100011000100011110;
        lfsr_reg3 = 32'b11001001101100111010110100100100;
    end

    // Clock the LFSR
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            lfsr_reg <= 32'b10001110101011110110100101101100;  // Reset the LFSR to initial state (any non-zero value)
            lfsr_reg1 <= 32'b10001111010100111101000000101001;
            lfsr_reg2 <= 32'b01001101111001100011000100011110;
            lfsr_reg3 <= 32'b00110010010001100011011110001000;
        end else begin
            // lfsr_reg[31] = lfsr_reg[30] ^ lfsr_reg[11]; // Feedback from taps 32 and 22
            // lfsr_reg[24] = lfsr_reg[0] ^ lfsr_reg[24];  // Feedback from taps 1 and 23
            // lfsr_reg[14] = lfsr_reg[8] ^ lfsr_reg[19];  // Feedback from taps 2 and 24
            // lfsr_reg[3] = lfsr_reg[5] ^ lfsr_reg[28];  // Feedback from taps 5 and 17
            // lfsr_reg[0] <= lfsr_reg[31] ^ lfsr_reg[29] ^ lfsr_reg[25] ^ lfsr_reg[24];
            
            lfsr_reg[0] <= lfsr_reg[1] ^ lfsr_reg[5] ^ lfsr_reg[6] ^ lfsr_reg[31]; //-> TO ADD
            lfsr_reg1[0] <= lfsr_reg1[1] ^ lfsr_reg1[5] ^ lfsr_reg1[6] ^ lfsr_reg1[31];
            lfsr_reg2[0] <= lfsr_reg2[1] ^ lfsr_reg2[5] ^ lfsr_reg2[6] ^ lfsr_reg2[31];
            lfsr_reg3[0] <= lfsr_reg3[1] ^ lfsr_reg3[5] ^ lfsr_reg3[6] ^ lfsr_reg3[31];
            
            lfsr_reg = lfsr_reg << 1;
            lfsr_reg1 = lfsr_reg1 << 1;
            lfsr_reg2 = lfsr_reg2 << 1;
            lfsr_reg3 = lfsr_reg3 << 1;

            // lfsr_reg = {lfsr_reg[30:0], lfsr_reg[31]};  // Shift left
        end
    end

    wire [3:0] rand;
    // Instantiate XOR gates for feedback
    // assign rand[0] = lfsr_reg[30] ^ lfsr_reg[11]; // Feedback from taps 32 and 22
    // assign rand[1] = lfsr_reg[0] ^ lfsr_reg[24];  // Feedback from taps 1 and 23
    // assign rand[2] = lfsr_reg[8] ^ lfsr_reg[19];  // Feedback from taps 2 and 24
    // assign rand[3] = lfsr_reg[5] ^ lfsr_reg[28];  // Feedback from taps 5 and 17
    // assign rand[0] = lfsr_reg[0]; // Feedback from taps 32 and 22
    // assign rand[1] = lfsr_reg[1]; // Feedback from taps 1 and 23
    // assign rand[2] = lfsr_reg[2]; // Feedback from taps 2 and 24
    // assign rand[3] = lfsr_reg[3];  // Feedback from taps 5 and 17

    assign rand[0] = lfsr_reg[0]; //-> TODO-> uncomment
    assign rand[1] = lfsr_reg1[0]; 
    assign rand[2] = lfsr_reg2[0]; 
    assign rand[3] = lfsr_reg3[0]; 

    assign limiter = rand[3] & ~rand[2] & ~rand[1] & ~rand[0];
    assign random_acc = limiter ?  4'd0 : rand; //want to keep + and - sides even, but 2's complement isn't even, so -8 becomes 0
    // 4'b1001
    assign randNum[4] = random_acc[3];
    assign randNum[5] = random_acc[3];
    assign randNum[6] = random_acc[3];
    assign randNum[7] = random_acc[3];
    assign randNum[8] = random_acc[3];
    assign randNum[9] = random_acc[3];
    assign randNum[10] = random_acc[3];
    assign randNum[11] = random_acc[3];
    assign randNum[12] = random_acc[3];
    assign randNum[13] = random_acc[3];
    assign randNum[14] = random_acc[3];
    assign randNum[15] = random_acc[3];
    assign randNum[16] = random_acc[3];
    assign randNum[17] = random_acc[3];
    assign randNum[18] = random_acc[3];
    assign randNum[19] = random_acc[3];
    assign randNum[20] = random_acc[3];
    assign randNum[21] = random_acc[3];
    assign randNum[22] = random_acc[3];
    assign randNum[23] = random_acc[3];
    assign randNum[24] = random_acc[3];
    assign randNum[25] = random_acc[3];
    assign randNum[26] = random_acc[3];
    assign randNum[27] = random_acc[3];
    assign randNum[28] = random_acc[3];
    assign randNum[29] = random_acc[3];
    assign randNum[30] = random_acc[3];
    assign randNum[31] = random_acc[3];
    
    assign randNum[3:0] = random_acc[3:0];   
    endmodule

