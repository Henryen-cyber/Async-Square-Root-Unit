module CordicSquareRoot #(
  parameter int FP32 = pa_AsyncCordic::FP32
)(
  input  logic[FP32:0] data_i,

  input  logic         ck,

  input  logic         arst,

  output logic         finished,
  output logic[FP32:0] data_o

);

  pa_AsyncCordic::fp_components_t asyncCordic_o;

  logic[FP32:0] data;
  logic         asyncOutput_ack;

  AsyncCordic  asyncCordic         (
    .data_i    (  data_i           ),
    .ack_o     (  asyncOutput_ack  ),
    .arst      (  arst             ),
    .data_o    (  asyncCordic_o    )
  );

  AsyncOutput asyncOutput          (
    .data_i    (  asyncCordic_o    ),
    .ck        (  ck               ),
    .arst      (  arst             ),
    .ack_i     (  asyncOutput_ack  ),
    .data_o    (  data             )
  );

  assign finished = asyncOutput_ack;

  always_ff @(posedge ck) begin
    if (asyncOutput_ack) begin
      data_o <= data;
    end
  end

endmodule
