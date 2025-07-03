
// Main STR components:
// - Interpolator (fir)
// - Gardner TED (Timing Error Detector)
// - Loop Filter (PI Controller)
// - NCO (Phase Accumulator + Fractional Delay)

/*system_info:
- System Clock:       100 MHz
- ADC Sample Rate:    10.2 MS/s
- Symbol Rate:        5.1 MS/s
- TED Update Rate:    Once per symbol (20 clocks)
*/



// BIGGG NOTEEE: this code only for testing with a sample data from text file because new sample data comes every 100ns. so counter is used to simulate a real life signal behaviour.


module Top #(parameter width =15)(
    input clk,
    input reset,
    input signed [15:0] I_adc,
    input signed [15:0] Q_adc,
    output reg signed [width:0] I_out,
    output reg signed [width:0] Q_out,
    output reg signed [15:0] m_k

);


// upsampled , 2 samples per symbol -------> interpolator -------------------------->output
//                                                |                           |
//                                                |                           |
//                                                |                           |
//                                                |                           |
//                                              NCO <-------loop_filter< ----gardner_ted
                                                                                               

wire signed [15:0] u_k;
wire signed [31:0] er;
wire signed [31:0] fe;
reg signed [width:0] I_interp, Q_interp;
wire data_out_en_I, data_out_en_Q;
wire ted_out_en;
wire loop_out_en;
wire strobe;
reg interpolator_en;



//        
interpolator interp_I (
    .data_in(I_adc),
    .f(u_k),
    .clk(clk),
    .rst_n(!reset),
    .interpolator_en(strobe),
    .m_k(m_k),
    .data_out_en(data_out_en_I),
    .data_out(I_interp)
);

    
interpolator interp_Q (
    .data_in(Q_adc),
    .f(u_k),
    .clk(clk),
    .rst_n(!reset),
    .interpolator_en(strobe),
    .m_k(m_k),
    .data_out_en(data_out_en_Q),
    .data_out(Q_interp)
);

        
gardner_ted g_uut (
    .clk(clk),
    .reset(reset),
    .I_interp(I_interp),
    .Q_interp(Q_interp),
    .gardner_en_I(data_out_en_I),
    .gardner_en_Q(data_out_en_Q),
    .er(er),
    .ted_out_en(ted_out_en)
);


loop_filter f_uut (
    .clk(clk),
    .reset(reset),
    .ted_out_en(ted_out_en),
    .er(er),
    .fe(fe),
    .loop_out_en(loop_out_en)

);



NCO n_uut(
    .clk(clk),
    .reset(reset),
    .fe(fe),
    .loop_out_en(loop_out_en),
    .u_k(u_k),
    .m_k(m_k),
    .strobe(strobe)
);



always@(posedge clk)begin
    if(reset) begin
        I_out <= 0;
        Q_out <= 0;
    end

    else if (strobe) begin
        I_out <= 2*I_interp;
        Q_out <= 2*Q_interp; // give the output only when the strobe is one
    end
end



endmodule