module lfsr_tb ();

  logic clk;
  logic reset;
  logic [3:0] lfsr_o;

  lfsr LFSR (.*);

  always begin
    clk = 1'b1;
    #5;
    clk = 1'b0;
    #5;
  end

  initial begin
    // Dumpfile setup for waveform viewing
    $dumpfile("lfsr_tb.vcd");       // Output VCD file
    $dumpvars(0, lfsr_tb);          // Dump all variables in this module

    reset <= 1'b1;
    @(posedge clk);
    reset <= 1'b0;

    for (int i = 0; i < 32; i = i + 1)
      @(posedge clk);

    $finish();
  end

endmodule