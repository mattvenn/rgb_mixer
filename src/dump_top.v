module dump();
    initial begin
        $dumpfile ("top.vcd");
        $dumpvars (0, top);
        #1;
    end
endmodule
