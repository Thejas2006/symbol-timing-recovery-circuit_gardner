`timescale 1ns / 1ps
`include "loop_filter.v"

module loop_filter_tb;

    // Inputs

    reg clk;
    reg reset;
    reg signed [17:0] er;
    reg ted_out_en =1;

    wire loop_out_en;


    wire signed [31:0] fe;

   
    loop_filter  uut (
        .clk(clk),
        .reset(reset),
        .er(er),
        .en_lpf(en_lpf),
        .ted_out_en(ted_out_en),
        .loop_out_en(loop_out_en)
    );

    
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $dumpfile("loop_filter_tb.vcd");
        $dumpvars(0, loop_filter_tb);


        $display("Time\t\ter\t\tfe");
        $monitor("%0dns\t%d\t\t%d", $time, er, fe);

        reset = 1;
        er = 0;
        #20;
        reset = 0;

        er = 17'sd234;  // ~0.03125 in Q1.15
        #100;

        
        er = -17'sd456;  // ~-0.0156
        #100;

        // Zero error
        er = 0;
        #100;

        $finish;
    end
endmodule