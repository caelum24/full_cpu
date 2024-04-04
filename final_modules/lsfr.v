module lsfr(clock, reset, random_acc);

    //it works for now ig, but we may want to split it into 4 separate value generators
    input clock, reset;
    output [3:0] random_acc;
    
    wire limiter;
    
    reg [31:0] lfsr_reg;  // Register to hold the LFSR state
    
    // Initialize the LFSR register value upon startup
    initial begin
        lfsr_reg = 32'b10101010101011110110100101101100;  // Set initial value to a specific value
    end

    // Clock the LFSR
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            lfsr_reg <= 32'b10101010101011110110100101101100;  // Reset the LFSR to initial state (any non-zero value)
        end else begin
            lfsr_reg[31] = lfsr_reg[30] ^ lfsr_reg[11]; // Feedback from taps 32 and 22
            lfsr_reg[24] = lfsr_reg[0] ^ lfsr_reg[24];  // Feedback from taps 1 and 23
            lfsr_reg[14] = lfsr_reg[8] ^ lfsr_reg[19];  // Feedback from taps 2 and 24
            lfsr_reg[3] = lfsr_reg[5] ^ lfsr_reg[28];  // Feedback from taps 5 and 17
            lfsr_reg = {lfsr_reg[30:0], lfsr_reg[31]};  // Shift left
        end
    end

    wire [3:0] rand;
    // Instantiate XOR gates for feedback
    assign rand[0] = lfsr_reg[30] ^ lfsr_reg[11]; // Feedback from taps 32 and 22
    assign rand[1] = lfsr_reg[0] ^ lfsr_reg[24];  // Feedback from taps 1 and 23
    assign rand[2] = lfsr_reg[8] ^ lfsr_reg[19];  // Feedback from taps 2 and 24
    assign rand[3] = lfsr_reg[5] ^ lfsr_reg[28];  // Feedback from taps 5 and 17

    assign limiter = &rand[3] & ~rand[2:0];
    assign random_acc = limiter ?  4'd0 : rand; //want to keep + and - sides even, but 2's complement isn't even, so -8 becomes 0
    // 4'b1001

    endmodule

