module AsyncFP #(
  parameter int RW   = pa_AsyncCordic::RW,
  parameter int EW   = pa_AsyncCordic::EW,
  parameter int FW   = pa_AsyncCordic::FW,
  parameter int FP32 = pa_AsyncCordic::FP32
)(
  input  logic[FP32:0]                     data_i,
  input  logic                             exp_ack,
  input  logic                             data_ack,

  input  logic                             arst,


  output pa_AsyncCordic::dual_rail_t[EW:0] exp_o,
  output pa_AsyncCordic::cordic_coord_t    data_o
);

  localparam FORTH = pa_AsyncCordic::FORTH;

  // operandSource
  pa_AsyncCordic::dual_rail_t[FP32 - 1:0] operandSource_o;

  // biasSource
  pa_AsyncCordic::dual_rail_t[EW:0] biasSource_o;

  // operandFork
  pa_AsyncCordic::dual_rail_t[EW:0]   operandFork_exp;
  pa_AsyncCordic::dual_rail_t[FW:0]   operandFork_frac;
  logic                               operandFork_ack;

  // expBiasedLatch
  pa_AsyncCordic::dual_rail_t[EW:0] expBiasedLatch_o;
  logic                             expBiasedLatch_ack;

  // fracLatch
  pa_AsyncCordic::dual_rail_t[FW:0] fracLatch_o;
  logic                             fracLatch_ack;

  // expFork
  pa_AsyncCordic::dual_rail_t[1:0][EW:0] expFork_o;
  logic                                  expFork_ack;

  // equalZeroLatch
  pa_AsyncCordic::dual_rail_t[EW:0] equalZeroLatch_o;
  logic                             equalZeroLatch_ack;

  // needNameLatch
  pa_AsyncCordic::dual_rail_t[EW:0] needNameLatch_o;
  logic                             needNameLatch_ack;

  // expEqualZero
  pa_AsyncCordic::dual_rail_t equalZero_o;
  logic                       equalZero_ack;

  // equalZeroFork
  pa_AsyncCordic::dual_rail_t[1:0] equalZeroFork_o;
  logic                            equalZeroFork_ack;

  // equalZeroCtrlLatch
  pa_AsyncCordic::dual_rail_t equalZeroCtrlLatch_o;
  logic                       equalZeroCtrlLatch_ack;

  // equalZeroCtrlFork
  pa_AsyncCordic::dual_rail_t[1:0] equalZeroCtrlFork_o;
  logic                            equalZeroCtrlFork_ack;

  // DEMUXctrlLatch
  pa_AsyncCordic::dual_rail_t DEMUXctrlLatch_o;
  logic                       DEMUXctrlLatch_ack;

  // MUXctrlLatch
  pa_AsyncCordic::dual_rail_t MUXctrlLatch_o;
  logic                       MUXctrlLatch_ack;

  // expBiasJoin
  pa_AsyncCordic::dual_rail_t[1:0][EW:0] expBiasJoin_o;
  logic[1:0]                             expBiasJoin_ack;

  // expBiasLatch
  pa_AsyncCordic::dual_rail_t[1:0][EW:0] expBiasLatch_o;
  logic                                  expBiasLatch_ack;

  // expSubtract
  pa_AsyncCordic::dual_rail_t[EW:0] expSubtract_o;

  // expLatch
  pa_AsyncCordic::dual_rail_t[EW:0] expLatch_o;
  logic                             expLatch_ack;

  // normalSource
  pa_AsyncCordic::dual_rail_t[1:0] normalSource_o;

  // subnormalSource
  pa_AsyncCordic::dual_rail_t[1:0] subnormalSource_o;

  // accBitsSource
  pa_AsyncCordic::dual_rail_t[4:0] accBitsSource_o;

  // hiddenBitMUX
  pa_AsyncCordic::dual_rail_t[1:0] hiddenBitMUX_o;
  logic                            hiddenBitMUX_01ack;
  logic                            hiddenBitMUX_10ack;
  logic                            hiddenBitMUX_ctrlack;

  //hiddenBitLatch
  pa_AsyncCordic::dual_rail_t[1:0] hiddenBitLatch_o;
  logic                            hiddenBitLatch_ack;

  // hiddenBitJoin
  pa_AsyncCordic::dual_rail_t[RW:0] hiddenBitJoin_o;
  logic                             hiddenBitJoinHiddenBit_ack;
  logic                             hiddenBitJoinFrac_ack;
  logic                             hiddenBitJoinAccBits_ack;

  //radLatch
  pa_AsyncCordic::dual_rail_t[RW:0] radLatch_o;
  logic                             radLatch_ack;

  // operandJoin
  pa_AsyncCordic::operand_t operandJoin_o;
  logic                     operandJoinExp_ack;
  logic                     operandJoinRad_ack;

  // operandLatch
  pa_AsyncCordic::operand_t operandLatch_o;
  logic                     operandLatch_ack;

  // operandDEMUX
  pa_AsyncCordic::operand_t operandDEMUX_01;
  pa_AsyncCordic::operand_t operandDEMUX_10;
  logic                     operandDEMUX_ack;
  logic                     operandDEMUX_ctrlack;

  // operandNorm
  pa_AsyncCordic::operand_t operandNorm_o;
  logic                     operandNorm_ack;

  // operandMUX
  pa_AsyncCordic::operand_t operandMUX_o;
  logic                     operandMUX_01ack;
  logic                     operandMUX_10ack;
  logic                     operandMUX_ctrlack;

  // operandNormLatch
  pa_AsyncCordic::operand_t operandNormLatch_o;
  logic                     operandNormLatch_ack;

  // operandAlignFork
  pa_AsyncCordic::dual_rail_t[EW:0] operandAlignFork_exp;
  pa_AsyncCordic::dual_rail_t[RW:0] operandAlignFork_rad;
  logic                             operandAlignFork_ack;

  // alignExpLatch
  pa_AsyncCordic::dual_rail_t[EW:0] alignExpLatch_o;
  logic                             alignExpLatch_ack;

  // alignRadLatch
  pa_AsyncCordic::dual_rail_t[RW:0] alignRadLatch_o;
  logic                             alignRadLatch_ack;

  // alignExpFork
  pa_AsyncCordic::dual_rail_t[1:0][EW:0] alignExpFork_o;
  logic                                  alignExpFork_ack;

  // alignCtrlFork
  pa_AsyncCordic::dual_rail_t[3:0] alignCtrlFork_o;
  logic                            alignCtrlFork_ack;

  // alignExpDEMUX
  pa_AsyncCordic::dual_rail_t[EW:0] alignExpDEMUX_01;
  pa_AsyncCordic::dual_rail_t[EW:0] alignExpDEMUX_10;
  logic                             alignExpDEMUX_ctrlack;
  logic                             alignExpDEMUX_ack;

  // oneSource
  pa_AsyncCordic::dual_rail_t[EW:0] oneSource_o;

  // alignExpJoin
  pa_AsyncCordic::dual_rail_t[1:0][EW:0] alignExpJoin_o;
  logic[1:0]                             alignExpJoin_ack;

  // alignExpAdd
  pa_AsyncCordic::dual_rail_t[EW:0] alignExpAdd_o;

  // alignExpAddLatch
  pa_AsyncCordic::dual_rail_t[EW:0] expAddLatch_o;
  logic                             expAddLatch_ack;

  // alignExpMUX
  pa_AsyncCordic::dual_rail_t[EW:0] alignExpMUX_o;
  logic                             alignExpMUX_01ack;
  logic                             alignExpMUX_10ack;
  logic                             alignExpMUX_ctrlack;

  // expShift
  pa_AsyncCordic::dual_rail_t[EW:0] expShift_o;

  // expFinLatch
  pa_AsyncCordic::dual_rail_t[EW:0] expFinLatch_o;
  logic                             expFinLatch_ack;

  // alignRadDEMUX
  pa_AsyncCordic::dual_rail_t[RW:0] alignRadDEMUX_01;
  pa_AsyncCordic::dual_rail_t[RW:0] alignRadDEMUX_10;
  logic                             alignRadDEMUX_ack;
  logic                             alignRadDEMUX_ctrlack;

  // alignRadShift
  pa_AsyncCordic::dual_rail_t[RW:0] alignRadShift_o;

  // radShiftLatch
  pa_AsyncCordic::dual_rail_t[RW:0] radShiftLatch_o;
  logic                             radShiftLatch_ack;

  // alignRadMUX
  pa_AsyncCordic::dual_rail_t[RW:0] alignRadMUX_o;
  logic                             alignRadMUX_01ack;
  logic                             alignRadMUX_10ack;
  logic                             alignRadMUX_ctrlack;

  // radFinLatch
  pa_AsyncCordic::dual_rail_t[RW:0] radFinLatch_o;
  logic                             radFinLatch_ack;

  // cordicInitFork
  pa_AsyncCordic::dual_rail_t[1:0][RW:0] cordicInitFork_o;
  logic                                  cordicInitFork_ack;

  // forthSource
  pa_AsyncCordic::dual_rail_t[RW:0] forthSource_o;

  // forthFork
  pa_AsyncCordic::dual_rail_t[1:0][RW:0] forthFork_o;
  logic                                  forthFork_ack;

  // x0Join
  pa_AsyncCordic::dual_rail_t[1:0][RW:0] x0Join_o;
  logic[1:0]                             x0Join_ack;

  // y0Join
  pa_AsyncCordic::dual_rail_t[1:0][RW:0] y0Join_o;
  logic[1:0]                             y0Join_ack;

  // x0Add
  pa_AsyncCordic::dual_rail_t[RW:0] x0Add_o;

  //x0Latch
  pa_AsyncCordic::dual_rail_t[RW:0] x0Latch_o;
  logic                             x0Latch_ack;

  // y0Subtract
  pa_AsyncCordic::dual_rail_t[RW:0] y0Subtract_o;

  //x0Latch
  pa_AsyncCordic::dual_rail_t[RW:0] y0Latch_o;
  logic                             y0Latch_ack;

  // cordicInitJoin
  pa_AsyncCordic::cordic_coord_t cordicInitJoin_o;
  logic                          cordicInitJoinY_ack;
  logic                          cordicInitJoinX_ack;

  // cordicInitLatch
  logic cordicInitLatch_ack;

  AsyncOperandSource operandSource (
    // INPUTS
    .data_i    (  data_i           ),
    .ack_i     (  operandFork_ack  ),
    // OUTPUTS
    .data_o    (  operandSource_o  )
  );

  AsyncSource #(
    .SIZE      (  EW                  )
  ) biasSource (
    // INPUTS
    .data_i    (  8'd127              ),
    .ack_i     (  expBiasJoin_ack[0]  ),
    // OUTPUTS
    .data_o    (  biasSource_o        )
  );

  AsyncFPFork operandFork                  (
    //INPUTS
    .fp32           (  operandSource_o     ),
    .exp_ack        (  expBiasedLatch_ack  ),
    .fraction_ack   (  fracLatch_ack       ),
    .arst           (  arst                ),
    //OUTPUTS
    .exp            (  operandFork_exp     ),
    .fraction       (  operandFork_frac    ),
    .ack_i          (  operandFork_ack     )
  );

  AsyncLatch  #(
    .SIZE      (  EW                  )
  ) expBiasedLatch                    (
    .data_i    (  operandFork_exp     ),
    .ack_o     (  expFork_ack         ),
    .arst      (  arst                ),
    .data_o    (  expBiasedLatch_o    ),
    .ack_i     (  expBiasedLatch_ack  )
  );

  AsyncLatch  #(
    .SIZE      (  FW                     )
  ) fracLatch  (
    .data_i    (  operandFork_frac       ),
    .ack_o     (  hiddenBitJoinFrac_ack  ),
    .arst      (  arst                   ),
    .data_o    (  fracLatch_o            ),
    .ack_i     (  fracLatch_ack          )
  );

  AsyncFork   #(
    .SIZE      (  EW                      ),
    .WIDTH     (  1                       )
  ) expFork    (
    // INPUTS
    .data_i    (  expBiasedLatch_o         ),
    .ack_o     (  { needNameLatch_ack,
                    equalZeroLatch_ack }  ),
    .arst      (  arst                    ),
    // OUTPUTS
    .data_o    (  expFork_o               ),
    .ack_i     (  expFork_ack             )
  );

  AsyncLatch  #(
    .SIZE      (  EW                  )
  ) equalZeroLatch                    (
    .data_i    (  expFork_o[1]        ),
    .ack_o     (  equalZero_ack       ),
    .arst      (  arst                ),
    .data_o    (  equalZeroLatch_o    ),
    .ack_i     (  equalZeroLatch_ack  )
  );

  AsyncLatch  #(
    .SIZE      (  EW                  )
  ) needNameLatch                     (
    .data_i    (  expFork_o[0]        ),
    .ack_o     (  expBiasJoin_ack[1]  ),
    .arst      (  arst                ),
    .data_o    (  needNameLatch_o     ),
    .ack_i     (  needNameLatch_ack   )
  );

  AsyncEqualZero expEqualZero        (
    // INPUTS
    .exponent  (  equalZeroLatch_o   ),
    .ctrl_ack  (  equalZeroFork_ack  ),
    .arst      (  arst               ),
    // OUTPUTS
    .ctrl      (  equalZero_o        ),
    .ack_i     (  equalZero_ack      )
  );

  AsyncFork   #(
    .SIZE      (  0                          ),
    .WIDTH     (  1                          )
  ) equalZeroFork                            (
    // INPUTS
    .data_i    (  equalZero_o                ),
    .ack_o     ( { hiddenBitMUX_ctrlack,
                   equalZeroCtrlLatch_ack }  ),
    .arst      (  arst                       ),
    // OUTPUTS
    .data_o    (  equalZeroFork_o            ),
    .ack_i     (  equalZeroFork_ack          )
  );

  AsyncLatch  #(
    .SIZE      (    0                     )
  ) equalZeroCtrlLatch                    (
    .data_i    (  equalZeroFork_o[1]      ),
    .ack_o     (  equalZeroCtrlFork_ack   ),
    .arst      (  arst                    ),
    .data_o    (  equalZeroCtrlLatch_o    ),
    .ack_i     (  equalZeroCtrlLatch_ack  )
  );

  AsyncFork   #(
    .SIZE      (  0   ),
    .WIDTH     (  1   )
  ) equalZeroCtrlFork  (
    .data_i    (  equalZeroCtrlLatch_o        ),
    .ack_o     (  {  DEMUXctrlLatch_ack,
                     MUXctrlLatch_ack    }    ),
    .arst      (  arst                        ),
    .data_o    (  equalZeroCtrlFork_o         ),
    .ack_i     (  equalZeroCtrlFork_ack       )
  );

  AsyncLatch  #(
    .SIZE      (  0                       )
  ) DEMUXctrlLatch                        (
    .data_i    (  equalZeroCtrlFork_o[1]  ),
    .ack_o     (  operandDEMUX_ctrlack    ),
    .arst      (  arst                    ),
    .data_o    (  DEMUXctrlLatch_o        ),
    .ack_i     (  DEMUXctrlLatch_ack      )
  );

  AsyncLatch  #(
    .SIZE      (  0                       )
  ) MUXctrlLatch                          (
    .data_i    (  equalZeroCtrlFork_o[0]  ),
    .ack_o     (  operandMUX_ctrlack      ),
    .arst      (  arst                    ),
    .data_o    (  MUXctrlLatch_o          ),
    .ack_i     (  MUXctrlLatch_ack        )
  );

  AsyncJoin #(
    .SIZE    (  EW                   ),
    .WIDTH   (  1                    )
  ) expBiasJoin                      (
    // INPUTS
    .ack_o   (  expBiasLatch_ack     ),
    .data_i  (  { biasSource_o,
                  needNameLatch_o }  ),
    // OUTPUTS
    .ack_i   (  expBiasJoin_ack      ),
    .data_o  (  expBiasJoin_o        )
  );

  AsyncLatch  #(
    .SIZE      (  (2 * EW) + 1     )
  ) expBiasLatch                   (
    .data_i    (  expBiasJoin_o    ),
    .ack_o     (  expLatch_ack     ),
    .arst      (  arst             ),
    .data_o    (  expBiasLatch_o   ),
    .ack_i     ( expBiasLatch_ack  )
  );

  AsyncAdder  #(
    .SIZE      (  EW                )
  ) expSubtract(
    // INPUTS
    .a         (  expBiasLatch_o[0]  ),
    .b         (  expBiasLatch_o[1]  ),
    .carry     (  2'b01              ),
    .arst      (  arst               ),
    // OUTPUTS
    .data_o    (  expSubtract_o      )
  );

  AsyncLatch  #(
    .SIZE      (  EW                  )
  ) expLatch   (
    // INPUTS
    .data_i    (  expSubtract_o       ),
    .ack_o     (  operandJoinExp_ack  ),
    .arst      (  arst                ),
    // OUTPUTS
    .data_o    (  expLatch_o          ),
    .ack_i     (  expLatch_ack        )
  );

  AsyncNormalSource normalSource      (
    .ack_i     (  hiddenBitMUX_10ack  ),
    .hiddenBit (  normalSource_o      )
  );

  AsyncSubnormalSource subnormalSource (
    .ack_i      (  hiddenBitMUX_01ack  ),
    .hiddenBit  (  subnormalSource_o   )
  );

  AsyncAccBitsSource accBitsSource         (
    .ack_i    (  hiddenBitJoinAccBits_ack  ),
    .accBits  (  accBitsSource_o           )
  );

  AsyncMUX    #(
    .SIZE      (  1                     )
  ) hiddenBitMUX                        (
    // INPUTS
    .data_x    (  subnormalSource_o     ), // 1
    .data_y    (  normalSource_o        ), // 0
    .ctrl      (  equalZeroFork_o[0]    ),
    .z_ack     (  hiddenBitLatch_ack    ),
    .arst      (  arst                  ),
    // OUTPUTS
    .x_ack     (  hiddenBitMUX_01ack    ),  // input 1
    .y_ack     (  hiddenBitMUX_10ack    ),  // input 0
    .ctrl_ack  (  hiddenBitMUX_ctrlack  ),
    .data_z    (  hiddenBitMUX_o        )
  );

  AsyncLatch   #(
    .SIZE      (  1                           )
  ) hiddenBitLatch                            (
    .data_i    (  hiddenBitMUX_o              ),
    .ack_o     (  hiddenBitJoinHiddenBit_ack  ),
    .arst      (  arst                        ),
    .data_o    (  hiddenBitLatch_o            ),
    .ack_i     (  hiddenBitLatch_ack          )
  );

  AsyncHiddenBitJoin hiddenBitJoin                 (
    .hiddenBit      (  hiddenBitLatch_o            ),
    .fraction       (  fracLatch_o                 ),
    .accBits        (  accBitsSource_o             ),
    .ack_i          (  radLatch_ack                ),
    .hiddenBit_ack  (  hiddenBitJoinHiddenBit_ack  ),
    .fraction_ack   (  hiddenBitJoinFrac_ack       ),
    .accBits_ack    (  hiddenBitJoinAccBits_ack    ),
    .radicand       (  hiddenBitJoin_o             )
  );

  AsyncLatch  #(
    .SIZE      (  RW                  )
  ) radLatch   (
    .data_i    (  hiddenBitJoin_o     ),
    .ack_o     (  operandJoinRad_ack  ),
    .arst      (  arst                ),
    .data_o    (  radLatch_o          ),
    .ack_i     (  radLatch_ack        )
  );

  AsyncOperandJoin operandJoin            (
    // INPUTS
    .radicand      (  radLatch_o          ),
    .exp           (  expLatch_o          ),
    .operand_ack   (  operandLatch_ack    ),
    // OUTPUTS
    .operand       (  operandJoin_o       ),
    .exp_ack       (  operandJoinExp_ack  ),
    .radicand_ack  (  operandJoinRad_ack  )
  );

  AsyncOperandLatch  operandLatch    (
    .data_i     (  operandJoin_o     ),
    .ack_o      (  operandDEMUX_ack  ),
    .arst       (  arst              ),
    .data_o     (  operandLatch_o    ),
    .ack_i      (  operandLatch_ack  )
  );

  AsyncOperandDEMUX operandDEMUX        (
    // INPUTS
    .data_x    (  operandLatch_o        ),
    .ctrl      (  DEMUXctrlLatch_o      ),
    .y_ack     (  operandNorm_ack       ),
    .z_ack     (  operandMUX_10ack      ),
    .arst      (  arst                  ),
    // OUTPUTS
    .data_y    (  operandDEMUX_01       ),
    .data_z    (  operandDEMUX_10       ),
    .x_ack     (  operandDEMUX_ack      ),
    .ctrl_ack  (  operandDEMUX_ctrlack  )
  );

  AsyncFPNormalize operandNorm      (
    // INPUTS
    .data_i    (  operandDEMUX_01   ),
    .ack_o     (  operandMUX_01ack  ),
    .arst      (  arst              ),
    // OUTPUTS
    .ack_i     (  operandNorm_ack   ),
    .data_o    (  operandNorm_o     )
  );

  AsyncOperandMUX operandMUX            (
    // INPUTS
    .data_x    (  operandNorm_o         ),
    .data_y    (  operandDEMUX_10       ),
    .ctrl      (  MUXctrlLatch_o        ),
    .z_ack     (  operandNormLatch_ack  ),
    .arst      (  arst                  ),
    //OUTPUTS
    .x_ack     (  operandMUX_01ack      ),
    .y_ack     (  operandMUX_10ack      ),
    .ctrl_ack  (  operandMUX_ctrlack    ),
    .data_z    (  operandMUX_o          )
  );

  AsyncOperandLatch operandNormLatch    (
    .data_i    (  operandMUX_o          ),
    .ack_o     (  operandAlignFork_ack  ),
    .arst      (  arst                  ),
    .data_o    (  operandNormLatch_o    ),
    .ack_i     (  operandNormLatch_ack  )
  );

  AsyncOperandFork operandAlignFork         (
    // INPUTS
    .operand       (  operandNormLatch_o    ),
    .exp_ack       (  alignExpLatch_ack     ),
    .radicand_ack  (  alignRadLatch_ack     ),
    .arst          (  arst                  ),
    // OUTPUTS
    .exp           (  operandAlignFork_exp  ),
    .radicand      (  operandAlignFork_rad  ),
    .ack_i         (  operandAlignFork_ack  )
  );

  AsyncLatch  #(
    .SIZE      (  EW                    )
  ) alignExpLatch                       (
    .data_i    (  operandAlignFork_exp  ),
    .ack_o     (  alignExpFork_ack      ),
    .arst      (  arst                  ),
    .data_o    (  alignExpLatch_o       ),
    .ack_i     (  alignExpLatch_ack     )
  );

  AsyncLatch  #(
    .SIZE      (  RW                    )
  ) alignRadLatch                       (
    .data_i    (  operandAlignFork_rad  ),
    .ack_o     (  alignRadDEMUX_ack     ),
    .arst      (  arst                  ),
    .data_o    (  alignRadLatch_o       ),
    .ack_i     (  alignRadLatch_ack     )
  );

  AsyncFork   #(
    .SIZE      (  EW                     ),
    .WIDTH     (  1                      )
  ) alignExpFork                         (
    // INPUTS
    .data_i    (  alignExpLatch_o        ),
    .ack_o     (  { alignExpDEMUX_ack,
                    alignCtrlFork_ack }  ),
    .arst      (  arst                   ),
    // OUTPUTS
    .data_o    (  alignExpFork_o         ),
    .ack_i     (  alignExpFork_ack       )
  );

  AsyncFork   #(
    .SIZE      (  0                        ),
    .WIDTH     (  3                        )
  ) alignCtrlFork                          (
    // INPUTS
    .data_i    (  alignExpFork_o[0][0]     ),
    .ack_o     (  { alignExpDEMUX_ctrlack,
                    alignExpMUX_ctrlack,
                    alignRadDEMUX_ctrlack,
                    alignRadMUX_ctrlack }  ),
    .arst      (  arst                     ),
    // OUTPUTS
    .data_o    (  alignCtrlFork_o          ),
    .ack_i     (  alignCtrlFork_ack        )
  );

  AsyncDEMUX  #(
    .SIZE      (  EW                     )
  ) alignExpDEMUX                        (
    // INPUTS
    .data_x    (  alignExpFork_o[1]      ),
    .ctrl      (  alignCtrlFork_o[0]     ),
    .y_ack     (  alignExpJoin_ack[0]    ),
    .z_ack     (  alignExpMUX_10ack      ),
    .arst      (  arst                   ),
    // OUTPUTS
    .data_y    (  alignExpDEMUX_01       ),
    .data_z    (  alignExpDEMUX_10       ),
    .x_ack     (  alignExpDEMUX_ack      ),
    .ctrl_ack  (  alignExpDEMUX_ctrlack  )
  );

  AsyncSource #(
    .SIZE      (  EW                   )
  ) oneSouce   (
    .data_i    (  8'h01                ),
    .ack_i     (  alignExpJoin_ack[1]  ),
    .data_o    (  oneSource_o          )
  );

  AsyncJoin   #(
    .SIZE      (  EW                     ),
    .WIDTH     (  1                      )
  ) alignExpJoin                         (
    .ack_o     (  expAddLatch_ack        ),
    .data_i    (  { alignExpDEMUX_01,
                    oneSource_o       }  ),
    .ack_i     (  alignExpJoin_ack       ),
    .data_o    (  alignExpJoin_o         )
  );

  AsyncAdder  #(
    .SIZE      (  EW                )
  ) alignExpAdd(
    // INPUTS
    .a         (  alignExpJoin_o[1]  ),
    .b         (  alignExpJoin_o[0]  ),
    .carry     (  2'b10              ), // 0 carry
    .arst      (  arst               ),
    // OUTPUTS
    .data_o    (  alignExpAdd_o      )
  );

  AsyncLatch  #(
    .SIZE      (  EW                 )
  ) expAddLAtch                      (
    .data_i    (  alignExpAdd_o      ),
    .ack_o     (  alignExpMUX_01ack  ),
    .arst      (  arst               ),
    .data_o    (  expAddLatch_o      ),
    .ack_i     (  expAddLatch_ack    )
  );

  AsyncMUX    #(
    .SIZE      (  EW                   )
  ) alignExpMUX(
    // INPUTS
    .data_x    (  expAddLatch_o        ),
    .data_y    (  alignExpDEMUX_10     ),
    .ctrl      (  alignCtrlFork_o[1]   ),
    .z_ack     (  expFinLatch_ack      ),
    .arst      (  arst                 ),
    // OUTPUTS
    .x_ack     (  alignExpMUX_01ack    ),
    .y_ack     (  alignExpMUX_10ack    ),
    .ctrl_ack  (  alignExpMUX_ctrlack  ),
    .data_z    (  alignExpMUX_o        )
  );

  AsyncShift #(
    .SIZE        (  EW             ),
    .SHIFT       (  0              )
  ) expShift     (
    .data_i      (  alignExpMUX_o  ),
    .shift_amnt  (  1'b1           ),
    .data_o      (  expShift_o     )
  );

  AsyncLatch   #(
    .SIZE       (  EW               )
  ) expFinLatch (
    // INPUTS
    .data_i     (  expShift_o       ),
    .ack_o      (  exp_ack          ),
    .arst       (  arst             ),
    // OUTPUTS
    .data_o     (  exp_o            ),
    .ack_i      (  expFinLatch_ack  )
  );

  AsyncDEMUX  #(
    .SIZE      (  RW                     )
  ) alignRadDEMUX                        (
    // INPUTS
    .data_x    (  alignRadLatch_o        ),
    .ctrl      (  alignCtrlFork_o[2]     ),
    .y_ack     (  radShiftLatch_ack      ),
    .z_ack     (  alignRadMUX_10ack      ),
    .arst      (  arst                   ),
    // OUTPUTS
    .data_y    (  alignRadDEMUX_01       ),
    .data_z    (  alignRadDEMUX_10       ),
    .x_ack     (  alignRadDEMUX_ack      ),
    .ctrl_ack  (  alignRadDEMUX_ctrlack  )
  );

  AsyncShift    #(
    .SIZE        (  RW                ),
    .SHIFT       (  1                 )
  ) alignRadShift(
    // INPUTS
    .data_i      (  alignRadDEMUX_01  ),
    .shift_amnt  (  2'b01             ),
    // OUTPUTS
    .data_o      (  alignRadShift_o   )
  );

  AsyncLatch  #(
    .SIZE      (  RW                 )
  ) radShiftLatch                    (
    // INPUTS
    .data_i    (  alignRadShift_o    ),
    .ack_o     (  alignRadMUX_01ack  ),
    .arst      (  arst               ),
    // OUTPUTS
    .data_o    (  radShiftLatch_o    ),
    .ack_i     (  radShiftLatch_ack  )
  );

  AsyncMUX    #(
    .SIZE      (  RW                   )
  ) alignRadMUX(
    // INPUTS
    .data_x    (  radShiftLatch_o      ),
    .data_y    (  alignRadDEMUX_10     ),
    .ctrl      (  alignCtrlFork_o[3]   ),
    .z_ack     (  radFinLatch_ack      ),
    .arst      (  arst                 ),
    // OUTPUTS
    .x_ack     (  alignRadMUX_01ack    ),
    .y_ack     (  alignRadMUX_10ack    ),
    .ctrl_ack  (  alignRadMUX_ctrlack  ),
    .data_z    (  alignRadMUX_o        )
  );

  AsyncLatch  #(
    .SIZE      (  RW                  )
  ) radFinLatch(
    // INPUTS
    .data_i    (  alignRadMUX_o       ),
    .ack_o     (  cordicInitFork_ack  ),
    .arst      (  arst                ),
    // OUTPUTS
    .data_o    (  radFinLatch_o       ),
    .ack_i     (  radFinLatch_ack     )
  );

  AsyncFork #(
    .SIZE      ( RW                   ),
    .WIDTH     (  1                   )
  ) cordicInitFork                    (
    // INPUTS
    .data_i    (  radFinLatch_o       ),
    .ack_o     (  { x0Join_ack[0],
                    y0Join_ack[1] }   ),
    .arst      (  arst                ),
    // OUTPUTS
    .data_o    (  cordicInitFork_o    ),
    .ack_i     (  cordicInitFork_ack  )
  );

  AsyncSource #(
    .SIZE      (  RW             )
  )  forthSource                 (
    // INPUTS
    .data_i    (  FORTH          ),
    .ack_i     (  forthFork_ack  ),
    // OUTPUTS
    .data_o    (  forthSource_o  )
  );

  AsyncFork   #(
    .SIZE      (  RW                 ),
    .WIDTH     (  1                  )
  ) forthFork  (
    // INPUTS
    .data_i    (  forthSource_o      ),
    .ack_o     (  { x0Join_ack[1],
                    y0Join_ack[0] }  ),
    .arst      (  arst               ),
    // OUTPUTS
    .data_o    (  forthFork_o        ),
    .ack_i     (  forthFork_ack      )
  );

  AsyncJoin #(
    .SIZE    (  RW                       ),
    .WIDTH   (  1                        )
  ) x0Join   (
    // INPUTS
    .ack_o   (  x0Latch_ack              ),
    .data_i  (  { forthFork_o[0],
                  cordicInitFork_o[1] }  ),
    // OUTPUTS
    .ack_i   (  x0Join_ack               ),
    .data_o  (  x0Join_o                 )
  );

  AsyncJoin #(
    .SIZE    (  RW                       ),
    .WIDTH   (  1                        )
  ) y0Join   (
    // INPUTS
    .ack_o   (  y0Latch_ack              ),
    .data_i  (  { forthFork_o[1],
                  cordicInitFork_o[0] }  ),
    // OUTPUTS
    .ack_i   (  y0Join_ack               ),
    .data_o  (  y0Join_o                 )
  );

  AsyncAdder  #(
    .SIZE      (  RW           )
  ) x0Add      (
    // INPUTS
    .a         (  x0Join_o[0]  ),
    .b         (  x0Join_o[1]  ),
    .carry     (  2'b10        ),
    .arst      (  arst         ),
    // OUTPUTS
    .data_o    (  x0Add_o      )
  );

  AsyncLatch  #(
    .SIZE      (  RW                   )
  ) x0Latch    (
    // INPUTS
    .data_i    (  x0Add_o              ),
    .ack_o     (  cordicInitJoinX_ack  ), // 0 for testing purposes
    .arst      (  arst                 ),
    // OUTPUTS
    .data_o    (  x0Latch_o            ),
    .ack_i     (  x0Latch_ack          )
  );

  AsyncAdder  #(
    .SIZE      (  RW            )
  ) y0Subtract (
    // INPUTS
    .a         (  y0Join_o[0]   ),
    .b         (  y0Join_o[1]   ),
    .carry     (  2'b01         ),
    .arst      (  arst          ),
    // OUTPUTS
    .data_o    (  y0Subtract_o  )
  );

  AsyncLatch  #(
    .SIZE      (  RW           )
  ) y0Latch    (
    // INPUTS
    .data_i    (  y0Subtract_o         ),
    .ack_o     (  cordicInitJoinY_ack  ), // 0 for testing purposes
    .arst      (  arst                 ),
    // OUTPUTS
    .data_o    (  y0Latch_o            ),
    .ack_i     (  y0Latch_ack          )
  );

  AsyncCordicCoordJoin cordicInitJoin  (
    .data_x  (  x0Latch_o              ),
    .data_y  (  y0Latch_o              ),
    .ack_o   (  cordicInitLatch_ack    ),
    .x_ack   (  cordicInitJoinX_ack    ),
    .y_ack   (  cordicInitJoinY_ack    ),
    .data_o  (  cordicInitJoin_o       )
  );

  AsyncLatch  #(
    .SIZE      (  2 * (RW) + 1         )
  ) cordicInitLatch                    (
    .data_i    (  cordicInitJoin_o     ),
    .ack_o     (  data_ack             ),
    .arst      (  arst                 ),
    .ack_i     (  cordicInitLatch_ack  ),
    .data_o    (  data_o               )
  );

endmodule
