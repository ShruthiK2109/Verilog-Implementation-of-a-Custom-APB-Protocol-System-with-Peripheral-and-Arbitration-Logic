module SIMPLE_MEMORY_INTERFACE_tb ();

  logic        clk;
  logic        reset;
  logic        req_i;
  logic        req_rnw_i;
  logic[9:0]   req_addr_i;
  logic[31:0]  req_wdata_i;
  logic        req_ready_o;
  logic[31:0]  req_rdata_o;

  // Instantiate the RTL
  SIMPLE_MEMORY_INTERFACE simple_memory_interface (.*);

  logic [9:0] [9:0] addr_list;

  // Clock generation
  always begin
    clk = 1'b1;
    #5;
    clk = 1'b0;
    #5;
  end

  // Stimulus generation
  initial begin
    // 🔽 Waveform dump setup
    $dumpfile("simple_memory_interface.vcd");
    $dumpvars(0, SIMPLE_MEMORY_INTERFACE_tb);

    reset <= 1'b1;
    req_i <= 1'b0;
    @(posedge clk);
    reset <= 1'b0;
    @(posedge clk);

    // Write 10 transactions
    for (int txn=0; txn<10; txn++) begin
      req_i       <= 1'b1;
      req_rnw_i   <= 0;
      req_addr_i  <= $urandom_range(0, 1023);
      addr_list[txn] = req_addr_i;
      req_wdata_i <= $urandom_range(0, 32'hFFFF);
      while (~req_ready_o) @(posedge clk);
      req_i <= 1'b0;
      @(posedge clk);
    end

    // Read 10 transactions
    for (int txn=0; txn<10; txn++) begin
      req_i       <= 1'b1;
      req_rnw_i   <= 1;
      req_addr_i  <= addr_list[txn];
      req_wdata_i <= $urandom_range(0, 32'hFFFF); // Irrelevant on reads
      while (~req_ready_o) @(posedge clk);
      req_i <= 1'b0;
      @(posedge clk);
    end

    $finish();
  end

endmodule