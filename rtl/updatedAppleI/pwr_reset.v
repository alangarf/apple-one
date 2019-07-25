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

module pwr_reset(
    input clk25,        // 25Mhz master clock
    input rst_n,        // active low synchronous reset
    input enable,       // clock enable
    output rst          // active high synchronous system reset
    );

    reg hard_reset;
    reg [5:0] reset_cnt;
    wire pwr_up_flag = &reset_cnt;

    always @(posedge clk25)
    begin
        if (rst_n == 1'b0)
        begin
            reset_cnt  <= 6'b0;
            hard_reset <= 1'b0;
        end
        else if (enable)
        begin
            if (!pwr_up_flag)
                reset_cnt <= reset_cnt + 6'b1;

            hard_reset <= pwr_up_flag;
        end
    end

    assign rst = ~hard_reset;

endmodule
