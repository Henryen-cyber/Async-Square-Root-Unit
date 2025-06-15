module AsyncCordic #(
  parameter int RW   = pa_AsyncCordic::RW,
  parameter int EW   = pa_AsyncCordic::EW,
  parameter int FW   = pa_AsyncCordic::FW,
  parameter int FP32 = pa_AsyncCordic::FP32
)(
  input  logic[FP32:0]                   data_i,
  input  logic                           ack_o,

  input  logic                           arst,

  output pa_AsyncCordic::fp_components_t data_o
);

  // asyncFP
  pa_AsyncCordic::dual_rail_t[EW:0] asyncFP_exp;
  pa_AsyncCordic::cordic_coord_t    asyncFP_rad;

  // expLatch
  pa_AsyncCordic::dual_rail_t[EW:0] expLatch_o;
  logic                             expLatch_ack;

  // asyncCordicCore
  pa_AsyncCordic::cordic_coord_t asyncCordicCore_o;
  logic                          asyncCordicCore_ack;

  // resultFork
  pa_AsyncCordic::dual_rail_t[RW:0] resultFork_x;
  pa_AsyncCordic::dual_rail_t[RW:0] resultFork_y;
  logic                             resultFork_ack;

  // ySink
  logic ySink_ack;

  // xLatch
  pa_AsyncCordic::dual_rail_t[RW:0] xLatch_o;
  logic                             xLatch_ack;

  // normalizeJoin
  pa_AsyncCordic::operand_t normalizeJoin_o;
  logic                     normalizeJoinRad_ack;
  logic                     normalizeJoinExp_ack;

  // finNorm
  pa_AsyncCordic::operand_t finNorm_o;
  logic                     finNorm_ack;

  // biasSource
  pa_AsyncCordic::dual_rail_t[EW:0] biasSource_o;

  // finFork
  pa_AsyncCordic::dual_rail_t[EW:0] finFork_exp;
  pa_AsyncCordic::dual_rail_t[RW:0] finFork_radicand;
  logic                             finFork_ack;

  // radicandLatch
  pa_AsyncCordic::dual_rail_t[RW:0] radicandLatch_o;
  logic                             radicandLatch_ack;

  // expBiasAddJoin
  pa_AsyncCordic::dual_rail_t[1:0][EW:0] expBiasAddJoin_o;
  logic[1:0]                             expBiasAddJoin_ack;

  // expBiasAdd
  pa_AsyncCordic::dual_rail_t[EW:0] expBiasAdd_o;

  // expBiasAddedLatch
  pa_AsyncCordic::dual_rail_t[EW:0] expBiasAddedLatch_o;
  logic                             expBiasAddedLatch_ack;

  // finJoin
  pa_AsyncCordic::operand_t finJoin_o;
  logic                     finJoinRad_ack;
  logic                     finJoinExp_ack;

  // finShift
  pa_AsyncCordic::dual_rail_t[RW:0] finShift_o;

  // finShiftLatch
  pa_AsyncCordic::dual_rail_t[RW:0] finShiftLatch_o;
  logic                             finShiftLatch_ack;

  // finCalcFork
  pa_AsyncCordic::dual_rail_t[1:0][RW:0] finCalcFork_o;
  logic                                  finCalcFork_ack;

  // finCalcShift
  pa_AsyncCordic::dual_rail_t[RW:0] finCalcShift_o;

  // finCalcShiftLatch
  pa_AsyncCordic::dual_rail_t[RW:0] finCalcShiftLatch_o;
  logic                             finCalcShiftLatch_ack;

  // finCalcLatch
  pa_AsyncCordic::dual_rail_t[RW:0] finCalcLatch_o;
  logic                             finCalcLatch_ack;

  // finCalcJoin
  pa_AsyncCordic::dual_rail_t[1:0][RW:0] finCalcJoin_o;
  logic[1:0]                             finCalcJoin_ack;

  // finCalcAdd
  pa_AsyncCordic::dual_rail_t[RW:0] finCalcAdd_o;

  // finCalcAddLatch
  pa_AsyncCordic::dual_rail_t[RW:0] finCalcAddLatch_o;
  logic                             finCalcAddLatch_ack;

  AsyncFP asyncFP                      (
    .data_i    (  data_i               ),
    .arst      (  arst                 ),
    .exp_ack   (  expLatch_ack         ),
    .data_ack  (  asyncCordicCore_ack  ),
    .exp_o     (  asyncFP_exp          ),
    .data_o    (  asyncFP_rad          )
  );

  AsyncLatch  #(
    .SIZE      ( EW                     )
  ) expLatch   (
    .data_i    (  asyncFP_exp           ),
    .ack_o     (  normalizeJoinExp_ack  ),
    .arst      (  arst                  ),
    .data_o    (  expLatch_o            ),
    .ack_i     (  expLatch_ack          )
  );

  AsyncCordicCore asyncCordicCore       (
    .data_i    (  asyncFP_rad           ),
    .ack_o     (  resultFork_ack        ),
    .arst      (  arst                  ),
    .data_o    (  asyncCordicCore_o     ),
    .ack_i     (  asyncCordicCore_ack   )
  );

  AsyncCordicCoordFork resultFork    (
    .data_i    (  asyncCordicCore_o  ),
    .x_ack     (  xLatch_ack         ),
    .y_ack     (  ySink_ack          ),
    .arst      (  arst               ),
    .data_x    (  resultFork_x       ),
    .data_y    (  resultFork_y       ),
    .ack_i     (  resultFork_ack     )
  );

  AsyncSink   #(
    .SIZE      (  RW            )
  ) ySink      (
    .data_i    (  resultFork_y  ),
    .arst      (  arst          ),
    .ack_i     (  ySink_ack     )
  );

  AsyncLatch  #(
    .SIZE      ( RW                     )
  ) xLatch     (
    .data_i    (  resultFork_x          ),
    .ack_o     (  finShiftLatch_ack     ),
    .arst      (  arst                  ),
    .data_o    (  xLatch_o              ),
    .ack_i     (  xLatch_ack            )
  );

  AsyncShift    #(
    .SIZE        (  RW          ),
    .SHIFT       (  1           )
  ) finShift     (
    .data_i      (  xLatch_o    ),
    .shift_amnt  (  2'd2        ),
    .data_o      (  finShift_o  )
  );

  AsyncLatch  #(
    .SIZE      (  RW                 )
  ) finShiftLatch                    (
    .data_i    (  finShift_o         ),
    .ack_o     (  finCalcFork_ack    ),
    .arst      (  arst               ),
    .data_o    (  finShiftLatch_o    ),
    .ack_i     (  finShiftLatch_ack  )
  );

  AsyncFork   #(
    .SIZE      (  RW                         ),
    .WIDTH     (  1                          )
  ) finCalcFork                              (
    .data_i    (  finShiftLatch_o            ),
    .ack_o     (  { finCalcAddLatch_ack,
                    finCalcShiftLatch_ack }  ),
    .arst      (  arst                       ),
    .data_o    (  finCalcFork_o              ),
    .ack_i     (  finCalcFork_ack            )
  );

  AsyncLeftShift #(
    .SHIFT     (  2                  )
  ) finCalcShift                     (
    .data_i    (  finCalcFork_o[0]   ),
    .arst      (  arst               ),
    .data_o    (  finCalcShift_o     )
  );

  AsyncLatch  #(
    .SIZE      (  RW                     )
  ) finCalcShiftLatch                    (
    .data_i    (  finCalcShift_o         ),
    .ack_o     (  finCalcJoin_ack[0]     ),
    .arst      (  arst                   ),
    .data_o    (  finCalcShiftLatch_o    ),
    .ack_i     (  finCalcShiftLatch_ack  )
  );

  AsyncLatch  #(
    .SIZE      (  RW                  )
  ) finCalcLatch                      (
    .data_i    (  finCalcFork_o[1]    ),
    .ack_o     (  finCalcJoin_ack[1]  ),
    .arst      (  arst                ),
    .data_o    (  finCalcLatch_o      ),
    .ack_i     (  finCalcLatch_ack    )
  );

  AsyncJoin   #(
    .SIZE      (  RW                       ),
    .WIDTH     (  1                        )
  ) finCalcJoin                            (
    .data_i    (  { finCalcLatch_o,
                    finCalcShiftLatch_o }  ),
    .ack_o     (  finCalcAddLatch_ack      ),
    .ack_i     (  finCalcJoin_ack          ),
    .data_o    (  finCalcJoin_o            )
  );

  AsyncAdder  finCalcAdd  (
    .a         (  finCalcJoin_o[0]  ),
    .b         (  finCalcJoin_o[1]  ),
    .carry     (  2'b10             ),
    .arst      (  arst              ),
    .data_o    (  finCalcAdd_o      )
  );

  AsyncLatch  #(
    .SIZE      (  RW                    )
  ) finCalcAddLatch                     (
    .data_i    (  finCalcAdd_o          ),
    .ack_o     (  normalizeJoinRad_ack  ),
    .arst      (  arst                  ),
    .data_o    (  finCalcAddLatch_o     ),
    .ack_i     (  finCalcAddLatch_ack   )
  );

  AsyncOperandJoin normalizeJoin            (
    .radicand      (  finCalcAddLatch_o     ),
    .exp           (  expLatch_o            ),
    .operand_ack   (  finNorm_ack           ),
    .operand       (  normalizeJoin_o       ),
    .exp_ack       (  normalizeJoinExp_ack  ),
    .radicand_ack  (  normalizeJoinRad_ack  )
  );

  AsyncFPNormalize  finNorm        (
    .data_i    (  normalizeJoin_o  ),
    .ack_o     (  ack_o            ),
    .arst      (  arst             ),
    .ack_i     (  finNorm_ack      ),
    .data_o    (  finNorm_o        )
  );

  AsyncSource #(
    .SIZE      (  EW                     )
  ) biasSource                           (
    .data_i    (  8'd127                 ),
    .ack_i     (  expBiasAddJoin_ack[0]  ),
    .data_o    (  biasSource_o           )
  );

  AsyncOperandFork finFork (
    .operand       (  finNorm_o              ),
    .exp_ack       (  expBiasAddJoin_ack[1]  ),
    .radicand_ack  (  radicandLatch_ack      ),
    .arst          (  arst                   ),
    .exp           (  finFork_exp            ),
    .radicand      (  finFork_radicand       ),
    .ack_i         (  finFork_ack            )
  );

  AsyncLatch  #(
    .SIZE      (  RW                 )
  ) radicandLatch                    (
    .data_i    (  finFork_radicand   ),
    .ack_o     (  finJoinRad_ack     ),
    .arst      (  arst               ),
    .data_o    (  radicandLatch_o    ),
    .ack_i     (  radicandLatch_ack  )
  );

  AsyncJoin  #(
    .SIZE     (  EW                     ),
    .WIDTH    (  1                      )
  ) expBiasAddJoin                      (
    .data_i   (  { finFork_exp,
                   biasSource_o }       ),
    .ack_o    (  expBiasAddedLatch_ack  ),
    .ack_i    (  expBiasAddJoin_ack     ),
    .data_o   (  expBiasAddJoin_o       )
  );

  AsyncAdder #(
    .SIZE     (  EW                    )
  ) expBiasAdd                         (
    .a         (  expBiasAddJoin_o[0]  ),
    .b         (  expBiasAddJoin_o[1]  ),
    .carry     (  2'b10                ),
    .arst      (  arst                 ),
    .data_o    (  expBiasAdd_o         )
  );

  AsyncLatch  #(
    .SIZE      (  EW                     )
  ) expBiasAddedLatch                    (
    .data_i    (  expBiasAdd_o           ),
    .ack_o     (  finJoinExp_ack         ),
    .arst      (  arst                   ),
    .data_o    (  expBiasAddedLatch_o    ),
    .ack_i     (  expBiasAddedLatch_ack  )
  );

  AsyncOperandJoin finJoin                 (
    .radicand      (  radicandLatch_o      ),
    .exp           (  expBiasAddedLatch_o  ),
    .operand_ack   (  ack_o                ),
    .operand       (  finJoin_o            ),
    .exp_ack       (  finJoinExp_ack       ),
    .radicand_ack  (  finJoinRad_ack       )
  );

  assign data_o.fraction = finJoin_o.radicand[RW - 2:3];
  assign data_o.exp      = finJoin_o.exp;

endmodule
