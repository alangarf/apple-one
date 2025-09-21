////////////////////////////////////////////////////////
// RS-232 RX and TX module
// (c) fpga4fun.com & KNJN LLC - 2003 to 2016

// The RS-232 settings are fixed
// TX: 8-bit data, 2 stop, no-parity
// RX: 8-bit data, 1 stop, no-parity (the receiver can accept more stop bits of course)

////////////////////////////////////////////////////////
module async_receiver (
    input clk,
    input rst,
    input RxD,
    output reg RxD_data_ready,
    // data received, valid only (for one clock cycle) when RxD_data_ready is asserted
    output reg [7:0] RxD_data,

    // We also detect if a gap occurs in the received stream of characters
    // That can be useful if multiple characters are sent in burst
    //  so that multiple characters can be treated as a "packet"
    output RxD_idle,  // asserted when no data has been received for a while
    // asserted for one clock cycle when a packet has been detected (i.e. RxD_idle is going high)
    output reg RxD_endofpacket
);

  parameter integer ClkFrequency = 25000000;
  parameter integer Baud = 115200;
  parameter integer Oversampling = 8;
  // we oversample the RxD line at a fixed rate to capture each RxD data bit at the "right" time
  // 8 times oversampling by default, use 16 for higher quality reception

  ////////////////////////////////
  reg [3:0] RxD_state;

  wire OversamplingTick;
  baud_tick_gen #(
      .ClkFrequency(ClkFrequency),
      .Baud(Baud),
      .Oversampling(Oversampling)
  ) tickgen (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .tick(OversamplingTick)
  );

  // synchronize RxD to our clk domain
  reg [1:0] RxD_sync;  // 2'b11
  always @(posedge clk or posedge rst) begin
    if (rst) RxD_sync <= 2'b11;
    else if (OversamplingTick) RxD_sync <= {RxD_sync[0], RxD};
  end

  // and filter it
  reg [1:0] Filter_cnt;  // 2'b11
  reg       RxD_bit;  // 1'b1
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      Filter_cnt <= 2'b11;
      RxD_bit <= 1'b1;
    end else if (OversamplingTick) begin
      if (RxD_sync[1] == 1'b1 && Filter_cnt != 2'b11) Filter_cnt <= Filter_cnt + 1'd1;
      else if (RxD_sync[1] == 1'b0 && Filter_cnt != 2'b00) Filter_cnt <= Filter_cnt - 1'd1;

      if (Filter_cnt == 2'b11) RxD_bit <= 1'b1;
      else if (Filter_cnt == 2'b00) RxD_bit <= 1'b0;
    end
  end

  // and decide when is the good time to sample the RxD line
  function static integer log2(input integer v);
    begin
      log2 = 0;
      while (v > 1) begin
        v = v >> 1;
        log2 = log2 + 1;
      end
    end
  endfunction

  localparam l2o = log2(Oversampling);
  reg [l2o-1:0] OversamplingCnt;

  always @(posedge clk)
    if (OversamplingTick)
      OversamplingCnt <= (RxD_state == 0) ? 1'd0 : OversamplingCnt + 1'd1;

  wire sampleNow = OversamplingTick && (OversamplingCnt == Oversampling / 2 - 1);

  // now we can accumulate the RxD bits in a shift-register
  always @(posedge clk or posedge rst) begin
    if (rst) RxD_state <= 0;
    else
      case (RxD_state)
        4'b0000: if (~RxD_bit) RxD_state <= 4'b0001;  // start bit found?
        4'b0001: if (sampleNow) RxD_state <= 4'b1000;  // sync start bit to sampleNow
        4'b1000: if (sampleNow) RxD_state <= 4'b1001;  // bit 0
        4'b1001: if (sampleNow) RxD_state <= 4'b1010;  // bit 1
        4'b1010: if (sampleNow) RxD_state <= 4'b1011;  // bit 2
        4'b1011: if (sampleNow) RxD_state <= 4'b1100;  // bit 3
        4'b1100: if (sampleNow) RxD_state <= 4'b1101;  // bit 4
        4'b1101: if (sampleNow) RxD_state <= 4'b1110;  // bit 5
        4'b1110: if (sampleNow) RxD_state <= 4'b1111;  // bit 6
        4'b1111: if (sampleNow) RxD_state <= 4'b0010;  // bit 7
        4'b0010: if (sampleNow) RxD_state <= 4'b0000;  // stop bit
        default: RxD_state <= 4'b0000;
      endcase
  end

  always @(posedge clk or posedge rst) begin
    if (rst) RxD_data <= 0;
    else if (sampleNow && RxD_state[3]) RxD_data <= {RxD_bit, RxD_data[7:1]};
  end

  always @(posedge clk or posedge rst) begin
    if (rst) RxD_data_ready <= 0;
    // make sure a stop bit is received
    else
      RxD_data_ready <= (sampleNow && RxD_state == 4'b0010 && RxD_bit);
  end

  reg [l2o+1:0] GapCnt;
  always @(posedge clk or posedge rst) begin
    if (rst) GapCnt <= 0;
    else if (RxD_state != 0) GapCnt <= 0;
    else if (OversamplingTick & ~GapCnt[log2(Oversampling)+1]) GapCnt <= GapCnt + 1'h1;
  end

  assign RxD_idle = GapCnt[l2o+1];
  always @(posedge clk or posedge rst) begin
    if (rst) RxD_endofpacket <= 0;
    else RxD_endofpacket <= OversamplingTick & ~GapCnt[l2o+1] & &GapCnt[l2o:0];
  end

endmodule
