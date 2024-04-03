module seg7_handle(clock, reset, num, controls, seg_ctrl, out_seg);
    input clock, reset;
    input [13:0] num;
    output [6:0] controls;
    output [3:0] seg_ctrl;
    output [3:0] out_seg;

    reg [3:0] thousands, hundreds, tens, ones;
    always @(*) begin
        ones = num %10;
        tens = (num/10)%10;
        hundreds = (num/100)%10;
        thousands = (num/1000)%10;
    end

    //this module will be used to handle the 7 segment displays to show generation count
    wire [1:0] seg_choose;
    mod_4_counter seg(.count(seg_choose), .clock(clock), .en(1'b1), .reset(reset));
    //TODO: REMEMBER THAT AN3-0 are low driven active

    assign seg_ctrl[0] = ~seg_choose[1] & ~seg_choose[0];
    assign seg_ctrl[1]= ~seg_choose[1] & seg_choose[0];
    // assign seg_ctrl[1] = 1'b1;
    assign seg_ctrl[2] = seg_choose[1] & ~seg_choose[0];
    assign seg_ctrl[3] = seg_choose[1] & seg_choose[0];

    wire [3:0] wire1, wire2, out_seg;
    assign wire1 = seg_choose[0] ? tens : ones;
    assign wire2 = seg_choose[0] ? thousands : hundreds;
    assign out_seg = seg_choose[1] ? wire2 : wire1;

    wire is_0, is_1, is_2, is_3, is_4, is_5, is_6, is_7, is_8, is_9;
    assign is_0 = ~out_seg[3] & ~out_seg[2] & ~out_seg[1] & ~out_seg[0];
    assign is_1 = ~out_seg[3] & ~out_seg[2] & ~out_seg[1] & out_seg[0];
    assign is_2 = ~out_seg[3] & ~out_seg[2] & out_seg[1] & ~out_seg[0];
    assign is_3 = ~out_seg[3] & ~out_seg[2] & out_seg[1] & out_seg[0];
    assign is_4 = ~out_seg[3] & out_seg[2] & ~out_seg[1] & ~out_seg[0];
    assign is_5 = ~out_seg[3] & out_seg[2] & ~out_seg[1] & out_seg[0];
    assign is_6 = ~out_seg[3] & out_seg[2] & out_seg[1] & ~out_seg[0];
    assign is_7 = ~out_seg[3] & out_seg[2] & out_seg[1] & out_seg[0];
    assign is_8 = out_seg[3] & ~out_seg[2] & ~out_seg[1] & ~out_seg[0];
    assign is_9 = out_seg[3] & ~out_seg[2] & ~out_seg[1] & out_seg[0];

    //0 is CA, 6 is CG
    assign controls[0] = ~is_1 & ~is_4;
    assign controls[1] = ~is_5 & ~is_6;
    assign controls[2] = ~is_2;
    assign controls[3] = ~is_1 & ~is_4 & ~is_7;
    assign controls[4] = is_0 | is_2 | is_6 | is_8;
    assign controls[5] = ~is_1 & ~is_2 & ~is_3 & ~is_7;
    assign controls[6] = ~is_0 & ~is_1;
    
endmodule