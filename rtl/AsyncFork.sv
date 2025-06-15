module AsyncFork #(
  parameter int SIZE,
  parameter int WIDTH
)(
  input  pa_AsyncCordic::dual_rail_t[SIZE:0]          data_i,
  input  logic[WIDTH:0]                               ack_o,

  input  logic                                        arst,

  output pa_AsyncCordic::dual_rail_t[WIDTH:0][SIZE:0] data_o,
  output logic                                        ack_i
);

  genvar i;
  generate
    for (i = 0; i <= WIDTH; i++) begin
      assign data_o[i] = data_i;
    end
  endgenerate

  AsyncMullerCTree #(
    .WIDTH      (  WIDTH + 1  )
  )
  u_AsyncMullerCTree_ack(
    .treeInput  (  ack_o      ),
    .arst_n     (  arst       ),
    .treeOutput (  ack_i      )
  );

endmodule

module AsyncOperandFork #(
  parameter int EW = pa_AsyncCordic::EW,
  parameter int RW = pa_AsyncCordic::RW
)(
  input  pa_AsyncCordic::operand_t         operand,
  input  logic                             exp_ack,
  input  logic                             radicand_ack,

  input  logic                             arst,

  output pa_AsyncCordic::dual_rail_t[EW:0] exp,
  output pa_AsyncCordic::dual_rail_t[RW:0] radicand,
  output logic                             ack_i
);

  assign exp      = operand.exp;
  assign radicand = operand.radicand;

  AsyncMullerC u_AsyncMullerC_fork (
    .a         (  radicand_ack  ),
    .b         (  exp_ack       ),
    .y         (  ack_i         ),
    .arstn     (  arst          )
  );


endmodule

module AsyncFPFork #(
  parameter int FP32 = pa_AsyncCordic::FP32,
  parameter int FW   = pa_AsyncCordic::FW,
  parameter int EW   = pa_AsyncCordic::EW
)(
  input  pa_AsyncCordic::fp_components_t   fp32,
  input  logic                             exp_ack,
  input  logic                             fraction_ack,

  input  logic                             arst,

  output pa_AsyncCordic::dual_rail_t[FW:0] fraction,
  output pa_AsyncCordic::dual_rail_t[EW:0] exp,
  output logic                             ack_i
);

  assign exp      = fp32.exp;
  assign fraction = fp32.fraction;

  AsyncMullerC u_AsyncMullerC_FPfork (
    .a         (  fraction_ack  ),
    .b         (  exp_ack       ),
    .y         (  ack_i         ),
    .arstn     (  arst          )
  );

endmodule

module AsyncCordicCoordFork #(
  parameter int RW = pa_AsyncCordic::RW
)(
  input  pa_AsyncCordic::cordic_coord_t    data_i,
  input  logic                             x_ack,
  input  logic                             y_ack,

  input  logic                             arst,

  output pa_AsyncCordic::dual_rail_t[RW:0] data_x,
  output pa_AsyncCordic::dual_rail_t[RW:0] data_y,
  output logic                             ack_i
);

  assign data_x = data_i.x;
  assign data_y = data_i.y;

  AsyncMullerC u_AsyncMullerC_FPfork (
    .a         (  x_ack     ),
    .b         (  y_ack     ),
    .y         (  ack_i     ),
    .arstn     (  arst      )
  );

endmodule
