`default_nettype none
`timescale 1ns/1ns
// create a 1 clock wide pulse every (2^WIDTH)/2 clocks
module strobe_gen #(
    parameter WIDTH = 8
    ) (
    input wire clk,
    output wire out
    );

    reg [WIDTH-1:0] count;
    assign out = count[WIDTH-1];

    always @(posedge clk) begin
        if(count[WIDTH-1] == 1'b1) begin
            count <= 1'b0;
        end else begin
            count <= count + 1'b1;
        end
    end

endmodule

