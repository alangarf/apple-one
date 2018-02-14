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

module apple1_top(
    input  clk,             // 100 MHz board clock

    // I/O interface to computer
    input  uart_rx,         // asynchronous serial data input from computer
    output uart_tx,         // asynchronous serial data output to computer
    output uart_cts,        // clear to send flag to computer

    // Outputs to VGA display
    output vga_h_sync,          // hozizontal VGA sync pulse
    output vga_v_sync,          // vertical VGA sync pulse
    output [2:0] vga_r,         // red VGA signal
    output [2:0] vga_g,         // green VGA signal
    output [2:0] vga_b,         // blue VGA signal

    input [1:0] button
);

    wire clk25;

    pll pll(.clock_in(clk),
        .clock_out(clk25),
    );

    wire vga_bit;

    // set the monochrome base colour here..
    assign vga_r[2:0] = vga_bit ? 3'b100 : 3'b000;
    assign vga_g[2:0] = vga_bit ? 3'b111 : 3'b000;
    assign vga_b[2:0] = vga_bit ? 3'b100 : 3'b000;

    // apple one main system
    apple1 my_apple1(
        .clk25(clk25),
        .rst_n(button[0]),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),
        .clr_screen_btn(0),
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_bit),
        .ps2_select(1'b0),
    );
endmodule
