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
    input  clk,             // 12 MHz board clock

    // I/O interface to computer
    input  uart_rx,         // asynchronous serial data input from computer
    output uart_tx,         // asynchronous serial data output to computer
    output uart_cts,        // clear to send flag to computer

    // Debugging ports
    output [7:0] led,       // 8 LEDs on the iCE40HX8K board

    output [7:0] ledx,      // 8 LEDs on optionally attached YL-4 board
    input [3:0] button      // 4 buttons on optionall attached YL-4 board
);

    wire clk25;

    // 12MHz up to 25MHz
    clock_pll clock_pll_inst(
            .REFERENCECLK(clk),
            .PLLOUTGLOBAL(clk25),
            .RESET(1'b1)
            );

    wire [15:0] pc_monitor;
    assign led[7:0] = pc_monitor[7:0];
    assign ledx[7:0] = ~pc_monitor[15:8];

    // TODO: debounce buttons

    // apple one main system
    apple1 my_apple1(
        .clk25(clk25),
        .rst_n(button[0]),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),
        .pc_monitor(pc_monitor)
    );
    
endmodule
