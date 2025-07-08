`timescale 1ns / 1ps

module Top_tb;

  reg clk = 0;
  reg reset = 1;
  reg signed [15:0] I_adc = 0; 
  reg signed [15:0] Q_adc = 0;

    // Define a symbol pattern: 2 samples per symbol

  reg signed [15:0] I_sym_1 = 16'sd17000, I_sym_2 = 16'sd21000;
  reg signed [15:0] Q_sym_1 = 16'sd20000, Q_sym_2 = 16'sd23000; // every symbol given constant offset.

  wire signed [15:0] m_k;
  wire signed [15:0] I_out;
  wire signed [15:0] Q_out;

  integer i;

  Top uut (
    .clk(clk),
    .reset(reset),
    .I_adc(I_adc),
    .Q_adc(Q_adc),
    .I_out(I_out),
    .Q_out(Q_out),
    .m_k(m_k)
  );

  always #5 clk = ~clk;

  always @(posedge clk) begin
    if (!reset) begin
      $display("Time=%0t, I_out=%0d, Q_out=%0d, m_k=%0d", $time, I_out, Q_out, m_k);
    end
  end

  initial begin

    $dumpfile("Top_tb.vcd");
    $dumpvars(0, Top_tb);

    #20 reset = 0;


    // Generate 60 symbols, alternating sign each symbol
    for (i = 0; i < 60; i = i + 1) begin
      if (i % 2 == 0) begin
        // Even symbol: positive
        I_adc = I_sym_1; Q_adc = Q_sym_1; #100;
        I_adc = I_sym_2; Q_adc = Q_sym_2; #100;
      end else begin
        // Odd symbol: negative (same shape)
        I_adc = -I_sym_1; Q_adc = -Q_sym_1; #100;
        I_adc = -I_sym_2; Q_adc = -Q_sym_2; #100;
      end
    end

    #200;

    $display("Simulation complete.");
    $finish;
  end

endmodule
