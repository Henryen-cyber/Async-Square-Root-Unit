module AsyncCounter #(
  parameter int SIZE,
  parameter int LOOP
)(
  input  pa_AsyncCordic::dual_rail_t[SIZE:0] data_i,
  input  logic                               ack_o,

  input  logic                               arst,

  output logic                               ack_i,
  output pa_AsyncCordic::dual_rail_t         ctrl_o,
  output logic[LOOP:0]                       shift_amnt
);

  logic         rst;
  logic         ctrl;
  logic         ack;
  logic[LOOP:0] cnt;
  logic[5:0]    rep;

  AsyncSink   #(
    .SIZE      (  SIZE      )
  ) u_AsyncSink_Counter     (
    .data_i    (  data_i    ),
    .arst      (  arst      ),
    .ack_i     (  ack       )
  );

  assign ack_i = ack;

  always_ff @(posedge ack or negedge arst) begin
    if (~arst) begin
      cnt         <= 1;
      ctrl        <= 1'b1;
      rep         <= 4;
      shift_amnt  <= 1;
    end else if (ack) begin
      if (cnt == pa_AsyncCordic::RW + 2) begin
        ctrl       <= 1'b0;
        cnt        <= 1;
        rep        <= 4;
        shift_amnt <= 1;
      end else begin
        ctrl <= 1'b1;
        cnt++;
        if (shift_amnt == rep) begin
          shift_amnt <= shift_amnt;
          rep        <= 3 * rep + 1;
        end else begin
          shift_amnt++;
        end
      end
    end
  end

  AsyncSource  #(
    .SIZE       (  0       )
  ) cntSource   (
    .data_i     (  ctrl    ),
    .ack_i      (  ack_o   ),
    .data_o     (  ctrl_o  )
  );


endmodule
