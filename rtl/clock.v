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
// Description: Clock divider to provide clock enables for 
//              devices.
//
// Author.....: Alan Garfield
//              Niels A. Moseley
// Date.......: 29-1-2018
//

module clock(
    input clk25,            // 25MHz clock master clock
    input rst_n,            // active low synchronous reset

    // Clock enables
    output reg cpu_clken    // 1MHz clock enable for the CPU and devices
    );

    // generate clock enable once every
    // 25 clocks. This will (hopefully) make
    // the 6502 run at 1 MHz or 1Hz
    //
    // the clock division counter is synchronously
    // reset using rst_n to avoid undefined signals
    // in simulation
    //

    //`define SLOWCPU
    `ifdef SLOWCPU
        reg [25:0] clk_div;
        always @(posedge clk25)
        begin
            // note: clk_div should be compared to
            //       N-1, where N is the clock divisor
            if ((clk_div == 24999999) || (rst_n == 1'b0))
                clk_div <= 0;
            else
                clk_div <= clk_div + 1'b1;

            cpu_clken <= (clk_div[25:0] == 0);
        end
    `else
        reg [4:0] clk_div;
        always @(posedge clk25)
        begin
            // note: clk_div should be compared to
            //       N-1, where N is the clock divisor
            if ((clk_div == 24) || (rst_n == 1'b0))
                clk_div <= 0;
            else
                clk_div <= clk_div + 1'b1;

            cpu_clken <= (clk_div[4:0] == 0);
        end
    `endif

endmodule
