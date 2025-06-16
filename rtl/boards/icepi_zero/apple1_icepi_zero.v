// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
// Description: Apple 1 implementation for the Blackeice II ICE40HX8K +
//
// Author.....: Chengyin Yao
// Date.......: 14-06-2025 (inspired by blackice2/apple1_ice40updevboard.v)
//

// Should be pulled high?
module apple1_top #(
    parameter BASIC_FILENAME      = "../../../roms/basic.hex",
    parameter FONT_ROM_FILENAME   = "../../../roms/vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "../../../roms/ram.hex",
    parameter VRAM_FILENAME       = "../../../roms/vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "../../../roms/wozmon.hex"
) (
    input  clk,               // 50 MHz board clock

    // I/O interface to computer
    input  usb_tx,            // asynchronous serial data input from computer
    output usb_rx,            // asynchronous serial data output to computer

    // I/O interface to keyboard
    input [1:0] usb_dp,       // PS/2 keyboard serial clock input
    input [1:0] usb_dn,       // PS/2 keyboard serial data input

    output [1:0] usb_pull_dp, // USB pullup/pulldown
    output [1:0] usb_pull_dn, // USB pullup/pulldown

    // DVI port
    output [3:0] gpdi_dp,

    // Debugging ports
    output [3:0] led,
    input button
);
    wire uart_cts; // No CTS pin

    wire clkp, clkt; // clkp: 25MHz, clkt: 250MHz
    dvi_pll pll(clk, clkp, clkt, led[0]);

    wire vsync, hsync, de;
    wire [7:0] vga_r, vga_g, vga_b;

    // Active low
    assign led[1] = reset_n;
    assign led[2] = hsync;
    assign led[3] = 1'b1;

    wire vga_bit;

    // set the monochrome base colour here..
    assign vga_r = vga_bit ? 8'b10000000 : 4'b00000000;
    assign vga_g = vga_bit ? 8'b11111111 : 4'b00000000;
    assign vga_b = vga_bit ? 8'b10000000 : 4'b00000000;

    // debounce reset button
    wire reset_n;
    debounce reset_button (
        .clk25(clkp),
        .rst(1'b0),
        .sig_in(button),
        .sig_out(reset_n)
    );

    // apple one main system
    apple1 #(
        .BASIC_FILENAME (BASIC_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME),
        .RAM_FILENAME (RAM_FILENAME),
        .VRAM_FILENAME (VRAM_FILENAME),
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) my_apple1(
        .clk25(clkp),
        .rst_n(reset_n),

        .uart_rx(usb_tx),
        .uart_tx(usb_rx),
        .uart_cts(uart_cts),

        .ps2_clk(usb_dp[0]),
        .ps2_din(usb_dn[0]),
        .ps2_select(1'b1),       // PS/2 enabled, UART TX disabled
        // .ps2_select(1'b0),    // PS/2 disabled, UART TX enabled

        .vga_h_sync(hsync),
        .vga_v_sync(vsync),
        .vga_red(vga_bit),
        .vga_cls(~reset_n),
	.vga_de(de)
    );

    assign usb_pull_dn[0] = 1'b1; // PS/2 emulation mode
    assign usb_pull_dp[0] = 1'b1;

    // Convert the signal to DVI and send over HDMI
    vga2tmds tmds_generator(clkp, clkt, vsync, hsync, de, vga_r, vga_g, vga_b, gpdi_dp);
endmodule
