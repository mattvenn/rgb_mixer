`default_nettype none
`timescale 1ns/1ns
module debounce #(
    parameter HISTORY = 8) (
    input wire clk,
    input wire reset,
    input wire button,
    output reg debounced
);

   reg [HISTORY-1:0] shift;
   reg out;

    always @(posedge clk) begin
        if (reset) begin
            shift <= 0;
            out <= 0;
        end else begin
            shift <= {shift[HISTORY-2:0], button};
            
            if (shift == {HISTORY{1'b1}}) begin
                debounced <= 1'b1;
            end
            if (shift == {HISTORY{1'b0}}) begin
                debounced <= 0;
            end
        end
    end
endmodule
