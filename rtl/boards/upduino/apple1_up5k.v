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
    // I/O interface to computer
    input  uart_rx,         // asynchronous serial data input from computer
    output uart_tx,         // asynchronous serial data output to computer
    output uart_cts,        // clear to send flag to computer

    // Outputs to VGA display
    output vga_h_sync,          // hozizontal VGA sync pulse
    output vga_v_sync,          // vertical VGA sync pulse
    output reg vga_red,         // red VGA signal
    output reg vga_grn,         // green VGA signal
    output reg vga_blu,         // blue VGA signal

    // Tricolor LED on the UPDuino
    output red_led,
    output green_led,
    output blue_led
);

    wire [15:0] leds;
    assign red_led    = ~leds[9];
    assign green_led  = ~leds[8];
    assign blue_led   = ~leds[7];

    wire clk25;
    wire clk;

    SB_HFOSC inthosc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );

    pll pll(
        .clock_in(clk),
        .clock_out(clk25),
    );

    // apple one main system
    apple1 #(
        .BASIC_FILENAME (BASIC_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME),
        .RAM_FILENAME (RAM_FILENAME),
        .VRAM_FILENAME (VRAM_FILENAME),
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) my_apple1(
        .clk25(clk25),
        .rst_n(1'b1),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_grn(vga_grn),
        .vga_blu(vga_blu),
        .pc_monitor(leds),
	.ps2_select(1'b0), // no ps2 keyboard right now
    );
    
endmodule
