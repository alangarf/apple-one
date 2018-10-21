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
    input clk,          // 16 MHz board clock

    // I/O interface to computer
    input  uart_rx,         // asynchronous serial data input from computer
    output uart_tx,         // asynchronous serial data output to computer

    // Outputs to VGA display
    output vga_h_sync,      // hozizontal VGA sync pulse
    output vga_v_sync,      // vertical VGA sync pulse
    output reg vga_red,     // red VGA signal
    output reg vga_grn,     // green VGA signal
    output reg vga_blu,     // blue VGA signal

    inout lt_dat,
    inout lt_env
);

    wire clk25;

    // 16MHz up to 25MHz
    clock_pll clock_pll_inst(
            .REFERENCECLK(clk),
            .PLLOUTGLOBAL(clk25),
            .RESET(1'b1)
            );

    reg lt_data_rw;
    wire lt_data_in, lt_data_out;
    SB_IO #(
        .PIN_TYPE(6'b101001),
        .PULLUP(1'b1)
    ) lt_dat_io (
        .PACKAGE_PIN(lt_dat),
        .OUTPUT_ENABLE(lt_data_rw),
        .D_IN_0(lt_data_in),
        .D_OUT_0(lt_data_out)
    );

    reg lt_env_rw;
    wire lt_env_in, lt_env_out;
    SB_IO #(
        .PIN_TYPE(6'b101001),
        .PULLUP(1'b1)
    ) lt_env_io (
        .PACKAGE_PIN(lt_env),
        .OUTPUT_ENABLE(lt_env_rw),
        .D_IN_0(lt_env_in),
        .D_OUT_0(lt_env_out)
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
        //.ps2_clk(),
        //.ps2_din(),
        .ps2_select(1'b1),
        .uart_rx(uart_tx),
        .uart_tx(uart_rx),
        //.uart_cts(),        
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_grn(vga_grn),
        .vga_blu(vga_blu)
        //.pc_monitor(pc_monitor)
    );

endmodule
