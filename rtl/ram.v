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
// Description: 8KB RAM for system
//
// Author.....: Alan Garfield
//              Niels A. Moseley
// Date.......: 26-1-2018
//

module ram #(
    parameter RAM_FILENAME        = "../../../roms/ram.hex"
) (
    input clk,              // clock signal
    input [12:0] address,   // address bus
    input w_en,             // active high write enable strobe
    input [7:0] din,        // 8-bit data bus (input)
    output reg [7:0] dout   // 8-bit data bus (output)
);

    reg [7:0] ram_data[0:8191];

    initial
        $readmemh(RAM_FILENAME, ram_data, 0, 8191);

    always @(posedge clk)
    begin
        dout <= ram_data[address];
        if (w_en) ram_data[address] <= din;
    end

endmodule
     
