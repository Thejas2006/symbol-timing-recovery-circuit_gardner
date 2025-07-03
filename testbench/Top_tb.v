`timescale 1ns / 1ps

module Top_tb;

  reg clk = 0;
  reg reset = 1;
  reg signed [15:0] I_adc = 0; 
  reg signed [15:0] Q_adc = 0;

  wire signed [15:0]m_k;

  wire signed [15:0] I_out;
  wire signed [15:0] Q_out;

  // Instantiate the DUT (Top STR module)
  Top uut (
    .clk(clk),
    .reset(reset),
    .I_adc(I_adc),
    .Q_adc(Q_adc),
    .I_out(I_out),
    .Q_out(Q_out),
    .m_k(m_k)
  );

  // Generate 100 MHz clock
  always #5 clk = ~clk;

  // Display output every clock (not inside initial block)
  always @(posedge clk) begin
    if (!reset) begin
      $display("Time=%0t, I_out=%0d, Q_out=%0d", $time, I_out, Q_out);
    end
  end

  // Stimulus: 2x oversampled sine wave
  initial begin
    $dumpfile("Top_tb.vcd");
    $dumpvars(0, Top_tb);

    #20 reset = 0;

    // Feed 50 sine/cosine samples, 100ns per sample (10 clock cycles)
    I_adc = 16'sd1090;    Q_adc = 16'sd32504;  #100;
    I_adc = 16'sd15286;   Q_adc = 16'sd30763;  #100;
    I_adc = 16'sd19341;   Q_adc = 16'sd26655;  #100;
    I_adc = 16'sd26240;   Q_adc = 16'sd20446;  #100;
    I_adc = 16'sd30763;   Q_adc = 16'sd10286;  #100;
    I_adc = 16'sd32504;   Q_adc = 16'sd0;      #100;
    I_adc = 16'sd30763;   Q_adc = -16'sd10286; #100;
    I_adc = 16'sd26240;   Q_adc = -16'sd20446; #100;
    I_adc = 16'sd19341;   Q_adc = -16'sd26655; #100;
    I_adc = 16'sd10286;   Q_adc = -16'sd30763; #100;
    I_adc = 16'sd0;       Q_adc = -16'sd32504; #100;
    I_adc = -16'sd10286;  Q_adc = -16'sd30763; #100;
    I_adc = -16'sd19341;  Q_adc = -16'sd26655; #100;
    I_adc = -16'sd26240;  Q_adc = -16'sd20446; #100;
    I_adc = -16'sd30763;  Q_adc = -16'sd10286; #100;
    I_adc = -16'sd32504;  Q_adc = 16'sd0;      #100;
    I_adc = -16'sd30763;  Q_adc = 16'sd10286;  #100;
    I_adc = -16'sd26240;  Q_adc = 16'sd20446;  #100;
    I_adc = -16'sd19341;  Q_adc = 16'sd26655;  #100;
    I_adc = -16'sd10286;  Q_adc = 16'sd30763;  #100;
    I_adc = 16'sd0;       Q_adc = 16'sd32504;  #100;
    I_adc = 16'sd10286;   Q_adc = 16'sd30763;  #100;
    I_adc = 16'sd19341;   Q_adc = 16'sd26655;  #100;
    I_adc = 16'sd26240;   Q_adc = 16'sd20446;  #100;
    I_adc = 16'sd30763;   Q_adc = 16'sd10286;  #100;
    I_adc = 16'sd32504;   Q_adc = 16'sd0;      #100;
    I_adc = 16'sd30763;   Q_adc = -16'sd10286; #100;
    I_adc = 16'sd26240;   Q_adc = -16'sd20446; #100;
    I_adc = 16'sd19341;   Q_adc = -16'sd26655; #100;
    I_adc = 16'sd10286;   Q_adc = -16'sd30763; #100;
    I_adc = 16'sd0;       Q_adc = -16'sd32504; #100;
    I_adc = -16'sd10286;  Q_adc = -16'sd30763; #100;
    I_adc = -16'sd19341;  Q_adc = -16'sd26655; #100;
    I_adc = -16'sd26240;  Q_adc = -16'sd20446; #100;
    I_adc = -16'sd30763;  Q_adc = -16'sd10286; #100;
    I_adc = -16'sd32504;  Q_adc = 16'sd0;      #100;
    I_adc = -16'sd30763;  Q_adc = 16'sd10286;  #100;
    I_adc = -16'sd26240;  Q_adc = 16'sd20446;  #100;
    I_adc = -16'sd19341;  Q_adc = 16'sd26655;  #100;
    I_adc = -16'sd10286;  Q_adc = 16'sd30763;  #100;

      I_adc = 16'sd1090;    Q_adc = 16'sd32504;  #100;
    I_adc = 16'sd15286;   Q_adc = 16'sd30763;  #100;
    I_adc = 16'sd19341;   Q_adc = 16'sd26655;  #100;
    I_adc = 16'sd26240;   Q_adc = 16'sd20446;  #100;
    I_adc = 16'sd30763;   Q_adc = 16'sd10286;  #100;
    I_adc = 16'sd32504;   Q_adc = 16'sd0;      #100;
    I_adc = 16'sd30763;   Q_adc = -16'sd10286; #100;
    I_adc = 16'sd26240;   Q_adc = -16'sd20446; #100;
    I_adc = 16'sd19341;   Q_adc = -16'sd26655; #100;
    I_adc = 16'sd10286;   Q_adc = -16'sd30763; #100;
    I_adc = 16'sd0;       Q_adc = -16'sd32504; #100;
    I_adc = -16'sd10286;  Q_adc = -16'sd30763; #100;
    I_adc = -16'sd19341;  Q_adc = -16'sd26655; #100;
    I_adc = -16'sd26240;  Q_adc = -16'sd20446; #100;
    I_adc = -16'sd30763;  Q_adc = -16'sd10286; #100;
    I_adc = -16'sd32504;  Q_adc = 16'sd0;      #100;
    I_adc = -16'sd30763;  Q_adc = 16'sd10286;  #100;
    I_adc = -16'sd26240;  Q_adc = 16'sd20446;  #100;
    I_adc = -16'sd19341;  Q_adc = 16'sd26655;  #100;
    I_adc = -16'sd10286;  Q_adc = 16'sd30763;  #100;
    I_adc = 16'sd0;       Q_adc = 16'sd32504;  #100;
    I_adc = 16'sd10286;   Q_adc = 16'sd30763;  #100;
    I_adc = 16'sd19341;   Q_adc = 16'sd26655;  #100;
    I_adc = 16'sd26240;   Q_adc = 16'sd20446;  #100;
    I_adc = 16'sd30763;   Q_adc = 16'sd10286;  #100;
    I_adc = 16'sd32504;   Q_adc = 16'sd0;      #100;
    I_adc = 16'sd30763;   Q_adc = -16'sd10286; #100;
    I_adc = 16'sd26240;   Q_adc = -16'sd20446; #100;
    I_adc = 16'sd19341;   Q_adc = -16'sd26655; #100;
    I_adc = 16'sd10286;   Q_adc = -16'sd30763; #100;
    I_adc = 16'sd0;       Q_adc = -16'sd32504; #100;
    I_adc = -16'sd10286;  Q_adc = -16'sd30763; #100;
    I_adc = -16'sd19341;  Q_adc = -16'sd26655; #100;
    I_adc = -16'sd26240;  Q_adc = -16'sd20446; #100;
    I_adc = -16'sd30763;  Q_adc = -16'sd10286; #100;
    I_adc = -16'sd32504;  Q_adc = 16'sd0;      #100;
    I_adc = -16'sd30763;  Q_adc = 16'sd10286;  #100;
    I_adc = -16'sd26240;  Q_adc = 16'sd20446;  #100;
    I_adc = -16'sd19341;  Q_adc = 16'sd26655;  #100;
    I_adc = -16'sd10286;  Q_adc = 16'sd30763;  #100;



    $display("Simulation complete.");
    $finish;
  end

endmodule
