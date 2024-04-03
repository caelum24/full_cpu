module mod_8_counter(count, clock, en, reset);

    input clock, en, reset;
    output [2:0] count;

    wire three_in;
    tff_reset ones(count[0], 1'b1, clock, en, reset);
    tff_reset twos(count[1], count[0], clock, en, reset);
    and threes_input(three_in, count[0], count[1]);
    tff_reset threes(count[2], three_in, clock, en, reset);

endmodule