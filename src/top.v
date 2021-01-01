`default_nettype none
module top (
    input clk,
    input reset,
    input a,
    input b
);

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile ("top.vcd");
            $dumpvars (0, top);
            #1;
        end
    `endif

    wire a_db, b_db;
    debounce #(.hist_len(4)) debounce_a(.clk(clk), .reset(reset), .button(a), .debounced(a_db));
    debounce #(.hist_len(4)) debounce_b(.clk(clk), .reset(reset), .button(b), .debounced(b_db));

    wire [15:0] pot;
    encoder #(.width(8)) encoder_inst(.clk(clk), .reset(reset), .a(a_db), .b(b_db), .value(pot));

endmodule
