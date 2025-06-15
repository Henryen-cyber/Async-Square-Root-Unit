module AsyncMullerC #(
  parameter int RESET = 1
)(
  input  logic a,
  input  logic b,
  input  logic arstn,
  output logic y
);

  always_latch begin
     if (arstn == 0)
        y <= RESET;
     else if ( (a == 1) && (b == 1) )
        y <= 1;
     else if ( (a == 0) && (b == 0) )
        y <= 0;
  end

endmodule
