module usb_keyboard (
    input usb_clk,
    input rst,

    // I/O interface to computer
    input cs,               // chip select, active high
    input address,          // =0 RX buffer, =1 RX status
    output reg [7:0] dout,  // 8-bit output bus.

    // LEDs
    output led_connerr,
    output led_activity,

    // USB
    inout usb_dm,
    inout usb_dp
);

`include "scancodes.v"

wire [1:0] usb_type;
wire [7:0] key_modifiers, key1, key2, key3, key4;
wire [7:0] hid_regs [7:0];

wire usb_report;
wire usb_conerr;

usb_hid_host usb (
    .usbclk(usb_clk),
    .usbrst_n(!rst),
    .usb_dm(usb_dm),
    .usb_dp(usb_dp),
    .typ(usb_type),
    .report(usb_report),
    .key_modifiers(key_modifiers),
    .key1(key1),
    .key2(key2),
    .key3(key3),
    .key4(key4),
    .conerr(usb_conerr)
);

reg report_toggle;      // blinks whenever there's a report
reg usb_rdy;            // new USB character flag
reg ascii_rdy;          // new ASCII character for CPU
reg [7:0] ascii;        // ASCII code of key character
reg [7:0] key_active;

always @(posedge usb_clk or posedge rst) begin
    if(rst) begin
        usb_rdy <= 1'b0;
        ascii_rdy <= 1'b0;
    end else begin
        usb_rdy <= 1'b0;

        if (usb_report) report_toggle <= ~report_toggle;

        if (usb_report && usb_type == 1'd1) begin
            // keyboard
            if (key1 != 0 && key1 != key_active) begin
                ascii <= scancode2char(key1, key_modifiers);
                usb_rdy <= 1'b1;
            end
            key_active <= key1;
        end

        // handle I/O from CPU
        if (cs == 1'b1) begin
            if (address == 1'b0) begin
                // CPU RX buffer address
                dout <= {1'b1, ascii[6:0]};
                ascii_rdy <= 1'b0;
            end
            else
            begin
                // CPU RX status register
                dout <= {ascii_rdy, 7'b0};
            end
        end

        if (usb_rdy == 1'b1) begin
            ascii_rdy <= 1'b1;
        end
    end
end

assign led_connerr = ~usb_conerr;
assign led_activity = ~report_toggle;

endmodule
