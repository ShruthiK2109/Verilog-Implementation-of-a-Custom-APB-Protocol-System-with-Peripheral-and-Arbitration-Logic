module FIXED_PRIORITY_ARBITRER_tb ();

  localparam NUM_PORTS = 8;

  logic [NUM_PORTS-1:0] req_i;
  logic [NUM_PORTS-1:0] gnt_o;

  FIXED_PRIORITY_ARBITRER #(NUM_PORTS) fixed_priority_arbitrer (.*);

  initial begin
    // Dumpfile setup for waveform viewing
    $dumpfile("FIXED_PRIORITY_ARBITRER_tb.vcd"); // Name of the dump file
    $dumpvars(0, FIXED_PRIORITY_ARBITRER_tb);    // Dump all variables in the testbench

    for (int i = 0; i < 32; i = i + 1) begin
      req_i = $urandom_range(0, 2**NUM_PORTS - 1);
      #5;
    end

    #10 $finish; // Optional: finish simulation after test
  end

endmodule