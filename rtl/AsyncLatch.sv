module AsyncLatch #(
  parameter int                          SIZE,
  parameter pa_AsyncCordic::e_LatchModes MODE = 3
  `ifndef SYNTHESIS
    , parameter time                         RTL_OUTPUT_DELAY = pa_AsyncCordic::RTL_OUTPUT_DELAY
  `endif

)(
  input  pa_AsyncCordic::dual_rail_t[SIZE:0] data_i,
  input  logic                               ack_o,

  input  logic                               arst,

  output pa_AsyncCordic::dual_rail_t[SIZE:0] data_o,
  output logic                               ack_i
);

  pa_AsyncCordic::dual_rail_t[SIZE:0] data_d;

  genvar i;
  genvar j;
  genvar k;
  generate
    if (MODE == 0) begin : ZERO_TOKEN
      for(i = 0; i <= SIZE; i++) begin
        AsyncMullerC                  #(
          .RESET  (  1                 )
        ) MullerC_0                    (
          .a      (  data_i[i].data_0  ),
          .b      (  ~ack_o            ),
          .y      (  data_d[i].data_0  ),
          .arstn  (  arst              )
        );

        AsyncMullerC                  #(
          .RESET  (  0                 )
        ) MullerC_1                    (
          .a      (  data_i[i].data_1  ),
          .b      (  ~ack_o            ),
          .y      (  data_d[i].data_1  ),
          .arstn  (  arst              )
        );
      end

    end else if (MODE == 1) begin : ONE_TOKEN
      for(k = 0; k <= SIZE; k++) begin
        AsyncMullerC                  #(
          .RESET  (  0                 )
        ) MullerC_0                    (
          .a      (  data_i[k].data_0  ),
          .b      (  ~ack_o            ),
          .y      (  data_d[k].data_0  ),
          .arstn  (  arst              )
        );

        AsyncMullerC                  #(
          .RESET  (  1                 )
        ) MullerC_1                    (
          .a      (  data_i[k].data_1  ),
          .b      (  ~ack_o            ),
          .y      (  data_d[k].data_1  ),
          .arstn  (  arst              )
        );
      end

    end else if (MODE == 3) begin : EMPTY_TOKEN
      for (j = 0; j <= SIZE; j++) begin
        AsyncMullerC u_AsyncMullerC_0    (
          .a        (  data_i[j].data_0  ),
          .b        (  ~ack_o            ),
          .y        (  data_d[j].data_0  ),
          .arstn    (  arst              )
        );

        AsyncMullerC u_AsyncMullerC_1    (
          .a        (  data_i[j].data_1  ),
          .b        (  ~ack_o            ),
          .y        (  data_d[j].data_1  ),
          .arstn    (  arst              )
        );

      end
    end

  endgenerate

  `ifndef SYNTHESIS
    always_comb begin
      data_o <= #RTL_OUTPUT_DELAY data_d;
    end
  `else
    assign data_o = data_d;
  `endif


  AsyncCompletionDetection    #(
    .SIZE     (  SIZE          )
  ) u_AsyncCompletionDetection (
    .valid    (  data_o        ),
    .arst     (  arst          ),
    .ack_i    (  ack_i         )
  );


endmodule

module AsyncOperandLatch #(
  parameter int EW = pa_AsyncCordic::EW,
  parameter int RW = pa_AsyncCordic::RW
  `ifndef SYNTHESIS
    , parameter time RTL_OUTPUT_DELAY = pa_AsyncCordic::RTL_OUTPUT_DELAY
  `endif
)(
  input  pa_AsyncCordic::operand_t data_i,
  input  logic                     ack_o,

  input  logic                     arst,

  output pa_AsyncCordic::operand_t data_o,
  output logic                     ack_i
);

  logic exp_ack;
  logic rad_ack;
  logic ack;

  pa_AsyncCordic::operand_t data;

  AsyncLatch  #(
    .SIZE      (  EW          )
  ) expLatch   (
    .data_i    (  data_i.exp  ),
    .ack_o     (  ack_o       ),
    .arst      (  arst        ),
    .data_o    (  data.exp    ),
    .ack_i     (  exp_ack     )
  );

  AsyncLatch  #(
    .SIZE      (  RW               )
  ) radLatch   (
    .data_i    (  data_i.radicand  ),
    .ack_o     (  ack_o            ),
    .arst      (  arst             ),
    .data_o    (  data.radicand    ),
    .ack_i     (  rad_ack          )
  );

  AsyncMullerC ack_C        (
    .a         (  exp_ack   ),
    .b         (  rad_ack   ),
    .y         (  ack       ),
    .arstn     (  arst      )
  );

  always_comb begin

    `ifndef SYNTHESIS
      data_o <= #RTL_OUTPUT_DELAY data;
      ack_i  <= #RTL_OUTPUT_DELAY ack;
    `else
      data_o <= data;
      ack_i  <= ack;
    `endif

  end

endmodule
