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
    debounce #(.hist_len(8)) debounce_a(.clk(clk), .reset(reset), .button(a), .debounced(a_db));
    debounce #(.hist_len(8)) debounce_b(.clk(clk), .reset(reset), .button(b), .debounced(b_db));

    wire [7:0] encoder;
    encoder #(.width(8)) encoder_inst(.clk(clk), .reset(reset), .a(a_db), .b(b_db), .value(encoder));

endmodule
