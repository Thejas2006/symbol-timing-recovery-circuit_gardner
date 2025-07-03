`timescale 1ns / 1ps
`include "NCO.v"

module NCO_tb;

    reg clk = 0;
    reg reset = 1;
    reg [31:0] fe = 32'sd0;  // zero correction
    wire signed [15:0] u_k;
    wire strobe;

    // Instantiate NCO
    NCO #(.width(15)) dut (
        .clk(clk),
        .reset(reset),
        .fe(fe),
        .u_k(u_k),
        .strobe(strobe)
    );

    // 100MHz clock
    always #5 clk = ~clk;

    initial begin

        $dumpfile("NCO_tb.vcd");
        $dumpvars(0, NCO_tb);


        $display("Time\tclk\treset\tfe\taccumulator_overflow\tstrobe\tu_k");
        $monitor("%g\t%b\t%b\t%d\t%b\t%d", 
            $time, clk, reset, fe, strobe, u_k);

        // Hold reset for 2 clock cycles
        #20;
        reset = 0;

        fe = 32'sd107374182;

    
        // Simulate for 500 clocks (5 samples per symbol = 100 clocks)
        #1000;

        $finish;
    end

endmodule
