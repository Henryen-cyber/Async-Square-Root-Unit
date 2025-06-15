/* POSSIBLY REMAKE */
module AsyncJoin #(
  parameter int SIZE,
  parameter int WIDTH
)(
  input  logic                                        ack_o,
  input  pa_AsyncCordic::dual_rail_t[WIDTH:0][SIZE:0] data_i,

  output logic[WIDTH:0]                               ack_i,
  output pa_AsyncCordic::dual_rail_t[WIDTH:0][SIZE:0] data_o
);

  assign data_o = data_i;

  genvar i;
  generate
    for (i = 0; i <= WIDTH; i++) begin
      assign ack_i[i]  = ack_o;
    end
  endgenerate

endmodule

module AsyncOperandJoin #(
  parameter int RW = pa_AsyncCordic::RW,
  parameter int EW = pa_AsyncCordic::EW
)(
  input  pa_AsyncCordic::dual_rail_t[RW:0] radicand,
  input  pa_AsyncCordic::dual_rail_t[EW:0] exp,
  input  logic                             operand_ack,

  output pa_AsyncCordic::operand_t         operand,
  output logic                             exp_ack,
  output logic                             radicand_ack
);

  assign operand.exp      = exp;
  assign exp_ack          = operand_ack;
  assign operand.radicand = radicand;
  assign radicand_ack     = operand_ack;

endmodule

module AsyncHiddenBitJoin #(
  parameter int FW = pa_AsyncCordic::FW,
  parameter int RW = pa_AsyncCordic::RW
)(
  input  pa_AsyncCordic::dual_rail_t[1:0]  hiddenBit,
  input  pa_AsyncCordic::dual_rail_t[FW:0] fraction,
  input  pa_AsyncCordic::dual_rail_t[4:0]  accBits,
  input  logic                             ack_i,

  output logic                             hiddenBit_ack,
  output logic                             fraction_ack,
  output logic                             accBits_ack,

  output pa_AsyncCordic::dual_rail_t[RW:0] radicand
);

  assign radicand = {hiddenBit, fraction, accBits};

  assign hiddenBit_ack = ack_i;
  assign fraction_ack  = ack_i;
  assign accBits_ack   = ack_i;

endmodule

module AsyncCordicCoordJoin #(
  parameter int RW = pa_AsyncCordic::RW
)(
  input  pa_AsyncCordic::dual_rail_t[RW:0] data_x,
  input  pa_AsyncCordic::dual_rail_t[RW:0] data_y,

  input  logic                             ack_o,

  output pa_AsyncCordic::cordic_coord_t    data_o,
  output logic                             x_ack,
  output logic                             y_ack
);

  assign data_o.x = data_x;
  assign data_o.y = data_y;

  assign x_ack = ack_o;
  assign y_ack = ack_o;

endmodule
