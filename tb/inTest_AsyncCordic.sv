interface inTest_AsyncCordic;

  // -------------------------------------
  // ------------ Testbench --------------
  // -------------------------------------

  logic arst;
  logic ck;

  event doReset;
  event resetDone;

  // -------------------------------------
  // -------------- DUT I/O --------------
  // -------------------------------------

  localparam int SIZE = pa_AsyncCordic::RW;
  localparam int FP32 = pa_AsyncCordic::FP32;

  logic         FINISHED;
  logic[FP32:0] DATA_I;
  logic[FP32:0] DATA_O;

endinterface
