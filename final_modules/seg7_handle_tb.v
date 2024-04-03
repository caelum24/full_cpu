`timescale 1ns / 1ps

module seg7_handle_tb;
    reg clock, reset;
    reg [13:0] num;
    wire [6:0] controls;
    wire [3:0] seg_ctrl;
    wire [3:0] out_seg;

    // Instantiate the seg7_handle module
    seg7_handle uut (
        .clock(clock),
        .reset(reset),
        .num(num),
        .controls(controls),
        .seg_ctrl(seg_ctrl),
        .out_seg(out_seg)
    );

    // Clock generation
    always #10 clock = ~clock;

    // Reset generation
    initial begin
        clock = 0;
        reset = 1;
        #20 reset = 0;
        $dumpfile("seg7_handle_tb.vcd");
        $dumpvars(0, seg7_handle_tb);
    end

    // initial begin
    //     $display("clock = %b, seg_ctrl = %b", clock, seg_ctrl); #20;
    //     $display("clock = %b, seg_ctrl = %b", clock, seg_ctrl); #20;
    //     $display("clock = %b, seg_ctrl = %b", clock, seg_ctrl); #20;
    //     $display("clock = %b, seg_ctrl = %b", clock, seg_ctrl); #20;
    //     $display("clock = %b, seg_ctrl = %b", clock, seg_ctrl); #20;
    //     $display("clock = %b, seg_ctrl = %b", clock, seg_ctrl); #20;
    //     $finish;
    // end

    // Stimulus
    initial begin
        // Test with different num values
        num = 0; #20;
        $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        num = 10; #20;
        $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        num = 232; #20;
        $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        num = 3566; #20;
        $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        num = 4564; #20;
        $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        num = 54; #20;
        $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        num = 609; #20;
        $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        num = 7432; #20;
        $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        num = 8; #20;
        $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        num = 93; #20;
        $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        // num = 10; #20;
        // $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        // num = 11; #20;
        // $display("num = %d, seg_ctrl = %b, controls = %b, outnum = %d", num, seg_ctrl, controls, out_seg);
        // Add more test cases as needed
        // End simulation
        $finish;
    end

    // Monitor
    // always @(posedge clock) begin
    //     $display("num = %d, seg_ctrl = %b, controls = %b", num, seg_ctrl, controls);
    // end
endmodule