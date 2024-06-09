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

module uart_tb;

    reg clk25, enable, rst, w_en, uart_rx;
    reg [2:0] state;
    reg [1:0] address;
    reg [7:0] din;
    wire [7:0] dout;
    wire uart_tx, uart_cts;

    //////////////////////////////////////////////////////////////////////////
    // Setup dumping of data for inspection

    initial begin

        state = 3'd0;

        clk25 = 1'b0;
        rst = 1'b1;

        enable = 1'b0;
        w_en = 1'b0;
        uart_rx = 1'b1;
        address = 2'b11;
        din = 8'b0;

        $display("Starting...");
        $dumpfile("uart_tb.vcd");
        $dumpvars;

        #40
        rst = 1'b0;     // reset release
        state = 3'd1;

        #1                  // TX first byte - ignored
        address = 2'b10;
        din = 8'b00101010;
        enable = 1'b1;
        w_en = 1'b1;
        state = 3'd3;

        #2
        w_en = 1'b0;
        enable = 1'b0;
        state = 3'd4;

        #40                 // TX second byte
        address = 2'b10;
        din = 8'b00101010;
        enable = 1'b1;
        w_en = 1'b1;
        state = 3'd3;

        #2
        w_en = 1'b0;
        enable = 1'b0;
        state = 3'd4;

        #6000
        state = 3'd5;

        uart_rx = 1'b1;
        #434 uart_rx = 1'b0; // start
        #434 uart_rx = 1'b0; // 1
        #434 uart_rx = 1'b1; // 2
        #434 uart_rx = 1'b0; // 3
        #434 uart_rx = 1'b1; // 4
        #434 uart_rx = 1'b0; // 5
        #434 uart_rx = 1'b1; // 6
        #434 uart_rx = 1'b0; // 7
        #434 uart_rx = 1'b1; // 8
        #434 uart_rx = 1'b1; // stop bit 1
        #434 uart_rx = 1'b1; // stop bit 2
        state = 3'd6;
        
        #6000
        address = 2'b00;
        enable = 1'b1;
        state = 3'd7;
        #20
        enable = 1'b0;

        #10000 $display("Stopping...");
        $finish;
    end

    //////////////////////////////////////////////////////////////////////////
    // Clock

    always
        #1 clk25 = !clk25;

    //////////////////////////////////////////////////////////////////////////
    // Core of system
    uart #(
        .ClkFrequency(25000000),
        .Baud(115200),
        .Oversampling(8)
    ) my_uart (
        .clk(clk25),
        .enable(1'b1),
        .rst(rst),
        .address(address),
        .w_en(w_en),
        .din(din),
        .dout(dout),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts)
    );

endmodule
