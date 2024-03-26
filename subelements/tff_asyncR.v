module tff_reset(Q, T, clock, en, reset);

    input clock, T, en, reset;
    output Q;

    wire d_in, t_off, t_on;

    and ton(t_on, T, ~Q);
    and toff(t_off, ~T, Q);
    or din(d_in, t_off, t_on);
    dff_sync_clear toggle_reg(Q, d_in, clock, en, reset); //enable on if not ctrl_Div

endmodule