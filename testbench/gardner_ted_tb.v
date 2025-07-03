`timescale 1ns / 1ps
`include "gardner_ted.v"

module gardner_ted_tb;

    parameter width = 15;

    reg clk = 0;
    reg reset = 1;
    reg signed [width:0] I_adc, Q_adc;
    wire signed [31:0] er;
    wire ted_out_en;

    // Instantiate the DUT
    gardner_ted #(.width(width)) uut (
        .clk(clk),
        .reset(reset),
        .I_adc(I_adc),
        .Q_adc(Q_adc),
        .er(er),
        .ted_out_en(ted_out_en)
    );

    // Clock generation: 100 MHz
    always #5 clk = ~clk;

    initial begin
        $dumpfile("gardner_ted_tb.vcd");
        $dumpvars(0, gardner_ted_tb);

        reset = 1;
        I_adc = 0;
        Q_adc = 0;
        #20;
        reset = 0;

        // Stimulus: test samples (assumed 2x oversampled, i.e., 3 per symbol)
        I_adc = -16'sd792;  Q_adc =  16'sd838;   #100;
        I_adc = -16'sd1000; Q_adc =  16'sd1000;  #100;
        I_adc = -16'sd727;  Q_adc =  16'sd806;   #100;

        I_adc =  16'sd822;  Q_adc = -16'sd725;   #100;
        I_adc =  16'sd1000; Q_adc = -16'sd1000;  #100;
        I_adc =  16'sd816;  Q_adc = -16'sd810;   #100;

        I_adc =  16'sd815;  Q_adc = -16'sd927;   #100;
        I_adc =  16'sd1000; Q_adc = -16'sd1000;  #100;
        I_adc =  16'sd757;  Q_adc = -16'sd767;   #100;

        I_adc = -16'sd756;  Q_adc =  16'sd913;   #100;
        I_adc = -16'sd1000; Q_adc =  16'sd1000;  #100;
        I_adc = -16'sd837;  Q_adc =  16'sd727;   #100;

        I_adc =  16'sd802;  Q_adc = -16'sd723;   #100;
        I_adc =  16'sd1000; Q_adc = -16'sd1000;  #100;
        I_adc =  16'sd790;  Q_adc = -16'sd726;   #100;

        I_adc =  16'sd807;  Q_adc = -16'sd844;   #100;
        I_adc =  16'sd1000; Q_adc = -16'sd1000;  #100;
        I_adc =  16'sd818;  Q_adc = -16'sd899;   #100;

        I_adc =  16'sd782;  Q_adc = -16'sd738;   #100;
        I_adc =  16'sd1000; Q_adc = -16'sd1000;  #100;

        $display("Simulation complete.");
        $finish;
    end

endmodule
