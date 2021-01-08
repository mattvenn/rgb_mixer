module dump();
    initial begin
        $dumpfile ("encoder.vcd");
        $dumpvars (0, test_encoder);
        #1;
    end
endmodule
