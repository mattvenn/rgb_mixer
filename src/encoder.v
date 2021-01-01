`default_nettype none
module encoder #(
    parameter width = 4,
    parameter increment = 1
)(
    input clk,
    input reset,
    input a,
    input b,
    output reg [width-1:0] value
);

    reg oa;
    reg ob;

    always @(posedge clk) begin
        if(reset) begin

            oa <= 0;
            ob <= 0;
            value <= 0;

        end else begin

            oa <= a;
            ob <= b;

            if(a != oa || b != ob )
                case ({a,oa,b,ob})
                    4'b1000: value <= value + increment;
                    4'b0111: value <= value + increment;
                    4'b0010: value <= value - increment;
                    4'b1101: value <= value - increment;
                endcase 
        end
    end

endmodule
