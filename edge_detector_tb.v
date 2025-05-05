module edge_detector_tb ();

  logic    clk;
  logic    reset;
  logic    a_i;
  logic    rising_edge_o;
  logic    falling_edge_o;

  edge_detector EDGE_DETECTOR (.*);

  // clk
  always begin
    clk = 1'b1;
    #5;
    clk = 1'b0;
    #5;
  end

  // Stimulus
  initial begin
    // Dumpfile setup
    $dumpfile("edge_detector_tb.vcd");    // Name of the VCD output file
    $dumpvars(0, edge_detector_tb);       // Dump all variables in this module

    reset <= 1'b1;
    a_i <= 1'b1;
    @(posedge clk);
    reset <= 1'b0;
    @(posedge clk);
    for (int i=0; i<32; i++) begin
      a_i <= $random % 2;
      @(posedge clk);
    end
    $finish;
  end

endmodule