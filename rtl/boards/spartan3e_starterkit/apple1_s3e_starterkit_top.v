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
// Description: Top level Apple 1 module for Digilent Spartan 3E
//              starter kit board
//
// Author.....: Niels A. Moseley
// Date.......: 11-2-2018
// 


module apple1_s3e_starterkit_top #(
    parameter BASIC_FILENAME      = "../../../roms/basic.hex",
    parameter FONT_ROM_FILENAME   = "../../../roms/vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "../../../roms/ram.hex",
    parameter VRAM_FILENAME       = "../../../roms/vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "../../../roms/wozmon.hex"
) (    
    input   CLK_50MHZ,      // the 50 MHz master clock

    // UART I/O signals
    output  UART_TXD,       // UART transmit pin on board
    input   UART_RXD,       // UART receive pin on board
        
    input   PS2_KBCLK,
    input   PS2_KBDAT,

    input   BUTTON,         // Button for RESET
    input   SWITCH,         // Switch between PS/2 input and UART

    output  VGA_R,
    output  VGA_G,
    output  VGA_B,
    output  VGA_HS,
    output  VGA_VS    
);

    //////////////////////////////////////////////////////////////////////////    
    // Registers and Wires
    reg clk25;
    wire [15:0] pc_monitor;

    wire rst_n;    
    assign rst_n = ~BUTTON;

    // generate 25MHz clock from 50MHz master clock
    always @(posedge CLK_50MHZ)
    begin
        clk25 <= ~clk25;
    end    
    
    //////////////////////////////////////////////////////////////////////////    
    // Core of system
    apple1 #(
        .BASIC_FILENAME (BASIC_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME),
        .RAM_FILENAME (RAM_FILENAME),
        .VRAM_FILENAME (VRAM_FILENAME),
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) apple1_top(
        .clk25(clk25),
        .rst_n(rst_n),         // we don't have any reset pulse..
        .uart_rx(UART_RXD),
        .uart_tx(UART_TXD),
        //.uart_cts(UART_CTS),  // there is no CTS on the board :(
        .ps2_clk(PS2_KBCLK),
        .ps2_din(PS2_KBDAT),
        .ps2_select(SWITCH),
        .vga_h_sync(VGA_HS),
        .vga_v_sync(VGA_VS),
        .vga_red(VGA_R),
        .vga_grn(VGA_G),
        .vga_blu(VGA_B),
        .vga_cls(~rst_n),
        .pc_monitor(pc_monitor)
    );
    
endmodule
