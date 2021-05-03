`default_nettype none
`timescale 1ns/1ns
module rgb_mixer #(
    parameter NUM_LEDS = 3)(
    input clk,
    input reset,
    input [NUM_LEDS-1:0] enc_a,
    input [NUM_LEDS-1:0] enc_b,
    output [NUM_LEDS-1:0] pwm_out
);
    wire [NUM_LEDS-1:0][7:0] enc;
    wire [NUM_LEDS-1:0] enc_a_debounced, enc_b_debounced;

    genvar i;
    generate
        for (i = 0; i < NUM_LEDS; i = i + 1) begin : encoder
            debounce debounce_a (.clk(clk), .reset(reset), .button(enc_a[i]), .debounced(enc_a_debounced[i]));
            debounce debounce_b (.clk(clk), .reset(reset), .button(enc_b[i]), .debounced(enc_b_debounced[i]));
            encoder encoder     (.clk(clk), .reset(reset), .a(enc_a_debounced[i]), .b(enc_b_debounced[i]), .value(enc[i]));
            pwm pwm             (.clk(clk), .reset(reset), .level(enc[i]), .out(pwm_out[i]));
        end
    endgenerate
endmodule
