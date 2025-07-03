module NCO#(parameter width =15)(
    input clk,
    input reset,
    input loop_out_en,
    input signed [31:0]fe,              //16.16 format
    output reg   [15:0]u_k, //1.15 format(fractional part)
    output reg signed [15:0] m_k, // counts every strobe(symbol)
    output reg signed strobe
);


//NCO should run every 10 clock cycles(per sample), but it will update once accum overflows only
//Interpolation is not driven by a clock. Instead, a number-controlled oscillator (NCO) keeps track of fractional time. The strobe is generated only when the interpolated time crosses the symbol boundary.
// The interpolator then calculates the sample using the fractional offset u_k


reg signed [31:0]acc =0; //16.16 bit format

reg signed [31:0] word = 32'sd1073741824;          // Ts/Tsym*2^31 -- 31 and 1 bit assigned for sign . 16.16 bit format 




always@(posedge clk)begin
    if(reset)begin
        m_k <=0;
        u_k <=0;
        acc <=0;
        strobe <=0;
       
  
    end
    else if(loop_out_en)begin
        acc <= acc + word + fe;

        if (acc[30]==1) begin  // overflow = 1.0 crossed, 31 bit is a sign
            strobe <= 1;

            m_k <= m_k + 1;      // track base sample index
            u_k <= acc[15:0]>>1 ;    // fractional part , should be between (0 and 32440)

            acc <= acc - 32'sd1073741824; // wrap back after overflow

            $display("Time=%0t: STROBE: m_k=%0d, u_k=%0d", $time, m_k, u_k);
        end else  begin
            strobe <= 0;

        end
    end
    else  begin
        strobe <= 0;
    end
end


endmodule
