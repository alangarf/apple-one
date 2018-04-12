
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

module ukp_tb;

    reg clk12;
    reg rst, enable;
    reg usb_dm_out, usb_dp_out;
    reg [3:0] kbd_adr;

    inout usb_dm, usb_dp;

    wire usb_dm_in, usb_dp_in;
    wire record_n;
    wire [7:0] kbd_data;

    assign usb_dm = (enable) ? usb_dm_out : 1'bZ;
    assign usb_dp = (enable) ? usb_dp_out : 1'bZ;
    assign usb_dm_in = usb_dm;
    assign usb_dp_in = usb_dp;

    //////////////////////////////////////////////////////////////////////////
    // Setup dumping of data for inspection

    initial begin

        clk12 = 1'b0;
        enable = 1'b1;
        usb_dm_out = 1'b0;
        usb_dp_out = 1'b0;
        kbd_adr = 1'b0;
        rst = 1'b1;

        $display("Starting...");
        $dumpfile("ukp_tb.vcd");
        $dumpvars;
        #5
        rst = 1'b0;

        #48000
        usb_dm_out = 1'b1;
        #1000
        enable = 1'b0;

        #3267997
        usb_dm_out = 1'b1;
        enable = 1'b1;

        #10
        usb_dm_out = 1'b0;
        usb_dp_out = 1'b1;
        #10
        usb_dm_out = 1'b1;
        usb_dp_out = 1'b0;
        #10
        usb_dm_out = 1'b0;
        usb_dp_out = 1'b1;

        #50000 $display("Stopping...");
        $finish;
    end

    //////////////////////////////////////////////////////////////////////////
    // Clock

    always
        #2 clk12 = !clk12;

    //////////////////////////////////////////////////////////////////////////
    // Core of system
    ukp my_ukp (
        .clk12(clk12),
        .rst(rst),
        .usb_dm(usb_dm),
        .usb_dp(usb_dp),
        .record_n(record_n),
        .kbd_adr(kbd_adr),
        .kbd_data(kbd_data)
    );

endmodule
