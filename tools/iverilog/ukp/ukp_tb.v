
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

`timescale 1ns/100ps

module ukp_tb;

    reg clk25;
    reg clkusb;
    reg rst;
    reg [3:0] kbd_adr;

    wire usb_dm_out, usb_dp_out;
    reg usb_dm_in, usb_dp_in;

    wire record_n;
    wire [7:0] kbd_data;

    //////////////////////////////////////////////////////////////////////////
    // Setup dumping of data for inspection
    
    initial begin

        clk25 = 1'b0;
        clkusb = 1'b0;
        usb_dm_in = 1'b1;
        usb_dp_in = 1'b0;
        kbd_adr = 1'b0;
        rst = 1'b1;

        $display("Starting...");
        $dumpfile("ukp_tb.vcd");
        $dumpvars;
        #5
        rst = 1'b0;

        // switch off drive to allow seeing bus reset, real USB bus would have
        // pull downs and device would have stronger pull up on the D- pin. To
        // reset bus host yanks both D+ and D- to ground, in verilog hiz only
        // way to see that. It's not real, but useful to see
        #6097910.3
        usb_dm_in = 1'b0; // K -- SYNC
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // K --
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J -- ACK 0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // J        1
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K        0
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J        0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // J        1
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K        0
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // K        1
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // K --     1
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // -- SE0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // -- SE0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;

        #33776.2
        usb_dm_in = 1'b0; // K -- SYNC
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // K --
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J -- NACK 0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // J        1
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K        0
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // J        1
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // J        1
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // K        0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // K        1
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K --     0
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // -- SE0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // -- SE0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;

        #33776.2
        usb_dm_in = 1'b0; // K -- SYNC
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // K --
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // K -- DATA0 1
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // K        1
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // J        0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // J        1
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K        0
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; // K        0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // K        1
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // K --     0
        usb_dp_in = 1'b1;
        #667.2  
        usb_dm_in = 1'b1; // -- CRC
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0;
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1;
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; 
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; 
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; 
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; 
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; 
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; 
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; 
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; 
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; 
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; 
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; 
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b1; 
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; 
        usb_dp_in = 1'b1;
        #667.2
        usb_dm_in = 1'b0; // -- SE0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b0; // -- SE0
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;
        #667.2
        usb_dm_in = 1'b1; // J
        usb_dp_in = 1'b0;

        #1500000 $display("Stopping...");
        $finish;
    end

    //////////////////////////////////////////////////////////////////////////
    // Clock
    //
    always
        #20 clk25 = !clk25;

    always
        #41.665 clkusb <= !clkusb;

    //////////////////////////////////////////////////////////////////////////
    // Core of system
    ukp my_ukp (
        .clk25(clk25),
        .clkusb(clkusb),
        .rst(rst),
        .usb_dm_in(usb_dm_in),
        .usb_dp_in(usb_dp_in),
        .usb_dm_out(usb_dm_out),
        .usb_dp_out(usb_dp_out),
        .record_n(record_n),
        .kbd_adr(kbd_adr),
        .kbd_data(kbd_data)
    );

endmodule
