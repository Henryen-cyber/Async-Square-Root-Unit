module AsyncOutput #(
  parameter int EW   = pa_AsyncCordic::EW,
  parameter int FW   = pa_AsyncCordic::FW,
  parameter int FP32 = pa_AsyncCordic::FP32
)(
  input  pa_AsyncCordic::fp_components_t data_i,
  input  logic                           ck,

  input  logic                           arst,

  output logic                           ack_i,
  output logic[FP32:0]                   data_o
);

  pa_AsyncCordic::dual_rail_t[FP32:0] data;

  genvar i;
  genvar j;
  generate
    for (i = 0; i <= EW; i++) begin

      AsyncMullerC u_AsyncMullerC_exp1        (
        .a        (  data_i.exp[i].data_1     ),
        .b        (  ck                       ),
        .y        (  data[FW + 1 + i].data_1  ),
        .arstn    (  arst                     ),
      );

      AsyncMullerC u_AsyncMullerC_exp0        (
        .a        (  data_i.exp[i].data_0     ),
        .b        (  ck                       ),
        .y        (  data[FW + 1 + i].data_0  ),
        .arstn    (  arst                     ),
      );

    assign data_o[FW + 1 + i] = data[FW + 1 + i].data_1 && ~data[FW + 1 + i].data_0;

    end

    for (j = 0; j <= FW; j++) begin

      AsyncMullerC u_AsyncMullerC_rad1          (
        .a        (  data_i.fraction[j].data_1  ),
        .b        (  ck                         ),
        .y        (  data[j].data_1             ),
        .arstn    (  arst                       ),
      );

      AsyncMullerC u_AsyncMullerC_rad0          (
        .a        (  data_i.fraction[j].data_0  ),
        .b        (  ck                         ),
        .y        (  data[j].data_0             ),
        .arstn    (  arst                       ),
      );

      assign data_o[j] = data[j].data_1 && ~data[j].data_0;

    end

  endgenerate

  assign data_o[FP32] = 0;

  AsyncCompletionDetection #(
    .SIZE      (  FP32      )
  ) outputComplete          (
    .valid     (  data      ),
    .arst      (  arst      ),
    .ack_i     (  ack_i     )
  );

endmodule
