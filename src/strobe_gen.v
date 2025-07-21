`default_nettype none
`timescale 1ns/1ns
// create a 1 clock wide pulse every (2^WIDTH)/2 clocks
module strobe_gen #(
    parameter WIDTH = 8
    ) (
    input wire clk,
    input wire reset,
    output reg out
    );

    reg [WIDTH-1:0] count;

    always @(posedge clk) begin
        if(reset) begin
            count <= 1'b0;
            out <= 1'b0;
        end else if(count[WIDTH-1] == 1'b1) begin
            count <= 1'b0;
            out <= 1'b1;
        end else begin
            count <= count + 1'b1;
            out <= 1'b0;
        end
    end

endmodule

