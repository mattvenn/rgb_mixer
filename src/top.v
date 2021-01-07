`default_nettype none
`timescale 1ns/1ns
module top (
    input clk,
    input reset,
    input a,
    input b,
    output pwm_out
);

    wire a_db, b_db;
    debounce #(.hist_len(8)) debounce_a(.clk(clk), .reset(reset), .button(a), .debounced(a_db));
    debounce #(.hist_len(8)) debounce_b(.clk(clk), .reset(reset), .button(b), .debounced(b_db));

    wire [7:0] encoder;
    encoder #(.width(8)) encoder_inst(.clk(clk), .reset(reset), .a(a_db), .b(b_db), .value(encoder));

    pwm #(.width(8)) pwm_inst(.clk(clk), .reset(reset), .out(pwm_out), .level(encoder));

endmodule
