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
// Description: Apple1 implementation for the Tang Primer 25k
//
// Author.....: Alan Garfield
// Date.......: 20/09/2025
//

module apple1_primer #(
    parameter BASIC_FILENAME      = "../../../roms/basic.hex",
    parameter FONT_ROM_FILENAME   = "../../../roms/vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "../../../roms/ram.hex",
    parameter VRAM_FILENAME       = "../../../roms/vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "../../../roms/wozmon.hex"
) (
    input  clk,
    input  rst,

    input  uart_rx,
    output uart_tx,

    inout usb_dm,
    inout usb_dp,
    output usb_led_err,
    output usb_led_act,

    output vga_h_sync,
    output vga_v_sync,
    output vga_red,
    output vga_grn,
    output vga_blu,
    input vga_cls,
    output vga_de
);

    //////////////////////////////////////////////////////////////////////////
    // Registers and Wires
    wire uart_cts; // No CTS pin

    wire clk25;
    wire usb_clk;

    Gowin_PLL your_instance_name(
        .clkin(clk),
        .clkout0(clk25),
        .clkout1(usb_clk),
        .mdclk(1'd0)
    );

    apple1 #(
        .BASIC_FILENAME (BASIC_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME),
        .RAM_FILENAME (RAM_FILENAME),
        .VRAM_FILENAME (VRAM_FILENAME),
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) my_apple1(
        .clk25(clk25),
        .rst_n(!rst),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),

        .ps2_clk(1'b0),
        .ps2_din(1'b0),
        .ps2_select(1'b0),    // PS/2 disabled, UART TX enabled

        .usb_clk(usb_clk),
        .usb_dm(usb_dm),
        .usb_dp(usb_dp),
        .usb_led_err(usb_led_err),
        .usb_led_act(usb_led_act),

        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_grn(vga_grn),
        .vga_blu(vga_blu),
        .vga_cls(vga_cls),
        .vga_de(vga_de),

        .pc_monitor()
    );
endmodule
