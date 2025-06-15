module AsyncShift #(
  parameter int SIZE,
  parameter int SHIFT
)(
  input  pa_AsyncCordic::dual_rail_t[SIZE:0] data_i,
  input  logic[SHIFT:0]                      shift_amnt,

  output pa_AsyncCordic::dual_rail_t[SIZE:0] data_o
);

  logic[SIZE:0]                       msbs;
  pa_AsyncCordic::dual_rail_t[SIZE:0] data_shift;
  pa_AsyncCordic::dual_rail_t[SIZE:0] data_msbs;

  genvar i;
  generate
    assign data_shift = data_i >> (2 * shift_amnt);
    for (i = 0; i <= SIZE; i++) begin
      always_comb begin
        msbs[i] = data_shift[i].data_1 || data_shift[i].data_0;
        data_msbs[i].data_1 = ~msbs[i] && data_i[SIZE].data_1;
        data_msbs[i].data_0 = ~msbs[i] && data_i[SIZE].data_0;
      end
    end
  endgenerate
  assign data_o = data_shift + data_msbs;
endmodule

module AsyncLeftShift #(
  parameter int SIZE  = pa_AsyncCordic::RW,
  parameter int SHIFT = 1
)(
  input  pa_AsyncCordic::dual_rail_t[SIZE:0] data_i,

  input                                      arst,

  output pa_AsyncCordic::dual_rail_t[SIZE:0] data_o
);

  logic nonZero_token;
  AsyncCompletionDetection      #(
    .SIZE      (  SIZE           )
  ) validInput (
    .valid     (  data_i         ),
    .arst      (  arst           ),
    .ack_i     (  nonZero_token  )
  );

  always_comb begin

    if (nonZero_token ) begin
      data_o <= (data_i << (2 * SHIFT)) + {SHIFT{2'b01}};
    end else begin
      data_o <= 0;
    end

  end

endmodule
