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
// Description: Top level test bench for apple1_top
//
// Author.....: Niels A. Moseley
// Date.......: 26-1-2018
//

`timescale 1ns/1ps

module apple1_tb #(
    parameter BASIC_FILENAME      = "../roms/basic.hex",
    parameter FONT_ROM_FILENAME   = "../roms/vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "../roms/ram.hex",
    parameter VRAM_FILENAME       = "../roms/vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "../roms/wozmon.hex"
);

    reg clk25, uart_rx, rst_n;
    wire uart_tx, uart_cts;

    //////////////////////////////////////////////////////////////////////////
    // Setup dumping of data for inspection

    initial begin

        clk25 = 1'b0;
        uart_rx = 1'b1;
        rst_n = 1'b0;
        #40 rst_n = 1'b1;

        $display("Starting...");
        $dumpfile("apple1_top_tb.vcd");
        $dumpvars;

        #180000
        uart_rx = 1'b0;
        #400
        uart_rx = 1'b1;
        #400
        uart_rx = 1'b0;
        #400
        uart_rx = 1'b1;
        #800
        uart_rx = 1'b0;
        #1600
        uart_rx = 1'b1;
 

        #1000000 $display("Stopping...");
        $finish;
    end

    //////////////////////////////////////////////////////////////////////////
    // Clock

    always
        #20 clk25 = !clk25;

    //////////////////////////////////////////////////////////////////////////
    // Core of system
    apple1 #(
        .BASIC_FILENAME (BASIC_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME),
        .RAM_FILENAME (RAM_FILENAME),
        .VRAM_FILENAME (VRAM_FILENAME),
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) core_top (
        .clk25(clk25),
        .rst_n(rst_n),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts)
    );

endmodule
