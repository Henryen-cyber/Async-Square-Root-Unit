module AsyncSource #(
  parameter int SIZE
)(
  input  logic[SIZE:0]                       data_i,
  input  logic                               ack_i,

  output pa_AsyncCordic::dual_rail_t[SIZE:0] data_o
);

  genvar i;
  generate
    for(i = 0; i <= SIZE; i++) begin
      assign data_o[i].data_1 =  data_i[i] && ~ack_i;
      assign data_o[i].data_0 = ~data_i[i] && ~ack_i;
    end
  endgenerate

endmodule


module AsyncOperandSource #(
  parameter int FP32 = pa_AsyncCordic::FP32,
  parameter int FW   = pa_AsyncCordic::FW,
  parameter int EW   = pa_AsyncCordic::EW
)(
  input  logic[FP32:0]                   data_i,
  input  logic                           ack_i,

  output pa_AsyncCordic::fp_components_t data_o
);

  genvar i;
  generate
    for (i = 0; i <= FW; i++) begin
      assign data_o.fraction[i].data_1 =  data_i[i] && ~ack_i;
      assign data_o.fraction[i].data_0 = ~data_i[i] && ~ack_i;
    end
  endgenerate

  genvar j;
  generate
    for (j = FW + 1; j < FP32; j++) begin
      assign data_o.exp[j - (FW + 1)].data_1 =  data_i[j] && ~ack_i;
      assign data_o.exp[j - (FW + 1)].data_0 = ~data_i[j] && ~ack_i;
    end
  endgenerate
endmodule
