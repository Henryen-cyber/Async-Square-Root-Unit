module AsyncFPNormalize #(
  parameter int RW = pa_AsyncCordic::RW,
  parameter int EW = pa_AsyncCordic::EW
)(
  input  pa_AsyncCordic::operand_t  data_i,
  input  logic                      ack_o,

  input  logic                      arst,

  output logic                      ack_i,
  output pa_AsyncCordic::operand_t  data_o
);

  // normalizeMUX
  logic                     normalizeMUX_10ack;
  logic                     normalizeMUX_ctrlack;
  pa_AsyncCordic::operand_t normalizeMUX_o;

  // normalizeMSBFork
  pa_AsyncCordic::operand_t[1:0] normalizeMSBFork_o;
  logic                          normalizeMSBFork_ack;

  // normalizeMSBLatch
  pa_AsyncCordic::operand_t normalizeMSBLatch_o;
  logic                     normalizeMSBLatch_ack;

  // normalizeCtrlFork
  logic                            normalizeCtrlFork_ack;
  pa_AsyncCordic::dual_rail_t[1:0] normalizeCtrlFork_o;

  // normalizeDEMUX
  pa_AsyncCordic::operand_t normalizeDEMUX_10;
  logic                     normalizeDEMUX_ack;
  logic                     normalizeDEMUX_ctrlack;

  // ctrlLatch0
  pa_AsyncCordic::dual_rail_t ctrlLatch0_o;
  logic                       ctrlLatch0_ack;

  // ctrlLatch1
  pa_AsyncCordic::dual_rail_t ctrlLatch1_o;
  logic                       ctrlLatch1_ack;

  // normalizeFork
  pa_AsyncCordic::dual_rail_t[EW:0] normalizeFork_exp;
  pa_AsyncCordic::dual_rail_t[RW:0] normalizeFork_rad;
  logic                             normalizeFork_ack;

  // normalizeExpLatch
  pa_AsyncCordic::dual_rail_t[EW:0] normalizeExpLatch_o;
  logic                             normalizeExpLatch_ack;

  // oneSource
  pa_AsyncCordic::dual_rail_t[EW:0] oneSource_o;

  // expSubtractJoin
  pa_AsyncCordic::dual_rail_t[1:0][EW:0] expSubtractJoin_o;
  logic[1:0]                             expSubtractJoin_ack;

  // expSubtract
  pa_AsyncCordic::dual_rail_t[EW:0] expSubtract_o;

  // expSubtractLatch
  pa_AsyncCordic::dual_rail_t[EW:0] expSubtractLatch_o;
  logic                             expSubtractLatch_ack;

  // normalizeRadLatch
  pa_AsyncCordic::dual_rail_t[RW:0] normalizeRadLatch_o;
  logic                             normalizeRadLatch_ack;

  // normalizeRadShift
  pa_AsyncCordic::dual_rail_t[RW:0] normalizeRadShift_o;

  // radShiftLatch
  pa_AsyncCordic::dual_rail_t[RW:0] radShiftLatch_o;
  logic                             radShiftLatch_ack;

  // normalizeJoin
  pa_AsyncCordic::operand_t normalizeJoin_o;
  logic                     normalizeJoinRad_ack;
  logic                     normalizeJoinExp_ack;

  // normalizeOperandLatch
  pa_AsyncCordic::operand_t normalizeOperandLatch_o;
  logic                     normalizeOperandLatch_ack;

  AsyncOperandMUX normalizeMUX             (
    // INPUTS
    .data_x    (  data_i                   ),
    .data_y    (  normalizeOperandLatch_o  ),
    .ctrl      (  ctrlLatch1_o             ),
    .z_ack     (  normalizeDEMUX_ack       ),
    .arst      (  arst                     ),
    // OUTPUTS
    .x_ack     (  ack_i                    ),
    .y_ack     (  normalizeMUX_10ack       ),
    .ctrl_ack  (  normalizeMUX_ctrlack     ),
    .data_z    (  normalizeMUX_o           )
  );

  AsyncFork   #(
    .SIZE      (  EW + RW + 1                 ),
    .WIDTH     (  1                           )
  ) normalizeMSBFork                          (
    .data_i    (  normalizeMUX_o              ),
    .ack_o     (  { normalizeMSBLatch_ack,
                    normalizeDEMUX_ack     }  ),
    .arst      (  arst                        ),
    .data_o    (  normalizeMSBFork_o          ),
    .ack_i     (  normalizeMSBFork_ack        )
  );

  AsyncLatch  #(
    .SIZE      (  EW + RW + 1            )
  ) normalizeMSBLatch                    (
    .data_i    (  normalizeMSBFork_o[0]  ),
    .ack_o     (  normalizeCtrlFork_ack  ),
    .arst      (  arst                   ),
    .data_o    (  normalizeMSBLatch_o    ),
    .ack_i     (  normalizeMSBLatch_ack  )
  );

  AsyncFork   #(
    .SIZE      (  0                                 ),
    .WIDTH     (  1                                 )
  ) normalizeCtrlFork                               (
    // INPUTS
    .data_i    (  normalizeMSBLatch_o.radicand[RW]  ),
    .ack_o     (  { normalizeDEMUX_ctrlack,
                    ctrlLatch0_ack          }       ),
    .arst      (  arst                              ),
    // OUTPUTS
    .data_o    (  normalizeCtrlFork_o               ),
    .ack_i     (  normalizeCtrlFork_ack             )
  );

  AsyncOperandDEMUX normalizeDEMUX        (
    // INPUTS
    .data_x    (  normalizeMSBFork_o[1]   ),
    .ctrl      (  normalizeCtrlFork_o[1]  ),
    .y_ack     (  ack_o                   ),
    .z_ack     (  normalizeFork_ack       ),
    .arst      (  arst                    ),
    // OUTPUTS
    .data_y    (  data_o                  ),
    .data_z    (  normalizeDEMUX_10       ),
    .x_ack     (  normalizeDEMUX_ack      ),
    .ctrl_ack  (  normalizeDEMUX_ctrlack  )
  );

  AsyncLatch  #(
    .SIZE      (  0                       )
  ) ctrlLatch0                            (
    // INPUTS
    .data_i    (  normalizeCtrlFork_o[0]  ),
    .ack_o     (  ctrlLatch1_ack          ),
    .arst      (  arst                    ),
    // OUTPUTS
    .data_o    (  ctrlLatch0_o            ),
    .ack_i     (  ctrlLatch0_ack          )
  );

  AsyncLatch    #(
    .SIZE        (  0                     ),
    .MODE        (  1                     )
  ) ctrlLatch1                            (
    // INPUTS
    .data_i      (  ctrlLatch0_o          ),
    .ack_o       (  normalizeMUX_ctrlack  ),
    .arst        (  arst                  ),
    // OUTPUTS
    .data_o      (  ctrlLatch1_o          ),
    .ack_i       (  ctrlLatch1_ack        )
  );

  AsyncOperandFork normalizeFork             (
    // INPUTS
    .operand       (  normalizeDEMUX_10      ),
    .exp_ack       (  normalizeExpLatch_ack  ),
    .radicand_ack  (  normalizeRadLatch_ack  ),
    .arst          (  arst                   ),
    // OUTPUTS
    .exp           (  normalizeFork_exp      ),
    .radicand      (  normalizeFork_rad      ),
    .ack_i         (  normalizeFork_ack      )
  );

  AsyncLatch  #(
    .SIZE      (  EW                      )
  ) normalizeExpLatch                     (
    // INPUTS
    .data_i    (  normalizeFork_exp       ),
    .ack_o     (  expSubtractJoin_ack[0]  ),
    .arst      (  arst                    ),
    // OUTPUTS
    .data_o    (  normalizeExpLatch_o     ),
    .ack_i     (  normalizeExpLatch_ack   )
  );

  AsyncSource #(
    .SIZE      (  EW                      )
  ) oneSource                             (
    .data_i    (  8'h01                   ),
    .ack_i     (  expSubtractJoin_ack[1]  ),
    .data_o    (  oneSource_o             )
  );

  AsyncJoin  #(
    .SIZE     (  EW                       ),
    .WIDTH    (  1                        )
  ) expSubtractJoin                       (
    // INPUTS
    .ack_o    (  expSubtractLatch_ack     ),
    .data_i   (  { oneSource_o,
                   normalizeExpLatch_o }  ),
    // OUTPUTS
    .ack_i    (  expSubtractJoin_ack      ),
    .data_o   (  expSubtractJoin_o        )
  );

  AsyncAdder  #(
    .SIZE      (  EW                    )
  ) expSubtract                         (
    .a         (  expSubtractJoin_o[0]  ),
    .b         (  expSubtractJoin_o[1]  ),
    .carry     (  2'b01                 ),
    .arst      (  arst                  ),
    .data_o    (  expSubtract_o         )
  );

  AsyncLatch  #(
    .SIZE      (  EW                    )
  ) expSubtractLatch                    (
      //INPUTS
    .data_i    (  expSubtract_o         ),
    .ack_o     (  normalizeJoinExp_ack  ),
    .arst      (  arst                  ),
    //OUTPUTS
    .data_o    (  expSubtractLatch_o    ),
    .ack_i     (  expSubtractLatch_ack  )
  );

  AsyncLatch  #(
    .SIZE      (  RW                     )
  ) normalizeRadLatch                    (
    // INPUTS
    .data_i    (  normalizeFork_rad      ),
    .ack_o     (  radShiftLatch_ack      ),
    .arst      (  arst                   ),
    // OUTPUTS
    .data_o    (  normalizeRadLatch_o    ),
    .ack_i     (  normalizeRadLatch_ack  )
  );

  AsyncLeftShift normalizeRadShift     (
    // INPUT
    .data_i    (  normalizeRadLatch_o  ),
    .arst      (  arst                 ),
    // OUTPUT
    .data_o    (  normalizeRadShift_o  )
  );

  AsyncLatch  #(
    .SIZE      (  RW                    )
  ) radShiftLatch                       (
    // INPUTS
    .data_i    (  normalizeRadShift_o   ),
    .ack_o     (  normalizeJoinRad_ack  ),
    .arst      (  arst                  ),
    // OUTPUTS
    .data_o    (  radShiftLatch_o       ),
    .ack_i     (  radShiftLatch_ack     )
  );

  AsyncOperandJoin normalizeJoin                 (
    .radicand      (  radShiftLatch_o            ),
    .exp           (  expSubtractLatch_o         ),
    .operand_ack   (  normalizeOperandLatch_ack  ),
    .operand       (  normalizeJoin_o            ),
    .exp_ack       (  normalizeJoinExp_ack       ),
    .radicand_ack  (  normalizeJoinRad_ack       )
  );

  AsyncOperandLatch normalizeOperandLatch    (
    .data_i    (  normalizeJoin_o            ),
    .ack_o     (  normalizeMUX_10ack         ),
    .arst      (  arst                       ),
    .data_o    (  normalizeOperandLatch_o    ),
    .ack_i     (  normalizeOperandLatch_ack  )
  );
endmodule
