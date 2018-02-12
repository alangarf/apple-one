
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

module vga_tb;

    reg clk25, rst, address, w_en, blink_clken;
    reg [7:0] din;
    wire vga_h_sync, vga_v_sync, vga_red, vga_grn, vga_blu;

    //////////////////////////////////////////////////////////////////////////
    // Setup dumping of data for inspection

    initial begin

        clk25 = 1'b0;
        rst = 1'b0;
        address = 1'b0;
        w_en = 1'b0;
        blink_clken = 1'b0;
        din = 8'd0;

        #5
        rst = 1'b1;
        #5
        rst = 1'b0;

        $display("Starting...");
        $dumpfile("vga_tb.vcd");
        $dumpvars;

        //#180000
        //uart_rx = 1'b0;
        //#400
        //uart_rx = 1'b1;
        //#400
        //uart_rx = 1'b0;
        //#400
        //uart_rx = 1'b1;
        //#800
        //uart_rx = 1'b0;
        //#1600
        //uart_rx = 1'b1;
 

        #50000000 $display("Stopping...");
        $finish;
    end

    //////////////////////////////////////////////////////////////////////////
    // Clock

    always
        #20 clk25 = !clk25;

    //////////////////////////////////////////////////////////////////////////
    // Core of system
    vga my_vga (
        .clk25(clk25),
        .enable(1'b1),
        .rst(rst),
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_grn(vga_grn),
        .vga_blu(vga_blu),
        .address(address),
        .w_en(w_en),
        .din(din)
    );

endmodule
