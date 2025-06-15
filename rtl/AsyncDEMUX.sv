module AsyncDEMUX #(
  parameter SIZE = pa_AsyncCordic::RW
)(
  input  pa_AsyncCordic::dual_rail_t[SIZE:0] data_x,
  input  pa_AsyncCordic::dual_rail_t         ctrl,
  input  logic                               y_ack,
  input  logic                               z_ack,

  input  logic                               arst,

  output pa_AsyncCordic::dual_rail_t[SIZE:0] data_y,
  output pa_AsyncCordic::dual_rail_t[SIZE:0] data_z,
  output logic                               x_ack,
  output logic                               ctrl_ack
);

  assign x_ack    = y_ack || z_ack;
  assign ctrl_ack = y_ack || z_ack;

  genvar i;
  generate
    for(i = 0; i <= SIZE; i++) begin

      AsyncMullerC u_AsyncMullerC_y1 (
        .a        (  data_x[i].data_1   ),
        .b        (  ctrl.data_1        ),
        .y        (  data_y[i].data_1   ),
        .arstn    (  arst               )
      );
      AsyncMullerC u_AsyncMullerC_y0 (
        .a        (  data_x[i].data_0   ),
        .b        (  ctrl.data_1        ),
        .y        (  data_y[i].data_0   ),
        .arstn    (  arst               )
      );

      AsyncMullerC u_AsyncMullerC_z1 (
        .a        (  data_x[i].data_1   ),
        .b        (  ctrl.data_0        ),
        .y        (  data_z[i].data_1   ),
        .arstn    (  arst               )
      );
      AsyncMullerC u_AsyncMullerC_z0 (
        .a        (  data_x[i].data_0   ),
        .b        (  ctrl.data_0        ),
        .y        (  data_z[i].data_0   ),
        .arstn    (  arst               )
      );

    end
  endgenerate
endmodule

module AsyncOperandDEMUX #(
  parameter int RW = pa_AsyncCordic::RW,
  parameter int EW = pa_AsyncCordic::EW
)(
  input  pa_AsyncCordic::operand_t   data_x,
  input  pa_AsyncCordic::dual_rail_t ctrl,
  input  logic                       y_ack,
  input  logic                       z_ack,

  input  logic                       arst,

  output pa_AsyncCordic::operand_t   data_y,
  output pa_AsyncCordic::operand_t   data_z,
  output logic                       x_ack,
  output logic                       ctrl_ack
);

  assign x_ack    = y_ack || z_ack;
  assign ctrl_ack = y_ack || z_ack;

  genvar i;
  generate
    for (i = 0; i <= RW; i++) begin

      AsyncMullerC u_AsyncMullerC_y1             (
        .a        (  data_x.radicand[i].data_1   ),
        .b        (  ctrl.data_1                 ),
        .y        (  data_y.radicand[i].data_1   ),
        .arstn    (  arst                        )
      );
      AsyncMullerC u_AsyncMullerC_y0             (
        .a        (  data_x.radicand[i].data_0   ),
        .b        (  ctrl.data_1                 ),
        .y        (  data_y.radicand[i].data_0   ),
        .arstn    (  arst                        )
      );

      AsyncMullerC u_AsyncMullerC_z1             (
        .a        (  data_x.radicand[i].data_1   ),
        .b        (  ctrl.data_0                 ),
        .y        (  data_z.radicand[i].data_1   ),
        .arstn    (  arst                        )
      );
      AsyncMullerC u_AsyncMullerC_z0             (
        .a        (  data_x.radicand[i].data_0   ),
        .b        (  ctrl.data_0                 ),
        .y        (  data_z.radicand[i].data_0   ),
        .arstn    (  arst                        )
      );

    end
  endgenerate

  genvar j;
  generate
    for (j = 0; j <= EW; j++) begin

      AsyncMullerC u_AsyncMullerC_y1             (
        .a        (  data_x.exp[j].data_1        ),
        .b        (  ctrl.data_1                 ),
        .y        (  data_y.exp[j].data_1        ),
        .arstn    (  arst                        ),
      );
      AsyncMullerC u_AsyncMullerC_y0             (
        .a        (  data_x.exp[j].data_0        ),
        .b        (  ctrl.data_1                 ),
        .y        (  data_y.exp[j].data_0        ),
        .arstn    (  arst                        ),
      );

      AsyncMullerC u_AsyncMullerC_z1             (
        .a        (  data_x.exp[j].data_1        ),
        .b        (  ctrl.data_0                 ),
        .y        (  data_z.exp[j].data_1        ),
        .arstn    (  arst                        ),
      );
      AsyncMullerC u_AsyncMullerC_z0             (
        .a        (  data_x.exp[j].data_0        ),
        .b        (  ctrl.data_0                 ),
        .y        (  data_z.exp[j].data_0        ),
        .arstn    (  arst                        )
      );

    end
  endgenerate

endmodule
