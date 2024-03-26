module latch(out, reset, set);

    input reset, set;
    output out;
    wire s1;
    nor setter(s1, out, set);
    nor resetter(out, reset, s1);

endmodule



