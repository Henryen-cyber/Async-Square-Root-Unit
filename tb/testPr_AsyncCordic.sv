program automatic testPr_AsyncCordic (
  inTest_AsyncCordic  uin_AsyncCordic
);

  localparam int EW    = 7;
  localparam int FW    = 22;
  localparam int FP32  = 31;
  localparam int N     = 99;
  localparam int N_SQR = 18;

  string filename = "async_cordic_results.txt";
  int file;

  initial begin
    // Reset design
    ->uin_AsyncCordic.doReset;
    wait(uin_AsyncCordic.resetDone);
    $display("Running tests:");
  end

  // -------------------------------------
  // --------- Tasks & Functions ---------
  // -------------------------------------

  // Reset
  task ta_reset();
    $display("Resetting");
    ->uin_AsyncCordic.doReset;
    wait(uin_AsyncCordic.resetDone);
  endtask

  // Final
  function void fu_printEndStatus;
    $display("");
    $display("--------------------------------------------------------------------------------");
    $display("--------------------------------------------------------------------------------");
    $display("%t - SIMULATIONS FINISHED.", $time);
    $display("--------------------------------------------------------------------------------");
    $display("--------------------------------------------------------------------------------");
    $display("");
  endfunction

  // Subnormal Numbers
  logic[FP32:0] test_sn0 = 32'b00000000000010010011000000101000;
  logic[FP32:0] test_sn1 = 32'b00000000010000010101000100101010;
  logic[FP32:0] test_sn2 = 32'b00000000010001011101000100101111;
  logic[FP32:0] test_sn3 = 32'b00000000011100011101000100101111;

  // Normal Numbers
  logic[FP32:0] test_n0 = 32'b00111111111100011101000100101111;
  logic[FP32:0] test_n1 = 32'b00110100111111111111111111111111;
  logic[FP32:0] test_n2 = 32'b00111111111111111111111111111111;
  logic[FP32:0] test_n3 = 32'b00111111111111010101110111101110;

  // True Squares
  logic[FP32:0] test_ts0 = 32'b01000001110010000000000000000000; // 25
  logic[FP32:0] test_ts1 = 32'b01000010111100100000000000000000; // 144
  logic[FP32:0] test_ts2 = 32'b01000011000100000000000000000000; // 169
  logic[FP32:0] test_ts3 = 32'b01000011101101001000000000000000; // 361

  initial begin
    $timeformat(-15, 1, " fs", 0);
    $display("--- Staring Simulation ---");
    ta_reset();
    uin_AsyncCordic.DATA_I = test_ts3;
    wait(uin_AsyncCordic.FINISHED);
    $display("Input: %h - Output: %h", uin_AsyncCordic.DATA_I, uin_AsyncCordic.DATA_O);
    fu_printEndStatus();
    $finish;
  end

endprogram
