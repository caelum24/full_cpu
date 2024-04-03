module mod_4_counter(count, clock, en, reset);

    input clock, T, en, reset;
    output [1:0] count;
    tff_reset ones(count[0], 1'b1, clock, en, reset);
    tff_reset twos(count[1], count[0], clock, en, reset);

endmodule