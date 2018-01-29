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
// Description: A wrapper for Arlet Ottens 6502 CPU core
//
// Author.....: Alan Garfield
//              Niels A. Moseley
// Date.......: 26-1-2018
//

module arlet_6502(
    input clk,                  // clock signal
    input enable,               // clock enable strobe
    input rst,                  // active high reset signal
    output reg [15:0] ab,       // address bus
    input [7:0] dbi,            // 8-bit data bus (input)
    output reg [7:0] dbo,       // 8-bit data bus (output)
    output reg we,              // active high write enable strobe
    input irq_n,                // active low interrupt request
    input nmi_n,                // active low non-maskable interrupt
    input ready,                // CPU updates when ready = 1
    output [15:0] pc_monitor    // program counter monitor signal for debugging
);

    wire [7:0] dbo_c;
    wire [15:0] ab_c;
    wire we_c;

    cpu arlet_cpu(
        .clk(clk),
        .reset(rst),
        .AB(ab_c),
        .DI(dbi),
        .DO(dbo_c),
        .WE(we_c),
        .IRQ(~irq_n),
        .NMI(~nmi_n),
        .RDY(ready),
        .PC_MONITOR(pc_monitor)
    );

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            ab <= 16'd0;
            dbo <= 8'd0;
            we <= 1'b0;
        end
        else
            if (enable)
            begin
                ab <= ab_c;
                dbo <= dbo_c;
                we <= we_c;
            end
    end
endmodule
