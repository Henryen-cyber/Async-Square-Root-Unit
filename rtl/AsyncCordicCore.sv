module AsyncCordicCore #(
  parameter int RW   = pa_AsyncCordic::RW,
  parameter int EW   = pa_AsyncCordic::EW,
  parameter int LOOP = pa_AsyncCordic::LOOPS
)(
  input  pa_AsyncCordic::cordic_coord_t data_i,

  input  logic                          ack_o,

  input  logic                          arst,

  output pa_AsyncCordic::cordic_coord_t data_o,
  output logic                          ack_i
);

  // cordicCoreMUX
  pa_AsyncCordic::cordic_coord_t cordicCoreMUX_o;
  logic                          cordicCoreMUX_01ack;
  logic                          cordicCoreMUX_ctrlack;

  // cordicCoreDEMUX
  pa_AsyncCordic::cordic_coord_t cordicCoreDEMUX_01;
  logic                          cordicCoreDEMUX_ack;
  logic                          cordicCoreDEMUX_ctrlack;

  // cordicCoordFork
  pa_AsyncCordic::dual_rail_t[RW:0] cordicCoordFork_x;
  pa_AsyncCordic::dual_rail_t[RW:0] cordicCoordFork_y;
  logic                             cordicCoordFork_ack;

  // xLatch
  pa_AsyncCordic::dual_rail_t[RW:0] xLatch_o;
  logic                             xLatch_ack;

  // xFork
  pa_AsyncCordic::dual_rail_t[1:0][RW:0] xFork_o;
  logic                                  xFork_ack;

  // xShift
  pa_AsyncCordic::dual_rail_t[RW:0] xShift_o;

  // xShiftLatch
  pa_AsyncCordic::dual_rail_t[RW:0] xShiftLatch_o;
  logic                             xShiftLatch_ack;

  // xyShiftJoin
  pa_AsyncCordic::cordic_coord_t xyShiftJoin_o;
  logic                          xyShiftJoinX_ack;
  logic                          xyShiftJoinY_ack;

  // xDEMUX
  pa_AsyncCordic::cordic_coord_t xDEMUX_01;
  pa_AsyncCordic::cordic_coord_t xDEMUX_10;
  logic                          xDEMUX_ack;
  logic                          xDEMUX_ctrlack;

  // xAdd
  pa_AsyncCordic::dual_rail_t[RW:0] xAdd_o;

  // xAddLatch
  pa_AsyncCordic::dual_rail_t[RW:0] xAddLatch_o;
  logic                             xAddLatch_ack;

  // xSubtract
  pa_AsyncCordic::dual_rail_t[RW:0] xSubtract_o;

  // xSubtractLatch
  pa_AsyncCordic::dual_rail_t[RW:0] xSubtractLatch_o;
  logic                             xSubtractLatch_ack;

  // xMUX
  pa_AsyncCordic::dual_rail_t[RW:0] xMUX_o;
  logic                             xMUX_01ack;
  logic                             xMUX_10ack;
  logic                             xMUX_ctrlack;

  // xNewLatch
  pa_AsyncCordic::dual_rail_t[RW:0] xNewLatch_o;
  logic                             xNewLatch_ack;

  // yLatch
  pa_AsyncCordic::dual_rail_t[RW:0] yLatch_o;
  logic                             yLatch_ack;

  // yFork
  pa_AsyncCordic::dual_rail_t[2:0][RW:0] yFork_o;
  logic                                  yFork_ack;

  // yShift
  pa_AsyncCordic::dual_rail_t[RW:0] yShift_o;

  // yShiftLatch
  pa_AsyncCordic::dual_rail_t[RW:0] yShiftLatch_o;
  logic                             yShiftLatch_ack;

  // yxShiftJoin
  pa_AsyncCordic::cordic_coord_t yxShiftJoin_o;
  logic                          yxShiftJoinX_ack;
  logic                          yxShiftJoinY_ack;

  // yDEMUX
  pa_AsyncCordic::cordic_coord_t yDEMUX_01;
  pa_AsyncCordic::cordic_coord_t yDEMUX_10;
  logic                          yDEMUX_ack;
  logic                          yDEMUX_ctrlack;

  // yAdd
  pa_AsyncCordic::dual_rail_t[RW:0] yAdd_o;

  // yAddLatch
  pa_AsyncCordic::dual_rail_t[RW:0] yAddLatch_o;
  logic                             yAddLatch_ack;


  // ySubtract
  pa_AsyncCordic::dual_rail_t[RW:0] ySubtract_o;

  // ySubtractLatch
  pa_AsyncCordic::dual_rail_t[RW:0] ySubtractLatch_o;
  logic                             ySubtractLatch_ack;

  // yMUX
  pa_AsyncCordic::dual_rail_t[RW:0] yMUX_o;
  logic                             yMUX_01ack;
  logic                             yMUX_10ack;
  logic                             yMUX_ctrlack;

  // yNewLatch
  pa_AsyncCordic::dual_rail_t[RW:0] yNewLatch_o;
  logic                             yNewLatch_ack;

  // ySignFork
  pa_AsyncCordic::dual_rail_t[3:0] ySignFork_o;
  logic                            ySignFork_ack;

  // cordicCntFork
  pa_AsyncCordic::cordic_coord_t[1:0] cordicCntFork_o;
  logic                               cordicCntFork_ack;

  // cordicCnt
  pa_AsyncCordic::dual_rail_t cordicCnt_ctrl;
  logic[LOOP:0]               cordicCnt_shiftamnt;
  logic                       cordicCnt_ack;

  // loopCtrlFork
  pa_AsyncCordic::dual_rail_t[1:0] loopCtrlFork_o;
  logic                            loopCtrlFork_ack;

  // loopCtrlLatch0
  pa_AsyncCordic::dual_rail_t loopCtrlLatch0_o;
  logic                       loopCtrlLatch0_ack;

  // loopCtrlLatch1
  pa_AsyncCordic::dual_rail_t loopCtrlLatch1_o;
  logic                       loopCtrlLatch1_ack;

  // cordicNewCoordJoin
  pa_AsyncCordic::cordic_coord_t cordicNewCoordJoin_o;
  logic                          cordicNewCoordJoinX_ack;
  logic                          cordicNewCoordJoinY_ack;

  // cordicNewCoordLatch
  pa_AsyncCordic::cordic_coord_t cordicNewCoordLatch_o;
  logic                          cordicNewCoordLatch_ack;


  AsyncMUX    #(
    .SIZE      (  ( 2 * RW ) + 1           )
  ) cordicCoreMUX                          (
    .data_x    (  cordicNewCoordLatch_o    ),
    .data_y    (  data_i                   ),
    .ctrl      (  loopCtrlLatch1_o         ),
    .z_ack     (  cordicCoreDEMUX_ack      ),
    .arst      (  arst                     ),
    .x_ack     (  cordicCoreMUX_01ack      ),
    .y_ack     (  ack_i                    ),
    .ctrl_ack  (  cordicCoreMUX_ctrlack    ),
    .data_z    (  cordicCoreMUX_o          )
  );

  AsyncDEMUX  #(
    .SIZE      (  ( 2 * RW ) + 1           )
  ) cordicCoreDEMUX                        (
    .data_x    (  cordicCoreMUX_o          ),
    .ctrl      (  loopCtrlFork_o[1]        ),
    .y_ack     (  cordicCoordFork_ack      ),
    .z_ack     (  ack_o                    ),
    .arst      (  arst                     ),
    .data_y    (  cordicCoreDEMUX_01       ),
    .data_z    (  data_o                   ),
    .x_ack     (  cordicCoreDEMUX_ack      ),
    .ctrl_ack  (  cordicCoreDEMUX_ctrlack  )
  );

  AsyncCordicCoordFork cordicCoordFork (
    .data_i    (  cordicCoreDEMUX_01   ),
    .x_ack     (  xLatch_ack           ),
    .y_ack     (  yLatch_ack           ),
    .arst      (  arst                 ),
    .data_x    (  cordicCoordFork_x    ),
    .data_y    (  cordicCoordFork_y    ),
    .ack_i     (  cordicCoordFork_ack  )
  );

  AsyncLatch  #(
    .SIZE      (  RW                 )
  ) xLatch     (
    .data_i    (  cordicCoordFork_x  ),
    .ack_o     (  xFork_ack          ),
    .arst      (  arst               ),
    .data_o    (  xLatch_o           ),
    .ack_i     (  xLatch_ack         )
  );

  AsyncFork   #(
    .SIZE      (  RW                    ),
    .WIDTH     (  1                     )
  ) xFork      (
    .data_i    (  xLatch_o              ),
    .ack_o     (  { xShiftLatch_ack,
                    xyShiftJoinX_ack }  ),
    .arst      (  arst                  ),
    .ack_i     (  xFork_ack             ),
    .data_o    (  xFork_o               )
  );

  AsyncShift    #(
    .SIZE        (  RW                   ),
    .SHIFT       (  LOOP                 )
  ) xShift       (
    .data_i      (  xFork_o[1]           ),
    .shift_amnt  (  cordicCnt_shiftamnt  ),
    .data_o      (  xShift_o             )
  );

  AsyncLatch  #(
    .SIZE      (  RW                )
  ) xShiftLatch                     (
    .data_i    (  xShift_o          ),
    .ack_o     (  yxShiftJoinX_ack  ),
    .arst      (  arst              ),
    .data_o    (  xShiftLatch_o     ),
    .ack_i     (  xShiftLatch_ack   )
  );

  AsyncCordicCoordJoin xyShiftJoin  (
    .data_x    (  xFork_o[0]        ),
    .data_y    (  yShiftLatch_o     ),
    .ack_o     (  xDEMUX_ack        ),
    .data_o    (  xyShiftJoin_o     ),
    .x_ack     (  xyShiftJoinX_ack  ),
    .y_ack     (  xyShiftJoinY_ack  )
  );

  AsyncDEMUX  #(
    .SIZE      (  ( 2 * RW ) + 1      )
  ) xDEMUX     (
    .data_x    (  xyShiftJoin_o       ),
    .ctrl      (  ySignFork_o[0]      ),
    .y_ack     (  xAddLatch_ack       ),
    .z_ack     (  xSubtractLatch_ack  ),
    .arst      (  arst                ),
    .ctrl_ack  (  xDEMUX_ctrlack      ),
    .x_ack     (  xDEMUX_ack          ),
    .data_y    (  xDEMUX_01           ),
    .data_z    (  xDEMUX_10           )
  );

  AsyncAdder  #(
    .SIZE      (  RW           )
  ) xAdd       (
    .a         (  xDEMUX_01.x  ),
    .b         (  xDEMUX_01.y  ),
    .carry     (  2'b10        ),
    .arst      (  arst         ),
    .data_o    (  xAdd_o       )
  );

  AsyncLatch  #(
    .SIZE      (  RW             )
  ) xAddLatch  (
    .data_i    (  xAdd_o         ),
    .ack_o     (  xMUX_01ack     ),
    .arst      (  arst           ),
    .data_o    (  xAddLatch_o    ),
    .ack_i     (  xAddLatch_ack  )
  );

  AsyncAdder  #(
    .SIZE      (  RW           )
  ) xSubtract  (
    .a         (  xDEMUX_10.x  ),
    .b         (  xDEMUX_10.y  ),
    .carry     (  2'b01        ),  // What is 1 and 0 in dual_rail_t again..?
    .arst      (  arst         ),
    .data_o    (  xSubtract_o  )
  );

  AsyncLatch  #(
    .SIZE      (  RW                  )
  ) xSubtractLatch                    (
    .data_i    (  xSubtract_o         ),
    .ack_o     (  xMUX_10ack          ),
    .arst      (  arst                ),
    .data_o    (  xSubtractLatch_o    ),
    .ack_i     (  xSubtractLatch_ack  )
  );

  AsyncMUX    #(
    .SIZE      (  RW                )
  ) xMUX       (
    .data_x    (  xAddLatch_o       ),
    .data_y    (  xSubtractLatch_o  ),
    .ctrl      (  ySignFork_o[1]    ),
    .z_ack     (  xNewLatch_ack     ),
    .arst      (  arst              ),
    .x_ack     (  xMUX_01ack        ),
    .y_ack     (  xMUX_10ack        ),
    .ctrl_ack  (  xMUX_ctrlack      ),
    .data_z    (  xMUX_o            )
  );

  AsyncLatch  #(
    .SIZE      (  RW                       )
  ) xNewLatch  (
    .data_i    (  xMUX_o                   ),
    .ack_o     (  cordicNewCoordJoinX_ack  ),
    .arst      (  arst                     ),
    .data_o    (  xNewLatch_o              ),
    .ack_i     (  xNewLatch_ack            )
  );

  AsyncLatch  #(
    .SIZE      (  RW                 )
  ) yLatch     (
    .data_i    (  cordicCoordFork_y  ),
    .ack_o     (  yFork_ack          ),
    .arst      (  arst               ),
    .data_o    (  yLatch_o           ),
    .ack_i     (  yLatch_ack         )
  );

  AsyncFork   #(
    .SIZE      (  RW                    ),
    .WIDTH     (  2                     )
  ) yFork      (
    .data_i    (  yLatch_o              ),
    .ack_o     (  { yShiftLatch_ack,
                    ySignFork_ack,
                    yxShiftJoinY_ack }  ),
    .arst      (  arst                  ),
    .data_o    (  yFork_o               ),
    .ack_i     (  yFork_ack             )
  );

  AsyncShift    #(
    .SIZE        (  RW                   ),
    .SHIFT       (  LOOP                 )
  ) yShift       (
    .data_i      (  yFork_o[2]           ),
    .shift_amnt  (  cordicCnt_shiftamnt  ),
    .data_o      (  yShift_o             )
  );

  AsyncLatch  #(
    .SIZE      (  RW                )
  ) yShiftLatch                     (
    .data_i    (  yShift_o          ),
    .ack_o     (  xyShiftJoinY_ack  ),
    .arst      (  arst              ),
    .data_o    (  yShiftLatch_o     ),
    .ack_i     (  yShiftLatch_ack   )
  );

  AsyncCordicCoordJoin yxShiftJoin  (
    .data_x    (  xShiftLatch_o     ),
    .data_y    (  yFork_o[0]        ),
    .ack_o     (  yDEMUX_ack        ),
    .x_ack     (  yxShiftJoinX_ack  ),
    .y_ack     (  yxShiftJoinY_ack  ),
    .data_o    (  yxShiftJoin_o     )
  );

  AsyncDEMUX  #(
    .SIZE      (  ( 2 * RW ) + 1      )
  ) yDEMUX     (
    .data_x    (  yxShiftJoin_o       ),
    .ctrl      (  ySignFork_o[2]      ),
    .y_ack     (  ySubtractLatch_ack  ),
    .z_ack     (  yAddLatch_ack       ),
    .arst      (  arst                ),
    .data_y    (  yDEMUX_01           ),
    .data_z    (  yDEMUX_10           ),
    .x_ack     (  yDEMUX_ack          ),
    .ctrl_ack  (  yDEMUX_ctrlack      )
  );

  AsyncAdder  #(
    .SIZE      (  RW           )
  ) yAdd       (
    .a         (  yDEMUX_01.y  ),
    .b         (  yDEMUX_01.x  ),
    .carry     (  2'b10        ),
    .arst      (  arst         ),
    .data_o    (  yAdd_o       )
  );

  AsyncLatch  #(
    .SIZE      (  RW             )
  ) yAddLatch  (
    .data_i    (  yAdd_o         ),
    .ack_o     (  yMUX_01ack     ),
    .arst      (  arst           ),
    .data_o    (  yAddLatch_o    ),
    .ack_i     (  yAddLatch_ack  )
  );

  AsyncAdder  #(
    .SIZE      (  RW           )
  ) ySubtract  (
    .a         (  yDEMUX_10.y  ),
    .b         (  yDEMUX_10.x  ),
    .carry     (  2'b01        ),
    .arst      (  arst         ),
    .data_o    (  ySubtract_o  )
  );

  AsyncLatch  #(
    .SIZE      (  RW                  )
  ) ySubtractLatch                    (
    .data_i    (  ySubtract_o         ),
    .ack_o     (  yMUX_10ack          ),
    .arst      (  arst                ),
    .data_o    (  ySubtractLatch_o    ),
    .ack_i     (  ySubtractLatch_ack  )
  );

  AsyncMUX    #(
    .SIZE      (  RW                )
  ) yMUX       (
    .data_x    (  yAddLatch_o       ),
    .data_y    (  ySubtractLatch_o  ),
    .ctrl      (  ySignFork_o[3]    ),
    .z_ack     (  yNewLatch_ack     ),
    .arst      (  arst              ),
    .x_ack     (  yMUX_01ack        ),
    .y_ack     (  yMUX_10ack        ),
    .ctrl_ack  (  yMUX_ctrlack      ),
    .data_z    (  yMUX_o            )
  );

  AsyncLatch  #(
    .SIZE      (  RW                       )
  ) yNewLatch  (
    .data_i    (  yMUX_o                   ),
    .ack_o     (  cordicNewCoordJoinY_ack  ),
    .arst      (  arst                     ),
    .data_o    (  yNewLatch_o              ),
    .ack_i     (  yNewLatch_ack            )
  );

  AsyncCordicCoordJoin cordicNewCoordJoin  (
    .data_x    (  xNewLatch_o              ),
    .data_y    (  yNewLatch_o              ),
    .ack_o     (  cordicCntFork_ack        ),
    .data_o    (  cordicNewCoordJoin_o     ),
    .x_ack     (  cordicNewCoordJoinX_ack  ),
    .y_ack     (  cordicNewCoordJoinY_ack  )
  );

  AsyncFork   #(
    .SIZE      (  0                 ),
    .WIDTH     (  3                 )
  ) ySignFork  (
    .data_i    (  yFork_o[1][RW]    ),
    .ack_o     (  { xDEMUX_ctrlack,
                    xMUX_ctrlack  ,
                    yDEMUX_ctrlack,
                    yMUX_ctrlack }  ),
    .arst      (  arst              ),
    .data_o    (  ySignFork_o       ),
    .ack_i     (  ySignFork_ack     )
  );

  AsyncFork   #(
    .SIZE      (  ( 2 * RW ) + 1               ),
    .WIDTH     (  1                            )
  ) cordicCntFork                              (
    .data_i    (  cordicNewCoordJoin_o         ),
    .ack_o     (  { cordicCnt_ack,
                    cordicNewCoordLatch_ack }  ),
    .arst      (  arst                         ),
    .data_o    (  cordicCntFork_o              ),
    .ack_i     (  cordicCntFork_ack            )
  );

  AsyncLatch   #(
    .SIZE       (  (  2 * RW ) + 1         )
  ) cordicNewCoordLatch                    (
    .data_i    (  cordicCntFork_o[0]       ),
    .ack_o     (  cordicCoreMUX_01ack      ),
    .arst      (  arst                     ),
    .data_o    (  cordicNewCoordLatch_o    ),
    .ack_i     (  cordicNewCoordLatch_ack  )
  );

  AsyncCounter  #(
    .SIZE        (  ( 2 * RW ) + 1       ),
    .LOOP        (  LOOP                 )
  ) cordicCnt    (
    .data_i      (  cordicCntFork_o[1]   ),
    .ack_o       (  loopCtrlFork_ack     ),
    .arst        (  arst                 ),
    .ack_i       (  cordicCnt_ack        ),
    .ctrl_o      (  cordicCnt_ctrl       ),
    .shift_amnt  (  cordicCnt_shiftamnt  )
  );

  AsyncFork   #(
    .SIZE      (  0                            ),
    .WIDTH     (  1                            )
  ) loopCtrlFork                               (
    .data_i    (  cordicCnt_ctrl               ),
    .ack_o     (  { loopCtrlLatch0_ack,
                    cordicCoreDEMUX_ctrlack }  ),
    .arst      (  arst                         ),
    .data_o    (  loopCtrlFork_o               ),
    .ack_i     (  loopCtrlFork_ack             )
  );

  AsyncLatch  #(
    .SIZE      (  0                   )
  ) loopCtrlLatch0                    (
    .data_i    (  loopCtrlFork_o[0]   ),
    .ack_o     (  loopCtrlLatch1_ack  ),
    .arst      (  arst                ),
    .data_o    (  loopCtrlLatch0_o    ),
    .ack_i     (  loopCtrlLatch0_ack  )
  );

  AsyncLatch  #(
    .SIZE      (  0                      ),
    .MODE      (  0                      )
  ) loopCtrlLatch1                       (
    .data_i    (  loopCtrlLatch0_o       ),
    .ack_o     (  cordicCoreMUX_ctrlack  ),
    .arst      (  arst                   ),
    .data_o    (  loopCtrlLatch1_o       ),
    .ack_i     (  loopCtrlLatch1_ack     )
  );

endmodule
