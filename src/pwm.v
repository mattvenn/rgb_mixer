`default_nettype none
module pwm #(
    parameter WIDTH = 8,
    parameter INVERT = 0
    ) (
    input wire clk,
    input wire reset,
    output wire pwm,
    input wire [WIDTH-1:0] level
    );

    reg [WIDTH-1:0] count;
    wire pwm_out = count < level;

    always @(posedge clk) begin
        if(reset) 
            count <= 0;
        else
            count <= count + 1;
    end

    assign pwm = INVERT == 0 ? pwm_out : ! pwm_out;

endmodule
