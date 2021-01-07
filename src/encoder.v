`default_nettype none
module encoder #(
    parameter WIDTH = 4,
    parameter INCREMENT = 1
)(
    input clk,
    input reset,
    input a,
    input b,
    output reg [WIDTH-1:0] value
);

    reg oa;
    reg ob;

    always @(posedge clk or posedge reset) begin
        if(reset) begin

            oa <= 0;
            ob <= 0;
            value <= 0;

        end else begin

            oa <= a;
            ob <= b;

            if(a != oa || b != ob )
                case ({a,oa,b,ob})
                    4'b1000: value <= value + INCREMENT;
                    4'b0111: value <= value + INCREMENT;
                    4'b0010: value <= value - INCREMENT;
                    4'b1101: value <= value - INCREMENT;
                endcase 
        end
    end

endmodule
