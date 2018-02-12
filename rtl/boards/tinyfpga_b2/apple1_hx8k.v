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
// Author.....: Miodrag Milanovic
// Date.......: 11-2-2018
//

module apple1_top #(
    parameter BASIC_FILENAME      = "../../../roms/basic.hex",
    parameter FONT_ROM_FILENAME   = "../../../roms/vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "../../../roms/ram.hex",
    parameter VRAM_FILENAME       = "../../../roms/vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "../../../roms/wozmon.hex"
) (
    input  pin3_clk_16mhz,// 16 MHz board clock

    // Outputs to VGA display
    output pin4,          // hozizontal VGA sync pulse
    output pin5,          // vertical VGA sync pulse
    
    input  pin6,          // PS/2 data input
    input  pin7,          // PS/2 clock

    // I/O interface to computer
    input  pin11,         // asynchronous serial data input from computer
    output pin12,         // asynchronous serial data output to computer
    output pin13,         // clear to send flag to computer
    
    output reg pin24,     // red VGA signal
    output reg pin23,     // red VGA signal
    output reg pin22,     // green VGA signal
    output reg pin21,     // green VGA signal
    output reg pin20,     // blue VGA signal
    output reg pin19      // blue VGA signal

);

    wire clk25;

    // 16MHz up to 25MHz
    clock_pll clock_pll_inst(
            .REFERENCECLK(pin3_clk_16mhz),
            .PLLOUTGLOBAL(clk25),
            .RESET(1'b1)
            );

    wire [15:0] pc_monitor;

    reg [1:0] button = 2'b01;

    wire vga_red;
    wire vga_grn;
    wire vga_blu;

    // apple one main system
    apple1 #(
        .BASIC_FILENAME (BASIC_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME),
        .RAM_FILENAME (RAM_FILENAME),
        .VRAM_FILENAME (VRAM_FILENAME),
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) my_apple1(
        .clk25(clk25),
        .rst_n(button[0]),
        .ps2_clk(pin7), // PS/2 not working with my keyboard
        .ps2_din(pin6),
        .ps2_select(1'b0), // change to 1 in order to test with keyboard
        .uart_rx(pin11),
        .uart_tx(pin12),
        .uart_cts(pin13),        
        .vga_h_sync(pin4),
        .vga_v_sync(pin5),
        .vga_red(vga_red),
        .vga_grn(vga_grn),
        .vga_blu(vga_blu),
        .pc_monitor(pc_monitor)
    );

    assign pin19 = vga_blu;
    assign pin20 = vga_blu;
    assign pin21 = vga_grn;
    assign pin22 = vga_grn;
    assign pin23 = vga_red;
    assign pin24 = vga_red;

endmodule
