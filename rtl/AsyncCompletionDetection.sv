module AsyncCompletionDetection #(
  parameter int SIZE
)(
  input  pa_AsyncCordic::dual_rail_t[SIZE:0] valid,

  input  logic                               arst,

  output logic                               ack_i
);

  logic[SIZE:0] or_o;

  genvar i;
  generate
    for (i = 0; i <= SIZE; i++) begin
      assign or_o[i] = valid[i].data_1 || valid[i].data_0;
    end
  endgenerate

  generate
    if (SIZE) begin

      AsyncMullerCTree          #(
        .WIDTH      (  SIZE + 1  )
      ) u_AsyncMullerCTree       (
        .treeInput  (  or_o      ),
        .arst_n     (  arst      ),
        .treeOutput (  ack_i     )
      );

    end else
      assign ack_i = or_o;
  endgenerate

endmodule
