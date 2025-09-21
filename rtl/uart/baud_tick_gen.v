////////////////////////////////////////////////////////
// RS-232 RX and TX module
// (c) fpga4fun.com & KNJN LLC - 2003 to 2016

// The RS-232 settings are fixed
// TX: 8-bit data, 2 stop, no-parity
// RX: 8-bit data, 1 stop, no-parity (the receiver can accept more stop bits of course)

////////////////////////////////////////////////////////
module baud_tick_gen (
    input  clk,
    rst,
    enable,
    output tick  // generate a tick at the specified baud rate * oversampling
);

  parameter integer ClkFrequency = 25000000;
  parameter integer Baud = 115200;
  parameter integer Oversampling = 1;

  // +/- 2% max timing error over a byte
  parameter integer AccWidth = log2(ClkFrequency / Baud) + 8;

  // this makes sure Inc calculation doesn't overflow
  parameter integer ShiftLimiter = log2(Baud * Oversampling >> (31 - AccWidth));

  parameter integer Inc = (
    (Baud*Oversampling << (AccWidth-ShiftLimiter))+(ClkFrequency>>(ShiftLimiter+1))
  )/(ClkFrequency>>ShiftLimiter);

  function static integer log2(input integer v);
    begin
      log2 = 0;
      while (v >> log2) log2 = log2 + 1;
    end
  endfunction

  reg [AccWidth:0] Acc;

  always @(posedge clk) begin
    if (rst) Acc <= 0;
    else if (enable) Acc <= Acc[AccWidth-1:0] + Inc[AccWidth:0];
    else Acc <= Inc[AccWidth:0];
  end
  assign tick = Acc[AccWidth];

endmodule
