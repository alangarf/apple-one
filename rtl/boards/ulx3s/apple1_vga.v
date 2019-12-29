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
// Author.....: Lawrie Griffiths and Alan Garfield
// Date.......: 31-3-2018
//

module apple1_top #(
    parameter BASIC_FILENAME      = "../../../roms/basic.hex",
    parameter FONT_ROM_FILENAME   = "../../../roms/vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "../../../roms/ram.hex",
    parameter VRAM_FILENAME       = "../../../roms/vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "../../../roms/wozmon.hex"
) (
    input  clk_25mhz,       // 25 MHz board clock

    // I/O interface to computer
    input  uart_rx,         // asynchronous serial data input from computer
    output uart_tx,         // asynchronous serial data output to computer
    output uart_cts,        // clear to send flag to computer - not used

    // I/O interface to keyboard
    input ps2_clk,          // PS/2 keyboard serial clock input
    input ps2_din,          // PS/2 keyboard serial data input

    // Outputs to VGA display
    output vga_h_sync,      // hozizontal VGA sync pulse
    output vga_v_sync,      // vertical VGA sync pulse

    output [3:0] vga_r,     // red VGA signal
    output [3:0] vga_g,     // green VGA signal
    output [3:0] vga_b,     // blue VGA signal

    output usb_fpga_pu_dp,
    output usb_fpga_pu_dn, 
    
	    // Debugging ports
    output [3:0] led,
    input [1:0] button      // 2 buttons on board
);

    assign usb_fpga_pu_dp = 1;
    assign usb_fpga_pu_dn = 1;

    assign led[0] = 1;
    assign led[1] = reset_n;
    assign led[2] = clr_screen_n;
    assign led[3] = 0;

    wire vga_bit;

    // set the monochrome base colour here..
    assign vga_r[3:0] = vga_bit ? 4'b1000 : 4'b0000;
    assign vga_g[3:0] = vga_bit ? 4'b1111 : 4'b0000;
    assign vga_b[3:0] = vga_bit ? 4'b1000 : 4'b0000;

    // debounce reset button
    wire reset_n;
    debounce reset_button (
        .clk25(clk_25mhz),
        .rst(1'b0),
        .sig_in(button[0]),
        .sig_out(reset_n)
    );

    // debounce clear screen button
    wire clr_screen_n;
    debounce clr_button (
        .clk25(clk_25mhz),
        .rst(~reset_n),
        .sig_in(~button[1]),
        .sig_out(clr_screen_n)
    );

    // apple one main system
    apple1 #(
        .BASIC_FILENAME (BASIC_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME),
        .RAM_FILENAME (RAM_FILENAME),
        .VRAM_FILENAME (VRAM_FILENAME),
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) my_apple1(
        .clk25(clk_25mhz),
        .rst_n(reset_n),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),

        .ps2_clk(ps2_clk),
        .ps2_din(ps2_din),
        .ps2_select(1'b1),       // PS/2 enabled, UART TX disabled
        //.ps2_select(1'b0),       // PS/2 disabled, UART TX enabled

        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_bit),
        //.vga_grn(vga_bit),
        //.vga_blu(vga_bit),
        .vga_cls(~clr_screen_n),
    );
endmodule
