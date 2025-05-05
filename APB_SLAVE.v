module APB_SLAVE (
  input         wire        clk,
  input         wire        reset,

  input         wire        psel_i,
  input         wire        penable_i,
  input         wire[9:0]   paddr_i,
  input         wire        pwrite_i,
  input         wire[31:0]  pwdata_i,
  output        wire[31:0]  prdata_o,
  output        wire        pready_o
);

  // Valid APB request
  logic apb_req;

  assign apb_req = psel_i & penable_i;

  // Instantiate the memory interface
  SIMPLE_MEMORY_INTERFACE simple_memory_interface (
    .clk            (clk),
    .reset          (reset),
    .req_i          (apb_req),
    .req_rnw_i      (~pwrite_i),
    .req_addr_i     (paddr_i),
    .req_wdata_i    (pwdata_i),
    .req_ready_o    (pready_o),
    .req_rdata_o    (prdata_o)
  );

endmodule

module SIMPLE_MEMORY_INTERFACE (
  input       wire        clk,
  input       wire        reset,

  input       wire        req_i,
  input       wire        req_rnw_i,    // 1 - read, 0 - write
  input       wire[3:0]   req_addr_i,
  input       wire[31:0]  req_wdata_i,
  output      wire        req_ready_o,
  output      wire[31:0]  req_rdata_o
);

  // Memory array
`ifdef FORMAL
  logic [31:0] mem[15:0];
`else
  logic [15:0][31:0] mem;
`endif

  logic mem_rd;
  logic mem_wr;

  logic req_rising_edge;

  logic [3:0] lfsr_val;
  logic [3:0] count;

  assign mem_rd = req_i &  req_rnw_i;
  assign mem_wr = req_i & ~req_rnw_i;

  // Detect a rising edge on the req_i
  edge_detector EDGE_DETECTOR (
    .clk            (clk),
    .reset          (reset),
    .a_i            (req_i),
    .rising_edge_o  (req_rising_edge),
    .falling_edge_o (/* Not needed */)
  );

  // Load a counter with random value on the rising edge
  logic[3:0] count_ff;
  logic[3:0] nxt_count;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      count_ff <= 4'h0;
    else
      count_ff <= nxt_count;

  assign nxt_count = req_rising_edge ? lfsr_val:
                                       count_ff + 4'h1;

  assign count = count_ff;

  // Generate a random load value
  lfsr LFSR (
    .clk            (clk),
    .reset          (reset),
    .lfsr_o         (lfsr_val)
  );

  // Write into the mem when the counter is 0
  always_ff @(posedge clk)
    if (mem_wr & ~|count)
      mem[req_addr_i] <= req_wdata_i;

  // Read directly
  assign req_rdata_o = mem[req_addr_i] & {32{mem_rd}};

  // Assert ready only when counter is at 0
  // This will add random delays on when memory gives the ready
  assign req_ready_o = ~|count;

endmodule

module edge_detector (
  input     wire    clk,
  input     wire    reset,

  input     wire    a_i,

  output    wire    rising_edge_o,
  output    wire    falling_edge_o
);

  logic a_ff;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      a_ff <= 1'b0;
    else
      a_ff <= a_i;

  // Rising edge when delayed signal is 0 but current is 1
  assign rising_edge_o = ~a_ff & a_i;

  // Falling edge when delayed signal is 1 but current is 0
  assign falling_edge_o = a_ff & ~a_i;

endmodule

module lfsr (
  input     wire      clk,
  input     wire      reset,

  output    wire[3:0] lfsr_o
);

  logic [3:0] lfsr_ff;
  logic [3:0] nxt_lfsr;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      lfsr_ff <= 4'hE;
    else
      lfsr_ff <= nxt_lfsr;

  assign nxt_lfsr = {lfsr_ff[2:0], lfsr_ff[1] ^ lfsr_ff[3]};

  assign lfsr_o = lfsr_ff;

endmodule