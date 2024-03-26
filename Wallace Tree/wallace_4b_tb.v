`timescale 1ns / 1ps

module wallace_4b_tb;

reg signed [3:0] data_operandA, data_operandB; // Use signed for two's complement
wire signed [7:0] data_result; // Use signed for two's complement

// Instance of wallaceTree module
wallace_tree_4b uut (
    .data_operandA(data_operandA),
    .data_operandB(data_operandB),
    .result(data_result)
);

initial begin
    // Initialize inputs in two's complement
    data_operandA = 4'sb0000;
    data_operandB = 4'sb0000;

    $dumpfile("wallace_4b_tb.vcd");
    $dumpvars(0, wallace_4b_tb);

    // Iterate through all possible input combinations
    repeat (8) begin
        data_operandB = 4'sd0; // Reset data_operandB for each new data_operandA value
        repeat (8) begin
            #10; // Wait 10 time units; adjust this delay as needed
            data_operandB = data_operandB + 4'sd1;
        end
        data_operandA = data_operandA + 4'sd1;
    end

    data_operandA = 4'sd0;
    data_operandB = 4'sd0;
    repeat (8) begin
        data_operandB = 4'sd0; // Reset data_operandB for each new data_operandA value
        repeat (8) begin
            #10; // Wait 10 time units; adjust this delay as needed
            data_operandB = data_operandB - 4'sd1;
        end
        data_operandA = data_operandA - 4'sd1;
    end

    data_operandA = 4'sd0;
    data_operandB = 4'sd0;
    repeat (8) begin
        data_operandB = 4'sd0; // Reset data_operandB for each new data_operandA value
        repeat (8) begin
            #10; // Wait 10 time units; adjust this delay as needed
            data_operandB = data_operandB + 4'sd1;
        end
        data_operandA = data_operandA - 4'sd1;
    end

    data_operandA = 4'sd0;
    data_operandB = 4'sd0;
    repeat (8) begin
        data_operandB = 4'sd0; // Reset data_operandB for each new data_operandA value
        repeat (8) begin
            #10; // Wait 10 time units; adjust this delay as needed
            data_operandB = data_operandB - 4'sd1;
        end
        data_operandA = data_operandA + 4'sd1;
    end
    
    #10; // Wait for the last operation to complete
    $finish; // End the simulation
end

// Optional: Display test results
initial begin
    $monitor("At time %t, data_operandA = %d, data_operandB = %d, data_result = %d",
             $time, data_operandA, data_operandB, data_result);
end

endmodule
