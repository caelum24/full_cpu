`timescale 1ns / 1ps

module tb_lsfr;

    reg clk, reset;
    wire [3:0] random_acc;

    // Instantiate the LSFR module
    lsfr lsfr_inst (
        .clock(clk),
        .reset(reset),
        .random_acc(random_acc)
    );

    // Clock generator
    always #5 clk = ~clk;

    // Reset generator
    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
    end

    // Output random number every cycle
    always @(posedge clk) begin
        $display("Random number: %d, %b", $signed(random_acc), random_acc);
    end

    // Stop simulation after some time
    initial begin
        #1000 $finish;
    end

endmodule