`default_nettype none
`timescale 1ns/1ns
module encoder #(
    parameter WIDTH = 8,
    parameter INC_VAL = 1)(
    input clk,
    input reset,
    input a,
    input b,
    output reg [WIDTH-1:0] value
);

    reg a_old;
    reg b_old;

    always @(posedge clk) begin
        if (reset) begin
            value <= 0;
            a_old <= 0;
            b_old <= 0;
        end else begin
            a_old <= a;
            b_old <= b;
            case ({a, b, a_old, b_old})
                // A leading B
                4'b1000: value <= value + INC_VAL;
                4'b0111: value <= value + INC_VAL;
                // B leading A
                4'b0100: value <= value - INC_VAL;
                4'b1011: value <= value - INC_VAL;
                // No change
                default: value <= value;
            endcase
        end
    end

endmodule
