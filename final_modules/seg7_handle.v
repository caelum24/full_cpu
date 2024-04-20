module seg7_handle(clock_100, reset, num, controls, seg_ctrl);
    input clock_100, reset;
    input [13:0] num;
    output [6:0] controls; //segment controllers
    output [7:0] seg_ctrl; //which digit to output
    // output [3:0] out_seg; //value of the 4 bit digit

    reg [32:0] count_250Hz;
    reg clock_250Hz;
    initial
    begin
    clock_250Hz <= 0;
    count_250Hz <= 0;
    end
    
    always @(posedge clock_100) begin
        if (count_250Hz == 100000) begin
            count_250Hz = 0;
            clock_250Hz = ~clock_250Hz;
        end
        else begin
            count_250Hz <= count_250Hz+1;
        end
    end
    
    wire [3:0] w_1, w_10, w_100, w_1000;
    wire [1:0] buff; //TODO: buffer idk what it does
    bin2bcd bin_conv(.bin(num), .bcd({buff, w_1000, w_100, w_10, w_1}));
    reg [3:0] thousands, hundreds, tens, ones;
    always @(posedge clock_250Hz) begin
//        ones = num %10;
//        tens = (num/10)%10;
//        hundreds = (num/100)%10;
//        thousands = (num/1000)%10;
        ones = w_1;
        tens = w_10;
        hundreds = w_100;
        thousands = w_1000;
    end
    
    
    reg [1:0] digishow;
    initial
    begin
    digishow = 2;
    end
    
    always @(posedge clock_250Hz) begin
        digishow <= digishow + 1;
    end
    
    assign seg_ctrl[0] = ~(digishow == 0);
    assign seg_ctrl[1]= ~(digishow == 1);
    // assign seg_ctrl[1] = 1'b1;
    assign seg_ctrl[2] = ~(digishow == 2);
    assign seg_ctrl[3] = ~(digishow == 3);
    assign seg_ctrl[7:4] = 4'b1111;
    
    wire [3:0] wire1, wire2, out_seg;
    assign wire1 = digishow[0] ? tens : ones;
    assign wire2 = digishow[0] ? thousands : hundreds;
    assign out_seg = digishow[1] ? wire2 : wire1;
    
    wire is_0, is_1, is_2, is_3, is_4, is_5, is_6, is_7, is_8, is_9;
    assign is_0 = out_seg == 0;
    assign is_1 = out_seg == 1;
    assign is_2 = out_seg == 2;
    assign is_3 = out_seg == 3;
    assign is_4 = out_seg == 4;
    assign is_5 = out_seg == 5;
    assign is_6 = out_seg == 6;
    assign is_7 = out_seg == 7;
    assign is_8 = out_seg == 8;
    assign is_9 = out_seg == 9;
    
    //0 is CA, 6 is CG
    assign controls[0] = ~(~is_1 & ~is_4);
    assign controls[1] = ~(~is_5 & ~is_6);
    assign controls[2] = ~(~is_2);
    assign controls[3] = ~(~is_1 & ~is_4 & ~is_7);
    assign controls[4] = ~(is_0 | is_2 | is_6 | is_8);
    assign controls[5] = ~(~is_1 & ~is_2 & ~is_3 & ~is_7);
    assign controls[6] = ~(~is_0 & ~is_1 & ~is_7);
    /*
    //old code
    //this module will be used to handle the 7 segment displays to show generation count
    wire [1:0] seg_choose;
    mod_4_counter seg(.count(seg_choose), .clock(clock_250Hz), .en(1'b1), .reset(reset));
    //TODO: REMEMBER THAT AN3-0 are low driven active

    assign seg_ctrl[0] = ~(~seg_choose[1] & ~seg_choose[0]);
    assign seg_ctrl[1]= ~(~seg_choose[1] & seg_choose[0]);
    // assign seg_ctrl[1] = 1'b1;
    assign seg_ctrl[2] = ~(seg_choose[1] & ~seg_choose[0]);
    assign seg_ctrl[3] = ~(seg_choose[1] & seg_choose[0]);
    assign seg_ctrl[7:4] = 4'b1111;

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
    assign controls[6] = ~is_0 & ~is_1 & ~is_7;
    */
endmodule

module bin2bcd
 #( parameter                W = 14)  // input width
  ( input      [W-1      :0] bin   ,  // binary
    output reg [W+(W-4)/3:0] bcd   ); // bcd {...,thousands,hundreds,tens,ones}

  integer i,j;

  always @(bin) begin
    for(i = 0; i <= W+(W-4)/3; i = i+1) bcd[i] = 0;     // initialize with zeros
    bcd[W-1:0] = bin;                                   // initialize with input vector
    for(i = 0; i <= W-4; i = i+1)                       // iterate on structure depth
      for(j = 0; j <= i/3; j = j+1)                     // iterate on structure width
        if (bcd[W-i+4*j -: 4] > 4)                      // if > 4
          bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; // add 3
  end

endmodule