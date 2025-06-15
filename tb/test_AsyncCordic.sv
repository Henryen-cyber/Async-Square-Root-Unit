`timescale 100fs/1fs

module test_AsyncCordic ();

  localparam SINK = pa_AsyncCordic::EW + pa_AsyncCordic::FW + 1;

  inTest_AsyncCordic uin_AsyncCordic();

  // -------------------------------------
  // ------------ PARAMATERS -------------
  // -------------------------------------

  localparam time T_CK16M = 62.5ns;

  // -------------------------------------
  // ----------- CK & RESET --------------
  // -------------------------------------

  initial begin
    uin_AsyncCordic.arst = 1;
    forever begin
      wait(uin_AsyncCordic.doReset) begin
        $display("Toggling reset...");
        #5;
        uin_AsyncCordic.arst = 0;
        $display("%b, %t", uin_AsyncCordic.arst, $time);
        #5;
        uin_AsyncCordic.arst = 1;
        ->uin_AsyncCordic.resetDone;
        $display("Reset done!");
        $display("%b, %t", uin_AsyncCordic.arst, $time);
      end
    end
  end

  initial begin
    uin_AsyncCordic.ck = 0;
    forever begin
      #(T_CK16M / 2);
      uin_AsyncCordic.ck = !uin_AsyncCordic.ck;
    end
  end

  // -------------------------------------
  // ---------------- DUT ----------------
  // -------------------------------------

  CordicSquareRoot cordicSquareRoot         (
    .data_i    (  uin_AsyncCordic.DATA_I    ),
    .ck        (  uin_AsyncCordic.ck        ),
    .arst      (  uin_AsyncCordic.arst      ),
    .finished  (  uin_AsyncCordic.FINISHED  ),
    .data_o    (  uin_AsyncCordic.DATA_O    )
  );

  // -------------------------------------
  // ----------- TEST PROGRAM ------------
  // -------------------------------------

  testPr_AsyncCordic u_testPr   (
    .uin_AsyncCordic            ( uin_AsyncCordic  )
  );

endmodule
