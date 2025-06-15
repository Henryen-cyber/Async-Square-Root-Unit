module AsyncSink #(
  parameter int SIZE
)(
  input  pa_AsyncCordic::dual_rail_t[SIZE:0]  data_i,

  input  logic                                arst,

  output logic                                ack_i
);

  logic [SIZE:0] or_i;

  genvar i;
  generate
    for (i = 0; i <= SIZE; i++) begin
      assign or_i[i] = data_i[i].data_1 || data_i[i].data_0;
    end
  endgenerate

  AsyncMullerCTree #(
    .WIDTH      (  SIZE + 1  )
  ) u_AsyncMullerCTree (
    .treeInput  (  or_i      ),
    .arst_n     (  arst      ),
    .treeOutput (  ack_i     )
  );

endmodule
