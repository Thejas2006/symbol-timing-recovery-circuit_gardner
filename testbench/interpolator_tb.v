`timescale 1ns / 1ps
`include "interpolator.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2024 14:49:40
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module interpolator_tb;
reg clk, reset, interpolator_en;
    reg signed [15:0] data_in;
    reg[15:0] f=16'd6554;
    wire data_out_en;
    //wire [3:0] m_axis_fir_tkeep;
    wire signed [15:0] data_out;
	
    //integer fd,t2,ft;
    
    /*
     * 100Mhz (10ns) clock 
     */
    always begin
    //ft=1;
    //fd=(10*ft)+2;
        clk = 1; #5;
        clk = 0; #5;
    end
  

    
    
    always begin
        //#50;
        reset = 1; #20;
        reset = 0; #50;
        reset = 1; #1000000;
    end
    
    always begin
        //#50;
        interpolator_en = 0; #100;
        interpolator_en = 1; #1000;
        
        interpolator_en = 1; #998920;
    end
    
    //always begin
    
        assign data_out_en = 1;// #1500;
       
         
    //end
    
    /* Instantiate FIR module to test. */
    interpolator dut(
        .clk(clk),
        .rst_n(reset),
        .data_in(data_in),   
        .interpolator_en(interpolator_en),
        .f(f),   
        .data_out_en(data_out_en),   
        .data_out(data_out));  
        

    
    /* This state machine generates a 200kHz sinusoid. */
    initial
        begin
        //#50;
        //$display("output here:%d",(data_out/32768));
            if (reset == 1'b0)
                begin
                    //cntr <= 4'd0;
                    data_in <= 16'd0;
                   // state_reg <= init;
                    //stop_cntr<=0;
                end
            else if(reset!=1'b0 )
            //$display("else");
                begin
                    //#20;
                     
                    #100;  data_in <= -16'h6ED9;
        #100;  data_in <=  16'h4000; 
        #100;  data_in <=  16'h6ED9;
        #100;  data_in <= -16'h4000;

        #100;  data_in <= -16'h6ED9;
        #100;  data_in <=  16'h4000; 
        #100;  data_in <=  16'h6ED9;
        #100;  data_in <= -16'h4000;

        #100;  data_in <= -16'h6ED9;
        #100;  data_in <=  16'h4000; 
        #100;  data_in <=  16'h6ED9;
        #100;  data_in <= -16'h4000;

        #100;  data_in <= -16'h6ED9;
        #100;  data_in <=  16'h4000; 
        #100;  data_in <=  16'h6ED9;
        #100;  data_in <= -16'h4000;

        #100;  data_in <= -16'h6ED9;
        #100;  data_in <=  16'h4000; 
        #100;  data_in <=  16'h6ED9;
        #100;  data_in <= -16'h4000;

        #100;  data_in <= -16'h6ED9;
        #100;  data_in <=  16'h4000; 
        #100;  data_in <=  16'h6ED9;
        #100;  data_in <= -16'h4000;

        #100;  data_in <= -16'h6ED9;
        #100;  data_in <=  16'h4000; 
        #100;  data_in <=  16'h6ED9;
        #100;  data_in <= -16'h4000;

        #100;  data_in <= -16'h6ED9;
        #100;  data_in <=  16'h4000; 
        #100;  data_in <=  16'h6ED9;
        #100;  data_in <= -16'h4000;

    

                    //#70; data_in <= 16'h0000;
                    //#70;  data_in <= 16'h0000; 
                    
                end
                //$display("simulation complete");
        end
        
    initial begin
$dumpfile("interpolator_tb.vcd");
$dumpvars(0, interpolator_tb);
end
initial begin
    #10000;
    $finish;
    end


endmodule