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
// Description: Apple 1 implementation for the iCE40HX8K dev
//              board.
//
// Author.....: Alan Garfield
// Date.......: 26-1-2018
//

module apple1_top #(
    parameter BASIC_FILENAME      = "../../../roms/basic.hex",
    parameter FONT_ROM_FILENAME   = "../../../roms/vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "../../../roms/ram.hex",
    parameter VRAM_FILENAME       = "../../../roms/vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "../../../roms/wozmon.hex"
) (
    input  clk,             // 12 MHz board clock

    // I/O interface to computer
    input  uart_rx,         // asynchronous serial data input from computer
    output uart_tx,         // asynchronous serial data output to computer
    output uart_cts,        // clear to send flag to computer

    // I/O interface to keyboard
    input ps2_clk,          // PS/2 keyboard serial clock input
    input ps2_din,          // PS/2 keyboard serial data input

    // Outputs to VGA display
    output vga_h_sync,      // hozizontal VGA sync pulse
    output vga_v_sync,      // vertical VGA sync pulse
    output reg vga_red,     // red VGA signal
    output reg vga_grn,     // green VGA signal
    output reg vga_blu,     // blue VGA signal

    // Debugging ports
    output [7:0] led,       // 8 LEDs on the iCE40HX8K board
    output [7:0] ledx,      // 8 LEDs on optionally attached YL-4 board
    input [3:0] button      // 4 buttons on optionally attached YL-4 board
);

    //////////////////////////////////////////////////////////////////////////
    // Registers and Wires
    wire clk25;

    wire [15:0] pc_monitor;
    assign led[7:0] = pc_monitor[7:0];
    assign ledx[7:0] = ~pc_monitor[15:8];

    //////////////////////////////////////////////////////////////////////////
    // Clocks
    // 12MHz up to 25MHz
    pll my_pll(
        .clock_in(clk),
        .clock_out(clk25)
    );

    //////////////////////////////////////////////////////////////////////////
    // PS/2 Keyboard

    // PS2 Pullups
    wire ps2__clk, ps2__din;
    SB_IO #(
        .PIN_TYPE(6'b000001),
        .PULLUP(1'b1)
    ) my_ps2_clk (
        .PACKAGE_PIN(ps2_clk),
        .D_IN_0(ps2__clk),
    );

    SB_IO #(
        .PIN_TYPE(6'b000001),
        .PULLUP(1'b1)
    ) my_ps2_din (
        .PACKAGE_PIN(ps2_din),
        .D_IN_0(ps2__din),
    );

    //////////////////////////////////////////////////////////////////////////
    // Reset, Clear Screen and PS/2 mode selection toggle

    // debounce reset button
    wire reset_n;
    debounce reset_button (
        .clk25(clk25),
        .rst(1'b0),
        .sig_in(button[0]),
        .sig_out(reset_n)
    );

    // debounce clear screen button
    wire clr_screen_n;
    debounce clr_button (
        .clk25(clk25),
        .rst(~reset_n),
        .sig_in(button[1]),
        .sig_out(clr_screen_n)
    );

    // debounce toggle button on PS2 select
    wire ps2_toggle;
    reg ps2_select;
    debounce ps2_button (
        .clk25(clk25),
        .rst(~reset_n),
        .sig_in(button[2]),
        .sig_out(ps2_toggle)
    );

    // defaults to PS2 mode, but can toggle between
    // UART and PS2 per button press
    always @(posedge ps2_toggle)
        ps2_select <= ~ps2_select;

    //////////////////////////////////////////////////////////////////////////
    // Core of system

    // apple one main system
    apple1 #(
        .BASIC_FILENAME (BASIC_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME),
        .RAM_FILENAME (RAM_FILENAME),
        .VRAM_FILENAME (VRAM_FILENAME),
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) my_apple1(
        .clk25(clk25),
        .rst_n(reset_n),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),
        .ps2_clk(ps2__clk),
        .ps2_din(ps2__din),
        .ps2_select(ps2_select),
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_grn(vga_grn),
        .vga_blu(vga_blu),
        .vga_cls(~clr_screen_n),
        .pc_monitor(pc_monitor)
    );

endmodule
