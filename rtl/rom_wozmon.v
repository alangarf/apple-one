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
// Description: Wrapper for the Woz Mon ROM
//
// Author.....: Alan Garfield
//              Niels A. Moseley
// Date.......: 26-1-2018
//

module rom_wozmon #(
    parameter WOZMON_ROM_FILENAME = "../../../roms/wozmon.hex"
) (
    input clk,              // clock signal
    input [7:0] address,    // address bus
    output reg [7:0] dout   // 8-bit data bus (output)
);

    reg [7:0] rom_data[0:255];

    initial
        $readmemh(WOZMON_ROM_FILENAME, rom_data, 0, 255);

    always @(posedge clk)
        dout <= rom_data[address];

endmodule
    
    
