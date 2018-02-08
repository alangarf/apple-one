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
// Description: PS/2 keyboard debounce logic to be used for the 
//              clock line
//
// Author.....: Niels A. Moseley
// Date.......: 8-2-2018
//

module debounce(
    input       clk25,      // 25MHz clock
    input       rst,        // active high reset
    
    input       sig_in,     // input signal
    output reg  sig_out     // debounced output signal
);

wire clk_enb;       // enable triggering at clk25 divided by 64
reg [5:0] clk_div;  // clock divider counter

reg sig_ff1;        // first  input signal synchronizer
reg sig_ff2;        // second input signal synchronizer

assign clk_enb = (clk_div == 6'd0);

// clock divider
always @(posedge clk25 or posedge rst)
begin
    if (rst)
        clk_div <= 6'd0;
    else
        clk_div <= clk_div + 6'd1;
end

// debounce timer
always @(posedge clk25 or posedge rst)
begin
    if (rst)
    begin
        sig_out <= 1'b0;
        sig_ff1 <= 1'b0;
        sig_ff2 <= 1'b0;
    end
    else if (clk_enb)
    begin
        // this runs ar approximately 391k Hz
        // giving a debounce time of around 2.5us
        sig_ff1 <= sig_in;
        sig_ff2 <= sig_ff1;
        if ((sig_ff1 ^ sig_ff2) == 1'd0)
        begin
            sig_out <= sig_ff2;
        end
    end
end

endmodule
