`default_nettype none
`timescale 1ns/1ns
module debounce #(
    parameter hist_len = 8
)(
    input wire clk,
    input wire reset,
    input wire button,
    output reg debounced
);
    localparam on_value = 2 ** hist_len - 1;
    reg [hist_len-1:0] button_hist;

    always@(posedge clk) begin
        if(reset) begin

            button_hist <= 0;
            debounced <= 0;

        end else begin

            button_hist = {button_hist[hist_len-2:0], button };

            if(button_hist == on_value) 
               debounced <= 1;
            else if(button_hist == 0)
               debounced <= 0;
       end
    end

endmodule
