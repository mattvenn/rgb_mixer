`default_nettype none
`timescale 1ns/1ns
module pwm #(
    parameter WIDTH = 8,
    parameter INVERT = 0
    ) (
    input wire clk,
    input wire reset,
    output wire out,
    input wire [WIDTH-1:0] level
    );

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile ("pwm.vcd");
            $dumpvars (0, pwm);
            #1;
        end
    `endif

    reg [WIDTH-1:0] count;
    wire pwm_on = count < level;

    always @(posedge clk) begin
        if(reset) 
            count <= 0;
        else
            count <= count + 1;
    end

    assign out = reset ? 0:
        INVERT == 0 ? pwm_on : ! pwm_on;

endmodule
