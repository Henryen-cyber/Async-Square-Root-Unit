module AsyncEqualZero #(
  parameter int EW = pa_AsyncCordic::EW
)(
  input  pa_AsyncCordic::dual_rail_t[EW:0] exponent,
  input  logic                             ctrl_ack,

  input  logic                             arst,

  output logic                             ack_i,
  output pa_AsyncCordic::dual_rail_t       ctrl
);

  logic[EW:0] data_1_o;
  logic[EW:0] data_0_o;

  AsyncSink   #(
    .SIZE      (  EW        )
  ) equalZeroSink           (
    .data_i    (  exponent  ),
    .arst      (  arst      ),
    .ack_i     (  ack_i     )
  );


  genvar i;
  generate
    for (i = 0; i <= EW; i++) begin
      AsyncMullerC u_AsyncMullerC_equalZero_1 (
        .a         (  exponent[i].data_1      ),
        .b         (  ~ctrl_ack               ),
        .y         (  data_1_o[i]             ),
        .arstn     (  arst                    )
      );

      AsyncMullerC u_AsyncMullerC_equalZero_0 (
        .a         (  exponent[i].data_0      ),
        .b         (  ~ctrl_ack               ),
        .y         (  data_0_o[i]             ),
        .arstn     (  arst                    )
      );
    end
  endgenerate

  AsyncMullerCTree #(
    .WIDTH       (  EW + 1                )
  ) u_AsyncMullerCTree_equalZero_1 (
    .treeInput   (  data_0_o              ),
    .arst_n      (  arst                  ),
    .treeOutput  (  ctrl.data_1           )
  );

  assign ctrl.data_0 = |data_1_o;

endmodule
