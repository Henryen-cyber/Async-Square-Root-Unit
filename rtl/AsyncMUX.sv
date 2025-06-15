module AsyncMUX #(
  parameter int SIZE  = pa_AsyncCordic::RW
)(
  input  pa_AsyncCordic::dual_rail_t[SIZE:0] data_x  ,
  input  pa_AsyncCordic::dual_rail_t[SIZE:0] data_y  ,
  input  pa_AsyncCordic::dual_rail_t         ctrl    ,
  input  logic                               z_ack   ,

  input  logic                               arst    ,

  output logic                               x_ack   ,
  output logic                               y_ack   ,
  output logic                               ctrl_ack,
  output pa_AsyncCordic::dual_rail_t[SIZE:0] data_z
);

  pa_AsyncCordic::dual_rail_t[SIZE:0] x_o    ;
  pa_AsyncCordic::dual_rail_t[SIZE:0] y_o    ;
  logic                               x_o_ack;
  logic                               y_o_ack;

  assign ctrl_ack = z_ack;

  genvar i;
  generate
    for(i = 0; i <= SIZE; i++) begin
      AsyncMullerC u_AsyncMullerC_x1 (
        .a        (  data_x[i].data_1  ),
        .b        (  ctrl.data_1       ),
        .y        (  x_o[i].data_1     ),
        .arstn    (  arst              )
      );

      AsyncMullerC u_AsyncMullerC_x0 (
        .a        (  data_x[i].data_0  ),
        .b        (  ctrl.data_1       ),
        .y        (  x_o[i].data_0     ),
        .arstn    (  arst              )
      );

      AsyncMullerC u_AsyncMullerC_y1 (
        .a        (  data_y[i].data_1  ),
        .b        (  ctrl.data_0       ),
        .y        (  y_o[i].data_1     ),
        .arstn    (  arst              )
      );

      AsyncMullerC u_AsyncMullerC_y0 (
        .a        (  data_y[i].data_0  ),
        .b        (  ctrl.data_0       ),
        .y        (  y_o[i].data_0     ),
        .arstn    (  arst              )
      );

      assign data_z[i].data_0 = y_o[i].data_0 || x_o[i].data_0;
      assign data_z[i].data_1 = y_o[i].data_1 || x_o[i].data_1;
    end
  endgenerate

  AsyncCompletionDetection #(
    .SIZE      (  SIZE      )
  ) u_AsyncCompletionDetetction_x (
    .valid     (  x_o       ),
    .arst      (  arst      ),
    .ack_i     (  x_o_ack   )
  );

  AsyncCompletionDetection #(
    .SIZE      (  SIZE      )
  ) u_AsyncCompletionDetetction_y (
    .valid     (  y_o       ),
    .arst      (  arst      ),
    .ack_i     (  y_o_ack   )
  );

  AsyncMullerC u_AsyncMullerC_x_ack (
    .a        (  x_o_ack    ),
    .b        (  z_ack      ),
    .y        (  x_ack      ),
    .arstn    (  arst       )
  );

  AsyncMullerC u_AsyncMullerC_y_ack (
    .a        (  y_o_ack    ),
    .b        (  z_ack      ),
    .y        (  y_ack      ),
    .arstn    (  arst       )
  );

endmodule

