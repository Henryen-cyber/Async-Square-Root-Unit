module AsyncAdderCore #(

  `ifndef SYNTHESIS
    parameter time RTL_OUTPUT_DELAY = pa_AsyncCordic::RTL_OUTPUT_DELAY
  `endif
)(
  input  pa_AsyncCordic::dual_rail_t a,
  input  pa_AsyncCordic::dual_rail_t b,
  input  pa_AsyncCordic::dual_rail_t c,

  input  logic                       arst,

  output pa_AsyncCordic::dual_rail_t s,
  output pa_AsyncCordic::dual_rail_t c_o
);

  pa_AsyncCordic::dual_rail_t carry = 2'b00;

  pa_AsyncCordic::dual_rail_t result;

  logic      start_o;

  logic C0_o;
  logic C1_o;
  logic C2_o;
  logic C3_o;
  logic C4_o;
  logic C5_o;
  logic C6_o;
  logic C7_o;

  logic gen;
  logic kill;

  logic finished;

  AsyncMullerCTree #(
    .WIDTH       (  3                                                                  )
  ) adderStart   (
    .treeInput   (  { a.data_0 ^ a.data_1, b.data_0 ^ b.data_1, c.data_1 ^ c.data_0 }  ),
    .arst_n      (  arst                                                               ),
    .treeOutput  (  start_o                                                            )
  );


  AsyncMullerCTree #(
  .WIDTH        (  4                                        ),
  .MODE         (  1                                        )
  ) u_AsyncMullerCTree_0                             (
    .treeInput  ( { a.data_0, b.data_0, c.data_0, start_o } ),
    .arst_n     (  arst                                     ),
    .treeOutput (  C0_o                                     )
  );

  AsyncMullerCTree #(
    .WIDTH      (  4                                        ),
    .MODE       (  1                                        )
  ) u_AsyncMullerCTree_1                             (
    .treeInput  ( { a.data_0, b.data_0, c.data_1, start_o } ),
    .arst_n     (  arst                                     ),
    .treeOutput (  C1_o                                     )
  );

  AsyncMullerCTree #(
    .WIDTH      (  4                                        ),
    .MODE       (  1                                        )
  ) u_AsyncMullerCTree_2                             (
    .treeInput  ( { a.data_0, b.data_1, c.data_0, start_o } ),
    .arst_n     (  arst                                     ),
    .treeOutput (  C2_o                                     )
  );

  AsyncMullerCTree #(
    .WIDTH      (  4                                        ),
    .MODE       (  1                                        )
  ) u_AsyncMullerCTree_3                             (
    .treeInput  ( { a.data_0, b.data_1, c.data_1, start_o } ),
    .arst_n     (  arst                                     ),
    .treeOutput (  C3_o                                     )
  );

  AsyncMullerCTree #(
    .WIDTH      (  4                                        ),
    .MODE       (  1                                        )
  ) u_AsyncMullerCTree_4                             (
    .treeInput  ( { a.data_1, b.data_0, c.data_0, start_o } ),
    .arst_n     (  arst                                     ),
    .treeOutput (  C4_o                                     )
  );

  AsyncMullerCTree #(
    .WIDTH      (  4                                        ),
    .MODE       (  1                                        )
  ) u_AsyncMullerCTree_5                             (
    .treeInput  ( { a.data_1, b.data_0, c.data_1, start_o } ),
    .arst_n     (  arst                                     ),
    .treeOutput (  C5_o                                     )
  );

  AsyncMullerCTree #(
    .WIDTH      (  4                                        ),
    .MODE       (  1                                        )
  ) u_AsyncMullerCTree_6                             (
    .treeInput  ( { a.data_1, b.data_1, c.data_0, start_o } ),
    .arst_n     (  arst                                     ),
    .treeOutput (  C6_o                                     )
  );

  AsyncMullerCTree #(
    .WIDTH      (  4                                        ),
    .MODE       (  1                                        )
  ) u_AsyncMullerCTree_7                             (
    .treeInput  ( { a.data_1, b.data_1, c.data_1, start_o } ),
    .arst_n     (  arst                                     ),
    .treeOutput (  C7_o                                     )
  );

  AsyncMullerC u_AsyncMullerC_kill      (
    .a          (  a.data_0 && start_o  ),
    .b          (  b.data_0 && start_o  ),
    .y          (  kill                 ),
    .arstn      (  arst                 ),
  );

  AsyncMullerC u_AsyncMullerC_generate  (
    .a          (  a.data_1 && start_o  ),
    .b          (  b.data_1 && start_o  ),
    .y          (  gen                  ),
    .arstn      (  arst                 ),
  );



  assign result.data_1 = C1_o || C2_o || C4_o || C7_o;
  assign result.data_0 = C0_o || C3_o || C5_o || C6_o;

  always_comb begin : reset
    if (~arst) begin
      carry = 2'b00;
    end else begin
      carry.data_1 = C3_o || C5_o || gen;
      carry.data_0 = C2_o || C4_o || kill;
    end
  end

  always @* begin
    `ifndef SYNTHESIS
      s   <= #RTL_OUTPUT_DELAY result;
      c_o <= #RTL_OUTPUT_DELAY carry;
    `else
      s   <= result;
      c_o <= carry;
    `endif
  end


endmodule


module AsyncAdder #(
  parameter int SIZE = pa_AsyncCordic::RW
)(
  input  pa_AsyncCordic::dual_rail_t[SIZE:0] a,
  input  pa_AsyncCordic::dual_rail_t[SIZE:0] b,
  input  pa_AsyncCordic::dual_rail_t         carry,

  input  logic                               arst,

  output pa_AsyncCordic::dual_rail_t[SIZE:0] data_o
);

  pa_AsyncCordic::dual_rail_t[SIZE + 1:0] carry_n;
  pa_AsyncCordic::dual_rail_t[SIZE:0]     carry_o;
  pa_AsyncCordic::dual_rail_t[SIZE:0]     b_xor;
  logic[SIZE:0]                           b_or;

  logic                                   spacers_a;
  logic                                   spacers_b;
  logic                                   all_zeroes;

  always_comb begin
    spacers_a  = (a == 0);
    spacers_b  = (b == 0);
    all_zeroes = spacers_a && spacers_b;
  end

  assign carry_n[0] = all_zeroes ? 2'b00 : carry;

  genvar i;
  generate
    for (i = 0; i <= SIZE; i++) begin

      always_comb begin
        b_or[i] = b[i].data_1 || b[i].data_0;

        if (b_or[i]) begin
          b_xor[i].data_0 <= b[i].data_0 ^ carry.data_1;
          b_xor[i].data_1 <= b[i].data_1 ^ carry.data_1;
        end else begin
          b_xor[i] <= 2'b00;
        end

      end

      AsyncAdderCore u_AsyncAdderCore (
        .a         (  a[i]            ),
        .b         (  b_xor[i]        ),
        .c         (  carry_n[i]      ),
        .arst      (  arst            ),
        .c_o       (  carry_o[i]      ),
        .s         (  data_o[i]       )
      );

      assign carry_n[i + 1] = all_zeroes ? 2'b00 : carry_o[i];

    end
  endgenerate

endmodule
