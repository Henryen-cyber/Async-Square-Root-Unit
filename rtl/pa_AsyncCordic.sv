//`ifndef SVPADEF_ASYNCCORDIC
//`define SVPADEF_ASYNCCORDIC
package pa_AsyncCordic;

  localparam int FP32  = 31 ;  // binary32 floating-point width
  localparam int BIAS  = 127;  // binary32 exponent bias
  localparam int LOOPS = 4  ;  // 5 bits for 30 loops
  localparam int RW    = 29 ;  // RADICAND_WIDTH = 24 fraction bits + log2(24) rounding bits
  localparam int FW    = 22 ;  // binary32 FRACTION_WIDTH
  localparam int EW    = 7  ;  // binary32 EXPONENT_WIDTH

  `ifndef SYNTHESIS
    localparam time                   RTL_OUTPUT_DELAY        = 1ps;
  `endif

  localparam FORTH = 30'b000100000000000000000000000000;

  typedef struct packed {
    logic data_0;
    logic data_1;
  } dual_rail_t;

  typedef struct packed {
    dual_rail_t[EW:0] exp;
    dual_rail_t[RW:0] radicand;
  } operand_t;

  typedef struct packed {
    dual_rail_t[FW:0] fraction;
    dual_rail_t[EW:0] exp;
  } fp_components_t;

  typedef struct packed {
    dual_rail_t[RW:0] x;
    dual_rail_t[RW:0] y;
  } cordic_coord_t;

endpackage