module AsyncOperandMUX #(
  parameter int RW = pa_AsyncCordic::RW,
  parameter int EW = pa_AsyncCordic::EW
)(
  input  pa_AsyncCordic::operand_t   data_x,
  input  pa_AsyncCordic::operand_t   data_y,
  input  pa_AsyncCordic::dual_rail_t ctrl,
  input  logic                       z_ack,

  input  logic                       arst,

  output logic                       x_ack,
  output logic                       y_ack,
  output logic                       ctrl_ack,
  output pa_AsyncCordic::operand_t   data_z

);

  pa_AsyncCordic::dual_rail_t[RW:0] operandX_o;
  pa_AsyncCordic::dual_rail_t[RW:0] operandY_o;
  pa_AsyncCordic::dual_rail_t[EW:0] expX_o;
  pa_AsyncCordic::dual_rail_t[EW:0] expY_o;

  logic                             x_o_ack;
  logic                             y_o_ack;

  assign ctrl_ack = z_ack;

  genvar i;
  generate
    for (i = 0; i <= RW; i++) begin : operand
      AsyncMullerC u_AsyncMullerC_operandx1     (
        .a        (  data_x.radicand[i].data_1  ),
        .b        (  ctrl.data_1                ),
        .y        (  operandX_o[i].data_1       ),
        .arstn    (  arst                       )
      );

      AsyncMullerC u_AsyncMullerC_operandx0     (
        .a        (  data_x.radicand[i].data_0  ),
        .b        (  ctrl.data_1                ),
        .y        (  operandX_o[i].data_0       ),
        .arstn    (  arst                       )
      );
      AsyncMullerC u_AsyncMullerC_operandy1     (
        .a        (  data_y.radicand[i].data_1  ),
        .b        (  ctrl.data_0                ),
        .y        (  operandY_o[i].data_1       ),
        .arstn    (  arst                       )
      );

      AsyncMullerC u_AsyncMullerC_operandy0     (
        .a        (  data_y.radicand[i].data_0  ),
        .b        (  ctrl.data_0                ),
        .y        (  operandY_o[i].data_0       ),
        .arstn    (  arst                       )
      );

      assign data_z.radicand[i].data_0 = operandX_o[i].data_0 || operandY_o[i].data_0;
      assign data_z.radicand[i].data_1 = operandX_o[i].data_1 || operandY_o[i].data_1;
    end
  endgenerate

  genvar j;
  generate
    for (j = 0; j <= EW; j++) begin : exponent
      AsyncMullerC u_AsyncMullerC_exponentx1    (
        .a        (  data_x.exp[j].data_1       ),
        .b        (  ctrl.data_1                ),
        .y        (  expX_o[j].data_1           ),
        .arstn    (  arst                       )
      );

      AsyncMullerC u_AsyncMullerC_exponentx0    (
        .a        (  data_x.exp[j].data_0       ),
        .b        (  ctrl.data_1                ),
        .y        (  expX_o[j].data_0           ),
        .arstn    (  arst                       )
      );
      AsyncMullerC u_AsyncMullerC_exponenty1    (
        .a        (  data_y.exp[j].data_1       ),
        .b        (  ctrl.data_0                ),
        .y        (  expY_o[j].data_1           ),
        .arstn    (  arst                       )
      );

      AsyncMullerC u_AsyncMullerC_exponenty0    (
        .a        (  data_y.exp[j].data_0       ),
        .b        (  ctrl.data_0                ),
        .y        (  expY_o[j].data_0           ),
        .arstn    (  arst                       )
      );

      assign data_z.exp[j].data_0 = expX_o[j].data_0 || expY_o[j].data_0;
      assign data_z.exp[j].data_1 = expX_o[j].data_1 || expY_o[j].data_1;

    end
  endgenerate

  AsyncCompletionDetection #(
    .SIZE      (  RW + EW + 1               )
  ) u_AsyncCompletionDetection_x            (
    .valid     (  {  operandX_o, expX_o  }  ),
    .arst      (  arst                      ),
    .ack_i     (  x_o_ack                   )
  );

  AsyncCompletionDetection #(
    .SIZE      (  RW + EW + 1               )
  ) u_AsyncCompletionDetection_y            (
    .valid     (  {  operandY_o, expY_o  }  ),
    .arst      (  arst                      ),
    .ack_i     (  y_o_ack                   )
  );

  AsyncMullerC u_AsyncMullerC_x_ack (
    .a        (  x_o_ack    ),
    .b        (  z_ack      ),
    .y        (  x_ack      ),
    .arstn    (  arst       )
  );

  AsyncMullerC u_AsyncMullerC_y_ack (
    .a        (  y_o_ack    ),
    .b        (  z_ack      ),
    .y        (  y_ack      ),
    .arstn    (  arst       )
  );

endmodule
