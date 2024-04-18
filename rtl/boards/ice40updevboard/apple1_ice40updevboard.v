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
// Author.....: Lawrence Manning
// Date.......: 18-04-2024 (inspired by blackice2/apple1_hx8k.v)
//

module apple1_top #(
    parameter BASIC_FILENAME      = "../../../roms/basic.hex",
    parameter FONT_ROM_FILENAME   = "../../../roms/vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "../../../roms/ram.hex",
    parameter VRAM_FILENAME       = "../../../roms/vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "../../../roms/wozmon.hex"
) (
    input  clk,             // 50 MHz board clock

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

    // Outputs to the ADV7123 RGB DAC IC
    output vga_clk,
    output vga_blank_n,

    output [3:0] vga_r,     // red VGA signal
    output [3:0] vga_g,     // green VGA signal
    output [3:0] vga_b,     // blue VGA signal

    // Debugging ports
    output [2:0] led,
    input button,            // 1 button on board
);

    assign vga_clk = clk25;
    assign vga_blank_n = 1;

    // Active low
    assign led[0] = reset_n;
    assign led[1] = 1;
    assign led[2] = 1;

    // ===============================================================
    // System Clock generation (25MHz)
    // ===============================================================

    reg clk25 = 1;

    // generate 25MHz clock from 50MHz master clock
    always @(posedge clk)
    begin
        clk25 <= ~clk25;
    end

    wire vga_bit;

    // set the monochrome base colour here..
    assign vga_r[3:0] = vga_bit ? 4'b1000 : 4'b0000;
    assign vga_g[3:0] = vga_bit ? 4'b1111 : 4'b0000;
    assign vga_b[3:0] = vga_bit ? 4'b1000 : 4'b0000;

    // debounce reset button
    wire reset_n;
    debounce reset_button (
        .clk25(clk25),
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
        .clk25(clk25),
        .rst_n(reset_n),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),

        .ps2_clk(ps2_clk),
        .ps2_din(ps2_din),
        .ps2_select(1'b1),       // PS/2 enabled, UART TX disabled
        // .ps2_select(1'b0),    // PS/2 disabled, UART TX enabled

        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_bit),
        .vga_cls(~reset_n),
    );
endmodule
